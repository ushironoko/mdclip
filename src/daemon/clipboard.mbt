///|
#cfg(not(platform="windows"))
pub async fn read_clipboard() -> String {
  let (exit_code, data) = @process.collect_stdout("pbpaste", [])
  if exit_code == 0 {
    try {
      data.text()
    } catch {
      _ => ""
    }
  } else {
    ""
  }
}

///|
#cfg(platform="windows")
pub async fn read_clipboard() -> String {
  let (exit_code, data) = @process.collect_stdout(
    "powershell",
    ["-NoProfile", "-Command", "Get-Clipboard"],
  )
  if exit_code == 0 {
    try {
      data.text()
    } catch {
      _ => ""
    }
  } else {
    ""
  }
}
