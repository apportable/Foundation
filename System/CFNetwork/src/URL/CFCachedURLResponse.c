//
//  CFCachedURLResponse.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFCachedURLResponse.h"
#include "CFRuntime.h"
#include "CFFSUtils.h"
#include "CFRuntimeUtils.h"
#include <libkern/OSAtomic.h>

typedef struct _CFCachedURLResponse {
    CFRuntimeBase _base;
    OSSpinLock lock;
    CFURLResponseRef response;
    size_t dataSize;
    CFDataRef data;
    CFDictionaryRef userInfo;
    CFCachedURLStoragePolicy policy;
    const void* owner;
    CFStringRef dataPath;
} _CFCachedURLResponse;


static Boolean loadCachedResponseData(CFCachedURLResponseRef, CFDataRef*);


/* Class */

static void cachedResponseDeallocate(CFTypeRef cf) {
    _CFCachedURLResponse* cachedResponse = (_CFCachedURLResponse *)cf;
    if (cachedResponse->response != NULL) {
        CFRelease(cachedResponse->response);
    }
    if (cachedResponse->data != NULL) {
        CFRelease(cachedResponse->data);
    }
    if (cachedResponse->userInfo != NULL) {
        CFRelease(cachedResponse->userInfo);
    }
    if (cachedResponse->dataPath != NULL) {
        CFRelease(cachedResponse->dataPath);
    }
}

static CFTypeID cachedResponseTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass cachedResponseClass = {
    .version = 0,
    .className = "CFCachedURLResponse",
    .finalize = &cachedResponseDeallocate,
};

CFTypeID CFCachedURLResponseGetTypeID(void) {
    _CFRuntimeRegisterClassOnce(&cachedResponseTypeID, &cachedResponseClass);
    return cachedResponseTypeID;
}


/* API */

CFCachedURLResponseRef CFCachedURLResponseCreate(CFAllocatorRef allocator,
                                                 CFURLResponseRef response,
                                                 CFTypeRef dataOrDataPath,
                                                 CFDictionaryRef userInfo,
                                                 CFCachedURLStoragePolicy storagePolicy) {
    if (!response || !dataOrDataPath) {
        return NULL;
    }

    _CFCachedURLResponse* cachedResponse = (_CFCachedURLResponse*)_CFRuntimeCreateInstance(
        allocator,
        CFCachedURLResponseGetTypeID(),
        sizeof(_CFCachedURLResponse) - sizeof(CFRuntimeBase),
        NULL);
    if (!cachedResponse) {
        return NULL;
    }

    if (CFGetTypeID(dataOrDataPath) == CFDataGetTypeID()) {
        cachedResponse->data = CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)dataOrDataPath);
        cachedResponse->dataSize = CFDataGetLength(cachedResponse->data);
    } else if (CFGetTypeID(dataOrDataPath) == CFStringGetTypeID()) {
        cachedResponse->dataPath = CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)dataOrDataPath);
        struct stat dataStat = {0};
        if (_CFFSStat(cachedResponse->dataPath, &dataStat) || dataStat.st_size > SIZE_MAX) {
            CFRelease(cachedResponse);
            return NULL;
        }
        cachedResponse->dataSize = (size_t)dataStat.st_size;
    }

    if (userInfo) {
        cachedResponse->userInfo = CFDictionaryCreateCopy(kCFAllocatorDefault, userInfo);
    }

    cachedResponse->lock = OS_SPINLOCK_INIT;
    cachedResponse->response = (CFURLResponseRef)CFRetain(response);
    cachedResponse->policy = storagePolicy;

    return cachedResponse;
}

CFURLResponseRef CFCachedURLResponseGetResponse(CFCachedURLResponseRef cachedResponse) {
    return cachedResponse->response;
}

size_t CFCachedURLResponseGetDataSize(CFCachedURLResponseRef cachedResponse) {
    return cachedResponse->dataSize;
}

Boolean CFCachedURLResponseLoadData(CFCachedURLResponseRef cachedResponse, CFDataRef* data) {
    Boolean result = false;
    OSSpinLockLock(&cachedResponse->lock);
    {
        if (!cachedResponse->dataSize) {
            *data = NULL;
            result = true;
        } else {
            result = loadCachedResponseData(cachedResponse, data);
        }
    }
    OSSpinLockUnlock(&cachedResponse->lock);
    return result;
}

CFCachedURLStoragePolicy CFCachedURLResponseGetStoragePolicy(CFCachedURLResponseRef cachedResponse) {
    return cachedResponse->policy;
}

CFDictionaryRef CFCachedURLResponseGetUserInfo(CFCachedURLResponseRef cachedResponse) {
    return cachedResponse->userInfo;
}

