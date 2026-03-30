# mdclip

Clipboard markdown viewer. Reads markdown from clipboard, converts to GitHub-styled HTML, and opens it in the default browser.

Powered by [mizchi/markdown.mbt](https://github.com/mizchi/markdown.mbt) (MoonBit native target).

## Install

### Prerequisites

- [MoonBit toolchain](https://www.moonbitlang.com/download)

### Build

```bash
git clone https://github.com/ushironoko/mdclip.git
cd mdclip
moon update
moon build --target native --release
```

### macOS

```bash
cp _build/native/release/build/src/main/main.exe ~/.local/bin/mdclip
chmod +x ~/.local/bin/mdclip
```

### Windows

```powershell
Copy-Item _build\native\release\build\src\main\main.exe $env:LOCALAPPDATA\mdclip\mdclip.exe
# Add $env:LOCALAPPDATA\mdclip to PATH
```

## Usage

```bash
mdclip          # Read clipboard, convert, open browser (default)
mdclip once     # Same as above
mdclip daemon   # Start daemon process (macOS/Linux only)
mdclip trigger  # Send USR1 signal to daemon (macOS/Linux only)
mdclip stop     # Stop daemon (macOS/Linux only)
```

## Keybind Setup

### macOS (Automator Quick Action)

1. Open **Automator.app** > File > New > **Quick Action**
2. Set "Workflow receives" to **no input** in **any application**
3. Drag **Run Shell Script** from the action library
4. Set shell to `/bin/zsh`, paste:
   ```bash
   /Users/<your-username>/.local/bin/mdclip once
   ```
5. Save as **"Preview Clipboard Markdown"** (Cmd+S)
6. Open **System Settings** > **Keyboard** > **Keyboard Shortcuts** > **Services**
7. Find "Preview Clipboard Markdown" under **General**, assign a shortcut (e.g. `Cmd+Shift+M`)

### Windows (AutoHotkey)

Install [AutoHotkey v2](https://www.autohotkey.com/).

Save as `mdclip.ahk`:

```autohotkey
#Requires AutoHotkey v2.0
#+m:: {
    Run A_LocalAppData "\mdclip\mdclip.exe"
}
```

This binds `Win+Shift+M` to run mdclip.

To run on startup, place the `.ahk` file (or a shortcut to it) in:

```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
```

### Windows (PowerShell + Task Scheduler)

Save as `mdclip-trigger.ps1`:

```powershell
& "$env:LOCALAPPDATA\mdclip\mdclip.exe"
```

Register a shortcut:

1. Create a shortcut to `powershell.exe -WindowStyle Hidden -File "C:\path\to\mdclip-trigger.ps1"`
2. Right-click the shortcut > Properties > **Shortcut key** > assign a key combo

## Platform Support

| Feature | macOS | Windows | Linux |
|---------|-------|---------|-------|
| `once` mode | pbpaste + open | PowerShell Get-Clipboard + start | xclip + xdg-open (*) |
| `daemon` mode | SIGUSR1 + launchd | Not supported | SIGUSR1 (*) |

(*) Linux: replace `pbpaste` with `xclip -selection clipboard -o` or `wl-paste`, and `open` with `xdg-open` in the source.

## How It Works

```
Keybind
  -> mdclip once
    -> pbpaste / Get-Clipboard (read clipboard)
    -> mizchi/markdown md_to_html() (convert)
    -> Write HTML with GitHub CSS + CSP header
    -> open / start (launch browser)
```

HTML output location:
- macOS: `~/Library/Caches/mdclip/preview.html`
- Windows: `%LOCALAPPDATA%\mdclip\preview.html`

## Security

- **CSP header** blocks script execution, iframes, forms, and base-uri changes
- `mizchi/markdown` passes raw HTML blocks through without sanitization, but CSP prevents execution of embedded scripts

## License

MIT
