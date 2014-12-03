//
//  CFURLCache.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFURLCache.h"
#include <CoreFoundation/CoreFoundation.h>
#include <libkern/OSAtomic.h>
#include "CFRuntime.h"
#include "CFCachedURLResponse.h"
#include "CFFSUtils.h"
#include "CFRuntimeUtils.h"
#include "CFMiscUtils.h"
#include <libkern/OSAtomic.h>
#include <objc/message.h>

typedef struct {
    CFRuntimeBase _base;
    CFStringRef requestKey;
    CFURLRequestRef request;
    CFCachedURLResponseRef cachedResponse;
    CFStringRef parcelPath;
    CFStringRef dataPath;
    CFAbsoluteTime creationTime;
    CFAbsoluteTime hitTime;
    CFIndex hitCount;
} CacheEntry;

typedef struct _CFURLCache {
    CFRuntimeBase _base;
    OSSpinLock lock;
    size_t memoryCapacity;
    size_t memoryUsage;
    size_t diskCapacity;
    size_t diskUsage;
    CFStringRef path;
    CFMutableSetRef entries;
    size_t disableLog;
    id nsCache;
} _CFURLCache;

static OSSpinLock sharedCacheLock = OS_SPINLOCK_INIT;
static CFURLCacheRef sharedCache = NULL;

static CFIndex const CacheEntryVersion = 1;
static CFStringRef const CacheEntryParcelFileExtension = CFSTR(".plist");
static CFStringRef const CacheEntryDataFileExtension = CFSTR(".data");

static CFPropertyListRef cachedResponseCreateParcel(CFCachedURLResponseRef);
static CFCachedURLResponseRef cachedResponseCreateFromParcel(CFPropertyListRef, CFStringRef);

static CFHashCode cacheEntryHash(CFTypeRef entryOrKey);
static Boolean cacheEntryEqual(CFTypeRef entryOrKey1, CFTypeRef entryOrKey2);
static CFComparisonResult cacheEntryEvictionSorter(CFTypeRef cf1, CFTypeRef cf2, void* context);
static CFPropertyListRef cacheEntryCreateParcel(CacheEntry*);
static CacheEntry* cacheEntryCreateFromParcel(CFStringRef);
static Boolean cacheEntryWriteParcel(CacheEntry*);

static CacheEntry* allocateCacheEntry(void);
static Boolean createCacheEntryPaths(_CFURLCache*, CacheEntry*);

static void loadCacheEntries(_CFURLCache*);

static void addCacheEntry(_CFURLCache*, CacheEntry*);
static void removeCacheEntry(_CFURLCache*, CacheEntry*);

static CFStringRef createKeyForRequest(CFURLRequestRef request);
static CacheEntry* findCacheEntryForRequest(_CFURLCache*, CFURLRequestRef);
static void removeCacheEntryForRequest(_CFURLCache*, CFURLRequestRef);

static void trimCacheEntries(_CFURLCache*);
static void evictCacheEntryFromMemory(_CFURLCache*, CacheEntry*);
static Boolean evictCacheEntriesToFitSize(_CFURLCache*, size_t, size_t);
static Boolean evictCacheEntriesToFitResponse(_CFURLCache*, CFCachedURLResponseRef);

static void cacheLog(_CFURLCache* cache, CFStringRef format, ...) CF_FORMAT_FUNCTION(2, 3);

static Boolean createNewFile(CFStringRef filePath);
static void deleteFileCallback(CFTypeRef fileName, void* path);
static Boolean isValidRequest(CFURLRequestRef request);

static id getRetainedNSCache(CFURLCacheRef cache);

/* Classes */

static void cacheDeallocate(CFTypeRef cf) {
    _CFURLCache *cache = (_CFURLCache*)cf;
    if (cache->path) {
        CFRelease(cache->path);
    }
    if (cache->entries) {
        CFRelease(cache->entries);
    }
}

static void cacheEntryDeallocate(CFTypeRef cf) {
    CacheEntry* entry = (CacheEntry*)cf;
    if (entry->requestKey) {
        CFRelease(entry->requestKey);
    }
    if (entry->request) {
        CFRelease(entry->request);
    }
    if (entry->cachedResponse) {
        CFRelease(entry->cachedResponse);
    }
    if (entry->dataPath) {
        CFRelease(entry->dataPath);
    }
    if (entry->parcelPath) {
        CFRelease(entry->parcelPath);
    }
}

static const CFRuntimeClass cacheClass = {
    .version = 0,
    .className = "CFURLCache",
    .finalize = &cacheDeallocate,
};

static const CFRuntimeClass cacheEntryClass = {
    .version = 0,
    .className = "CFURLCacheEntry",
    .finalize = &cacheEntryDeallocate,
};

