#ifndef _LIBV_MEMTRACE_H_
#define _LIBV_MEMTRACE_H_

#include <libv/libv.h>

LIBV_EXTERN void memory_init();
LIBV_EXTERN int __memtrace_enabled__;
LIBV_EXTERN int __malloc_verify__;
LIBV_EXTERN int __malloc_fence__;
LIBV_EXTERN int __malloc_scribble__;
LIBV_EXTERN void memtrace_alloc(void *ptr, int size);
LIBV_EXTERN void memtrace_free(void *ptr);
LIBV_EXTERN void memtrace_tic(int level);
LIBV_EXTERN void memtrace_toc(const char *tag, int level);

#endif
