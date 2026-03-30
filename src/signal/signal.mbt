extern "C" fn mdclip_register_usr1() -> Int = "mdclip_register_usr1"

extern "C" fn mdclip_check_and_clear_usr1() -> Int = "mdclip_check_and_clear_usr1"

extern "C" fn mdclip_getpid() -> Int = "mdclip_getpid"

pub fn init_signal_handler() -> Unit {
  let result = mdclip_register_usr1()
  if result != 0 {
    abort("Failed to register SIGUSR1 handler")
  }
}

pub fn poll_usr1() -> Bool {
  mdclip_check_and_clear_usr1() != 0
}

pub fn get_pid() -> Int {
  mdclip_getpid()
}
