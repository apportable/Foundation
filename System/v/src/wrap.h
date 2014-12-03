#ifndef _LIBV_WRAP_H_
#define _LIBV_WRAP_H_

#include <libv/libv.h>

#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/mman.h>
#include <dirent.h>
#include <libgen.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <pthread.h>
#include <sys/prctl.h>
#include <sys/resource.h>
#include <assert.h>
#include <wchar.h>
#include <fts.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <ftw.h>
#include <limits.h>

#include "memtrace.h"

#define WRAPFN(f) __wrap_##f
#define REALFN(f) __real_##f

#if __i386__
#define WRAPFN_PTHREADCREATE(f) __ap_wrap_##f
#else
#define WRAPFN_PTHREADCREATE(f) __wrap_##f
#endif

struct DIR {
    int             _DIR_fd;
    size_t          _DIR_avail;
    struct dirent*  _DIR_next;
    pthread_mutex_t _DIR_lock;
    struct dirent   _DIR_buff[15];
};

#pragma mark - memory

#ifdef ANDROID
LIBV_EXTERN int ashmem_create_region(const char *name, size_t size);
LIBV_EXTERN int ashmem_pin_region(int fd, size_t offset, size_t len);
LIBV_EXTERN int ashmem_unpin_region(int fd, size_t offset, size_t len);
#endif

#pragma mark - file io

typedef enum {
    fd_entry_real,
    fd_entry_virtual,
    fd_entry_cached,
} fd_entry_type;

typedef enum {
    non_virtual,
    virtual_bundle,
    virtual_system,
} virtual_prefix_type;

LIBV_EXTERN fd_entry_type __fd_type(int fd);
LIBV_EXTERN const char *__virtual_prefix(virtual_prefix_type type);

LIBV_EXTERN int REALFN(lstat)(const char *restrict path, struct stat *restrict buf);
LIBV_EXPORT int WRAPFN(lstat)(const char *restrict path, struct stat *restrict buf);

LIBV_EXTERN int REALFN(stat)(const char *restrict path, struct stat *restrict buf);
LIBV_EXPORT int WRAPFN(stat)(const char *restrict path, struct stat *restrict buf);

LIBV_EXTERN int REALFN(fstat)(int fildes, struct stat *restrict buf);
LIBV_EXPORT int WRAPFN(fstat)(int fildes, struct stat *restrict buf);

LIBV_EXTERN int REALFN(access)(const char *path, int amode);
LIBV_EXPORT int WRAPFN(access)(const char *path, int amode);

LIBV_EXTERN char *REALFN(realpath)(const char *restrict path, char *restrict resolved);
LIBV_EXPORT char *WRAPFN(realpath)(const char *restrict path, char *restrict resolved);

LIBV_EXTERN int REALFN(open)(const char *path, int oflag, ...);
LIBV_EXPORT int WRAPFN(open)(const char *path, int oflag, ...);

LIBV_EXTERN int REALFN(close)(int fd);
LIBV_EXPORT int WRAPFN(close)(int fd);

LIBV_EXTERN ssize_t REALFN(read)(int fildes, void *buf, size_t nbyte);
LIBV_EXPORT ssize_t WRAPFN(read)(int fildes, void *buf, size_t nbyte);

LIBV_EXTERN ssize_t WRAPFN(pread)(int d, void *buf, size_t nbyte, off_t offset);
LIBV_EXPORT ssize_t WRAPFN(pread)(int d, void *buf, size_t nbyte, off_t offset);

LIBV_EXTERN ssize_t REALFN(write)(int fildes, const void *buf, size_t nbyte);
LIBV_EXPORT ssize_t WRAPFN(write)(int fildes, const void *buf, size_t nbyte);

LIBV_EXTERN int REALFN(accept)(int s, struct sockaddr *addr, socklen_t *addrlen);
LIBV_EXPORT int WRAPFN(accept)(int s, struct sockaddr *addr, socklen_t *addrlen);

LIBV_EXTERN int REALFN(socket)(int domain, int type, int protocol);
LIBV_EXPORT int WRAPFN(socket)(int domain, int type, int protocol);

LIBV_EXTERN ssize_t REALFN(sendmsg)(int socket, const struct msghdr *message, int flags);
LIBV_EXPORT ssize_t WRAPFN(sendmsg)(int socket, const struct msghdr *message, int flags);

