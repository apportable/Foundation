//
//  NSCFURLSession.m
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCFURLSession.h"

#import <Foundation/NSData.h>
#import <Foundation/NSOperation.h>

@implementation __NSCFURLSessionConfiguration
@end

@implementation __NSCFURLSession

+ (NSURLSession *)sharedSession
{
    static dispatch_once_t once = 0L;
    static NSURLSession *sharedSession = nil;
    dispatch_once(&once, ^{
        sharedSession = (NSURLSession *)[[__NSCFURLSession alloc] initWithConfiguration:(NSURLSessionConfiguration *)[__NSCFURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    });
    return sharedSession;
}

+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
{
    return (NSURLSession *)[[[self alloc] initWithConfiguration:configuration delegate:nil delegateQueue:nil] autorelease];
}

+ (NSURLSession *)sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id <NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue
{
    return (NSURLSession *)[[[self alloc] initWithConfiguration:configuration delegate:delegate delegateQueue:queue] autorelease];
}

+ (void)_releaseProcessAssertionForSessionIdentifier:(NSString *)identifier
{
    // seems to be reserved for XPC stuff
}

+ (void)_sendPendingCallbacksForSessionIdentifier:(NSString *)identifier
{
    // seems to be reserved for XPC stuff
}

- (id)initWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id <NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self)
    {
        if (configuration == nil)
        {
            [self release];
            return nil;
        }
        _nsCFConfig = (__NSCFURLSessionConfiguration *)[configuration retain];
        _delegateQueue = [queue retain];
        _delegate = delegate;
    }
    return self;
}

- (void)delegate_didFinishEventsForBackgroundURLSession
{
    if ([self can_delegate_didFinishEventsForBackgroundURLSession])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)self];
        }];
    }
}

- (BOOL)can_delegate_didFinishEventsForBackgroundURLSession
{
    return [self.delegate respondsToSelector:@selector(URLSessionDidFinishEventsForBackgroundURLSession)];
}

- (void)delegate_downloadTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response
{
    if ([self can_delegate_downloadTask_didReceiveResponse])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self dataTask:task didReceiveResponse:response completionHandler:^(NSURLSessionResponseDisposition disposition){
            }];

        }];
    }
}

- (BOOL)can_delegate_downloadTask_didReceiveResponse
{
    return [self.delegate respondsToSelector:@selector(URLSession:downloadTask:didReceiveResponse:completionHandler:)];
}

- (void)delegate_downloadTask:(NSURLSessionDownloadTask *)task didResumeAtOffset:(int64_t)offset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    if ([self can_delegate_downloadTask_didResumeAtOffset])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self downloadTask:task didResumeAtOffset:offset expectedTotalBytes:expectedTotalBytes];
        }];
    }
}

- (BOOL)can_delegate_downloadTask_didResumeAtOffset
{
    return [self.delegate respondsToSelector:@selector(URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:)];
}

- (void)delegate_downloadTask:(NSURLSessionDownloadTask *)task didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if ([self can_delegate_downloadTask_didWriteData])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self downloadTask:task didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }];
    }
}

- (BOOL)can_delegate_downloadTask_didWriteData
{
    return [self.delegate respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)];
}

- (void)delegate_downloadTask:(NSURLSessionDownloadTask *)task didFinishDownloadingToURL:(NSURL *)location
{
    if ([self can_delegate_downloadTask_didFinishDownloadingToURL])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self downloadTask:task didFinishDownloadingToURL:location];
        }];
    }
}

- (BOOL)can_delegate_downloadTask_didFinishDownloadingToURL
{
    return [self.delegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)];
}

- (void)delegate_dataTask:(NSURLSessionTask *)task willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    if ([self can_delegate_dataTask_willCacheResponse])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self willCacheResponse:proposedResponse completionHandler:completionHandler];
        }];
    }
}

- (BOOL)can_delegate_dataTask_willCacheResponse
{
    return [self.delegate respondsToSelector:@selector(URLSession:dataTask:willCacheResponse:completionHandler:)];
}

- (void)delegate_dataTask:(NSURLSessionDataTask *)task didReceiveData:(NSData *)data
{
    if ([self can_delegate_dataTask_didReceiveData])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self dataTask:task didReceiveData:data];
        }];
    }
}

- (BOOL)can_delegate_dataTask_didReceiveData
{
    return [self.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)];
}