static CFTypeID cacheTypeID = _kCFRuntimeNotATypeID;
static CFTypeID cacheEntryTypeID = _kCFRuntimeNotATypeID;


/* API */

CFTypeID CFURLCacheGetTypeID(void) {
    _CFRuntimeRegisterClassOnce(&cacheTypeID, &cacheClass);
    _CFRuntimeRegisterClassOnce(&cacheEntryTypeID, &cacheEntryClass);
    return cacheTypeID;
}

void CFURLCacheSetShared(CFURLCacheRef cache) {
    OSSpinLockLock(&sharedCacheLock);
    {
        if (sharedCache != cache) {
            if (sharedCache != NULL) {
                CFRelease(sharedCache);
            }
            if (cache) {
                sharedCache = (CFURLCacheRef)CFRetain(cache);
            } else {
                sharedCache = NULL;
            }
        }
    }
    OSSpinLockUnlock(&sharedCacheLock);
}

Boolean CFURLCacheGetShared(CFURLCacheRef* cache) {
    if (!cache) {
        return false;
    }
    OSSpinLockLock(&sharedCacheLock);
    {
        if (sharedCache) {
            *cache = (CFURLCacheRef)CFRetain(sharedCache);
        } else {
            *cache = NULL;
        }
    }
    OSSpinLockUnlock(&sharedCacheLock);
    return *cache != NULL;
}

CFURLCacheRef CFURLCacheCreate(CFAllocatorRef allocator, size_t memoryCapacity, size_t diskCapacity, CFStringRef path) {
    _CFURLCache* cache = (_CFURLCache*)_CFRuntimeCreateInstance(
        allocator,
        CFURLCacheGetTypeID(),
        sizeof(_CFURLCache) - sizeof(CFRuntimeBase),
        NULL);

    cache->memoryCapacity = memoryCapacity;
    cache->diskCapacity = diskCapacity;
    cache->entries = CFSetCreateMutable(kCFAllocatorDefault, 0, &(CFSetCallBacks){
        .version = 0,
        .retain = kCFTypeSetCallBacks.retain,
        .release = kCFTypeSetCallBacks.release,
        .copyDescription = kCFTypeSetCallBacks.copyDescription,
        .equal = &cacheEntryEqual,
        .hash = &cacheEntryHash
    });
    if (path) {
        cache->path = (CFStringRef)CFRetain(path);
        if (!_CFFSCheckCreateDirectory(path)) {
            CFRelease(cache);
            return NULL;
        }
    }

    cacheLog(cache, CFSTR("created with capacity = %zd:%zd bytes, path = '%@'"),
        memoryCapacity, diskCapacity, path);

    loadCacheEntries(cache);
    trimCacheEntries(cache);

    return cache;
}

size_t CFURLCacheMemoryCapacity(CFURLCacheRef cache) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        size_t result = (size_t)objc_msgSend(nsCache, sel_registerName("_cf_memoryCapacity"));
        CFRelease(nsCache);
        return result;
    } else {
        return _CFURLCacheMemoryCapacity(cache);
    }
}

size_t _CFURLCacheMemoryCapacity(CFURLCacheRef cache) {
    size_t result = 0;
    OSSpinLockLock(&cache->lock);
    {
        result = cache->memoryCapacity;
    }
    OSSpinLockUnlock(&cache->lock);
    return result;
}

void CFURLCacheSetMemoryCapacity(CFURLCacheRef cache, size_t capacity) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        objc_msgSend(nsCache, sel_registerName("_cf_setMemoryCapacity:"), capacity);
        CFRelease(nsCache);
    } else {
        _CFURLCacheSetMemoryCapacity(cache, capacity);
    }
}

void _CFURLCacheSetMemoryCapacity(CFURLCacheRef cache, size_t capacity) {
    OSSpinLockLock(&cache->lock);
    {
        cache->memoryCapacity = capacity;
        trimCacheEntries(cache);
    }
    OSSpinLockUnlock(&cache->lock);
}

size_t CFURLCacheCurrentMemoryUsage(CFURLCacheRef cache) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        size_t result = (size_t)objc_msgSend(nsCache, sel_registerName("_cf_currentMemoryUsage"));
        CFRelease(nsCache);
        return result;
    } else {
        return _CFURLCacheCurrentMemoryUsage(cache);
    }
}

size_t _CFURLCacheCurrentMemoryUsage(CFURLCacheRef cache) {
    size_t result = 0;
    OSSpinLockLock(&cache->lock);
    {
        result = cache->memoryUsage;
    }
    OSSpinLockUnlock(&cache->lock);
    return result;
}

