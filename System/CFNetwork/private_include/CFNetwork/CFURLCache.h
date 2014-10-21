#ifndef __CFURLCACHE__
#define __CFURLCACHE__

#include "CFCachedURLResponse.h"
#include "CFURLRequest.h"
#include "CFURLResponse.h"

CF_EXTERN_C_BEGIN

typedef struct _CFURLCache* CFURLCacheRef;

CF_EXPORT
CFTypeID CFURLCacheGetTypeID(void);

CF_EXPORT
void CFURLCacheSetShared(CFURLCacheRef cache);

CF_EXPORT
Boolean CFURLCacheGetShared(CFURLCacheRef* cache); // CFRelease() cache

CF_EXPORT
CFURLCacheRef CFURLCacheCreate(CFAllocatorRef allocator,
                               size_t memoryCapacity, size_t diskCapacity,
                               CFStringRef path);

CF_EXPORT
size_t CFURLCacheMemoryCapacity(CFURLCacheRef cache);

CF_EXPORT
size_t _CFURLCacheMemoryCapacity(CFURLCacheRef cache);

CF_EXPORT
void CFURLCacheSetMemoryCapacity(CFURLCacheRef cache, size_t capacity);

CF_EXPORT
void _CFURLCacheSetMemoryCapacity(CFURLCacheRef cache, size_t capacity);

CF_EXPORT
size_t CFURLCacheCurrentMemoryUsage(CFURLCacheRef cache);

CF_EXPORT
size_t _CFURLCacheCurrentMemoryUsage(CFURLCacheRef cache);

CF_EXPORT
size_t CFURLCacheDiskCapacity(CFURLCacheRef cache);

CF_EXPORT
size_t _CFURLCacheDiskCapacity(CFURLCacheRef cache);

CF_EXPORT
void CFURLCacheSetDiskCapacity(CFURLCacheRef cache, size_t capacity);

CF_EXPORT
void _CFURLCacheSetDiskCapacity(CFURLCacheRef cache, size_t capacity);

CF_EXPORT
size_t CFURLCacheCurrentDiskUsage(CFURLCacheRef cache);

CF_EXPORT
size_t _CFURLCacheCurrentDiskUsage(CFURLCacheRef cache);

CF_EXPORT
CFCachedURLResponseRef CFURLCacheCopyResponseForRequest(CFURLCacheRef cache,
                                                        CFURLRequestRef request);
CF_EXPORT
CFCachedURLResponseRef _CFURLCacheCopyResponseForRequest(CFURLCacheRef cache,
                                                         CFURLRequestRef request);

CF_EXPORT
Boolean CFURLCacheAddCachedResponseForRequest(CFURLCacheRef cache,
                                              CFCachedURLResponseRef cachedResponse,
                                              CFURLRequestRef request);
CF_EXPORT
Boolean _CFURLCacheAddCachedResponseForRequest(CFURLCacheRef cache,
                                               CFCachedURLResponseRef cachedResponse,
                                               CFURLRequestRef request);

CF_EXPORT
void CFURLCacheRemoveCachedResponseForRequest(CFURLCacheRef cache,
                                              CFURLRequestRef request);

CF_EXPORT
void _CFURLCacheRemoveCachedResponseForRequest(CFURLCacheRef cache,
                                               CFURLRequestRef request);

CF_EXPORT
void CFURLCacheRemoveAllCachedResponses(CFURLCacheRef cache);

CF_EXPORT
void _CFURLCacheRemoveAllCachedResponses(CFURLCacheRef cache);

CF_EXPORT
void _CFURLCacheSetNSCache(CFURLCacheRef cache, void *nsCache);

CF_EXTERN_C_END

#endif // __CFURLCACHE__
