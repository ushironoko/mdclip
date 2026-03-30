///|
test "pipeline: frontmatter title is reflected" {
  let md =
    #|---
    #|title: My Doc
    #|---
    #|
    #|# Hello
  let html = markdown_to_styled_html(md)
  inspect(html.contains("<title>My Doc</title>"), content="true")
}

///|
test "pipeline: default title when no frontmatter" {
  let html = markdown_to_styled_html("hello world")
  inspect(
    html.contains("<title>Clipboard Markdown Preview</title>"),
    content="true",
  )
}

///|
test "pipeline: TOC generated when headings exist" {
  let md = "## Section 1\n\ntext\n\n## Section 2"
  let html = markdown_to_styled_html(md)
  inspect(html.contains("<nav class=\"toc\">"), content="true")
  inspect(html.contains("href=\"#section-1\""), content="true")
  inspect(html.contains("href=\"#section-2\""), content="true")
}

///|
test "pipeline: no TOC when no headings" {
  let html = markdown_to_styled_html("just a paragraph")
  inspect(html.contains("<nav class=\"toc\">"), content="false")
}

///|
test "pipeline: heading ids in body" {
  let md = "## Hello World"
  let html = markdown_to_styled_html(md)
  inspect(html.contains("id=\"hello-world\""), content="true")
}

///|
test "pipeline: full html document structure" {
  let html = markdown_to_styled_html("hello")
  inspect(html.contains("<!DOCTYPE html>"), content="true")
  inspect(html.contains("<html"), content="true")
  inspect(html.contains("</html>"), content="true")
  inspect(html.contains("Content-Security-Policy"), content="true")
}