size_t CFURLCacheDiskCapacity(CFURLCacheRef cache) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        size_t result = (size_t)objc_msgSend(nsCache, sel_registerName("_cf_diskCapacity"));
        CFRelease(nsCache);
        return result;
    } else {
        return _CFURLCacheDiskCapacity(cache);
    }
}

size_t _CFURLCacheDiskCapacity(CFURLCacheRef cache) {
    size_t result = 0;
    OSSpinLockLock(&cache->lock);
    {
        result = cache->diskCapacity;
    }
    OSSpinLockUnlock(&cache->lock);
    return result;
}

void CFURLCacheSetDiskCapacity(CFURLCacheRef cache, size_t capacity) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        objc_msgSend(nsCache, sel_registerName("_cf_setDiskCapacity:"), capacity);
        CFRelease(nsCache);
    } else {
        _CFURLCacheSetDiskCapacity(cache, capacity);
    }
}

void _CFURLCacheSetDiskCapacity(CFURLCacheRef cache, size_t capacity) {
    OSSpinLockLock(&cache->lock);
    {
        cache->diskCapacity = capacity;
        trimCacheEntries(cache);
    }
    OSSpinLockUnlock(&cache->lock);
}

size_t CFURLCacheCurrentDiskUsage(CFURLCacheRef cache) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        size_t result = (size_t)objc_msgSend(nsCache, sel_registerName("_cf_currentDiskUsage"));
        CFRelease(nsCache);
        return result;
    } else {
        return _CFURLCacheCurrentDiskUsage(cache);
    }
}

size_t _CFURLCacheCurrentDiskUsage(CFURLCacheRef cache) {
    size_t result = 0;
    OSSpinLockLock(&cache->lock);
    {
        result = cache->diskUsage;
    }
    OSSpinLockUnlock(&cache->lock);
    return result;
}

CFCachedURLResponseRef CFURLCacheCopyResponseForRequest(CFURLCacheRef cache,
                                                        CFURLRequestRef request)
{
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        CFCachedURLResponseRef result = (CFCachedURLResponseRef)objc_msgSend(nsCache,
                                                        sel_registerName("_cf_cachedResponseForRequest:"),
                                                        request);
        if (result) {
            CFRetain(result);
        }

        CFRelease(nsCache);
        return result;

    } else {
        return _CFURLCacheCopyResponseForRequest(cache, request);
    }
}

CFCachedURLResponseRef _CFURLCacheCopyResponseForRequest(CFURLCacheRef cache,
                                                         CFURLRequestRef request) {
    if (!isValidRequest(request)) {
        return NULL;
    }
    CFCachedURLResponseRef cachedResponse = NULL;
    OSSpinLockLock(&cache->lock);
    {
        CacheEntry* entry = findCacheEntryForRequest(cache, request);
        if (entry) {
            // TODO: match response's 'Vary' headers against request
            entry->hitTime = CFAbsoluteTimeGetCurrent();
            entry->hitCount++;
            cachedResponse = (CFCachedURLResponseRef)CFRetain(entry->cachedResponse);
        }
    }
    OSSpinLockUnlock(&cache->lock);
    return cachedResponse;
}

Boolean CFURLCacheAddCachedResponseForRequest(CFURLCacheRef cache,
                                              CFCachedURLResponseRef cachedResponse,
                                              CFURLRequestRef request)
{
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        Boolean result = (Boolean)objc_msgSend(nsCache,
                                               sel_registerName("_cf_storeCachedResponse:forCFRequest:"),
                                               cachedResponse,
                                               request);
        CFRelease(nsCache);
        return result;
    } else {
        return _CFURLCacheAddCachedResponseForRequest(cache, cachedResponse, request);
    }
}

Boolean _CFURLCacheAddCachedResponseForRequest(CFURLCacheRef cache,
                                               CFCachedURLResponseRef cachedResponse,
                                               CFURLRequestRef request)
{
    if (!isValidRequest(request)) {
        return false;
    }
    Boolean result = false;
    CacheEntry* entry = NULL;
    OSSpinLockLock(&cache->lock);
    do {
        removeCacheEntryForRequest(cache, request);

        if (!evictCacheEntriesToFitResponse(cache, cachedResponse)) {
            break;
        }

        if (!_CFCachedURLResponseClaimOwnership(cachedResponse, cache)) {
            break;
        }

        CacheEntry* entry = allocateCacheEntry();
        entry->creationTime = CFAbsoluteTimeGetCurrent();
        entry->request = CFURLRequestCreateCopy(kCFAllocatorDefault, request);
        entry->cachedResponse = (CFCachedURLResponseRef)CFRetain(cachedResponse);

        CFCachedURLStoragePolicy policy = CFCachedURLResponseGetStoragePolicy(cachedResponse);
        if (policy == CFURLCacheStorageAllowed) {
            if (!createCacheEntryPaths(cache, entry)) {
                break;
            }
            if (!cacheEntryWriteParcel(entry)) {
                break;
            }
            if (!_CFCachedURLResponseSetDataPath(cachedResponse, cache, entry->dataPath)) {
                break;
            }

            size_t memorySize = _CFCachedURLResponseGetMemorySize(cachedResponse);
            if (cache->memoryUsage + memorySize > cache->memoryCapacity &&
                !_CFCachedURLResponseEvictFromMemory(cachedResponse, cache))
            {
                break;
            }
        }

        addCacheEntry(cache, entry);

        result = true;
    } while (false);
    OSSpinLockUnlock(&cache->lock);
    if (!result) {
        _CFCachedURLResponseSetDataPath(cachedResponse, cache, NULL);
        _CFCachedURLResponseReleaseOwnership(cachedResponse, cache);
        if (entry) {
            if (entry->parcelPath) {
                _CFFSUnlink(entry->parcelPath);
            }
            if (entry->dataPath) {
                _CFFSUnlink(entry->dataPath);
            }
        }
    }
    if (entry) {
        CFRelease(entry);
    }

    return result;
}

