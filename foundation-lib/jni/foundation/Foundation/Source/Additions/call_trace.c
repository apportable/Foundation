#include <stdio.h>
#include <dlfcn.h>
#include <android/log.h>
#include <pthread.h>

void __cyg_log_func_enter(const char *)
       __attribute__ ((no_instrument_function));
void __cyg_log_func_exit (const char *)
       __attribute__ ((no_instrument_function));
void __cyg_enable_logging()
       __attribute__ ((no_instrument_function));
void __cyg_disable_logging()
       __attribute__ ((no_instrument_function));

static int __cyg_logging_enabled = 1;
static const char *padding = "  ";
static int paddingLength = 0;
static int indent_level = 0;

void __cyg_enable_logging() {
  __cyg_logging_enabled = 1;
}

void __cyg_disable_logging() {
  __cyg_logging_enabled = 0;
}

void __cyg_log_func_enter(const char *func) {
  if (__cyg_logging_enabled) {
    if (paddingLength == 0)
      paddingLength = strlen(padding);
    __android_log_print(ANDROID_LOG_INFO, "NSCALL_TRACE", "%ld)%*s>%s\n", pthread_self(), indent_level * paddingLength, padding, func);
    indent_level++;
  }
}

void __cyg_log_func_exit(const char *func) {
  if (__cyg_logging_enabled) {
    if (paddingLength == 0)
      paddingLength = strlen(padding);
    indent_level--;
    __android_log_print(ANDROID_LOG_INFO, "NSCALL_TRACE", "%ld)%*s<%s\n", pthread_self(), indent_level * paddingLength, padding, func);
  }
}

