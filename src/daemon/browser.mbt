///|
#cfg(not(platform="windows"))
pub async fn open_in_browser(path : String) -> Unit {
  let exit_code = @process.run("open", [path])
  if exit_code != 0 {
    println("mdclip: failed to open browser (exit code: \{exit_code})")
  }
}

///|
#cfg(platform="windows")
pub async fn open_in_browser(path : String) -> Unit {
  let exit_code = @process.run("cmd", ["/c", "start", "", path])
  if exit_code != 0 {
    println("mdclip: failed to open browser (exit code: \{exit_code})")
  }
}
