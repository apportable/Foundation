#include <stdlib.h>
#include <unistd.h>

#if !defined(TARGET_OS_ANDROID) && !defined(TARGET_OS_BBX)

#warning kill not supported
void kill(void) {
}
#endif

#warning killpg not supported
int killpg(int pgrp, int sig) {
  return 0;
}

#warning setsid not supported
pid_t setsid(void) {
  return -1;
}

#warning mprotect not supported
int mprotect(void *addr, size_t len, int prot) {
  return 0;
}

#ifdef __native_client__
#warning pagesize not supported
size_t getpagesize(void) {
  return 4096;
}
#endif
