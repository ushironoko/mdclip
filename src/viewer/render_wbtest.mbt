// Step 3a: upstream compatibility
///|
test "render paragraph matches upstream" {
  let doc = @markdown.parse("hello world")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render emphasis matches upstream" {
  let doc = @markdown.parse("*emphasis* and **strong**")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render blockquote matches upstream" {
  let doc = @markdown.parse("> quoted text")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render thematic break matches upstream" {
  let doc = @markdown.parse("---")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render bullet list matches upstream" {
  let doc = @markdown.parse("- item 1\n- item 2")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render ordered list matches upstream" {
  let doc = @markdown.parse("1. first\n2. second")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render table matches upstream" {
  let md = "| a | b |\n|---|---|\n| 1 | 2 |"
  let doc = @markdown.parse(md)
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

///|
test "render indented code matches upstream" {
  let doc = @markdown.parse("    code block")
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

// Step 3b: heading ID

///|
test "heading gets id attribute" {
  let doc = @markdown.parse("## Hello World")
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("id=\"hello-world\""), content="true")
}

///|
test "heading id from collect_headings" {
  let doc = @markdown.parse("## Hello World")
  let headings = collect_headings(doc.document)
  inspect(headings.length(), content="1")
  inspect(headings[0].id, content="hello-world")
  inspect(headings[0].level, content="2")
}

// Step 3c: duplicate heading IDs

///|
test "duplicate headings get unique ids" {
  let doc = @markdown.parse("## FAQ\n\n## FAQ\n\n## FAQ")
  let headings = collect_headings(doc.document)
  inspect(headings.length(), content="3")
  inspect(headings[0].id, content="faq")
  inspect(headings[1].id, content="faq-1")
  inspect(headings[2].id, content="faq-2")
}

// Step 3d: fenced code highlight

///|
test "fenced code with unknown lang uses fallback" {
  let md = "```python\nprint('hello')\n```"
  let doc = @markdown.parse(md)
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("language-python"), content="true")
}

///|
test "fenced code with typescript uses highlight" {
  let md = "```typescript\nconst x = 1\n```"
  let doc = @markdown.parse(md)
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("<pre class=\"highlight"), content="true")
}

///|
test "fenced code without lang matches upstream" {
  let md = "```\nplain code\n```"
  let doc = @markdown.parse(md)
  let upstream = @markdown.render_html(doc.document)
  let headings = collect_headings(doc.document)
  let enhanced = render_html_enhanced(doc.document, headings)
  inspect(upstream == enhanced, content="true")
}

// Step 3e: HtmlBlock/HtmlInline sanitization

///|
test "html block script tag is removed" {
  let md = "<script>alert(1)</script>\n"
  let doc = @markdown.parse(md)
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("<script>"), content="false")
}

///|
test "html block safe tags are preserved" {
  let md = "<div>safe content</div>\n"
  let doc = @markdown.parse(md)
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("<div>safe content</div>"), content="true")
}

// Step 3f: URL sanitization

///|
test "javascript url in link is removed" {
  let md = "[click](javascript:alert(1))"
  let doc = @markdown.parse(md)
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("javascript:"), content="false")
}

///|
test "safe url in link is preserved" {
  let md = "[click](https://example.com)"
  let doc = @markdown.parse(md)
  let headings = collect_headings(doc.document)
  let html = render_html_enhanced(doc.document, headings)
  inspect(html.contains("https://example.com"), content="true")
}
