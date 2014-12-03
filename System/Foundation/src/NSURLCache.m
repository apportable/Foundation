//
//  NSURLCache.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSURLCacheInternal.h"
#import "NSURLResponseInternal.h"
#import "NSURLRequestInternal.h"
#import <Foundation/NSException.h>
#import <Foundation/NSData.h>
#import <Foundation/NSPathUtilities.h>

static NSUInteger NSURLCacheDefaultMemoryCapacity = 512000;
static NSUInteger NSURLCacheDefaultDiskCapacity = 10000000;

@implementation NSCachedURLResponse {
    NSURLResponse* _response;
    CFCachedURLResponseRef _cachedResponseRef;
}

- (id)initWithResponse:(NSURLResponse*)response data:(NSData*)data
{
    return [self initWithResponse:response data:data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
}

- (id)initWithResponse:(NSURLResponse*)response data:(NSData*)data userInfo:(NSDictionary*)userInfo storagePolicy:(NSURLCacheStoragePolicy)storagePolicy
{
    CFCachedURLResponseRef cachedResponse = CFCachedURLResponseCreate(
        kCFAllocatorDefault,
        response._CFURLResponse,
        (CFDataRef)data,
        (CFDictionaryRef)userInfo,
        (CFCachedURLStoragePolicy)storagePolicy);
    self = [self _initWithCFCachedURLResponse:cachedResponse];
    if (self)
    {
        _response = [response retain];
    }
    if (cachedResponse)
    {
        CFRelease(cachedResponse);
    }
    return self;
}

- (id)_initWithCFCachedURLResponse:(CFCachedURLResponseRef)cachedResponse
{
    NSAssert([self class] == [NSCachedURLResponse class], @"Subclassing of NSCachedURLResponse is not supported");

    if (!cachedResponse)
    {
        [self release];
        return nil;
    }
    self = [super init];
    if (self)
    {
        _cachedResponseRef = (CFCachedURLResponseRef)CFRetain(cachedResponse);
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone
{
    return [self retain];
}

- (void)dealloc
{
    [_response release];
    CFRelease(_cachedResponseRef);
    [super dealloc];
}

- (id)initWithCoder:(NSCoder*)coder
{
    NSAssert(NO, @"not implemented");
    [self release];
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    NSAssert(NO, @"not implemented");
}

- (CFCachedURLResponseRef)_CFCachedURLResponse
{
    return _cachedResponseRef;
}

- (NSURLResponse*)response
{
    if (!_response)
    {
        CFURLResponseRef response = CFCachedURLResponseGetResponse(_cachedResponseRef);
        if (CFURLResponseIsHTTPResponse(response)) {
            _response = [[NSHTTPURLResponse _responseWithCFURLResponse:response] retain];
        } else {
            _response = [[NSURLResponse _responseWithCFURLResponse:response] retain];
        }
    }
    return _response;
}

- (NSData*)data
{
    CFDataRef data = NULL;
    CFCachedURLResponseLoadData(_cachedResponseRef, &data);
    NSAssert(data, @"Cached URL response data is not available");
    return [(NSData*)data autorelease];
}

- (NSDictionary*)userInfo
{
    return (NSDictionary*)CFCachedURLResponseGetUserInfo(_cachedResponseRef);
}

- (NSURLCacheStoragePolicy)storagePolicy
{
    return (NSURLCacheStoragePolicy)CFCachedURLResponseGetStoragePolicy(_cachedResponseRef);
}

@end

@implementation NSURLCache {
    CFURLCacheRef _cacheRef;
}

static NSURLCache* sharedURLCache = nil;
static Boolean sharedURLCacheSet = false;

+ (void)setSharedURLCache:(NSURLCache*)cache
{
    @synchronized(self)
    {
        if (sharedURLCache != cache)
        {
            [sharedURLCache release];
            sharedURLCache = [cache retain];
            CFURLCacheSetShared(sharedURLCache._CFURLCache);
            sharedURLCacheSet = true;
        }
    }
}

+ (NSURLCache*)sharedURLCache
{
    NSURLCache* cache;
    @synchronized(self)
    {
        cache = [sharedURLCache retain];

        // Hack to default initialize NSURLCache
        if (!cache && !sharedURLCacheSet) {
            cache = [[NSURLCache alloc] init];
            [self setSharedURLCache:cache];
        }
    }
    return [cache autorelease];
}

- (id)init
{
    return [self initWithMemoryCapacity:NSURLCacheDefaultMemoryCapacity diskCapacity:NSURLCacheDefaultDiskCapacity diskPath:nil];
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString*)path
{
    // Calculate full path for the cache.
    NSString* cachePath;
    {
        const char* cacheDir = getenv("CACHEDIR");
        if (!cacheDir)
        {
            // Memory caching only
            cachePath = nil;
        }
        else
        {
            NSString* basePath = [[NSString stringWithUTF8String:cacheDir] stringByAppendingPathComponent:@"NSURLCache"];
            if (path)
            {
                // Discard everything but the last component from the 'path' argument.
                cachePath = [basePath stringByAppendingPathComponent:[path lastPathComponent]];
            }
            else
            {
                // Nil 'path' means "default cache location"
                cachePath = basePath;
            }
        }
    }

    CFURLCacheRef cache = CFURLCacheCreate(kCFAllocatorDefault, memoryCapacity, diskCapacity, (CFStringRef)cachePath);
    if (!cache) {
        [self release];
        return nil;
    }

    self = [self _initWithExistingSharedCFURLCache:cache];
    if (self) {
        _CFURLCacheSetNSCache(cache, self);
    }
    CFRelease(cache);
    return self;
}

- (id)_initWithExistingSharedCFURLCache:(CFURLCacheRef)cache
{
    self = [super init];
    if (self)
    {
        _cacheRef = (CFURLCacheRef)CFRetain(cache);
    }
    return self;
}

- (void)dealloc
{
    _CFURLCacheSetNSCache(_cacheRef, NULL);
    CFRelease(_cacheRef);
    [super dealloc];
}

- (CFURLCacheRef)_CFURLCache
{
    return _cacheRef;
}

- (NSUInteger)memoryCapacity
{
    return _CFURLCacheMemoryCapacity(_cacheRef);
}

- (NSUInteger)_cf_memoryCapacity
{
    return [self memoryCapacity];
}

- (void)setMemoryCapacity:(NSUInteger)capacity
{
    _CFURLCacheSetMemoryCapacity(_cacheRef, capacity);
}

- (void)_cf_setMemoryCapacity:(NSUInteger)capacity
{
    [self setMemoryCapacity:capacity];
}

- (NSUInteger)diskCapacity
{
    return _CFURLCacheDiskCapacity(_cacheRef);
}

- (NSUInteger)_cf_diskCapacity
{
    return [self diskCapacity];
}

- (void)setDiskCapacity:(NSUInteger)capacity
{
    _CFURLCacheSetDiskCapacity(_cacheRef, capacity);
}

- (void)_cf_setDiskCapacity:(NSUInteger)capacity
{
    [self setDiskCapacity:capacity];
}

- (NSUInteger)currentMemoryUsage
{
    return _CFURLCacheCurrentMemoryUsage(_cacheRef);
}

- (NSUInteger)_cf_currentMemoryUsage
{
    return [self currentMemoryUsage];
}

- (NSUInteger)currentDiskUsage
{
    return _CFURLCacheCurrentDiskUsage(_cacheRef);
}

- (NSUInteger)_cf_currentDiskUsage
{
    return [self currentDiskUsage];
}

- (NSCachedURLResponse*)cachedResponseForRequest:(NSURLRequest*)request
{
    CFCachedURLResponseRef cachedResponse = _CFURLCacheCopyResponseForRequest(_cacheRef, request._CFURLRequest);
    if (!cachedResponse)
    {
        return nil;
    }
    NSCachedURLResponse* cached = [[[NSCachedURLResponse alloc] _initWithCFCachedURLResponse:cachedResponse] autorelease];
    CFRelease(cachedResponse);
    return cached;
}

- (CFCachedURLResponseRef)_cf_cachedResponseForRequest:(CFURLRequestRef)cfRequest
{
    NSURLRequest *request = [[[NSURLRequest alloc] _initWithCFURLRequest:cfRequest] autorelease];
    return [self cachedResponseForRequest:request]._CFCachedURLResponse;
}

- (void)storeCachedResponse:(NSCachedURLResponse*)cachedResponse forRequest:(NSURLRequest*)request
{
    _CFURLCacheAddCachedResponseForRequest(_cacheRef, cachedResponse._CFCachedURLResponse, request._CFURLRequest);
}

- (Boolean)_cf_storeCachedResponse:(CFCachedURLResponseRef)cfCachedResponse forCFRequest:(CFURLRequestRef)cfRequest
{
    NSCachedURLResponse *cachedResponse = [[[NSCachedURLResponse alloc] _initWithCFCachedURLResponse:cfCachedResponse] autorelease];
    NSURLRequest *request = [[[NSURLRequest alloc] _initWithCFURLRequest:cfRequest] autorelease];
    [self storeCachedResponse:cachedResponse forRequest:request];
    return true;
}

- (void)removeCachedResponseForRequest:(NSURLRequest*)request
{
    _CFURLCacheRemoveCachedResponseForRequest(_cacheRef, request._CFURLRequest);
}

- (void)_cf_removeCachedResponseForRequest:(CFURLRequestRef)cfRequest
{
    NSURLRequest *request = [[[NSURLRequest alloc] _initWithCFURLRequest:cfRequest] autorelease];
    [self removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses
{
    _CFURLCacheRemoveAllCachedResponses(_cacheRef);
}

- (void)_cf_removeAllCachedResponses
{
    [self removeAllCachedResponses];
}

@end
