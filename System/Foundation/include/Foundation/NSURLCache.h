#import <Foundation/NSObject.h>

typedef NS_ENUM(NSUInteger, NSURLCacheStoragePolicy) {
    NSURLCacheStorageAllowed,
    NSURLCacheStorageAllowedInMemoryOnly,
    NSURLCacheStorageNotAllowed,
};

@class NSData, NSDictionary, NSURLRequest, NSURLResponse;

@interface NSCachedURLResponse : NSObject <NSCoding, NSCopying>

- (id)initWithResponse:(NSURLResponse *)response data:(NSData *)data;
- (id)initWithResponse:(NSURLResponse *)response data:(NSData *)data userInfo:(NSDictionary *)userInfo storagePolicy:(NSURLCacheStoragePolicy)storagePolicy;
- (NSURLResponse *)response;
- (NSData *)data;
- (NSDictionary *)userInfo;
- (NSURLCacheStoragePolicy)storagePolicy;

@end

@interface NSURLCache : NSObject

+ (NSURLCache *)sharedURLCache;
+ (void)setSharedURLCache:(NSURLCache *)cache;
- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path;
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;
- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;
- (void)removeCachedResponseForRequest:(NSURLRequest *)request;
- (void)removeAllCachedResponses;
- (NSUInteger)memoryCapacity;
- (NSUInteger)diskCapacity;
- (void)setMemoryCapacity:(NSUInteger)memoryCapacity;
- (void)setDiskCapacity:(NSUInteger)diskCapacity;
- (NSUInteger)currentMemoryUsage;
- (NSUInteger)currentDiskUsage;

@end
