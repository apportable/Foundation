#import <Foundation/NSObject.h>

@class NSArray, NSURL, NSCachedURLResponse, NSData, NSError;
@class NSURLAuthenticationChallenge, NSURLRequest, NSURLResponse;
@class NSRunLoop, NSInputStream, NSURLProtectionSpace, NSOperationQueue;

@protocol NSURLConnectionDelegate;

@interface NSURLConnection : NSObject

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate;
+ (BOOL)canHandleRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate;
- (NSURLRequest *)originalRequest;
- (NSURLRequest *)currentRequest;
- (void)start;
- (void)cancel;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)setDelegateQueue:(NSOperationQueue*)queue;

@end

@protocol NSURLConnectionDelegate <NSObject>
@optional

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@protocol NSURLConnectionDataDelegate <NSURLConnectionDelegate>
@optional

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end

@protocol NSURLConnectionDownloadDelegate <NSURLConnectionDelegate>
@optional

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;
- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes;

@required

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL;

@end

@interface NSURLConnection (NSURLConnectionSynchronousLoading)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

@end

#if NS_BLOCKS_AVAILABLE
@interface NSURLConnection (NSURLConnectionQueuedLoading)

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *)) handler;
@end
#endif
