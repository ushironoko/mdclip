#ifdef _WIN32

int mdclip_register_usr1(void) { return -1; }
int mdclip_check_and_clear_usr1(void) { return 0; }
int mdclip_getpid(void) { return 0; }

#else

#include <signal.h>
#include <unistd.h>

static volatile sig_atomic_t usr1_received = 0;

static void usr1_handler(int sig) {
  (void)sig;
  usr1_received = 1;
}

int mdclip_register_usr1(void) {
  struct sigaction sa;
  sa.sa_handler = usr1_handler;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;
  return sigaction(SIGUSR1, &sa, NULL) == 0 ? 0 : -1;
}

int mdclip_check_and_clear_usr1(void) {
  if (usr1_received) {
    usr1_received = 0;
    return 1;
  }
  return 0;
}

int mdclip_getpid(void) {
  return (int)getpid();
}

#endif
