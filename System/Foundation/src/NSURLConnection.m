//
//  NSURLConnection.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSURLConnection.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSURLCredential.h>
#import <Foundation/NSURLRequest.h>
#import <Foundation/NSURLResponse.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSOperation.h>
#import <Foundation/NSURLProtocol.h>
#import "NSURLAuthenticationChallengeInternal.h"
#import "NSURLConnectionInternal.h"
#import "NSURLProtectionSpaceInternal.h"
#import "NSURLProtocolInternal.h"
#import "NSURLRequestInternal.h"
#import "NSURLResponseInternal.h"
#import "NSURLCacheInternal.h"
#import "NSObjectInternal.h"
#import <CFNetwork/CFURLConnection.h>
#import <CoreFoundation/CFData.h>
#import <Foundation/NSURLError.h>

@implementation NSURLConnectionInternal

- (void)_callBlock:(void(^)(void))block async:(BOOL)async
{
    if (_delegateQueue == nil) {
        block();
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
        [_delegateQueue addOperation:operation];
        if (!async) {
            [operation waitUntilFinished];
        }
    }
}

static Boolean canAuth(const void *info, CFURLProtectionSpaceRef cfspace)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return false;
    }

    NSURLProtectionSpace *space = [[NSURLProtectionSpace alloc] _initWithCFURLProtectionSpace:cfspace];
    __block Boolean canAuth = false;
    void (^canAuthBlock)(void) = ^{
        BOOL auth = [connectionInternal->_delegate connection:connectionInternal->_connection canAuthenticateAgainstProtectionSpace:space];
        canAuth = auth ? true : false;
        [space release];
    };
    if (connectionInternal->_delegateQueue == nil) {
        canAuthBlock();
    } else {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:canAuthBlock];
        [connectionInternal->_delegateQueue addOperation:op];
        [op waitUntilFinished];
    }
    return canAuth;
}

static void cancelledAuthChallenge(const void *info, CFURLAuthChallengeRef cfchallenge)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    NSURLAuthenticationChallenge *challenge = [[NSURLAuthenticationChallenge alloc] _initWithCFAuthChallenge:cfchallenge sender:connectionInternal];
    void (^cancelBlock)(void) = ^{
        [connectionInternal->_delegate connection:connectionInternal->_connection didCancelAuthenticationChallenge:challenge];
        [challenge release];
    };
    if (connectionInternal->_delegateQueue == nil) {
        cancelBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:cancelBlock];
    }
}

static void failed(const void *info, CFErrorRef cferror)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    NSError *error = (NSError *)cferror;
    void (^failBlock)(void) = ^{
        [connectionInternal->_delegate connection:connectionInternal->_connection didFailWithError:error];
    };
    if (connectionInternal->_delegateQueue == nil) {
        failBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:failBlock];
    }

    // invalidating here should be okay even for the block operation
    // because the delegate and _connection are retained by the block.
    [connectionInternal _invalidate];

}

static void receivedAuthChallenge(const void *info, CFURLAuthChallengeRef cfchallenge)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    NSURLAuthenticationChallenge *challenge = [[NSURLAuthenticationChallenge alloc] _initWithCFAuthChallenge:cfchallenge sender:connectionInternal];
    void (^receiveBlock)(void) = ^{
        [connectionInternal->_delegate connection:connectionInternal->_connection didReceiveAuthenticationChallenge:challenge];
        [challenge release];
    };
    if (connectionInternal->_delegateQueue == nil) {
        receiveBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:receiveBlock];
    }
}

static void sendRequestForAuthChallenge(const void *info, CFURLAuthChallengeRef cfchallenge)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    NSURLAuthenticationChallenge *challenge = [[NSURLAuthenticationChallenge alloc] _initWithCFAuthChallenge:cfchallenge sender:connectionInternal];
    void (^sendBlock)(void) = ^{
        [connectionInternal->_delegate connection:connectionInternal->_connection willSendRequestForAuthenticationChallenge:challenge];
        [challenge release];
    };
    if (connectionInternal->_delegateQueue == nil) {
        sendBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:sendBlock];
    }
}

