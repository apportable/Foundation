#import <Foundation/NSURLConnection.h>
#import <Foundation/NSURLAuthenticationChallenge.h>
#import "NSURLProtocolInternal.h"
#import <CFNetwork/CFURLConnection.h>

@class NSMutableDictionary;
@class NSMutableArray;

struct InternalInit {
    NSURLConnection *connection;
    NSURLRequest *request;
    id<NSURLConnectionDataDelegate> delegate;
    NSOperationQueue *queue;
    BOOL startImmediately;
    long long _field6;
};

@protocol NSURLConnectionRequired <NSObject>

@optional

- (void)_setShouldSkipCancelOnRelease:(BOOL)shouldSkip;
- (void)_resumeLoading;
- (void)_suspendLoading;
- (void)_setDelegateQueue:(NSOperationQueue *)queue;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)cancel;
- (void)start;

@end

CF_PRIVATE
@interface NSURLConnectionInternal : NSObject <NSURLConnectionRequired, NSURLAuthenticationChallengeSender> {
    NSURLConnection *_connection;
    NSOperationQueue *_delegateQueue;
    BOOL _scheduledInRunLoop;
    NSURL *_url;
    NSURLRequest *_originalRequest;
    NSURLRequest *_currentRequest;
    id<NSURLConnectionDataDelegate> _delegate;
    NSMutableDictionary *_connectionProperties;
    BOOL _connectionActive;
    CFURLConnectionRef _cfurlconnection;
    NSURLProtocol *_protocol;
}

- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)invokeForDelegate:(id<NSURLConnectionDelegate>)delegate;
- (void)_invalidate;
- (BOOL)isConnectionActive;
- (void)setConnectionActive:(BOOL)active;
- (void)_setDelegateQueue:(NSOperationQueue *)queue;
- (NSURLRequest *)currentRequest;
- (NSURLRequest *)originalRequest;
- (NSDictionary *)_connectionProperties;
- (void)dealloc;
- (id)initWithInfo:(const struct InternalInit *)info;

@end
