///|
test "toc_to_html with empty array returns empty string" {
  let items : Array[HeadingInfo] = []
  let result = toc_to_html(items)
  inspect(result, content="")
}

///|
test "toc_to_html with single item" {
  let items = [
    HeadingInfo::{ level: 2, text: "Hello", id: "hello", in_footnote: false },
  ]
  let result = toc_to_html(items)
  inspect(result.contains("<nav class=\"toc\">"), content="true")
  inspect(result.contains("href=\"#hello\""), content="true")
  inspect(result.contains("Hello"), content="true")
}

///|
test "toc_to_html escapes html in text" {
  let items = [
    HeadingInfo::{
      level: 2,
      text: "<script>xss</script>",
      id: "scriptxssscript",
      in_footnote: false,
    },
  ]
  let result = toc_to_html(items)
  inspect(result.contains("<script>"), content="false")
  inspect(result.contains("&lt;script&gt;"), content="true")
}

///|
test "toc_to_html includes data-level attribute" {
  let items = [
    HeadingInfo::{ level: 2, text: "H2", id: "h2", in_footnote: false },
    HeadingInfo::{ level: 3, text: "H3", id: "h3", in_footnote: false },
  ]
  let result = toc_to_html(items)
  inspect(result.contains("data-level=\"2\""), content="true")
  inspect(result.contains("data-level=\"3\""), content="true")
}
