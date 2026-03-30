///|
#cfg(not(platform="windows"))
fn get_cache_dir() -> String {
  let env = @sys.get_env_vars()
  match env.get("HOME") {
    Some(h) => h + "/Library/Caches/mdclip"
    None => abort("mdclip: HOME environment variable is not set")
  }
}

///|
#cfg(platform="windows")
fn get_cache_dir() -> String {
  let env = @sys.get_env_vars()
  match env.get("LOCALAPPDATA") {
    Some(dir) => dir + "\\mdclip"
    None => abort("mdclip: LOCALAPPDATA environment variable is not set")
  }
}

///|
#cfg(not(platform="windows"))
fn path_sep() -> String {
  "/"
}

///|
#cfg(platform="windows")
fn path_sep() -> String {
  "\\"
}

fn get_html_path() -> String {
  get_cache_dir() + path_sep() + "preview.html"
}

fn get_pid_path() -> String {
  get_cache_dir() + path_sep() + "mdclip.pid"
}

async fn ensure_cache_dir() -> Unit {
  try {
    @fs.mkdir(get_cache_dir().to_string_view(), permission=0o700, recursive=true)
  } catch {
    _ => ()
  }
}

async fn render_and_open(content : String) -> Unit {
  if content.is_empty() {
    println("mdclip: content is empty, skipping")
    return
  }
  let html = @viewer.markdown_to_styled_html(content)
  ensure_cache_dir()
  let html_path = get_html_path()
  @fs.write_file(
    html_path.to_string_view(),
    html,
    create=0o600,
  )
  open_in_browser(html_path)
  println("mdclip: preview opened")
}

pub async fn run_once() -> Unit {
  let clipboard_content = read_clipboard()
  if clipboard_content.is_empty() {
    println("mdclip: clipboard is empty, skipping")
    return
  }
  render_and_open(clipboard_content)
}

pub async fn run_from_file(file_path : String) -> Unit {
  let data = try {
    @fs.read_file(file_path.to_string_view())
  } catch {
    _ => {
      println("mdclip: failed to read file: \{file_path}")
      return
    }
  }
  let content = try {
    data.text()
  } catch {
    _ => {
      println("mdclip: failed to decode file: \{file_path}")
      return
    }
  }
  render_and_open(content)
}

fn is_valid_pid(s : String) -> Bool {
  if s.is_empty() {
    return false
  }
  for c in s {
    if c < '0' || c > '9' {
      return false
    }
  }
  true
}

async fn read_pid_file() -> String? {
  let pid_path = get_pid_path()
  let data = try {
    @fs.read_file(pid_path.to_string_view())
  } catch {
    _ => {
      println("mdclip: no running daemon found (PID file missing)")
      return None
    }
  }
  let pid_str = try {
    data.text()
  } catch {
    _ => {
      println("mdclip: failed to read PID file")
      return None
    }
  }
  let trimmed = pid_str.trim().to_string()
  if not(is_valid_pid(trimmed)) {
    println("mdclip: invalid PID in PID file: \{trimmed}")
    return None
  }
  Some(trimmed)
}

async fn remove_pid_file() -> Unit {
  try {
    @fs.remove(get_pid_path().to_string_view())
  } catch {
    _ => ()
  }
}

///|
#cfg(not(platform="windows"))
pub async fn run_daemon() -> Unit {
  @signal.init_signal_handler()
  let pid = @signal.get_pid()
  ensure_cache_dir()
  let pid_path = get_pid_path()
  match read_pid_file() {
    Some(existing_pid) => {
      let exit_code = @process.run("kill", ["-0", existing_pid])
      if exit_code == 0 {
        println("mdclip: daemon already running (PID: \{existing_pid})")
        return
      }
      remove_pid_file()
    }
    None => ()
  }
  @fs.write_file(
    pid_path.to_string_view(),
    pid.to_string(),
    create=0o600,
  )
  println("mdclip: daemon started (PID: \{pid})")
  println("mdclip: send USR1 to trigger: kill -USR1 \{pid}")
  while true {
    if @signal.poll_usr1() {
      let clipboard_content = read_clipboard()
      if not(clipboard_content.is_empty()) {
        render_and_open(clipboard_content)
      }
    }
    @async.sleep(200)
  }
}

///|
#cfg(platform="windows")
pub async fn run_daemon() -> Unit {
  println("mdclip: daemon mode is not supported on Windows")
  println("mdclip: use 'mdclip once' instead")
}

///|
#cfg(not(platform="windows"))
pub async fn send_trigger() -> Unit {
  let pid = match read_pid_file() {
    Some(p) => p
    None => return
  }
  let check = @process.run("kill", ["-0", pid])
  if check != 0 {
    println("mdclip: daemon not running (stale PID file), cleaning up")
    remove_pid_file()
    return
  }
  let exit_code = @process.run("kill", ["-USR1", pid])
  if exit_code != 0 {
    println("mdclip: failed to send signal to PID \{pid}")
  } else {
    println("mdclip: sent USR1 to PID \{pid}")
  }
}

///|
#cfg(platform="windows")
pub async fn send_trigger() -> Unit {
  println("mdclip: trigger is not supported on Windows")
}

///|
#cfg(not(platform="windows"))
pub async fn stop_daemon() -> Unit {
  let pid = match read_pid_file() {
    Some(p) => p
    None => return
  }
  let check = @process.run("kill", ["-0", pid])
  if check != 0 {
    println("mdclip: daemon not running (stale PID file), cleaning up")
    remove_pid_file()
    return
  }
  let exit_code = @process.run("kill", [pid])
  if exit_code != 0 {
    println("mdclip: failed to stop daemon (PID \{pid})")
  } else {
    println("mdclip: stopped daemon (PID \{pid})")
    remove_pid_file()
  }
}

///|
#cfg(platform="windows")
pub async fn stop_daemon() -> Unit {
  println("mdclip: stop is not supported on Windows")
}
