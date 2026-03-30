///|
#cfg(not(platform="windows"))
fn get_cache_dir() -> String {
  let env = @sys.get_env_vars()
  let home = match env.get("HOME") {
    Some(h) => h
    None => "/tmp"
  }
  home + "/Library/Caches/mdclip"
}

///|
#cfg(platform="windows")
fn get_cache_dir() -> String {
  let env = @sys.get_env_vars()
  match env.get("LOCALAPPDATA") {
    Some(dir) => dir + "\\mdclip"
    None =>
      match env.get("TEMP") {
        Some(t) => t + "\\mdclip"
        None => "C:\\Temp\\mdclip"
      }
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
    @fs.mkdir(get_cache_dir().to_string_view(), permission=0o755, recursive=true)
  } catch {
    _ => ()
  }
}

async fn handle_trigger() -> Unit {
  let clipboard_content = read_clipboard()
  if clipboard_content.is_empty() {
    println("mdclip: clipboard is empty, skipping")
    return
  }
  let html = @viewer.markdown_to_styled_html(clipboard_content)
  ensure_cache_dir()
  let html_path = get_html_path()
  @fs.write_file(
    html_path.to_string_view(),
    html,
    create=0o644,
  )
  open_in_browser(html_path)
  println("mdclip: preview opened")
}

pub async fn run_once() -> Unit {
  handle_trigger()
}

///|
#cfg(not(platform="windows"))
pub async fn run_daemon() -> Unit {
  @signal.init_signal_handler()
  let pid = @signal.get_pid()
  ensure_cache_dir()
  let pid_path = get_pid_path()
  @fs.write_file(
    pid_path.to_string_view(),
    pid.to_string(),
    create=0o644,
  )
  println("mdclip: daemon started (PID: \{pid})")
  println("mdclip: send USR1 to trigger: kill -USR1 \{pid}")
  while true {
    if @signal.poll_usr1() {
      handle_trigger()
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
  let pid_path = get_pid_path()
  let (exit_code, data) = @process.collect_stdout("cat", [pid_path])
  if exit_code != 0 {
    println("mdclip: no running daemon found (PID file missing)")
    return
  }
  let pid_str = try {
    data.text()
  } catch {
    _ => {
      println("mdclip: failed to read PID file")
      return
    }
  }
  let trimmed = pid_str.trim().to_string()
  let exit_code = @process.run("kill", ["-USR1", trimmed])
  if exit_code != 0 {
    println("mdclip: failed to send signal to PID \{trimmed}")
  } else {
    println("mdclip: sent USR1 to PID \{trimmed}")
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
  let pid_path = get_pid_path()
  let (exit_code, data) = @process.collect_stdout("cat", [pid_path])
  if exit_code != 0 {
    println("mdclip: no running daemon found")
    return
  }
  let pid_str = try {
    data.text()
  } catch {
    _ => {
      println("mdclip: failed to read PID file")
      return
    }
  }
  let trimmed = pid_str.trim().to_string()
  let exit_code = @process.run("kill", [trimmed])
  if exit_code != 0 {
    println("mdclip: failed to stop daemon (PID \{trimmed})")
  } else {
    println("mdclip: stopped daemon (PID \{trimmed})")
  }
}

///|
#cfg(platform="windows")
pub async fn stop_daemon() -> Unit {
  println("mdclip: stop is not supported on Windows")
}
