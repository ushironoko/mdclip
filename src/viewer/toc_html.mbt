///|
fn toc_to_html(items : Array[HeadingInfo]) -> String {
  if items.is_empty() {
    return ""
  }
  let buf = StringBuilder::new()
  buf.write_string("<nav class=\"toc\">\n<ul>\n")
  for item in items {
    buf.write_string("<li data-level=\"")
    buf.write_string(item.level.to_string())
    buf.write_string("\"><a href=\"#")
    buf.write_string(escape_html_attr(item.id))
    buf.write_string("\">")
    buf.write_string(escape_html(item.text))
    buf.write_string("</a></li>\n")
  }
  buf.write_string("</ul>\n</nav>\n")
  buf.to_string()
}