- (void)delegate_dataTask:(NSURLSessionDataTask *)task didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    if ([self can_delegate_dataTask_didBecomeDownloadTask])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self dataTask:task didBecomeDownloadTask:downloadTask];
        }];
    }
}

- (BOOL)can_delegate_dataTask_didBecomeDownloadTask
{
    return [self.delegate respondsToSelector:@selector(URLSession:dataTask:didBecomeDownloadTask:)];
}

- (void)delegate_dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if ([self can_delegate_dataTask_didReceiveResponse])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self dataTask:task didReceiveResponse:response completionHandler:completionHandler];
        }];
    }
}

- (BOOL)can_delegate_dataTask_didReceiveResponse
{
    return [self.delegate respondsToSelector:@selector(URLSession:dataTask:didReceiveResponse:completionHandler:)];
}

- (void)delegate_task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([self can_delegate_task_didCompleteWithError])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self task:task didCompleteWithError:error];
        }];
    }
}

- (BOOL)can_delegate_task_didCompleteWithError
{
    return [self.delegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)];
}

- (void)delegate_task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if ([self can_delegate_task_didSendBodyData])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
        }];
    }
}

- (BOOL)can_delegate_task_didSendBodyData
{
    return [self.delegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)];
}

- (void)delegate_task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    if ([self can_delegate_task_needNewBodyStream])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self task:task needNewBodyStream:completionHandler];
        }];
    }
}

- (BOOL)can_delegate_task_needNewBodyStream
{
    return [self.delegate respondsToSelector:@selector(URLSession:task:needNewBodyStream:)];
}

- (void)delegate_task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if ([self can_delegate_task_didReceiveChallenge])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self task:task didReceiveChallenge:challenge completionHandler:completionHandler];
        }];
    }
}

- (BOOL)can_delegate_task_didReceiveChallenge
{
    return [self.delegate respondsToSelector:@selector(URLSession:task:didReceiveChallenge:completionHandler:)];
}

- (void)delegate_task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    if ([self can_delegate_task_willPerformHTTPRedirection])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
        }];
    }
}

- (BOOL)can_delegate_task_willPerformHTTPRedirection
{
    return [self.delegate respondsToSelector:@selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:)];
}

- (void)delegate_didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    if ([self can_delegate_didReceiveChallenge])
    {
        [self addDelegateBLock:^{
            [self.delegate URLSession:(NSURLSession *)self didReceiveChallenge:challenge completionHandler:completionHandler];
        }];
    }
}

- (BOOL)can_delegate_didReceiveChallenge
{
    return [self.delegate respondsToSelector:@selector(URLSession:didReceiveChallenge:completionHandler:)];
}

- (void)addDelegateBlock:(void (^)(void))block
{
    [self.delegateQueue addOperationWithBlock:block];
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
{
    return [self downloadTaskWithResumeData:resumeData completionHandler:nil];
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *task = [[NSURLSessionDownloadTask alloc] initWithResumeData:resumeData completionHandler:completionHandler];

    return [task autorelease];
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url
{
    return [self downloadTaskWithURL:url completionHandler:nil];
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    return [self downloadTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
{
    return [self downloadTaskWithRequest:request completionHandler:nil];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSURLSessionDownloadTask *task = [[NSURLSessionDownloadTask alloc] initWithCompletionHandler:completionHandler];

    return [task autorelease];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL
{
    return [self uploadTaskWithRequest:request fromFile:fileURL completionHandler:nil];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    return [self uploadTaskWithRequest:request fromData:[NSData dataWithContentsOfURL:fileURL] completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData
{
    return [self uploadTaskWithRequest:request fromData:bodyData completionHandler:nil];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)bodyData completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSMutableURLRequest *uploadRequest = [request mutableCopy];
    [uploadRequest setHTTPBody:bodyData];
    NSURLSessionUploadTask *task = [[NSURLSessionUploadTask alloc] initWithRequest:uploadRequest completionHandler:completionHandler];
    [uploadRequest release];
    return [task autorelease];
}

- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
{
    return [self uploadTaskWithRequest:request fromData:nil completionHandler:nil];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
{
    return [self dataTaskWithRequest:request completionHandler:nil];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    return [[[NSURLSessionDataTask alloc] initWithRequest:request completionHandler:completionHandler] autorelease];
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
{
    return [self dataTaskWithURL:url completionHandler:nil];
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    return [self dataTaskWithRequest:request completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPGetRequest:(NSURL *)url
{
    return [self dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:nil];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPGetRequest:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    return [self dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:completionHandler];
}


@end
