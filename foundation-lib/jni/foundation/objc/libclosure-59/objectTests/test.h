// test.h
// Common definitions for trivial test harness


#ifndef TEST_H
#define TEST_H

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <libgen.h>
#include <unistd.h>
#include <sys/param.h>
#include <malloc/malloc.h>
#include <mach/mach_time.h>
#include <objc/objc.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <objc/objc-auto.h>
#include <TargetConditionals.h>

static inline void succeed(const char *name)  __attribute__((noreturn));
static inline void succeed(const char *name)
{
    if (name) {
        char path[MAXPATHLEN+1];
        strcpy(path, name);        
        fprintf(stderr, "OK: %s\n", basename(path));
    } else {
        fprintf(stderr, "OK\n");
    }
    exit(0);
}

static inline void fail(const char *msg, ...)   __attribute__((noreturn));
static inline void fail(const char *msg, ...)
{
    va_list v;
    if (msg) {
        fprintf(stderr, "BAD: ");
        va_start(v, msg);
        vfprintf(stderr, msg, v);
        va_end(v);
        fprintf(stderr, "\n");
    } else {
        fprintf(stderr, "BAD\n");
    }
    exit(1);
}

#define testassert(cond) \
    ((void) ((cond) ? (void)0 : __testassert(#cond, __FILE__, __LINE__)))
#define __testassert(cond, file, line) \
    (fail("failed assertion '%s' at %s:%u", cond, __FILE__, __LINE__))

/* time-sensitive assertion, disabled under valgrind */
#define timecheck(name, time, fast, slow)                                    \
    if (getenv("VALGRIND") && 0 != strcmp(getenv("VALGRIND"), "NO")) {  \
        /* valgrind; do nothing */                                      \
    } else if (time > slow) {                                           \
        fprintf(stderr, "SLOW: %s %llu, expected %llu..%llu\n",         \
                name, (uint64_t)(time), (uint64_t)(fast), (uint64_t)(slow)); \
    } else if (time < fast) {                                           \
        fprintf(stderr, "FAST: %s %llu, expected %llu..%llu\n",         \
                name, (uint64_t)(time), (uint64_t)(fast), (uint64_t)(slow)); \
    } else {                                                            \
        testprintf("time: %s %llu, expected %llu..%llu\n",              \
                   name, (uint64_t)(time), (uint64_t)(fast), (uint64_t)(slow)); \
    }


static inline void testprintf(const char *msg, ...)
{
    if (msg  &&  getenv("VERBOSE")) {
        va_list v;
        va_start(v, msg);
        fprintf(stderr, "VERBOSE: ");
        vfprintf(stderr, msg, v);
        va_end(v);
    }
}

// complain to output, but don't fail the test
// Use when warning that some test is being temporarily skipped 
// because of something like a compiler bug.
static inline void testwarn(const char *msg, ...)
{
    if (msg) {
        va_list v;
        va_start(v, msg);
        fprintf(stderr, "WARN: ");
        vfprintf(stderr, msg, v);
        va_end(v);
        fprintf(stderr, "\n");
    }
}


// Run GC. This is a macro to reach as high in the stack as possible.
#ifndef OBJC_NO_GC
#   define testcollect()                                                \
        do {                                                            \
            if (objc_collectingEnabled()) {                             \
                objc_clear_stack(0);                                    \
                objc_collect(OBJC_COLLECT_IF_NEEDED|OBJC_WAIT_UNTIL_DONE); \
                objc_collect(OBJC_EXHAUSTIVE_COLLECTION|OBJC_WAIT_UNTIL_DONE);\
                objc_collect(OBJC_EXHAUSTIVE_COLLECTION|OBJC_WAIT_UNTIL_DONE);\
            }                                                           \
        } while (0)
#else
#   define testcollect() do { } while (0)
#endif

/* Leak checking
   Fails if total malloc memory in use at leak_check(n) 
   is more than n bytes above that at leak_mark().

   fixme rdar://8437289 malloc_zone_statistics(auto_zone()) lies
*/

static size_t _leak_start;
static inline void leak_mark(void)
{
    if (objc_collectingEnabled()) return;
    malloc_statistics_t stats;
    testcollect();
    malloc_zone_statistics(NULL, &stats);
    _leak_start = stats.size_in_use;
}

#define leak_check(n)                                                   \
    do {                                                                \
        if (objc_collectingEnabled()) break;                            \
        const char *_check = getenv("LEAK_CHECK");                      \
        if (_check && 0 == strcmp(_check, "NO")) break;                 \
        testcollect();                                                  \
        malloc_statistics_t stats;                                      \
        malloc_zone_statistics(NULL, &stats);                           \
        if (stats.size_in_use > _leak_start + n) {                      \
            if (getenv("HANG_ON_LEAK")) {                               \
                printf("leaks %d\n", getpid());                         \
                while (1) sleep(1);                                     \
            }                                                           \
            fail("%zu bytes leaked at %s:%u",                           \
                 stats.size_in_use - _leak_start, __FILE__, __LINE__);  \
        }                                                               \
    } while (0)

static inline bool is_guardmalloc(void)
{
    const char *env = getenv("GUARDMALLOC");
    return (env  &&  0 == strcmp(env, "YES"));
}

#endif
