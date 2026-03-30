///|
async fn main {
  let args = @sys.get_cli_args()
  let command = if args.length() > 1 { args[1] } else { "once" }
  match command {
    "once" => @daemon.run_once()
    "file" =>
      if args.length() > 2 {
        @daemon.run_from_file(args[2])
      } else {
        println("Usage: mdclip file <path>")
      }
    "daemon" => @daemon.run_daemon()
    "trigger" => @daemon.send_trigger()
    "stop" => @daemon.stop_daemon()
    _ => {
      println("Usage: mdclip [once|file <path>|daemon|trigger|stop]")
      println("")
      println("Commands:")
      println(
        "  once           Read clipboard, convert to HTML, open browser (default)",
      )
      println("  file <path>    Read markdown from file")
      println("  daemon         Start daemon process (macOS/Linux only)")
      println("  trigger        Send USR1 signal to running daemon")
      println("  stop           Stop running daemon")
    }
  }
}