void CFURLCacheRemoveCachedResponseForRequest(CFURLCacheRef cache,
                                              CFURLRequestRef request)
{
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        objc_msgSend(nsCache, sel_registerName("_cf_removeCachedResponseForRequest:"), request);
        CFRelease(nsCache);
    } else {
        _CFURLCacheRemoveCachedResponseForRequest(cache, request);
    }
}

void _CFURLCacheRemoveCachedResponseForRequest(CFURLCacheRef cache,
                                               CFURLRequestRef request)
{
    if (!isValidRequest(request)) {
        return;
    }
    OSSpinLockLock(&cache->lock);
    {
        removeCacheEntryForRequest(cache, request);
    }
    OSSpinLockUnlock(&cache->lock);
}

void CFURLCacheRemoveAllCachedResponses(CFURLCacheRef cache) {
    id nsCache = getRetainedNSCache(cache);
    if (nsCache) {
        objc_msgSend(nsCache, sel_registerName("_cf_removeAllCachedResponses"));
        CFRelease(nsCache);
    } else {
        _CFURLCacheRemoveAllCachedResponses(cache);
    }
}

void _CFURLCacheRemoveAllCachedResponses(CFURLCacheRef cache) {
    OSSpinLockLock(&cache->lock);
    {
        CFIndex count = CFSetGetCount(cache->entries);
        CFTypeRef* entries = (CFTypeRef*)malloc(count * sizeof(CFTypeRef));
        if (entries) {
            CFSetGetValues(cache->entries, entries);

            cache->disableLog++;
            for (CFIndex i = 0; i != count; ++i) {
                removeCacheEntry(cache, (CacheEntry*)entries[i]);
            }
            cache->disableLog--;

            assert(!cache->diskUsage);
            assert(!cache->memoryUsage);

            free(entries);
        }

        cacheLog(cache, CFSTR("all entries removed"));
    }
    OSSpinLockUnlock(&cache->lock);
}

void _CFURLCacheSetNSCache(CFURLCacheRef cache, void *nsCache) {
    OSSpinLockLock(&cache->lock);
    {
        assert(!cache->nsCache || !nsCache);
        cache->nsCache = (id)nsCache;
    }
    OSSpinLockUnlock(&cache->lock);
}

/* Private */

static id getRetainedNSCache(CFURLCacheRef cache) {
    id result = NULL;
    OSSpinLockLock(&cache->lock);
    {
        if (cache->nsCache)
        {
            result = (id)CFRetain(cache->nsCache);
        }
    }
    OSSpinLockUnlock(&cache->lock);
    return result;
}

static CFPropertyListRef cachedResponseCreateParcel(CFCachedURLResponseRef cachedResponse) {
    CFMutableDictionaryRef parcel = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    do {
        CFURLResponseRef response = CFCachedURLResponseGetResponse(cachedResponse);
        CFPropertyListRef subParcel = _CFURLResponseCreateParcel(response);
        if (!subParcel) {
            break;
        }
        CFDictionarySetValue(parcel, CFSTR("response"), subParcel);
        CFRelease(subParcel);

        PARCEL_SET_OBJECT(
            parcel,
            CFCachedURLResponseGetUserInfo(cachedResponse), "userInfo");

        PARCEL_SET_ENUM(
            parcel,
            CFCachedURLResponseGetStoragePolicy(cachedResponse), "storagePolicy");

        return parcel;
    } while (0);

    CFRelease(parcel);
    return NULL;
}

