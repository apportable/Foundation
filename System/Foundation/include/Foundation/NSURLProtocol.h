#import <Foundation/NSObject.h>
#import <Foundation/NSURLCache.h>

@class NSCachedURLResponse, NSError, NSMutableURLRequest, NSURLAuthenticationChallenge;
@class NSURLConnection, NSURLProtocol, NSURLRequest, NSURLResponse;

@protocol NSURLProtocolClient <NSObject>

- (void)URLProtocol:(NSURLProtocol *)protocol wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
- (void)URLProtocol:(NSURLProtocol *)protocol cachedResponseIsValid:(NSCachedURLResponse *)cachedResponse;
- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveResponse:(NSURLResponse *)response cacheStoragePolicy:(NSURLCacheStoragePolicy)policy;
- (void)URLProtocol:(NSURLProtocol *)protocol didLoadData:(NSData *)data;
- (void)URLProtocolDidFinishLoading:(NSURLProtocol *)protocol;
- (void)URLProtocol:(NSURLProtocol *)protocol didFailWithError:(NSError *)error;
- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)URLProtocol:(NSURLProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@interface NSURLProtocol : NSObject

+ (BOOL)canInitWithRequest:(NSURLRequest *)request;
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request;
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b;
+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request;
+ (void)setProperty:(id)value forKey:(NSString *)key inRequest:(NSMutableURLRequest *)request;
+ (void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURLRequest *)request;
+ (BOOL)registerClass:(Class)protocolClass;
+ (void)unregisterClass:(Class)protocolClass;
- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client;
- (id <NSURLProtocolClient>)client;
- (NSURLRequest *)request;
- (NSCachedURLResponse *)cachedResponse;
- (void)startLoading;
- (void)stopLoading;

@end
