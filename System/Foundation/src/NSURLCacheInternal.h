#import <Foundation/NSURLCache.h>
#import <CFNetwork/CFURLCache.h>
#import <CFNetwork/CFCachedURLResponse.h>

@interface NSCachedURLResponse (Internal)
- (id)_initWithCFCachedURLResponse:(CFCachedURLResponseRef)response;
- (CFCachedURLResponseRef)_CFCachedURLResponse;
@end

@interface NSURLCache (Internal)
- (id)_initWithExistingSharedCFURLCache:(CFURLCacheRef)cache;
- (CFURLCacheRef)_CFURLCache;
@end
