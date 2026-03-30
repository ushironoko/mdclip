// Based on mizchi/markdown v0.4.7 renderer.mbt
// Customized: Heading IDs, syntax highlighting, CST-level sanitization, URL sanitization

///|
pub(all) struct HeadingInfo {
  level : Int
  text : String
  id : String
  in_footnote : Bool
}

///|
fn collect_headings(doc : @markdown.Document) -> Array[HeadingInfo] {
  let headings : Array[HeadingInfo] = []
  let id_counts : Map[String, Int] = {}
  for block in doc.children {
    collect_headings_from_block(block, headings, id_counts, false)
  }
  headings
}

///|
fn collect_headings_from_block(
  block : @markdown.Block,
  headings : Array[HeadingInfo],
  id_counts : Map[String, Int],
  in_footnote : Bool,
) -> Unit {
  match block {
    @markdown.Block::Heading(level~, children~, ..) => {
      let text = @toc.extract_text_from_inlines(children)
      let base_id = @slug.generate_heading_id(text)
      let id = match id_counts.get(base_id) {
        Some(count) => {
          id_counts[base_id] = count + 1
          base_id + "-" + count.to_string()
        }
        None => {
          id_counts[base_id] = 1
          base_id
        }
      }
      headings.push({ level, text, id, in_footnote })
    }
    @markdown.Block::Blockquote(children~, ..) =>
      for child in children {
        collect_headings_from_block(child, headings, id_counts, in_footnote)
      }
    @markdown.Block::BulletList(items~, ..) =>
      for item in items {
        for child in item.children {
          collect_headings_from_block(child, headings, id_counts, in_footnote)
        }
      }
    @markdown.Block::OrderedList(items~, ..) =>
      for item in items {
        for child in item.children {
          collect_headings_from_block(child, headings, id_counts, in_footnote)
        }
      }
    @markdown.Block::FootnoteDefinition(children~, ..) =>
      for child in children {
        collect_headings_from_block(child, headings, id_counts, true)
      }
    _ => ()
  }
}

///|
fn render_html_enhanced(
  doc : @markdown.Document,
  headings : Array[HeadingInfo],
) -> String {
  let buf = StringBuilder::new()
  let heading_idx = Ref::new(0)
  for block in doc.children {
    render_block(block, buf, headings, heading_idx)
  }
  buf.to_string()
}

