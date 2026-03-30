///|
pub fn github_css() -> String {
  let css =
    #|<style>
    #|.markdown-body {
    #|  color-scheme: light;
    #|  --fgColor-default: #1f2328;
    #|  --fgColor-accent: #0969da;
    #|  --fgColor-muted: #59636e;
    #|  --bgColor-default: #ffffff;
    #|  --bgColor-muted: #f6f8fa;
    #|  --bgColor-neutral-muted: #818b981f;
    #|  --borderColor-default: #d1d9e0;
    #|  --borderColor-muted: #d1d9e0b3;
    #|  --fontStack-sansSerif: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    #|  --fontStack-monospace: ui-monospace, SFMono-Regular, SF Mono, Menlo, Consolas, Liberation Mono, monospace;
    #|  margin: 0;
    #|  font-family: var(--fontStack-sansSerif);
    #|  font-size: 16px;
    #|  font-weight: 400;
    #|  line-height: 1.5;
    #|  color: var(--fgColor-default);
    #|  background-color: var(--bgColor-default);
    #|  word-wrap: break-word;
    #|}
    #|.markdown-body h1, .markdown-body h2, .markdown-body h3,
    #|.markdown-body h4, .markdown-body h5, .markdown-body h6 {
    #|  margin-top: 1.5rem; margin-bottom: 1rem; font-weight: 600; line-height: 1.25;
    #|}
    #|.markdown-body h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid var(--borderColor-muted); }
    #|.markdown-body h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid var(--borderColor-muted); }
    #|.markdown-body h3 { font-size: 1.25em; }
    #|.markdown-body h4 { font-size: 1em; }
    #|.markdown-body h5 { font-size: 0.875em; }
    #|.markdown-body h6 { font-size: 0.85em; color: var(--fgColor-muted); }
    #|.markdown-body p { margin-top: 0; margin-bottom: 10px; }
    #|.markdown-body a { color: var(--fgColor-accent); text-decoration: none; }
    #|.markdown-body a:hover { text-decoration: underline; }
    #|.markdown-body strong, .markdown-body b { font-weight: 600; }
    #|.markdown-body em, .markdown-body i { font-style: italic; }
    #|.markdown-body del { text-decoration: line-through; }
    #|.markdown-body img { max-width: 100%; border-style: none; }
    #|.markdown-body code, .markdown-body kbd, .markdown-body tt {
    #|  font-family: var(--fontStack-monospace); font-size: 85%;
    #|  padding: 0.2em 0.4em; margin: 0;
    #|  background-color: var(--bgColor-neutral-muted); border-radius: 6px;
    #|}
    #|.markdown-body pre {
    #|  margin-top: 0; margin-bottom: 1rem; padding: 1rem;
    #|  font-family: var(--fontStack-monospace); font-size: 85%; line-height: 1.45;
    #|  overflow: auto; background-color: var(--bgColor-muted); border-radius: 6px;
    #|}
    #|.markdown-body pre code { display: inline; padding: 0; margin: 0; background-color: transparent; border: 0; }
    #|.markdown-body blockquote { margin: 0; padding: 0 1em; color: var(--fgColor-muted); border-left: 0.25em solid var(--borderColor-default); }
    #|.markdown-body ul, .markdown-body ol { margin-top: 0; margin-bottom: 1rem; padding-left: 2em; }
    #|.markdown-body li { margin-top: 0.25em; }
    #|.markdown-body .task-list-item { list-style-type: none; }
    #|.markdown-body .task-list-item-checkbox { margin: 0 0.2em 0.25em -1.4em; vertical-align: middle; }
    #|.markdown-body hr { margin: 1.5rem 0; padding: 0; height: 0.25em; background-color: var(--borderColor-default); border: 0; }
    #|.markdown-body table { border-spacing: 0; border-collapse: collapse; display: block; width: max-content; max-width: 100%; overflow: auto; }
    #|.markdown-body table th, .markdown-body table td { padding: 6px 13px; border: 1px solid var(--borderColor-default); }
    #|.markdown-body table th { font-weight: 600; }
    #|.markdown-body table tr { background-color: var(--bgColor-default); border-top: 1px solid var(--borderColor-muted); }
    #|.markdown-body table tr:nth-child(2n) { background-color: var(--bgColor-muted); }
    #|.markdown-body h1, .markdown-body h2, .markdown-body h3,
    #|.markdown-body h4, .markdown-body h5, .markdown-body h6 {
    #|  scroll-margin-top: 1rem;
    #|}
    #|.markdown-body pre.highlight {
    #|  background-color: #0d1117; color: #e6edf3; border-radius: 6px;
    #|  padding: 1rem; margin-top: 0; margin-bottom: 1rem; overflow: auto;
    #|  font-family: var(--fontStack-monospace); font-size: 85%; line-height: 1.45;
    #|}
    #|.markdown-body pre.highlight code { display: inline; padding: 0; margin: 0; background-color: transparent; border: 0; }
    #|.markdown-body .toc {
    #|  border: 1px solid var(--borderColor-default); border-radius: 6px;
    #|  padding: 1rem 1.5rem; margin-bottom: 1.5rem;
    #|}
    #|.markdown-body .toc ul { list-style: none; padding-left: 0; margin: 0; }
    #|.markdown-body .toc li { margin: 0.25em 0; }
    #|.markdown-body .toc li[data-level="3"] { padding-left: 1em; }
    #|.markdown-body .toc li[data-level="4"] { padding-left: 2em; }
    #|.markdown-body .toc a { color: var(--fgColor-accent); text-decoration: none; }
    #|.markdown-body .toc a:hover { text-decoration: underline; }
    #|</style>
  css
}