size_t _CFCachedURLResponseGetDataSize(CFCachedURLResponseRef cachedResponse) {
    return cachedResponse->dataSize;
}

size_t _CFCachedURLResponseGetMemorySize(CFCachedURLResponseRef cachedResponse) {
    size_t result = 0;
    OSSpinLockLock(&cachedResponse->lock);
    {
        if (cachedResponse->data != 0) {
            result = cachedResponse->dataSize;
        }
    }
    OSSpinLockUnlock(&cachedResponse->lock);
    return result;
}

size_t _CFCachedURLResponseGetDiskSize(CFCachedURLResponseRef cachedResponse) {
    return (cachedResponse->policy == CFURLCacheStorageAllowed) ?
        cachedResponse->dataSize :
        0;
}

Boolean _CFCachedURLResponseClaimOwnership(CFCachedURLResponseRef cachedResponse,
                                           const void* owner) {
    if (!owner) {
        return false;
    }
    Boolean result = false;
    OSSpinLockLock(&cachedResponse->lock);
    {
        if (!cachedResponse->owner) {
            cachedResponse->owner = owner;
        }
        result = (cachedResponse->owner == owner);
    }
    OSSpinLockUnlock(&cachedResponse->lock);
    return result;
}

void _CFCachedURLResponseReleaseOwnership(CFCachedURLResponseRef cachedResponse,
                                          const void* owner)
{
    OSSpinLockLock(&cachedResponse->lock);
    {
        if (cachedResponse->owner == owner) {
            cachedResponse->owner = NULL;
        }
    }
    OSSpinLockUnlock(&cachedResponse->lock);
}

Boolean _CFCachedURLResponseSetDataPath(CFCachedURLResponseRef cachedResponse,
                                        const void* owner,
                                        CFStringRef dataPath)
{
    Boolean result = false;
    OSSpinLockLock(&cachedResponse->lock);
    do {
        if (!owner || cachedResponse->owner != owner) {
            break;
        }
        if (cachedResponse->policy != CFURLCacheStorageAllowed) {
            break;
        }

        if (_CFFSIsSamePath(cachedResponse->dataPath, dataPath)) {
            result = true;
            break;
        }

        CFDataRef data = NULL;
        result = loadCachedResponseData(cachedResponse, &data);
        if (!result) {
            break;
        }

        if (dataPath) {
            result = _CFFSWriteDataToFile(data, dataPath);
        } else {
            if (!cachedResponse->data) {
                cachedResponse->data = (CFDataRef)CFRetain(data);
            }
            result = true;
        }
        CFRelease(data);

        if (result) {
            if (cachedResponse->dataPath) {
                _CFFSUnlink(cachedResponse->dataPath);
                CFRelease(cachedResponse->dataPath);
            }
            if (dataPath) {
                cachedResponse->dataPath = (CFStringRef)CFRetain(dataPath);
            } else {
                cachedResponse->dataPath = NULL;
            }
        }
    } while (0);
    OSSpinLockUnlock(&cachedResponse->lock);
    return result;
}

Boolean _CFCachedURLResponseEvictFromMemory(CFCachedURLResponseRef cachedResponse,
                                            const void* owner)
{
    Boolean result = false;
    OSSpinLockLock(&cachedResponse->lock);
    do {
        if (!owner || cachedResponse->owner != owner) {
            break;
        }

        if (cachedResponse->dataPath) {
            if (cachedResponse->data) {
                CFRelease(cachedResponse->data);
                cachedResponse->data = NULL;
                result = true;
            }
        }
    } while(0);
    OSSpinLockUnlock(&cachedResponse->lock);
    return result;
}

Boolean _CFCachedURLResponseCacheToMemory(CFCachedURLResponseRef cachedResponse,
                                          const void* owner)
{
    Boolean result = false;
    OSSpinLockLock(&cachedResponse->lock);
    do {
        if (!owner || cachedResponse->owner != owner) {
            break;
        }

        if (cachedResponse->data) {
            result = true;
        } else {
            result = _CFFSCreateDataFromFile(&cachedResponse->data, cachedResponse->dataPath);
        }
    } while (0);
    OSSpinLockUnlock(&cachedResponse->lock);
    return result;
}


/* Private */

static Boolean loadCachedResponseData(CFCachedURLResponseRef cachedResponse, CFDataRef* data) {
    if (cachedResponse->data) {
        *data = (CFDataRef)CFRetain(cachedResponse->data);
        return true;
    } else {
        return _CFFSCreateDataFromFile(data, cachedResponse->dataPath);
    }
}
