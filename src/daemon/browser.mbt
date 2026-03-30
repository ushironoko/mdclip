///|
#cfg(not(platform="windows"))
pub async fn open_in_browser(path : String) -> Unit {
  let url = "file://" + path + "?t=" + @async.now().to_string()
  let exit_code = @process.run("osascript", [
    "-e",
    "open location \"" + url + "\"",
  ])
  if exit_code != 0 {
    println("mdclip: failed to open browser (exit code: \{exit_code})")
  }
}

///|
#cfg(platform="windows")
pub async fn open_in_browser(path : String) -> Unit {
  let url = "file:///" + path + "?t=" + @async.now().to_string()
  let exit_code = @process.run("cmd", ["/c", "start", "", url])
  if exit_code != 0 {
    println("mdclip: failed to open browser (exit code: \{exit_code})")
  }
}
