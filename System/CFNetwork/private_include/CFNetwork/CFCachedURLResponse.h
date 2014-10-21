#ifndef __CFCACHEDURLRESPONSE__
#define __CFCACHEDURLRESPONSE__

#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include "CFURLResponse.h"

CF_EXTERN_C_BEGIN

typedef CF_ENUM(CFIndex, CFCachedURLStoragePolicy) {
    CFURLCacheStorageAllowed,
    CFURLCacheStorageAllowedInMemoryOnly,
    CFURLCacheStorageNotAllowed,
};

typedef struct _CFCachedURLResponse* CFCachedURLResponseRef;

CF_EXPORT CFCachedURLResponseRef CFCachedURLResponseCreate(CFAllocatorRef allocator,
                                                           CFURLResponseRef response,
                                                           CFTypeRef dataOrDataPath,
                                                           CFDictionaryRef userInfo,
                                                           CFCachedURLStoragePolicy storagePolicy);

CF_EXPORT CFURLResponseRef CFCachedURLResponseGetResponse(CFCachedURLResponseRef);
CF_EXPORT size_t CFCachedURLResponseGetDataSize(CFCachedURLResponseRef);
CF_EXPORT Boolean CFCachedURLResponseLoadData(CFCachedURLResponseRef, CFDataRef* data); // CFRelease() data
CF_EXPORT CFDictionaryRef CFCachedURLResponseGetUserInfo(CFCachedURLResponseRef);
CF_EXPORT CFCachedURLStoragePolicy CFCachedURLResponseGetStoragePolicy(CFCachedURLResponseRef);

// These functions return either 0 or CFCachedURLResponseGetDataSize().
CF_EXPORT size_t _CFCachedURLResponseGetMemorySize(CFCachedURLResponseRef);
CF_EXPORT size_t _CFCachedURLResponseGetDiskSize(CFCachedURLResponseRef);

CF_EXPORT Boolean _CFCachedURLResponseClaimOwnership(CFCachedURLResponseRef, const void* owner);
CF_EXPORT void _CFCachedURLResponseReleaseOwnership(CFCachedURLResponseRef, const void* owner);
CF_EXPORT Boolean _CFCachedURLResponseSetDataPath(CFCachedURLResponseRef, const void* owner, CFStringRef dataPath);
CF_EXPORT Boolean _CFCachedURLResponseEvictFromMemory(CFCachedURLResponseRef, const void* owner);
CF_EXPORT Boolean _CFCachedURLResponseCacheToMemory(CFCachedURLResponseRef, const void* owner);

CF_EXTERN_C_END

#endif // __CFCACHEDURLRESPONSE__