static Boolean useCredentialStorage(const void *info)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return false;
    }

    __block Boolean useStorage = false;
    void (^storeBlock)(void) = ^{
        BOOL store = [connectionInternal->_delegate connectionShouldUseCredentialStorage:connectionInternal->_connection];
        useStorage = store ? true : false;
    };
    if (connectionInternal->_delegateQueue == nil) {
        storeBlock();
    } else {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:storeBlock];
        [connectionInternal->_delegateQueue addOperation:op];
        [op waitUntilFinished];
    }
    return useStorage;
}

static CFURLRequestRef redirect(const void *info, CFURLRequestRef request, CFURLResponseRef response) {
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return NULL;
    }

    __block NSURLRequest *redirection = nil;
    void (^redirectBlock)(void) = ^{
        @autoreleasepool {
            NSURLRequest *urlRequest = [[NSURLRequest alloc] _initWithCFURLRequest:request];
            NSHTTPURLResponse *urlResponse = [NSHTTPURLResponse _responseWithCFURLResponse:response];
            redirection = [[connectionInternal->_delegate connection:connectionInternal->_connection willSendRequest:urlRequest redirectResponse:urlResponse] retain];
            [urlRequest release];
        }
    };
    if (connectionInternal->_delegateQueue == nil) {
        redirectBlock();
    } else {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:redirectBlock];
        [connectionInternal->_delegateQueue addOperation:op];
        [op waitUntilFinished];
    }
    CFURLRequestRef result = [[redirection autorelease] _CFURLRequest];
    
    if (result != NULL)
    {
        return CFRetain(result);
    }
    else
    {
        return NULL;
    }
}

static void response(const void *info, CFURLResponseRef response) {
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    void (^responseBlock)(void) = ^{
        @autoreleasepool {
            NSHTTPURLResponse *urlResponse = [NSHTTPURLResponse _responseWithCFURLResponse:response];
            [connectionInternal->_delegate connection:connectionInternal->_connection didReceiveResponse:urlResponse];
        }
    };
    if (connectionInternal->_delegateQueue == nil) {
        responseBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:responseBlock];
    }
}

static void data(const void *info, CFDataRef cfdata) {
    NSData *data = (NSData *)cfdata;
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    void (^dataBlock)(void) = ^{
        [connectionInternal->_delegate connection:connectionInternal->_connection didReceiveData:(NSData *)data];
    };
    if (connectionInternal->_delegateQueue == nil) {
        dataBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:dataBlock];
    }
}

static CFReadStreamRef newBodyStream(const void *info, CFURLRequestRef request) {
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return NULL;
    }

    __block CFReadStreamRef stream = nil;
    NSURLRequest *urlRequest = [[NSURLRequest alloc] _initWithCFURLRequest:request];
    void (^newBodyStreamBlock)(void) = ^{
        stream = (CFReadStreamRef)[connectionInternal->_delegate connection:connectionInternal->_connection needNewBodyStream:urlRequest];
        [urlRequest release];
    };
    if (connectionInternal->_delegateQueue == nil) {
        newBodyStreamBlock();
    } else {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:newBodyStreamBlock];
        [connectionInternal->_delegateQueue addOperation:op];
        [op waitUntilFinished];
    }
    return stream;
}

static Boolean handledByProtocol(const void *info)
{
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || !connectionInternal->_protocol) {
        return false;
    }

    [connectionInternal->_protocol startLoading];
    [connectionInternal->_protocol stopLoading];
    return true;
}

static void sent(const void *info, CFIndex bytesWritten, CFIndex totalBytesWritten, CFIndex totalBytesExpectedToWrite) {
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    void (^sentBlock)(void) = ^{
        [connectionInternal->_delegate connection:connectionInternal->_connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite];
    };
    if (connectionInternal->_delegateQueue == nil) {
        sentBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:sentBlock];
    }
}

static void finished(const void *info) {
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return;
    }

    void (^finishedBlock)(void) = ^{
        [connectionInternal->_delegate connectionDidFinishLoading:connectionInternal->_connection];
    };
    if (connectionInternal->_delegateQueue == nil) {
        finishedBlock();
    } else {
        [connectionInternal->_delegateQueue addOperationWithBlock:finishedBlock];
    }

    [connectionInternal _invalidate];
}

static CFCachedURLResponseRef cache(const void *info, CFCachedURLResponseRef cachedResponse) {
    NSURLConnectionInternal *connectionInternal = [(_NSWeakRef *)info object];
    if (!connectionInternal || ![connectionInternal isConnectionActive]) {
        return NULL;
    }

    __block NSCachedURLResponse* response = nil;
    [connectionInternal _callBlock:^{
        response = [[[NSCachedURLResponse alloc] _initWithCFCachedURLResponse:cachedResponse] autorelease];
        response = [connectionInternal->_delegate connection:connectionInternal->_connection
                                           willCacheResponse:response];
    } async:NO];
    return response._CFCachedURLResponse;
}

