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


@interface _NSURLConnectionDataCollector : NSObject
{
  NSURLConnection   *_connection;   // Not retained
  NSMutableData     *_data;
  NSError       *_error;
  NSURLResponse     *_response;
  BOOL          _done;
}

- (NSData*) data;
- (BOOL) done;
- (NSError*) error;
- (NSURLResponse*) response;
- (void) setConnection: (NSURLConnection *)c;

@end

@implementation NSRunLoop (NSURLConnectionInitializer)
+ (void)initializeConnectionClasses
{
    [NSURLConnection load];
    [NSURLProtocol load];
}
@end

@implementation _NSURLConnectionDataCollector

- (void) dealloc
{
  [_data release];
  [_error release];
  [_response release];
  [super dealloc];
}

- (BOOL) done
{
  return _done;
}

- (NSData*) data
{
  return _data;
}

- (NSError*) error
{
  return _error;
}

- (NSURLResponse*) response
{
  return _response;
}

- (void) setConnection: (NSURLConnection*)c
{
  _connection = c;
}

- (void) connection: (NSURLConnection *)connection
   didFailWithError: (NSError *)error
{
  ASSIGN(_error, error);
  _done = YES;
}

- (void) connection: (NSURLConnection *)connection
 didReceiveResponse: (NSURLResponse*)response
{
  ASSIGN(_response, response);
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
  _done = YES;
}


- (void) connection: (NSURLConnection *)connection
     didReceiveData: (NSData *)data
{
  if (nil == _data)
    {
      _data = [data mutableCopy];
    }
  else
    {
      [_data appendData: data];
    }
}

@end

typedef struct {
    NSURLRequest    *_request;
    NSURLProtocol   *_protocol;
    id              _delegate;  // Not retained
    BOOL            _debug;
    BOOL            _started;
    NSRunLoop       *_runloop;
    NSString        *_mode;
} Internal;

#define this  ((Internal*)(self->_NSURLConnectionInternal))
#define inst  ((Internal*)(o->_NSURLConnectionInternal))

@implementation NSURLConnection

+ (BOOL)canHandleRequest:(NSURLRequest *)request
{
    return ([NSURLProtocol _classToHandleRequest: request] != nil);
}

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    return [[[self alloc] initWithRequest: request delegate: delegate startImmediately:YES] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    if ((self = [super init]) != nil)
    {
#if GS_WITH_GC
        _NSURLConnectionInternal = NSAllocateCollectable(sizeof(Internal), NSScannedOption);
#else
        _NSURLConnectionInternal = calloc(1, sizeof(Internal));
#endif
        this->_request = [request copy];
        this->_delegate = delegate;
        this->_protocol = [[NSURLProtocol alloc]
                           initWithRequest: this->_request
                           cachedResponse: nil
                           client: (id<NSURLProtocolClient>)self];
        if (startImmediately)
        {
            [self start];
        }
        this->_debug = YES; //GSDebugSet(@"NSURLConnection");
    }
    return self;
}

- (void)start
{
    if (!this->_started)
    {
        this->_started = YES;
        if (this->_runloop == NULL)
        {
            this->_runloop = [NSRunLoop currentRunLoop];
        }
        if (this->_mode == NULL)
        {
            this->_mode = [NSRunLoopCommonModes copy];
        }
        [this->_protocol startLoading:this->_runloop forMode:this->_mode];
    }
}

- (void)cancel
{
    if (this->_started)
    {
        this->_started = NO;
        [this->_protocol stopLoading];
        DEBUG_LOG("DESTROY protocol!");
        DESTROY(this->_protocol);
    }
}

- (void)dealloc
{
    if (this != 0)
    {
        [self cancel];
        RELEASE(this->_request);
        free(this);
        _NSURLConnectionInternal = 0;
    }
    [super dealloc];
}

- (void)finalize
{
    if (this != 0)
    {
        [self cancel];
    }
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    this->_runloop = aRunLoop;
    this->_mode = [mode copy];
}

@end



@implementation NSObject (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    return;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    return;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    return;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    return;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    return;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    return request;
}

@end



@implementation NSURLConnection (NSURLConnectionSynchronousLoading)

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    NSData *data = NULL;

    if (0 != response)
    {
        *response = NULL;
    }
    if (0 != error)
    {
        *error = NULL;
    }
    if ([self canHandleRequest: request] == YES)
    {
        _NSURLConnectionDataCollector *collector;
        NSURLConnection *conn;
        NSRunLoop *loop;

        collector = [_NSURLConnectionDataCollector new];
        conn = [[self alloc] initWithRequest: request delegate: [collector autorelease]];
        [collector setConnection: conn];
        loop = [NSRunLoop currentRunLoop];
        while ([collector done] == NO)
        {
            NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow: 1.0];
            [loop runMode: NSDefaultRunLoopMode beforeDate: limit];
            [limit release];
        }
        data = [[[collector data] retain] autorelease];
        if (0 != response)
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


@implementation NSURLConnection (URLProtocolClient)

- (void)URLProtocol:(NSURLProtocol *)protocol cachedResponseIsValid:(NSCachedURLResponse *)cachedResponse
{
    
}

- (void)URLProtocol:(NSURLProtocol *)protocol didFailWithError:(NSError *)error
{
    [this->_delegate connection:self didFailWithError:error];
}

- (void)URLProtocol: (NSURLProtocol *)protocol didLoadData: (NSData *)data
{
    [this->_delegate connection:self didReceiveData:data];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [this->_delegate connection:self didReceiveAuthenticationChallenge:challenge];
}

- (void)URLProtocol:(NSURLProtocol *)protocol
  didReceiveResponse: (NSURLResponse *)response cacheStoragePolicy: (NSURLCacheStoragePolicy)policy
{
    [this->_delegate connection:self didReceiveResponse:response];
    if (policy == NSURLCacheStorageAllowed || policy == NSURLCacheStorageAllowedInMemoryOnly)
    {
        // FIXME ... cache response here?
    }
}

- (void)URLProtocol:(NSURLProtocol *)protoco wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if (this->_debug)
    {
        NSLog(@"%@ tell delegate %@ about redirect to %@ as a result of %@",
              self, this->_delegate, request, redirectResponse);
    }
    request = [this->_delegate connection:self willSendRequest:request redirectResponse:redirectResponse];
    if (this->_protocol == nil)
    {
        if (this->_debug)
        {
            NSLog(@"%@ delegate cancelled request", self);
        }
        /* Our protocol is nil, so we have been cancelled by the delegate.
         */
        return;
    }
    if (request != nil)
    {
        if (this->_debug)
        {
            NSLog(@"%@ delegate allowed redirect to %@", self, request);
        }
        /* Follow the redirect ... stop the old load and start a new one.
         */
        [this->_protocol stopLoading];
        ASSIGNCOPY(this->_request, request);
        NSURLProtocol *redirect = [[NSURLProtocol alloc] initWithRequest:this->_request cachedResponse:nil client:(id<NSURLProtocolClient>)self];
        [redirect setRequest:this->_request];
        [redirect startLoading:this->_runloop forMode:this->_mode];
        DESTROY(this->_protocol);
        this->_protocol = redirect;
    }
    else if (this->_debug)
    {
        NSLog(@"%@ delegate cancelled redirect", self);
    }
}

- (void)URLProtocolDidFinishLoading:(NSURLProtocol *)protocol
{
    [this->_delegate connectionDidFinishLoading: self];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
    [this->_delegate connection: self didCancelAuthenticationChallenge: challenge];
}

@end

