#import <Foundation/NSObject.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSHTTPCookieStorage.h>

#include <Security/SecureTransport.h>

typedef NS_ENUM(NSInteger, NSURLSessionTaskState) {
    NSURLSessionTaskStateRunning = 0,
    NSURLSessionTaskStateSuspended = 1,
    NSURLSessionTaskStateCanceling = 2,
    NSURLSessionTaskStateCompleted = 3,
};

typedef NS_ENUM(NSInteger, NSURLSessionAuthChallengeDisposition) {
    NSURLSessionAuthChallengeUseCredential = 0,
    NSURLSessionAuthChallengePerformDefaultHandling = 1,
    NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,
    NSURLSessionAuthChallengeRejectProtectionSpace = 3,
};

typedef NS_ENUM(NSInteger, NSURLSessionResponseDisposition) {
    NSURLSessionResponseCancel = 0,
    NSURLSessionResponseAllow = 1,
    NSURLSessionResponseBecomeDownload = 2,
};

@class NSArray, NSCachedURLResponse, NSData, NSDictionary, NSError;
@class NSHTTPCookie, NSHTTPURLResponse, NSInputStream, NSOperationQueue;
@class NSString, NSURL, NSURLAuthenticationChallenge, NSURLCache;
@class NSURLCredential, NSURLCredentialStorage, NSURLProtectionSpace;
@class NSURLResponse, NSURLSession, NSURLSessionConfiguration;
@class NSURLSessionTask, NSURLSessionDataTask, NSURLSessionDownloadTask;
@class NSURLSessionUploadTask;

@protocol NSURLSessionDelegate <NSObject>
@optional

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error;
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session;

@end

@protocol NSURLSessionTaskDelegate <NSURLSessionDelegate>
@optional

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end

@protocol NSURLSessionDataDelegate <NSURLSessionTaskDelegate>
@optional

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse  completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler;

@end

@protocol NSURLSessionDownloadDelegate <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;

@end

FOUNDATION_EXPORT const int64_t NSURLSessionTransferSizeUnknown;
FOUNDATION_EXPORT NSString * const NSURLSessionDownloadTaskResumeData;

@interface NSURLSession : NSObject

@property (readonly, retain) NSOperationQueue *delegateQueue;
@property (readonly, retain) id <NSURLSessionDelegate> delegate;
@property (readonly, copy) NSURLSessionConfiguration *configuration;
@property (copy) NSString *sessionDescription;

+ (NSURLSession *)sharedSession;
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration;
+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id <NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue;
- (void)finishTasksAndInvalidate;
- (void)invalidateAndCancel;
- (void)resetWithCompletionHandler:(void (^)(void))completionHandler;
- (void)flushWithCompletionHandler:(void (^)(void))completionHandler;
- (void)getTasksWithCompletionHandler:(void (^)(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request;
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData;
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request;
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url;
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData;

@end

@interface NSURLSession (NSURLSessionAsynchronousConvenience)

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSURL *location, NSURLResponse *response, NSError *error))completionHandler;

@end

@interface NSURLSessionTask : NSObject <NSCopying>

@property (readonly) NSUInteger taskIdentifier;
@property (readonly, copy) NSURLRequest *originalRequest;
@property (readonly, copy) NSURLRequest *currentRequest;
@property (readonly, copy) NSURLResponse *response;
@property (readonly) int64_t countOfBytesReceived;
@property (readonly) int64_t countOfBytesSent;
@property (readonly) int64_t countOfBytesExpectedToSend;
@property (readonly) int64_t countOfBytesExpectedToReceive;
@property (copy) NSString *taskDescription;
@property (readonly) NSURLSessionTaskState state;
@property (readonly, copy) NSError *error;

- (void)cancel;
- (void)suspend;
- (void)resume;

@end

@interface NSURLSessionDataTask : NSURLSessionTask
@end

@interface NSURLSessionUploadTask : NSURLSessionDataTask
@end

@interface NSURLSessionDownloadTask : NSURLSessionTask

- (void)cancelByProducingResumeData:(void (^)(NSData *resumeData))completionHandler;

@end

@interface NSURLSessionConfiguration : NSObject <NSCopying>

+ (NSURLSessionConfiguration *)defaultSessionConfiguration;
+ (NSURLSessionConfiguration *)ephemeralSessionConfiguration;
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration:(NSString *)identifier;

@property (readonly, copy) NSString *identifier;
@property NSURLRequestCachePolicy requestCachePolicy;
@property NSTimeInterval timeoutIntervalForRequest;
@property NSTimeInterval timeoutIntervalForResource;
@property NSURLRequestNetworkServiceType networkServiceType;
@property BOOL allowsCellularAccess;
@property (getter=isDiscretionary) BOOL discretionary;
@property BOOL sessionSendsLaunchEvents;
@property (copy) NSDictionary *connectionProxyDictionary;
@property SSLProtocol TLSMinimumSupportedProtocol;
@property SSLProtocol TLSMaximumSupportedProtocol;
@property BOOL HTTPShouldUsePipelining;
@property BOOL HTTPShouldSetCookies;
@property NSHTTPCookieAcceptPolicy HTTPCookieAcceptPolicy;
@property (copy) NSDictionary *HTTPAdditionalHeaders;
@property NSInteger HTTPMaximumConnectionsPerHost;
@property (retain) NSHTTPCookieStorage *HTTPCookieStorage;
@property (retain) NSURLCredentialStorage *URLCredentialStorage;
@property (retain) NSURLCache *URLCache;
@property (copy) NSArray *protocolClasses;

@end

@interface NSURLSession (NSURLSessionDeprecated)

/* Use -dataTaskWithURL: instead */
- (NSURLSessionDataTask *)dataTaskWithHTTPGetRequest:(NSURL *)url;

/* Use -dataTaskWithURL:completionHandler: instead */
- (NSURLSessionDataTask *)dataTaskWithHTTPGetRequest:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

@end

