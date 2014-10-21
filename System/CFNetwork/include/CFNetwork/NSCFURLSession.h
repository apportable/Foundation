#import <os/object.h>
#import <Foundation/NSURLSession.h>
#import <dispatch/dispatch.h>

@class NSOperationQueue, NSString, __NSCFSessionBridge;

__attribute__((visibility("hidden")))
@interface __NSCFURLSessionConfiguration : NSObject
@end

__attribute__((visibility("hidden")))
@interface __NSCFURLSession : NSObject {
    __NSCFURLSessionConfiguration *_nsCFConfig;
    BOOL _invalid;
    NSOperationQueue *_delegateQueue;
    id <NSURLSessionDelegate> _delegate;
    NSString *_sessionDescription;
    dispatch_queue_t _workQueue;
    __NSCFSessionBridge *_connectionSession;
    __NSCFURLSession *_extraRetain;
    NSOperationQueue *_realDelegateQueue;
}

@property(retain) NSOperationQueue *realDelegateQueue; // @synthesize realDelegateQueue=_realDelegateQueue;
@property(retain) __NSCFURLSession *extraRetain; // @synthesize extraRetain=_extraRetain;
@property BOOL invalid; // @synthesize invalid=_invalid;
@property(retain) __NSCFSessionBridge *connectionSession; // @synthesize connectionSession=_connectionSession;
@property(retain) dispatch_queue_t workQueue; // @synthesize workQueue=_workQueue;
@property(copy) NSString *sessionDescription; // @synthesize sessionDescription=_sessionDescription;
@property(readonly) id <NSURLSessionDelegate> delegate; // @synthesize delegate=_delegate;
@property(readonly) NSOperationQueue *delegateQueue; // @synthesize delegateQueue=_delegateQueue;
@property(copy) __NSCFURLSessionConfiguration *configuration;

+ (id)sessionWithConfiguration:(id)configuration delegate:(id)delegate delegateQueue:(id)delegateQueue;
+ (id)sessionWithConfiguration:(id)configuration;
+ (id)sharedSession;
+ (void)_releaseProcessAssertionForSessionIdentifier:(NSString *)identifier;
+ (void)_sendPendingCallbacksForSessionIdentifier:(NSString *)identifier;

// + (const struct ClassicConnectionSession *)defaultClassicConnectionSession;

- (id)initWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id <NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue;

- (void)delegate_didFinishEventsForBackgroundURLSession;
- (BOOL)can_delegate_didFinishEventsForBackgroundURLSession;
- (id)delegate_downloadTaskNeedsDownloadDirectory:(id)needsDownloadDirectory;
- (BOOL)can_delegate_downloadTaskNeedsDownloadDirectory;
- (void)delegate_downloadTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response;
- (BOOL)can_delegate_downloadTask_didReceiveResponse;
- (void)delegate_downloadTask:(NSURLSessionDownloadTask *)task didResumeAtOffset:(int64_t)offset expectedTotalBytes:(int64_t)expectedTotalBytes;
- (BOOL)can_delegate_downloadTask_didResumeAtOffset;
- (void)delegate_downloadTask:(NSURLSessionDownloadTask *)task didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
- (BOOL)can_delegate_downloadTask_didWriteData;
- (void)delegate_downloadTask:(NSURLSessionDownloadTask *)task didFinishDownloadingToURL:(NSURL *)location;
- (BOOL)can_delegate_downloadTask_didFinishDownloadingToURL;
- (void)delegate_dataTask:(NSURLSessionTask *)task willCacheResponse:(NSCachedURLResponse *)proposedResponse  completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler;
- (BOOL)can_delegate_dataTask_willCacheResponse;
- (void)delegate_dataTask:(NSURLSessionDataTask *)task didReceiveData:(NSData *)data;
- (BOOL)can_delegate_dataTask_didReceiveData;
- (void)delegate_dataTask:(NSURLSessionDataTask *)task didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (BOOL)can_delegate_dataTask_didBecomeDownloadTask;
- (void)delegate_dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler;
- (BOOL)can_delegate_dataTask_didReceiveResponse;
- (void)delegate_task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
- (BOOL)can_delegate_task_didCompleteWithError;
- (void)delegate_task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (BOOL)can_delegate_task_didSendBodyData;
- (void)delegate_task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler;
- (BOOL)can_delegate_task_needNewBodyStream;
- (void)delegate_task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
- (BOOL)can_delegate_task_didReceiveChallenge;
- (void)delegate_task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler;
- (BOOL)can_delegate_task_willPerformHTTPRedirection;
- (void)delegate_didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
- (BOOL)can_delegate_didReceiveChallenge;

- (void)addDelegateBlock:(void (^)(void))block;

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData;
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url;
- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request;
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData;
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url;
- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (NSURLSessionDataTask *)dataTaskWithHTTPGetRequest:(NSURL *)url;
- (NSURLSessionDataTask *)dataTaskWithHTTPGetRequest:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

- (void)getTasksWithCompletionHandler:(id)handler;
- (void)flushWithCompletionHandler:(id)handler;
- (void)resetWithCompletionHandler:(id)handler;
- (void)finishTasksAndInvalidate;
- (void)invalidateAndCancel;
- (void)_onqueue_completeInvalidation:(BOOL)completeInvalidation;
- (void)_onqueue_completeInvalidationFinal;
- (void)_onqueue_withTasks:(id)tasks;
- (BOOL)isBackgroundSession;
- (id)getConfiguration;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)zone;

@end