static CFCachedURLResponseRef cachedResponseCreateFromParcel(CFPropertyListRef rawParcel,
                                                             CFStringRef dataPath)
{
    if (CFGetTypeID(rawParcel) != CFDictionaryGetTypeID()) {
        return NULL;
    }
    CFDictionaryRef parcel = (CFDictionaryRef)rawParcel;

    CFCachedURLResponseRef cachedResponse = NULL;
    CFURLResponseRef response = NULL;
    CFDictionaryRef userInfo = NULL;
    do {
        CFPropertyListRef subParcel = CFDictionaryGetValue(parcel, CFSTR("response"));
        if (subParcel) {
            response = _CFURLResponseCreateFromParcel(kCFAllocatorDefault, subParcel);
        }
        if (!response) {
            break;
        }

        PARCEL_GET_RETAINED_OBJECT(parcel, CFDictionary, userInfo, "userInfo");

        CFCachedURLStoragePolicy storagePolicy = CFURLCacheStorageNotAllowed;
        PARCEL_GET_ENUM(parcel, storagePolicy, "storagePolicy");

        cachedResponse = CFCachedURLResponseCreate(
            kCFAllocatorDefault,
            response, dataPath, userInfo, storagePolicy);
    }
    while (0);
    if (response) {
        CFRelease(response);
    }
    if (userInfo) {
        CFRelease(userInfo);
    }

    return cachedResponse;
}

static CFHashCode cacheEntryHash(CFTypeRef entryOrKey) {
    if (CFGetTypeID(entryOrKey) == cacheEntryTypeID) {
        entryOrKey = ((CacheEntry*)entryOrKey)->requestKey;
    } else {
        assert(CFGetTypeID(entryOrKey) == CFStringGetTypeID());
    }
    return CFHash(entryOrKey);
}

static Boolean cacheEntryEqual(CFTypeRef entryOrKey1, CFTypeRef entryOrKey2) {
    if (CFGetTypeID(entryOrKey1) == cacheEntryTypeID) {
        entryOrKey1 = ((CacheEntry*)entryOrKey1)->requestKey;
    } else {
        assert(CFGetTypeID(entryOrKey1) == CFStringGetTypeID());
    }
    if (CFGetTypeID(entryOrKey2) == cacheEntryTypeID) {
        entryOrKey2 = ((CacheEntry*)entryOrKey2)->requestKey;
    } else {
        assert(CFGetTypeID(entryOrKey2) == CFStringGetTypeID());
    }
    return CFEqual(entryOrKey1, entryOrKey2);
}

static CFComparisonResult cacheEntryEvictionSorter(CFTypeRef cf1, CFTypeRef cf2, void* context) {
    const CacheEntry* entry1 = (const CacheEntry*)cf1;
    const CacheEntry* entry2 = (const CacheEntry*)cf2;

    CFAbsoluteTime time1 = entry1->hitTime ? entry1->hitTime : entry1->creationTime;
    CFAbsoluteTime time2 = entry2->hitTime ? entry2->hitTime : entry2->creationTime;

    if (time1 > time2) {
        return kCFCompareGreaterThan;
    } else if (time1 < time2) {
        return kCFCompareLessThan;
    } else {
        return kCFCompareEqualTo;
    }
}

static CFPropertyListRef cacheEntryCreateParcel(CacheEntry* entry) {
    CFMutableDictionaryRef parcel = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    do {
        PARCEL_SET_CFINDEX(parcel, CacheEntryVersion, "version");

        PARCEL_SET_OBJECT(parcel, entry->dataPath, "dataPath");
        PARCEL_SET_TIME(parcel, entry->creationTime, "creationTime");
        PARCEL_SET_TIME(parcel, entry->hitTime, "hitTime");
        PARCEL_SET_CFINDEX(parcel, entry->hitCount, "hitCount");

        CFPropertyListRef subParcel = _CFURLRequestCreateParcel(entry->request);
        if (!subParcel) {
            break;
        }
        CFDictionarySetValue(parcel, CFSTR("request"), subParcel);
        CFRelease(subParcel);

        subParcel = cachedResponseCreateParcel(entry->cachedResponse);
        if (!subParcel) {
            break;
        }
        CFDictionarySetValue(parcel, CFSTR("cachedResponse"), subParcel);
        CFRelease(subParcel);

        return parcel;
    }
    while (0);

    CFRelease(parcel);
    return NULL;
}

