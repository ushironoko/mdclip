///|
#cfg(not(platform="windows"))
pub async fn read_clipboard() -> String {
  let (exit_code, data) = @process.collect_stdout("pbpaste", [], extra_env={
    "LC_CTYPE": "UTF-8",
  })
  if exit_code == 0 {
    data.text() catch {
      _ => ""
    }
  } else {
    ""
  }
}

///|
#cfg(platform="windows")
pub async fn read_clipboard() -> String {
  let (exit_code, data) = @process.collect_stdout("powershell", [
    "-NoProfile", "-Command", "Get-Clipboard",
  ])
  if exit_code == 0 {
    data.text() catch {
      _ => ""
    }
  } else {
    ""
  }
}