///|
fn render_block(
  block : @markdown.Block,
  buf : StringBuilder,
  headings : Array[HeadingInfo],
  heading_idx : Ref[Int],
) -> Unit {
  match block {
    @markdown.Block::Paragraph(children~, ..) => {
      buf.write_string("<p>")
      render_inlines(children, buf)
      buf.write_string("</p>\n")
    }
    @markdown.Block::Heading(level~, children~, ..) => {
      let id = if heading_idx.val < headings.length() {
        let h = headings[heading_idx.val]
        heading_idx.val = heading_idx.val + 1
        h.id
      } else {
        ""
      }
      buf.write_string("<h")
      buf.write_string(level.to_string())
      if not(id.is_empty()) {
        buf.write_string(" id=\"")
        buf.write_string(escape_html_attr(id))
        buf.write_char('"')
      }
      buf.write_char('>')
      render_inlines(children, buf)
      buf.write_string("</h")
      buf.write_string(level.to_string())
      buf.write_string(">\n")
    }
    @markdown.Block::ThematicBreak(..) => buf.write_string("<hr>\n")
    @markdown.Block::FencedCode(info~, code~, ..) =>
      if info.is_empty() {
        buf.write_string("<pre><code>")
        buf.write_string(escape_html(code))
        buf.write_string("</code></pre>\n")
      } else {
        let code_info = @markdown.parse_code_block_info(info)
        let lang = code_info.lang
        match highlight_code(lang, code) {
          Some(highlighted) => {
            buf.write_string(highlighted)
            buf.write_char('\n')
          }
          None => {
            buf.write_string("<pre><code class=\"language-")
            buf.write_string(escape_html(lang))
            buf.write_string("\">")
            buf.write_string(escape_html(code))
            buf.write_string("</code></pre>\n")
          }
        }
      }
    @markdown.Block::IndentedCode(code~, ..) => {
      buf.write_string("<pre><code>")
      buf.write_string(escape_html(code))
      buf.write_string("</code></pre>\n")
    }
    @markdown.Block::Blockquote(children~, ..) => {
      buf.write_string("<blockquote>\n")
      for child in children {
        render_block(child, buf, headings, heading_idx)
      }
      buf.write_string("</blockquote>\n")
    }
    @markdown.Block::BulletList(items~, tight~, ..) => {
      let has_task = items.iter().any(fn(item) { not(item.checked is None) })
      if has_task {
        buf.write_string("<ul class=\"contains-task-list\">\n")
      } else {
        buf.write_string("<ul>\n")
      }
      for item in items {
        render_list_item(item, buf, tight, has_task, headings, heading_idx)
      }
      buf.write_string("</ul>\n")
    }
    @markdown.Block::OrderedList(items~, start~, tight~, ..) => {
      let has_task = items.iter().any(fn(item) { not(item.checked is None) })
      if start == 1 {
        if has_task {
          buf.write_string("<ol class=\"contains-task-list\">\n")
        } else {
          buf.write_string("<ol>\n")
        }
      } else {
        if has_task {
          buf.write_string("<ol class=\"contains-task-list\" start=\"")
        } else {
          buf.write_string("<ol start=\"")
        }
        buf.write_string(start.to_string())
        buf.write_string("\">\n")
      }
      for item in items {
        render_list_item(item, buf, tight, has_task, headings, heading_idx)
      }
      buf.write_string("</ol>\n")
    }
    @markdown.Block::HtmlBlock(html~, ..) => {
      let sanitized = @purify.sanitize(html)
      buf.write_string(sanitized.content)
      if not(sanitized.content.has_suffix("\n")) {
        buf.write_char('\n')
      }
    }
    @markdown.Block::Table(header~, alignments~, rows~, ..) => {
      buf.write_string("<table>\n<thead>\n<tr>\n")
      for i, cell in header {
        let align = if i < alignments.length() {
          alignments[i]
        } else {
          @markdown.TableAlign::None
        }
        render_table_cell(cell, buf, "th", align)
      }
      buf.write_string("</tr>\n</thead>\n")
      if rows.length() > 0 {
        buf.write_string("<tbody>\n")
        for row in rows {
          buf.write_string("<tr>\n")
          for i, cell in row {
            let align = if i < alignments.length() {
              alignments[i]
            } else {
              @markdown.TableAlign::None
            }
            render_table_cell(cell, buf, "td", align)
          }
          buf.write_string("</tr>\n")
        }
        buf.write_string("</tbody>\n")
      }
      buf.write_string("</table>\n")
    }
    @markdown.Block::BlankLines(..) => ()
    @markdown.Block::FootnoteDefinition(label~, children~, ..) => {
      buf.write_string("<div class=\"footnote\" id=\"fn-")
      buf.write_string(escape_html(label))
      buf.write_string("\">\n")
      for child in children {
        render_block(child, buf, headings, heading_idx)
      }
      buf.write_string("</div>\n")
    }
  }
}

///|
fn render_list_item(
  item : @markdown.ListItem,
  buf : StringBuilder,
  tight : Bool,
  is_task_list : Bool,
  headings : Array[HeadingInfo],
  heading_idx : Ref[Int],
) -> Unit {
  if is_task_list && not(item.checked is None) {
    buf.write_string("<li class=\"task-list-item\">")
  } else {
    buf.write_string("<li>")
  }
  match item.checked {
    Some(true) =>
      buf.write_string("<input type=\"checkbox\" checked disabled> ")
    Some(false) => buf.write_string("<input type=\"checkbox\" disabled> ")
    None => ()
  }
  if tight {
    for child in item.children {
      match child {
        @markdown.Block::Paragraph(children~, ..) =>
          render_inlines(children, buf)
        _ => render_block(child, buf, headings, heading_idx)
      }
    }
  } else {
    buf.write_char('\n')
    for child in item.children {
      render_block(child, buf, headings, heading_idx)
    }
  }
  buf.write_string("</li>\n")
}

///|
fn render_table_cell(
  cell : @markdown.TableCell,
  buf : StringBuilder,
  tag : String,
  align : @markdown.TableAlign,
) -> Unit {
  buf.write_char('<')
  buf.write_string(tag)
  match align {
    @markdown.TableAlign::Left => buf.write_string(" align=\"left\"")
    @markdown.TableAlign::Center => buf.write_string(" align=\"center\"")
    @markdown.TableAlign::Right => buf.write_string(" align=\"right\"")
    @markdown.TableAlign::None => ()
  }
  buf.write_char('>')
  render_inlines(cell.children, buf)
  buf.write_string("</")
  buf.write_string(tag)
  buf.write_string(">\n")
}