static CacheEntry* cacheEntryCreateFromParcel(CFStringRef parcelPath) {
    CFPropertyListRef rawParcel = NULL;
    if (!_CFFSCreatePropertyListFromFile(&rawParcel, parcelPath)) {
        return false;
    }

    Boolean success = false;
    CacheEntry* entry = NULL;
    do {
        if (CFGetTypeID(rawParcel) != CFDictionaryGetTypeID()) {
            break;
        }
        CFDictionaryRef parcel = (CFDictionaryRef)rawParcel;

        entry = allocateCacheEntry();

        CFIndex version = 0;
        PARCEL_GET_CFINDEX(parcel, version, "version");
        if (version != CacheEntryVersion) {
            break;
        }

        PARCEL_GET_RETAINED_OBJECT(parcel, CFString, entry->dataPath, "dataPath");
        PARCEL_GET_TIME(parcel, entry->creationTime, "creationTime");
        PARCEL_GET_TIME(parcel, entry->hitTime, "hitTime");
        PARCEL_GET_CFINDEX(parcel, entry->hitCount, "hitCount");

        CFPropertyListRef subParcel = CFDictionaryGetValue(parcel, CFSTR("request"));
        if (subParcel) {
            entry->request = _CFURLRequestCreateFromParcel(kCFAllocatorDefault, subParcel);
        }

        subParcel = CFDictionaryGetValue(parcel, CFSTR("cachedResponse"));
        if (subParcel) {
            entry->cachedResponse = cachedResponseCreateFromParcel(subParcel, entry->dataPath);
        }

        if (!entry->request || !entry->dataPath || !entry->cachedResponse) {
            break;
        }

        entry->parcelPath = (CFStringRef)CFRetain(parcelPath);
        success = true;
    } while (0);
    CFRelease(rawParcel);
    if (!success && entry) {
        CFRelease(entry);
        entry = NULL;
    }

    return entry;
}

static Boolean cacheEntryWriteParcel(CacheEntry* entry) {
    CFPropertyListRef parcel = cacheEntryCreateParcel(entry);
    if (!parcel) {
        return false;
    }
    Boolean result = _CFFSWritePropertyListToFile(parcel, entry->parcelPath);
    CFRelease(parcel);
    return result;
}

static CacheEntry* allocateCacheEntry(void) {
    return (CacheEntry*)_CFRuntimeCreateInstance(
        kCFAllocatorDefault,
        cacheEntryTypeID,
        sizeof(CacheEntry) - sizeof(CFRuntimeBase),
        NULL);
}

static Boolean createCacheEntryPaths(_CFURLCache* cache, CacheEntry* entry) {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);

    CFStringRef parcelFileName = CFStringCreateWithFormat(
        kCFAllocatorDefault,
        NULL,
        CFSTR("%@%@"), uuidString, CacheEntryParcelFileExtension);
    CFStringRef dataFileName = CFStringCreateWithFormat(
        kCFAllocatorDefault,
        NULL,
        CFSTR("%@%@"), uuidString, CacheEntryDataFileExtension);
    CFRelease(uuidString);

    CFStringRef parcelPath = NULL;
    CFStringRef dataPath = NULL;

    _CFFSAppendPathComponent(&parcelPath, cache->path, parcelFileName);
    _CFFSAppendPathComponent(&dataPath, cache->path, dataFileName);
    CFRelease(parcelFileName);
    CFRelease(dataFileName);

    Boolean result = false;
    if (createNewFile(parcelPath)) {
        if (!createNewFile(dataPath)) {
            _CFFSUnlink(parcelPath);
        } else {
            entry->parcelPath = parcelPath;
            entry->dataPath = dataPath;
            result = true;
        }
    }
    if (!result) {
        CFRelease(parcelPath);
        CFRelease(dataPath);
    }

    return result;
}

static void loadCacheEntries(_CFURLCache* cache) {
    CFMutableArrayRef files = NULL;
    if (!_CFFSListPathContents(cache->path, &files, NULL)) {
        return;
    }

    CFMutableSetRef filesToDelete = CFSetCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeSetCallBacks);
    for (CFIndex i = 0; i != CFArrayGetCount(files); ++i) {
        CFSetAddValue(filesToDelete, CFArrayGetValueAtIndex(files, i));
    }

    cache->disableLog++;
    for (CFIndex i = 0; i != CFArrayGetCount(files); ++i) {
        CFStringRef fileName = (CFStringRef)CFArrayGetValueAtIndex(files, i);
        if (!CFStringHasSuffix(fileName, CacheEntryParcelFileExtension)) {
            continue;
        }

        CFStringRef parcelPath;
        _CFFSAppendPathComponent(&parcelPath, cache->path, fileName);
        CacheEntry* entry = cacheEntryCreateFromParcel(parcelPath);
        CFRelease(parcelPath);
        if (!entry) {
            continue;
        }

        if (!_CFCachedURLResponseClaimOwnership(entry->cachedResponse, cache)) {
            CFRelease(entry);
            continue;
        }

        addCacheEntry(cache, entry);
        CFSetRemoveValue(filesToDelete, fileName);

        if (entry->dataPath) {
            CFStringRef dataFileName = NULL;
            _CFFSGetLastPathComponent(&dataFileName, entry->dataPath);
            CFSetRemoveValue(filesToDelete, dataFileName);
            CFRelease(dataFileName);
        }
        CFRelease(entry);
    }
    cache->disableLog--;

    cacheLog(cache, CFSTR("loaded %ld entries"), CFSetGetCount(cache->entries));

    CFSetApplyFunction(filesToDelete, &deleteFileCallback, (void*)cache->path);

    CFRelease(files);
    CFRelease(filesToDelete);
}

