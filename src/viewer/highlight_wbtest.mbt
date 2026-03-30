///|
test "highlight_code returns Some for typescript" {
  let result = highlight_code("typescript", "const x = 1")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for ts alias" {
  let result = highlight_code("ts", "const x = 1")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for javascript via typescript fallback" {
  let result = highlight_code("javascript", "const x = 1")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for js alias" {
  let result = highlight_code("js", "const x = 1")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for json" {
  let result = highlight_code("json", "{\"key\": 1}")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for bash" {
  let result = highlight_code("bash", "echo hello")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for sh alias" {
  let result = highlight_code("sh", "echo hello")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for rust" {
  let result = highlight_code("rust", "fn main() {}")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for moonbit" {
  let result = highlight_code("moonbit", "fn main {}")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for mbt alias" {
  let result = highlight_code("mbt", "fn main {}")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for html" {
  let result = highlight_code("html", "<div>hello</div>")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns Some for css" {
  let result = highlight_code("css", "body { color: red; }")
  inspect(result is Some(_), content="true")
}

///|
test "highlight_code returns None for unknown language" {
  let result = highlight_code("unknown", "code")
  inspect(result is None, content="true")
}

///|
test "highlight_code returns None for empty string" {
  let result = highlight_code("", "code")
  inspect(result is None, content="true")
}

///|
test "highlight_code output contains pre.highlight" {
  match highlight_code("typescript", "const x = 1") {
    Some(html) =>
      inspect(html.contains("<pre class=\"highlight"), content="true")
    None => fail("expected Some")
  }
}
