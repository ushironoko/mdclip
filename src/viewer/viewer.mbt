///|
pub fn markdown_to_styled_html(source : String) -> String {
  let result = @markdown.parse(source)
  let doc = result.document
  let title = match doc.frontmatter {
    Some(fm) =>
      match @frontmatter.get_string(fm, "title") {
        Some(t) => t
        None => "Clipboard Markdown Preview"
      }
    None => "Clipboard Markdown Preview"
  }
  let headings = collect_headings(doc)
  let toc_headings = headings.filter(fn(h) { not(h.in_footnote) })
  let toc_html = if toc_headings.length() > 0 {
    toc_to_html(toc_headings)
  } else {
    ""
  }
  let html_body = render_html_enhanced(doc, headings)
  let css = github_css()
  let buf = StringBuilder::new()
  buf.write_string("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n")
  buf.write_string("<meta charset=\"UTF-8\">\n")
  buf.write_string(
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n",
  )
  buf.write_string(
    "<meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'none'; script-src 'none'; object-src 'none'; style-src 'unsafe-inline'; img-src data:; frame-src 'none'; form-action 'none'; base-uri 'none';\">\n",
  )
  buf.write_string("<title>")
  buf.write_string(escape_html(title))
  buf.write_string("</title>\n")
  buf.write_string(css)
  buf.write_string("\n</head>\n<body>\n")
  buf.write_string(
    "<article class=\"markdown-body\" style=\"max-width: 980px; margin: 0 auto; padding: 45px;\">\n",
  )
  buf.write_string(toc_html)
  buf.write_string(html_body)
  buf.write_string("\n</article>\n</body>\n</html>\n")
  buf.to_string()
}