static void addCacheEntry(_CFURLCache* cache, CacheEntry* entry) {
    size_t memorySize = _CFCachedURLResponseGetMemorySize(entry->cachedResponse);
    size_t diskSize = _CFCachedURLResponseGetDiskSize(entry->cachedResponse);

    cache->memoryUsage += memorySize;
    cache->diskUsage += diskSize;

    assert(!entry->requestKey);
    entry->requestKey = createKeyForRequest(entry->request);

    CFSetSetValue(cache->entries, entry);

    cacheLog(cache, CFSTR("added '%@' (%zd:%zd bytes)"),
        CFURLRequestGetURL(entry->request), memorySize, diskSize);
}

static void removeCacheEntry(_CFURLCache* cache, CacheEntry* entry) {
    size_t memorySize = _CFCachedURLResponseGetMemorySize(entry->cachedResponse);
    size_t diskSize = _CFCachedURLResponseGetDiskSize(entry->cachedResponse);

    cache->memoryUsage -= memorySize;
    cache->diskUsage -= diskSize;

    if (entry->parcelPath) {
        _CFFSUnlink(entry->parcelPath);
    }

    _CFCachedURLResponseSetDataPath(entry->cachedResponse, cache, NULL);
    if (entry->dataPath) {
        _CFFSUnlink(entry->dataPath);
    }

    _CFCachedURLResponseReleaseOwnership(entry->cachedResponse, cache);
    cacheLog(cache, CFSTR("removing '%@' (%zd:%zd bytes)"),
        CFURLRequestGetURL(entry->request), memorySize, diskSize);
    CFSetRemoveValue(cache->entries, entry->requestKey);
}

static CFStringRef createKeyForRequest(CFURLRequestRef request) {
    CFURLRef url = CFURLCopyAbsoluteURL(CFURLRequestGetURL(request));
    CFStringRef method = CFURLRequestCopyHTTPMethod(request);
    CFStringRef key = CFStringCreateWithFormat(
        kCFAllocatorDefault,
        NULL, CFSTR("%@ %@"), method, CFURLGetString(url));
    if (method) {
        CFRelease(method);
    }
    CFRelease(url);
    return key;
}

static CacheEntry* findCacheEntryForRequest(_CFURLCache* cache, CFURLRequestRef request) {
    CFStringRef requestKey = createKeyForRequest(request);
    CacheEntry* entry = (CacheEntry*)CFSetGetValue(cache->entries, requestKey);
    CFRelease(requestKey);
    return entry;
}

static void removeCacheEntryForRequest(_CFURLCache* cache, CFURLRequestRef request) {
    CacheEntry* entry = findCacheEntryForRequest(cache, request);
    if (entry) {
        removeCacheEntry(cache, entry);
    }
}

static void trimCacheEntries(_CFURLCache* cache) {
    evictCacheEntriesToFitSize(cache, 0, 0);
}

static void evictCacheEntryFromMemory(_CFURLCache* cache, CacheEntry* entry) {
    size_t size = _CFCachedURLResponseGetMemorySize(entry->cachedResponse);
    if (_CFCachedURLResponseEvictFromMemory(entry->cachedResponse, cache)) {
        cache->memoryUsage -= size;

        cacheLog(cache, CFSTR("evicted '%@' from memory (%zd bytes)"),
            CFURLRequestGetURL(entry->request), size);
    }
}