///|
fn render_inlines(
  inlines : Array[@markdown.Inline],
  buf : StringBuilder,
) -> Unit {
  for inline in inlines {
    render_inline(inline, buf)
  }
}

///|
fn render_inline(inline : @markdown.Inline, buf : StringBuilder) -> Unit {
  match inline {
    @markdown.Inline::Text(content~, ..) =>
      buf.write_string(escape_html(content))
    @markdown.Inline::Code(content~, ..) => {
      buf.write_string("<code>")
      buf.write_string(escape_html(content))
      buf.write_string("</code>")
    }
    @markdown.Inline::Emphasis(children~, ..) => {
      buf.write_string("<em>")
      render_inlines(children, buf)
      buf.write_string("</em>")
    }
    @markdown.Inline::Strong(children~, ..) => {
      buf.write_string("<strong>")
      render_inlines(children, buf)
      buf.write_string("</strong>")
    }
    @markdown.Inline::Strikethrough(children~, ..) => {
      buf.write_string("<del>")
      render_inlines(children, buf)
      buf.write_string("</del>")
    }
    @markdown.Inline::Link(children~, url~, title~, ..) => {
      let safe_url = match @purify.sanitize_url(url) {
        Some(u) => u
        None => ""
      }
      buf.write_string("<a href=\"")
      buf.write_string(escape_html_attr(safe_url))
      buf.write_char('"')
      if not(title.is_empty()) {
        buf.write_string(" title=\"")
        buf.write_string(escape_html_attr(title))
        buf.write_char('"')
      }
      buf.write_char('>')
      render_inlines(children, buf)
      buf.write_string("</a>")
    }
    @markdown.Inline::RefLink(children~, label~, ..) => {
      buf.write_char('[')
      render_inlines(children, buf)
      buf.write_string("][")
      buf.write_string(escape_html(label))
      buf.write_char(']')
    }
    @markdown.Inline::Autolink(url~, is_email~, ..) => {
      let safe_url = match @purify.sanitize_url(url) {
        Some(u) => u
        None => ""
      }
      buf.write_string("<a href=\"")
      if is_email {
        buf.write_string("mailto:")
      }
      buf.write_string(escape_html_attr(safe_url))
      buf.write_string("\">")
      buf.write_string(escape_html(url))
      buf.write_string("</a>")
    }
    @markdown.Inline::Image(alt~, url~, title~, ..) => {
      let safe_url = match @purify.sanitize_url(url) {
        Some(u) => u
        None => ""
      }
      buf.write_string("<img src=\"")
      buf.write_string(escape_html_attr(safe_url))
      buf.write_string("\" alt=\"")
      buf.write_string(escape_html_attr(alt))
      buf.write_char('"')
      if not(title.is_empty()) {
        buf.write_string(" title=\"")
        buf.write_string(escape_html_attr(title))
        buf.write_char('"')
      }
      buf.write_string(">")
    }
    @markdown.Inline::RefImage(alt~, label~, ..) => {
      buf.write_string("![")
      buf.write_string(escape_html(alt))
      buf.write_string("][")
      buf.write_string(escape_html(label))
      buf.write_char(']')
    }
    @markdown.Inline::HtmlInline(html~, ..) => {
      let sanitized = @purify.sanitize(html)
      buf.write_string(sanitized.content)
    }
    @markdown.Inline::SoftBreak(..) => buf.write_char('\n')
    @markdown.Inline::HardBreak(..) => buf.write_string("<br>\n")
    @markdown.Inline::FootnoteReference(label~, ..) => {
      buf.write_string("<sup><a href=\"#fn-")
      buf.write_string(escape_html_attr(label))
      buf.write_string("\" id=\"fnref-")
      buf.write_string(escape_html_attr(label))
      buf.write_string("\">")
      buf.write_string(escape_html(label))
      buf.write_string("</a></sup>")
    }
  }
}

///|
fn escape_html(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    match c {
      '&' => buf.write_string("&amp;")
      '<' => buf.write_string("&lt;")
      '>' => buf.write_string("&gt;")
      '"' => buf.write_string("&quot;")
      _ => buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
fn escape_html_attr(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    match c {
      '&' => buf.write_string("&amp;")
      '<' => buf.write_string("&lt;")
      '>' => buf.write_string("&gt;")
      '"' => buf.write_string("&quot;")
      '\'' => buf.write_string("&#39;")
      _ => buf.write_char(c)
    }
  }
  buf.to_string()
}
