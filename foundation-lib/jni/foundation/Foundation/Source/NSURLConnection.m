/* Implementation for NSURLConnection for GNUstep
   Copyright (C) 2006 Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2006

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
 */

#import "common.h"

#define EXPOSE_NSURLConnection_IVARS  1
#import "Foundation/NSRunLoop.h"
#import "GSURLPrivate.h"
#import "GSPrivate.h"
#import "Foundation/NSInvocation.h"
#import "Foundation/NSURLConnection.h"
#import "Foundation/NSThread.h"
#import "Foundation/NSOperation.h"
#import <pthread.h>

NSString* const _NSURLConnectionPrivateRunLoopMode = @"_NSURLConnectionPrivateRunLoopMode";

@interface _NSURLConnectionDataCollector : NSObject
{
    NSURLConnection   *_connection; // Not retained
    NSMutableData     *_data;
    NSError       *_error;
    NSURLResponse     *_response;
    BOOL _done;
}

- (NSData*)data;
- (BOOL)done;
- (NSError*)error;
- (NSURLResponse*)response;
- (void)setConnection:(NSURLConnection *)c;

@end

@interface NSURLProtocol (Private_NSURLConnection)
- (void)startLoading:(NSRunLoop *)rl forMode:(NSString *)mode;
- (void)setRequest:(NSURLRequest *)req;
@end

@implementation _NSURLConnectionDataCollector

- (void)dealloc
{
    [_data release];
    [_error release];
    [_response release];
    [super dealloc];
}

- (BOOL)done
{
    return _done;
}

- (NSData*)data
{
    return _data;
}

- (NSError*)error
{
    return _error;
}

- (NSURLResponse*)response
{
    return _response;
}

- (void)setConnection:(NSURLConnection*)c
{
    _connection = c;
}

- (void)connection:(NSURLConnection *)connection
    didFailWithError:(NSError *)error
{
    ASSIGN(_error, error);
    _done = YES;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveResponse:(NSURLResponse*)response
{
    ASSIGN(_response, response);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _done = YES;
}


- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    if (nil == _data)
    {
        _data = [data mutableCopy];
    }
    else
    {
        [_data appendData:data];
    }
}

@end

@implementation NSURLConnection {
    NSURLRequest    *_request;
    NSURLRequest    *_originalRequest;
    NSURLProtocol   *_protocol;
    id _delegate;               // Not retained
    BOOL _debug;
    BOOL _started;
    NSRunLoop       *_runloop;
    NSString        *_mode;
    pthread_mutex_t _delegateLock;
    pthread_mutexattr_t _delegateLockAttr;
    NSPort *_port;
    NSUInteger _order;
}

+ (BOOL)canHandleRequest:(NSURLRequest *)request
{
    return ([NSURLProtocol _classToHandleRequest:request] != nil);
}

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    return [[[self alloc] initWithRequest:request delegate:delegate startImmediately:YES] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    if ((self = [super init]) != nil)
    {
        pthread_mutexattr_init(&_delegateLockAttr);
        pthread_mutexattr_settype(&_delegateLockAttr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_delegateLock, &_delegateLockAttr);
        _request = [request copy];
        _originalRequest = [request copy];
        _delegate = [delegate retain];
        _protocol = [[NSURLProtocol alloc]
                     initWithRequest:_request
                     cachedResponse:nil
                     client:(id<NSURLProtocolClient>)self];
        _started = NO;
        if (startImmediately)
        {
            [self performSelector:@selector(start) withObject:nil afterDelay:0.0];
        }
        _debug = YES; //GSDebugSet(@"NSURLConnection");
    }
    return self;
}

- (void)setDelegate:(id)delegate
{
    if (_delegate != delegate)
    {
        [_delegate release];
        _delegate = delegate;
    }
}

- (void)start
{
    if (!_started)
    {
        _started = YES;
        if (_runloop == nil)
        {
            _runloop = [NSRunLoop currentRunLoop];
        }
        if (_mode == nil)
        {
            _mode = [NSDefaultRunLoopMode copy];
        }

        if (_runloop->_thread == [NSThread currentThread]) {
            [_protocol startLoading:_runloop forMode:_mode];
        }
        else {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_protocol methodSignatureForSelector:@selector(startLoading:forMode:)]];
            [invocation setSelector:@selector(startLoading:forMode:)];
            [invocation setArgument:&_runloop atIndex:2];
            [invocation setArgument:&_mode atIndex:3];
            [invocation setTarget:_protocol];
            [invocation performSelector:@selector(invoke) onThread:_runloop->_thread withObject:nil waitUntilDone:YES modes:[NSArray arrayWithObject:_mode]];
        }
    }
}

- (void)_finished
{
    if (_started)
    {
        _started = NO;
        [_delegate release];
        _delegate = nil;
    }
}

- (void)cancel
{
    _started = NO;
    [_protocol stopLoading];
    [_protocol release];
    _protocol = nil;
    pthread_mutex_lock(&_delegateLock);
    if (_delegate)
    {
        _delegate = nil;
    }
    pthread_mutex_unlock(&_delegateLock);
}

- (void)dealloc
{
    [self cancel];
    [_request release];
    [_originalRequest release];
    _request = nil;
    _originalRequest = nil;
    pthread_mutex_lock(&_delegateLock);
    if (_delegate)
    {
        _delegate = nil;
    }
    pthread_mutex_unlock(&_delegateLock);

    [super dealloc];
}


- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    _runloop = aRunLoop;
    _mode = [mode copy];
}

- (NSInputStream *)_inputStream
{
    return [_protocol _inputStream];
}

- (NSURLRequest *)_request
{
    return _request;
}

- (NSURLRequest *)originalRequest
{
    return _originalRequest;
}

- (NSURLRequest *)currentRequest
{
    return _request;
}

@end


@implementation NSURLConnection (NSURLConnectionSynchronousLoading)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSData *data = nil;

    if (response && 0 != *response)
    {
        *response = nil;
    }
    // Only the error parameter is allowed to be NULL, according to Apple's
    // docs.
    if (error && 0 != *error)
    {
        *error = nil;
    }
    if ([self canHandleRequest:request] == YES)
    {
        _NSURLConnectionDataCollector *collector = [_NSURLConnectionDataCollector new];
        NSURLConnection *conn = [[self alloc] initWithRequest:request delegate:[collector autorelease] startImmediately:NO];
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [conn scheduleInRunLoop:loop forMode:_NSURLConnectionPrivateRunLoopMode];
        [collector setConnection:conn];
        [conn start];
        while ([collector done] == NO)
        {
            NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:1.0];
            [loop runMode:_NSURLConnectionPrivateRunLoopMode beforeDate:limit];
            [limit release];
        }
        data = [[[collector data] retain] autorelease];
        if (response != nil)
        {
            *response = [[[collector response] retain] autorelease];
        }
        if (0 != error)
        {
            *error = [[[collector error] retain] autorelease];
        }
        [conn release];
    }
    return data;
}

@end

@implementation NSURLConnection (NSURLConnectionQueuedLoading)

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    [queue addOperationWithBlock:^{
         NSURLResponse *response = nil;
         NSError *error = nil;
         NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
         handler(response, data, error);
     }];
}

@end


@implementation NSURLConnection (URLProtocolClient)

- (void)URLProtocol:(NSURLProtocol *)protocol cachedResponseIsValid:(NSCachedURLResponse *)cachedResponse
{
}

- (void)URLProtocol:(NSURLProtocol *)protocol didFailWithError:(NSError *)error
{
    pthread_mutex_lock(&_delegateLock);
    [_delegate connection:self didFailWithError:error];
    pthread_mutex_unlock(&_delegateLock);
    [self _finished];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didLoadData:(NSData *)data
{
    pthread_mutex_lock(&_delegateLock);
    [_delegate connection:self didReceiveData:data];
    pthread_mutex_unlock(&_delegateLock);
}

- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    pthread_mutex_lock(&_delegateLock);
    [_delegate connection:self didReceiveAuthenticationChallenge:challenge];
    pthread_mutex_unlock(&_delegateLock);
}

- (void)URLProtocol:(NSURLProtocol *)protocol
    didReceiveResponse:(NSURLResponse *)response cacheStoragePolicy:(NSURLCacheStoragePolicy)policy
{
    pthread_mutex_lock(&_delegateLock);
    [_delegate connection:self didReceiveResponse:response];
    pthread_mutex_unlock(&_delegateLock);
    if (policy == NSURLCacheStorageAllowed || policy == NSURLCacheStorageAllowedInMemoryOnly)
    {
        // FIXME ... cache response here?
    }
}

- (void)URLProtocol:(NSURLProtocol *)protoco wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if (_debug)
    {
        NSLog(@"%@ tell delegate %@ about redirect to %@ as a result of %@",
              self, _delegate, request, redirectResponse);
    }
    pthread_mutex_lock(&_delegateLock);
    if (_delegate && [_delegate respondsToSelector:@selector(willSendRequest:redirectRequest:)]) {
        request = [_delegate connection:self willSendRequest:request redirectResponse:redirectResponse];
    }
    pthread_mutex_unlock(&_delegateLock);
    if (_protocol == nil)
    {
        if (_debug)
        {
            NSLog(@"%@ delegate cancelled request", self);
        }
        /* Our protocol is nil, so we have been cancelled by the delegate.
         */
        return;
    }
    if (request != nil)
    {
        if (_debug)
        {
            NSLog(@"%@ delegate allowed redirect to %@", self, request);
        }
        /* Follow the redirect ... stop the old load and start a new one.
         */
        [_protocol stopLoading];
        ASSIGNCOPY(_request, request);
        NSURLProtocol *redirect = [[NSURLProtocol alloc] initWithRequest:_request cachedResponse:nil client:(id<NSURLProtocolClient>)self];
        [redirect setRequest:_request];
        [redirect startLoading:_runloop forMode:_mode];
        DESTROY(_protocol);
        _protocol = redirect;
    }
    else if (_debug)
    {
        NSLog(@"%@ delegate cancelled redirect", self);
    }
}

- (void)URLProtocolDidFinishLoading:(NSURLProtocol *)protocol
{
    pthread_mutex_lock(&_delegateLock);
    [_delegate connectionDidFinishLoading:self];
    pthread_mutex_unlock(&_delegateLock);
    [self _finished];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    pthread_mutex_lock(&_delegateLock);
    [_delegate connection:self didCancelAuthenticationChallenge:challenge];
    pthread_mutex_unlock(&_delegateLock);
}

@end

