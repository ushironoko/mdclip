///|
fn highlight_code(lang : String, code : String) -> String? {
  let lang = lang.to_lower()
  match lang {
    "typescript" | "ts" => Some(@syntree_api.highlight_typescript(code))
    "javascript" | "js" => Some(@syntree_api.highlight_typescript(code))
    "json" => Some(@syntree_api.highlight_json(code))
    "html" => Some(@syntree_api.highlight_html(code))
    "css" => Some(@syntree_api.highlight_css(code))
    "bash" | "sh" => Some(@syntree_api.highlight_bash(code))
    "rust" => Some(@syntree_api.highlight_rust(code))
    "moonbit" | "mbt" => Some(@syntree_api.highlight_moonbit(code))
    _ => None
  }
}