- (id)initWithInfo:(const struct InternalInit *)info
{
    // Initialize NSURLCache
    [NSURLCache sharedURLCache];

    self = [super init];
    if (self)
    {
        _connection = info->connection;
        _originalRequest = [info->request copy]; // this should be a deep copy?
        _delegate = info->delegate;
        _delegateQueue = info->queue;
        _scheduledInRunLoop = NO;
        _connectionProperties = [[NSMutableDictionary alloc] init];

        CFURLConnectionContext ctx = {
            .version = 0,
            .info = self,
            .retain = NULL,
            .release = NULL,
            .copyDescription = &CFCopyDescription,
            .equal = &CFEqual,
            .hash = &CFHash,
        };
        ctx.handledByProtocol = &handledByProtocol;
        if ([_delegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)])
        {
            ctx.canAuth = &canAuth;
        }
        if ([_delegate respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)])
        {
            ctx.cancelledAuthChallenge = &cancelledAuthChallenge;
        }
        if ([_delegate respondsToSelector:@selector(connection:didFailWithError:)])
        {
            ctx.failed = &failed;
        }
        if ([_delegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)])
        {
            ctx.receivedAuthChallenge = &receivedAuthChallenge;
        }
        if ([_delegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)])
        {
            ctx.sendRequestForAuthChallenge = &sendRequestForAuthChallenge;
        }
        if ([_delegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)])
        {
            ctx.useCredentialStorage = &useCredentialStorage;
        }

        _cfurlconnection = CFURLConnectionCreate(kCFAllocatorDefault, [_originalRequest _CFURLRequest], &ctx);
        CFURLConnectionHandlerContext handler = {
            .info = [[[_NSWeakRef alloc] initWithObject:self] autorelease],
            .retain = &CFRetain,
            .release = &CFRelease
        };
        if ([_delegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
        {
            handler.redirect = &redirect;
        }
        if ([_delegate respondsToSelector:@selector(connection:didReceiveResponse:)])
        {
            handler.response = &response;
        }
        if ([_delegate respondsToSelector:@selector(connection:didReceiveData:)])
        {
            handler.data = &data;
        }
        if ([_delegate respondsToSelector:@selector(connection:needNewBodyStream:)])
        {
            handler.newBodyStream = &newBodyStream;
        }
        if ([_delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
        {
            handler.sent = &sent;
        }
        if ([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
        {
            handler.finished = &finished;
        }
        if ([_delegate respondsToSelector:@selector(connection:willCacheResponse:)])
        {
            handler.cache = &cache;
        }

        NSArray *registeredProtocols = [NSURLProtocol _registeredClasses];
        for (Class protocolClass in registeredProtocols) {
            if ([protocolClass canInitWithRequest:_originalRequest]) {
                NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:_originalRequest];
                NSURLRequest *requestForProtocol = [protocolClass canonicalRequestForRequest:_originalRequest];
                NSURLProtocolDefaultClient *client = [[NSURLProtocolDefaultClient alloc] init];
                client.connection = _connection;
                client.delegate = _delegate;
                NSURLProtocol *protocol = [[protocolClass alloc] initWithRequest:requestForProtocol cachedResponse:cachedResponse client:client];
                _protocol = [protocol retain];
                [client release];
                [protocol release];
                break;
            }
        }


        CFURLConnectionSetHandler(_cfurlconnection, &handler);
        if (info->startImmediately)
        {
            [self scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [self start];
        }
    }
    return self;
}

- (void)dealloc
{
    [_originalRequest release];
    [_protocol release];
    CFRelease(_cfurlconnection);
    [super dealloc];
}

- (void)_invalidate
{
    @synchronized (self) {
        if (_connectionActive) {
            _connectionActive = NO;
            [_delegate autorelease];
            [_connection release];
            _connection = nil;
            [self autorelease];
        }
    }
}

- (BOOL)isConnectionActive
{
    return _connectionActive;
}

- (void)setConnectionActive:(BOOL)active
{
    _connectionActive = active;
}

- (void)_setDelegateQueue:(NSOperationQueue *)queue
{
    _delegateQueue = queue;
}

- (NSURLRequest *)currentRequest
{
    return _currentRequest;
}

- (NSURLRequest *)originalRequest
{
    return _originalRequest;
}

- (NSDictionary *)_connectionProperties
{
    return _connectionProperties;
}

- (void)start
{
    if (!_connectionActive && _connection) {
        _connectionActive = YES;
        _delegate = [_delegate retain];
        _connection = [_connection retain];
        [self retain];
        if(!_scheduledInRunLoop)
        {
            [self scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        
        CFURLConnectionStart(_cfurlconnection);
    }
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    CFURLConnectionScheduleWithRunLoop(_cfurlconnection, [aRunLoop getCFRunLoop], (CFStringRef)mode);
    _scheduledInRunLoop = YES;
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    CFURLConnectionUnscheduleFromRunLoop(_cfurlconnection, [aRunLoop getCFRunLoop], (CFStringRef)mode);
    _scheduledInRunLoop = NO;
}

- (void)cancel
{
    [self _invalidate];

    CFURLConnectionCancel(_cfurlconnection);
}

@end

@implementation NSURLConnection {
    NSURLConnectionInternal *_internal;
}

+ (NSURLConnection*)connectionWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate
{
    return [[[NSURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:YES] autorelease];
}

+ (BOOL)canHandleRequest:(NSURLRequest *)request
{
    if ([[NSURLProtocol _registeredClasses] count] == 0) {
        return YES;
    }
    else {
        return [NSURLProtocol _protocolClassForRequest:request] != Nil;
    }
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate startImmediately:(BOOL)startImmediately
{
    self = [super init];
    if (self)
    {
        struct InternalInit info = {
            self,
            request,
            (id<NSURLConnectionDataDelegate>)delegate,
            nil,
            startImmediately,
            0
        };
        _internal = [[NSURLConnectionInternal alloc] initWithInfo:&info];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate
{
    return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

- (void)dealloc
{
    [_internal release];
    [super dealloc];
}

- (NSURLRequest *)originalRequest
{
    return [_internal originalRequest];
}

- (NSURLRequest *)currentRequest
{
    return [_internal currentRequest];
}

- (void)start
{
    [_internal start];
}

- (void)cancel
{
    [_internal cancel];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [_internal scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [_internal unscheduleFromRunLoop:aRunLoop forMode:mode];
}

- (void)setDelegateQueue:(NSOperationQueue*)queue
{
    [_internal _setDelegateQueue:queue];
}

@end

@implementation NSURLConnection (NSURLConnectionSynchronousLoading)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    if ([request URL] == nil)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
        }

        return nil;
    }

    CFDataRef data = NULL;
    CFErrorRef err = NULL;
    CFMutableURLRequestRef req = CFURLRequestCreateMutableCopy(kCFAllocatorDefault, [request _CFURLRequest]);
    CFURLResponseRef resp = NULL;
    if (!CFURLConnectionSendSynchronousRequest(req, &data, &resp, &err))
    {
        if (error)
        {
            *error = [[(NSError *)err retain] autorelease];
        }
        if (data != NULL)
        {
            CFRelease(data);
        }
        data = NULL;
    }
    if (response)
    {
        *response = resp ? [NSHTTPURLResponse _responseWithCFURLResponse:resp] : NULL;
    }
    if (resp != NULL)
    {
        CFRelease(resp);
    }
    if (err != NULL)
    {
        CFRelease(err);
    }
    CFRelease(req);
    return [(NSData *)data autorelease];
}

@end

@implementation NSURLConnection (NSURLConnectionQueuedLoading)

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    if ([request URL] == nil)
    {
        if (handler)
        {
            handler(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]);
        }

        return;
    }

    CFMutableURLRequestRef req = CFURLRequestCreateMutableCopy(kCFAllocatorDefault, [request _CFURLRequest]);
    CFURLConnectionSendAsynchronousRequest(req, ^(CFURLResponseRef response, CFDataRef data, CFErrorRef error) {
        NSURLResponse *resp = [NSHTTPURLResponse _responseWithCFURLResponse:response];
        NSData *d = (NSData *)data;
        NSError *err = (NSError *)error;
        [queue addOperationWithBlock:^{
            handler(resp, d, err);
        }];
    });
    CFRelease(req);
}

@end