LIBV_EXTERN ssize_t REALFN(sendto)(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);
LIBV_EXPORT ssize_t WRAPFN(sendto)(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);

LIBV_EXTERN ssize_t REALFN(recv)(int socket, void *buffer, size_t length, int flags);
LIBV_EXPORT ssize_t WRAPFN(recv)(int socket, void *buffer, size_t length, int flags);

LIBV_EXTERN ssize_t REALFN(recvfrom)(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len);
LIBV_EXPORT ssize_t WRAPFN(recvfrom)(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len);

LIBV_EXTERN ssize_t REALFN(recvmsg)(int socket, struct msghdr *message, int flags);
LIBV_EXPORT ssize_t WRAPFN(recvmsg)(int socket, struct msghdr *message, int flags);

LIBV_EXTERN ssize_t REALFN(send)(int socket, const void *buffer, size_t length, int flags);
LIBV_EXPORT ssize_t WRAPFN(send)(int socket, const void *buffer, size_t length, int flags);

LIBV_EXTERN off_t REALFN(lseek)(int fildes, off_t offset, int whence);
LIBV_EXPORT off_t WRAPFN(lseek)(int fildes, off_t offset, int whence);

LIBV_EXTERN FILE *REALFN(fopen)(const char *restrict filename, const char *restrict mode);
LIBV_EXPORT FILE *WRAPFN(fopen)(const char *restrict filename, const char *restrict mode);

LIBV_EXTERN FILE *REALFN(fdopen)(int fildes, const char *mode);
LIBV_EXPORT FILE *WRAPFN(fdopen)(int fildes, const char *mode);

LIBV_EXTERN int REALFN(fclose)(FILE *stream);
LIBV_EXPORT int WRAPFN(fclose)(FILE *stream);

LIBV_EXTERN int REALFN(fsync)(int fildes);
LIBV_EXPORT int WRAPFN(fsync)(int fildes);

LIBV_EXTERN int REALFN(rename)(const char *oldpath, const char *newpath);
LIBV_EXPORT int WRAPFN(rename)(const char *oldpath, const char *newpath);

LIBV_EXTERN int REALFN(unlink)(const char *path);
LIBV_EXPORT int WRAPFN(unlink)(const char *path);

LIBV_EXTERN int REALFN(rmdir)(const char *path);
LIBV_EXPORT int WRAPFN(rmdir)(const char *path);

LIBV_EXTERN char *REALFN(realpath)(const char *restrict file_name, char *restrict resolved_name);
LIBV_EXPORT char *WRAPFN(realpath)(const char *restrict file_name, char *restrict resolved_name);

LIBV_EXTERN char *REALFN(getcwd)(char *buf, size_t size);
LIBV_EXPORT char *WRAPFN(getcwd)(char *buf, size_t size);

LIBV_EXTERN int REALFN(chdir)(const char *path);
LIBV_EXPORT int WRAPFN(chdir)(const char *path);