static Boolean evictCacheEntriesToFitSize(_CFURLCache* cache,
                                          size_t memorySize, size_t diskSize)
{
    if (memorySize > cache->memoryCapacity || diskSize > cache->diskCapacity) {
        // No way it can fit
        return false;
    }

    Boolean evictFromMemory = (cache->memoryUsage + memorySize > cache->memoryCapacity);
    Boolean evictFromDisk = (cache->diskUsage + diskSize > cache->diskCapacity);

    if (!evictFromMemory && !evictFromDisk) {
        return true;
    }

    CFMutableArrayRef rankedEntries;
    {
        CFIndex count = CFSetGetCount(cache->entries);

        rankedEntries = CFArrayCreateMutable(kCFAllocatorDefault, count, &kCFTypeArrayCallBacks);

        CFTypeRef* values = (CFTypeRef*)malloc(count * sizeof(CFTypeRef));
        CFSetGetValues(cache->entries, values);
        for (CFIndex i = 0; i != count; ++i) {
            CFArrayAppendValue(rankedEntries, values[i]);
        }
        free(values);

        CFArraySortValues(rankedEntries, CFRangeMake(0, count), &cacheEntryEvictionSorter, NULL);
    }

    if (evictFromMemory) {
        for (CFIndex i = 0; i != CFArrayGetCount(rankedEntries); ++i) {
            CacheEntry* entry = (CacheEntry*)CFArrayGetValueAtIndex(rankedEntries, i);
            evictCacheEntryFromMemory(cache, entry);
            if (cache->memoryUsage + memorySize <= cache->memoryCapacity) {
                evictFromMemory = false;
                break;
            }
        }
    }

    if (evictFromMemory || evictFromDisk) {
        for (CFIndex i = 0; i != CFArrayGetCount(rankedEntries);) {
            CacheEntry* entry = (CacheEntry*)CFArrayGetValueAtIndex(rankedEntries, i);

            Boolean removeEntry = false;
            if (evictFromMemory &&
                _CFCachedURLResponseGetMemorySize(entry->cachedResponse) > 0)
            {
                removeEntry = true;
            }
            if (evictFromDisk &&
                _CFCachedURLResponseGetDiskSize(entry->cachedResponse) > 0)
            {
                removeEntry = true;
            }
            if (!removeEntry) {
                ++i;
                continue;
            }

            removeCacheEntry(cache, entry);
            CFArrayRemoveValueAtIndex(rankedEntries, i);
            entry = NULL;

            if (cache->memoryUsage + memorySize <= cache->memoryCapacity) {
                evictFromMemory = false;
            }
            if (cache->diskUsage + diskSize <= cache->diskCapacity) {
                evictFromDisk = false;
            }
            if (!evictFromMemory && !evictFromDisk) {
                break;
            }
        }
    }

    assert(!evictFromMemory);
    assert(!evictFromDisk);

    CFRelease(rankedEntries);
    return true;
}

static Boolean evictCacheEntriesToFitResponse(_CFURLCache* cache,
                                              CFCachedURLResponseRef cachedResponse)
{
    CFCachedURLStoragePolicy policy = CFCachedURLResponseGetStoragePolicy(cachedResponse);

    if (policy == CFURLCacheStorageNotAllowed) {
        return false;
    }

    return evictCacheEntriesToFitSize(
        cache,
        (policy == CFURLCacheStorageAllowedInMemoryOnly) ?
            _CFCachedURLResponseGetMemorySize(cachedResponse) : 0,
        (policy == CFURLCacheStorageAllowed) ?
            _CFCachedURLResponseGetDiskSize(cachedResponse) : 0);
}

static void cacheLog(_CFURLCache* cache, CFStringRef format, ...) {
    if (cache->disableLog != 0) {
        return;
    }

    va_list arguments;
    va_start(arguments, format);
    CFStringRef message = CFStringCreateWithFormatAndArguments(
        kCFAllocatorDefault,
        NULL, format, arguments);
    va_end(arguments);

    CFIndex cmessageLength = 1 + CFStringGetMaximumSizeForEncoding(
        CFStringGetLength(message),
        kCFStringEncodingUTF8);
    char cmessage[cmessageLength];
    if (CFStringGetCString(message, cmessage, cmessageLength, kCFStringEncodingUTF8)) {
        size_t memoryUsage = cache->memoryCapacity ?
            (cache->memoryUsage * 100 / cache->memoryCapacity) :
            0;
        size_t diskUsage = cache->diskCapacity ?
            cache->diskUsage * 100 / cache->diskCapacity :
            0;
#ifdef APPORTABLE
    #ifndef NDEBUG
        // DEBUG_LOG() includes too much noisy stuff (like file / function name)
        RELEASE_LOG("CFURLCache[%%%zd:%zd]: %s", memoryUsage, diskUsage, cmessage);
    #endif
#else
        printf("CFURLCache[%%%zd:%zd]: %s\n", memoryUsage, diskUsage, cmessage);
#endif
    }
    CFRelease(message);
}

static Boolean createNewFile(CFStringRef filePath) {
    int fd = _CFFSOpen(filePath, O_CREAT | O_WRONLY | O_EXCL, 0644);
    if (fd == -1) {
        return false;
    }
    close(fd);
    return true;
}

static void deleteFileCallback(CFTypeRef fileName, void* path) {
    CFStringRef filePath;
    _CFFSAppendPathComponent(&filePath, (CFStringRef)path, (CFStringRef)fileName);
    _CFFSUnlink(filePath);
    CFRelease(filePath);
}

static Boolean isValidRequest(CFURLRequestRef request) {
    return CFURLRequestGetURL(request) != NULL;
}