LIBV_EXTERN void *REALFN(mmap)(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
LIBV_EXPORT void *WRAPFN(mmap)(void *addr, size_t len, int prot, int flags, int fd, off_t offset);

LIBV_EXTERN int REALFN(munmap)(void *addr, size_t len);
LIBV_EXPORT int WRAPFN(munmap)(void *addr, size_t len);

LIBV_EXTERN FTS *REALFN(fts_open)(char * const *argv, int options, int (*compar)(const FTSENT **, const FTSENT **));
LIBV_EXPORT FTS *WRAPFN(fts_open)(char * const *argv, int options, int (*compar)(const FTSENT **, const FTSENT **));

LIBV_EXTERN int REALFN(fts_close)(FTS *sp);
LIBV_EXPORT int WRAPFN(fts_close)(FTS *sp);

LIBV_EXTERN int REALFN(fts_set)(FTS *sp, FTSENT *p, int instr);
LIBV_EXPORT int WRAPFN(fts_set)(FTS *sp, FTSENT *p, int instr);

LIBV_EXTERN FTSENT *REALFN(fts_children)(FTS *sp, int instr);
LIBV_EXPORT FTSENT *WRAPFN(fts_children)(FTS *sp, int instr);

LIBV_EXTERN int REALFN(ftw)(const char *path, int (*fn)(const char *, const struct stat *, int), int nfds);
LIBV_EXPORT int WRAPFN(ftw)(const char *path, int (*fn)(const char *, const struct stat *, int), int nfds);

LIBV_EXPORT int _nftw_context(const char *path, int (*fn)(const char *, const struct stat *, int, struct FTW *, void *), int nfds, int ftwflags, void *ctx);
LIBV_EXTERN int REALFN(nftw)(const char *path, int (*fn)(const char *, const struct stat *, int, struct FTW *), int nfds, int ftwflags);
LIBV_EXPORT int WRAPFN(nftw)(const char *path, int (*fn)(const char *, const struct stat *, int, struct FTW *), int nfds, int ftwflags);

typedef struct {
    int fd;
} AAsset;

typedef struct _AAssetManager AAssetManager;

LIBV_EXPORT AAsset* AAssetManager_open(AAssetManager* mgr, const char* filename, int mode);
LIBV_EXPORT int AAsset_read(AAsset* asset, void* buf, size_t count);
LIBV_EXPORT off_t AAsset_seek(AAsset* asset, off_t offset, int whence);
LIBV_EXPORT void AAsset_close(AAsset* asset);
LIBV_EXPORT off_t AAsset_getRemainingLength(AAsset* asset);

LIBV_EXTERN void file_io_init();

#pragma mark - stdio

LIBV_EXPORT const char *__printf_tag;

LIBV_EXTERN void REALFN(printf)(const char *format, ...);
LIBV_EXPORT void WRAPFN(printf)(const char *format, ...);

LIBV_EXTERN void stdio_init();

#pragma mark - tmpfile

LIBV_EXTERN int REALFN(mkstemps)(char *path, int slen);
LIBV_EXPORT int WRAPFN(mkstemps)(char *path, int slen);

LIBV_EXTERN int REALFN(mkstemp)(char *path);
LIBV_EXPORT int WRAPFN(mkstemp)(char *path);

LIBV_EXTERN char *REALFN(mkdtemp)(char *path);
LIBV_EXPORT char *WRAPFN(mkdtemp)(char *path);

LIBV_EXTERN char *REALFN(mktemp)(char *path);
LIBV_EXPORT char *WRAPFN(mktemp)(char *path);

LIBV_EXTERN FILE *REALFN(tmpfile)();
LIBV_EXPORT FILE *WRAPFN(tmpfile)();

#pragma mark - asprintf

LIBV_EXTERN int REALFN(vasprintf)(char **str, const char *format, va_list args);
LIBV_EXPORT int WRAPFN(vasprintf)(char **str, const char *format, va_list args);

LIBV_EXTERN int REALFN(asprintf)(char **str, const char *format, ...);
LIBV_EXPORT int WRAPFN(asprintf)(char **str, const char *format, ...);

#pragma mark - directory io

LIBV_EXTERN DIR *REALFN(opendir)(const char *dirname);
LIBV_EXPORT DIR *WRAPFN(opendir)(const char *dirname);

LIBV_EXTERN int REALFN(closedir)(DIR *dirp);
LIBV_EXPORT int WRAPFN(closedir)(DIR *dirp);

LIBV_EXTERN DIR *REALFN(fdopendir)(int fd);
LIBV_EXPORT DIR *WRAPFN(fdopendir)(int fd);

LIBV_EXTERN struct dirent *REALFN(readdir)(DIR *dirp);
LIBV_EXPORT struct dirent *WRAPFN(readdir)(DIR *dirp);

LIBV_EXTERN int REALFN(readdir_r)(DIR *dirp, struct dirent *entry, struct dirent **result);
LIBV_EXPORT int WRAPFN(readdir_r)(DIR *dirp, struct dirent *entry, struct dirent **result);

LIBV_EXTERN void REALFN(rewinddir)(DIR *dirp);
LIBV_EXPORT void WRAPFN(rewinddir)(DIR *dirp);

LIBV_EXTERN int REALFN(scandir)(const char *dir, struct dirent ***namelist,
                                int(*filter)(const struct dirent *),
                                int(*compar)(const struct dirent **, const struct dirent **));
LIBV_EXPORT int WRAPFN(scandir)(const char *dir, struct dirent ***namelist,
                                int(*filter)(const struct dirent *),
                                int(*compar)(const struct dirent **, const struct dirent **));

#pragma mark - memory

LIBV_EXTERN void *REALFN(memalign)(size_t boundary, size_t size);
LIBV_EXPORT void *WRAPFN(memalign)(size_t boundary, size_t size);

LIBV_EXTERN int REALFN(posix_memalign)(void **memptr, size_t alignment, size_t size);
LIBV_EXPORT int WRAPFN(posix_memalign)(void **memptr, size_t alignment, size_t size);

LIBV_EXTERN void *REALFN(calloc)(size_t count, size_t size);
LIBV_EXPORT void *WRAPFN(calloc)(size_t count, size_t size);

LIBV_EXTERN void REALFN(free)(void *ptr);
LIBV_EXPORT void WRAPFN(free)(void *ptr);

LIBV_EXTERN void *REALFN(malloc)(size_t size);
LIBV_EXPORT void *WRAPFN(malloc)(size_t size);

LIBV_EXTERN void *REALFN(realloc)(void *ptr, size_t size);
LIBV_EXPORT void *WRAPFN(realloc)(void *ptr, size_t size);

LIBV_EXTERN void *REALFN(valloc)(size_t size);
LIBV_EXPORT void *WRAPFN(valloc)(size_t size);

LIBV_EXTERN size_t REALFN(malloc_usable_size)(void *ptr);
LIBV_EXPORT size_t WRAPFN(malloc_usable_size)(void *ptr);

#pragma mark - threads/process

LIBV_EXTERN int REALFN(pthread_create)(pthread_t *thread, const pthread_attr_t *attr,  void *(*start_routine)(void *), void *context);
LIBV_EXPORT int WRAPFN(pthread_create)(pthread_t *thread, const pthread_attr_t *attr,  void *(*start_routine)(void *), void *context);

LIBV_EXTERN void REALFN(pthread_exit)(void *value_ptr);
LIBV_EXPORT void WRAPFN(pthread_exit)(void *value_ptr);

LIBV_EXTERN int REALFN(pthread_key_create)(pthread_key_t *key, void (*destructor)(void *));
LIBV_EXPORT_NOINST int WRAPFN(pthread_key_create)(pthread_key_t *key, void (*destructor)(void *));

LIBV_EXTERN int REALFN(pthread_key_delete)(pthread_key_t key);
LIBV_EXPORT_NOINST int WRAPFN(pthread_key_delete)(pthread_key_t key);

LIBV_EXTERN void *REALFN(pthread_getspecific)(pthread_key_t key);
LIBV_EXPORT_NOINST void *WRAPFN(pthread_getspecific)(pthread_key_t key);

LIBV_EXTERN int REALFN(pthread_setspecific)(pthread_key_t key, const void *value);
LIBV_EXPORT_NOINST int WRAPFN(pthread_setspecific)(pthread_key_t key, const void *value);

LIBV_EXPORT int WRAPFN(pthread_setname_np)(const char *name);

LIBV_EXTERN int REALFN(pthread_getschedparam)(pthread_t thread, int *restrict policy, struct sched_param *restrict param);
LIBV_EXPORT int WRAPFN(pthread_getschedparam)(pthread_t thread, int *restrict policy, struct sched_param *restrict param);

LIBV_EXTERN int REALFN(pthread_setschedparam)(pthread_t thread, int policy, const struct sched_param *param);
LIBV_EXPORT int WRAPFN(pthread_setschedparam)(pthread_t thread, int policy, const struct sched_param *param);

LIBV_EXTERN int REALFN(atexit)(void (*func)(void));
LIBV_EXPORT int WRAPFN(atexit)(void (*func)(void));

LIBV_EXTERN void REALFN(exit)(int value);
LIBV_EXPORT void WRAPFN(exit)(int value);

LIBV_EXTERN void REALFN(abort)();
LIBV_EXPORT void WRAPFN(abort)();

LIBV_EXPORT void __start();
LIBV_EXPORT void (*_start)(int argc, const char *argv[]);

LIBV_EXPORT pthread_t pthread_main_thread_np();
LIBV_EXPORT int pthread_main_np();
LIBV_EXPORT int pthread_set_main_np(pthread_t thread);

LIBV_EXTERN int __cxa_atexit(void (*)(void *), void *, void *);
LIBV_EXTERN void __cxa_finalize(void *);

LIBV_EXTERN void thread_init();

#pragma mark - allocators

LIBV_EXTERN void * REALFN(_Znwj)(unsigned int size);
LIBV_EXPORT void * WRAPFN(_Znwj)(unsigned int size);

LIBV_EXTERN void * REALFN(_Znwm)(unsigned long int size);
LIBV_EXPORT void * WRAPFN(_Znwm)(unsigned long int size);

LIBV_EXTERN void * REALFN(_Znaj)(unsigned int size);
LIBV_EXPORT void * WRAPFN(_Znaj)(unsigned int size);

LIBV_EXTERN void * REALFN(_Znam)(unsigned long int size);
LIBV_EXPORT void * WRAPFN(_Znam)(unsigned long int size);

LIBV_EXTERN void REALFN(_ZdlPv)(void *ptr);
LIBV_EXPORT void WRAPFN(_ZdlPv)(void *ptr);

LIBV_EXTERN void REALFN(_ZdaPv)(void *ptr);
LIBV_EXPORT void WRAPFN(_ZdaPv)(void *ptr);

LIBV_EXTERN char *REALFN(strndup)(const char *src, size_t len);
LIBV_EXPORT char *WRAPFN(strndup)(const char *src, size_t len);

LIBV_EXTERN char *REALFN(strdup)(const char *src);
LIBV_EXPORT char *WRAPFN(strdup)(const char *src);

#ifdef LEAK_DETECTOR

LIBV_EXPORT void * WRAPFN(pthread_join)(pthread_t thread, void **value_ptr);
LIBV_EXPORT void * WRAPFN(dlopen)(const char* path, int mode);
LIBV_EXPORT void * WRAPFN(pthread_detach)(pthread_t thread);
LIBV_EXPORT int WRAPFN(pthread_sigmask)(int how, const sigset_t *restrict set, sigset_t *restrict oset);

#endif

LIBV_EXPORT void __print_backtrace(void);
LIBV_EXPORT void __print_backtrace2(int max_depth, int use_cache);
LIBV_EXPORT void __do_backtrace(int max_depth, int skip_depth, int use_cache, int(*step)(int depth, void *pc, char *cfname, int offset, void *data), void *data);

#pragma mark - strings

#ifdef ANDROID
LIBV_EXPORT int ffs(int i);
LIBV_EXPORT int ffsl(long i);
LIBV_EXPORT int fls(int mask);
LIBV_EXPORT int flsl(long mask);
LIBV_EXPORT int bcmp(const void *p1, const void *p2, size_t len);
#endif

LIBV_EXPORT int WRAPFN(swprintf)(wchar_t * __restrict s, size_t n, const wchar_t * __restrict fmt, ...);
LIBV_EXPORT int WRAPFN(vswprintf)(wchar_t * __restrict s, size_t n, const wchar_t * __restrict fmt, __va_list ap);
LIBV_EXPORT size_t WRAPFN(mbsrtowcs)(wchar_t * __restrict dst, const char ** __restrict src, size_t len, mbstate_t * __restrict ps);

LIBV_EXTERN int REALFN(memcmp)(const void *s1, const void *s2, size_t n);
LIBV_EXPORT int WRAPFN(memcmp)(const void *s1, const void *s2, size_t n);

LIBV_EXTERN void *REALFN(memcpy)(void *restrict dst, const void *restrict src, size_t n);
LIBV_EXPORT void *WRAPFN(memcpy)(void *restrict dst, const void *restrict src, size_t n);

LIBV_EXTERN void REALFN(bcopy)(const void *src, void *dst, size_t len);
LIBV_EXPORT void WRAPFN(bcopy)(const void *src, void *dst, size_t len);

LIBV_EXTERN void * REALFN(memmove)(void *dst, const void *src, size_t len);
LIBV_EXPORT void * WRAPFN(memmove)(void *dst, const void *src, size_t len);

#pragma mark - random

LIBV_EXPORT int WRAPFN(rand)();
LIBV_EXPORT void WRAPFN(srand)(u_int seed);
LIBV_EXPORT void WRAPFN(sranddev)();

#pragma mark - math
LIBV_EXTERN float REALFN(fmodf)(float x, float y);
LIBV_EXPORT float WRAPFN(fmodf)(float x, float y);

#pragma mark - network

LIBV_EXPORT unsigned int REALFN(if_nametoindex)(const char *);
LIBV_EXPORT unsigned int WRAPFN(if_nametoindex)(const char *);
LIBV_EXPORT char * WRAPFN(if_indextoname)(unsigned ifindex, char *ifname);

LIBV_EXPORT void *__pthread_iter_start(int *count);
LIBV_EXPORT int __pthread_iter_next(void **ctx, pthread_t *t);
LIBV_EXPORT void __pthread_iter_end();

#endif /*_LIBV_WRAP_H_*/
