//
//  NSURLRequest.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSURLRequest.h>
#import "NSURLRequestInternal.h"
#import <Foundation/NSURL.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>

@implementation NSURLRequestInternal

- (void)dealloc
{
    CFRelease(request);
    [super dealloc];
}

@end


@implementation NSURLRequest {
    NSURLRequestInternal *_internal;
}

static NSTimeInterval defaultTimeout = 60.0;

+ (NSTimeInterval)defaultTimeoutInterval
{
    return defaultTimeout;
}

+ (void)setDefaultTimeoutInterval:(NSTimeInterval)ti
{
    defaultTimeout = ti;
}

+ (id)requestWithURL:(NSURL *)URL
{
    return [[[self alloc] initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[NSURLRequest defaultTimeoutInterval]] autorelease];
}

+ (id)requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    return [[[self alloc] initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval] autorelease];
}

- (id)init
{
    return [self initWithURL:nil];
}

- (id)initWithURL:(NSURL *)URL
{
    return [self initWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:[NSURLRequest defaultTimeoutInterval]];
}

- (id)_initWithCFURLRequest:(CFURLRequestRef)req
{
    self = [super init];
    if (self)
    {
        _internal = [[NSURLRequestInternal alloc] init];
        _internal->request = (CFURLRequestRef)CFRetain(req);
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
    CFURLRequestRef request = CFURLRequestCreate(kCFAllocatorDefault, (CFURLRef)URL, (CFURLRequestCachePolicy)cachePolicy, (CFTimeInterval)timeoutInterval);
    self = [self _initWithCFURLRequest:request];
    CFRelease(request);
    return self;
}

- (void)dealloc
{
    [_internal release];
    [super dealloc];
}

- (NSURL *)URL
{
    return (NSURL *)CFURLRequestGetURL(_internal->request);
}

- (NSURLRequestCachePolicy)cachePolicy
{
    return (NSURLRequestCachePolicy)CFURLRequestGetCachePolicy(_internal->request);
}

- (NSTimeInterval)timeoutInterval
{
    return (NSTimeInterval)CFURLRequestGetTimeout(_internal->request);
}

- (NSURL *)mainDocumentURL
{
    return [(NSURL *)CFURLRequestCopyMainDocumentURL(_internal->request) autorelease];
}

- (NSURLRequestNetworkServiceType)networkServiceType
{
    return (NSURLRequestNetworkServiceType)CFURLRequestGetServiceType(_internal->request);
}

- (BOOL)allowsCellularAccess
{
    return CFURLRequestAllowsCellularAccess(_internal->request);
}

- (CFURLRequestRef)_CFURLRequest
{
    return _internal->request;
}

static CFURLRequestRef _CFURLRequestMutableCopyFromNSURLRequest(NSURLRequest *self)
{
    CFURLRef url = CFURLRequestGetURL(self->_internal->request);
    CFURLRequestCachePolicy policy = CFURLRequestGetCachePolicy(self->_internal->request);
    CFTimeInterval timeout = CFURLRequestGetTimeout(self->_internal->request);
    CFURLRequestRef req = CFURLRequestCreate(kCFAllocatorDefault, url, policy, timeout);
    _CFURLSetMutable(req, true);
    CFURLRequestSetHTTPBody((CFMutableURLRequestRef)req, CFURLRequestGetHTTPBody(self->_internal->request));
    CFStringRef method = CFURLRequestCopyHTTPMethod(self->_internal->request);
    if (method != nil) {
        CFURLRequestSetHTTPMethod((CFMutableURLRequestRef)req, method);
        CFRelease(method);
    }
    CFURLRequestSetHTTPFields((CFMutableURLRequestRef)req, CFURLRequestCopyHTTPFields(self->_internal->request), CFURLRequestCopyHTTPValues(self->_internal->request));
    return req;
}

- (id)copyWithZone:(NSZone *)zone
{
    CFURLRequestRef req = _CFURLRequestMutableCopyFromNSURLRequest(self);
    _CFURLSetMutable(req, false);
    NSURLRequest *copy = [[NSURLRequest alloc] _initWithCFURLRequest:req];
    CFRelease(req);
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CFURLRequestRef req = _CFURLRequestMutableCopyFromNSURLRequest(self);
    NSMutableURLRequest *copy = [[NSMutableURLRequest alloc] _initWithCFURLRequest:req];
    CFRelease(req);
    return copy;
}

- (NSString *)debugDescription
{
    CFStringRef reqDesc = CFURLRequestCopyDebugDescription(_internal->request);
    NSString *desc = [NSString stringWithFormat:@"<NSURLRequest %p %@>", self, reqDesc];
    CFRelease(reqDesc);
    return desc;
}

@end


@implementation NSURLRequest (NSHTTPURLRequest)

- (NSString *)HTTPMethod
{
    return [(NSString *)CFURLRequestCopyHTTPMethod([self _CFURLRequest]) autorelease];
}

- (NSDictionary *)allHTTPHeaderFields
{
    CFURLRequestRef req = [self _CFURLRequest];
    return [(NSDictionary *)CFURLRequestCopyAllHTTPFields(req) autorelease];
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field
{
    return [(NSString *)CFURLRequestCopyValueForHTTPField([self _CFURLRequest], (CFStringRef)field) autorelease];
}

- (NSData *)HTTPBody
{
    return (NSData *)CFURLRequestGetHTTPBody([self _CFURLRequest]);
}

- (NSInputStream *)HTTPBodyStream
{
    return (NSInputStream *)CFURLRequestGetHTTPBodyStream([self _CFURLRequest]);
}

- (BOOL)HTTPShouldHandleCookies
{
    return CFURLRequestShouldHandleCookes([self _CFURLRequest]);
}

- (BOOL)HTTPShouldUsePipelining
{
    return CFURLRequestShouldUseHTTPPipelining([self _CFURLRequest]);
}

@end

@implementation NSMutableURLRequest

- (id)_initWithCFURLRequest:(CFURLRequestRef)req
{
    CFMutableURLRequestRef request = (CFMutableURLRequestRef)CFURLRequestCreateMutableCopy(kCFAllocatorDefault, req);
    self = [super _initWithCFURLRequest:request];
    return self;
}

- (void)setURL:(NSURL *)URL
{
    CFURLRequestSetURL((CFMutableURLRequestRef)[self _CFURLRequest], (CFURLRef)URL);
}

- (void)setCachePolicy:(NSURLRequestCachePolicy)policy
{
    CFURLRequestSetCachePolicy((CFMutableURLRequestRef)[self _CFURLRequest], (CFURLRequestCachePolicy)policy);
}

- (void)setTimeoutInterval:(NSTimeInterval)seconds
{
    CFURLRequestSetTimeout((CFMutableURLRequestRef)[self _CFURLRequest], (CFTimeInterval)seconds);
}

- (void)setMainDocumentURL:(NSURL *)URL
{
    CFURLRequestSetMainDocumentURL((CFMutableURLRequestRef)[self _CFURLRequest], (CFURLRef)URL);
}

- (void)setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType
{
    CFURLRequestSetNetworkServiceType((CFMutableURLRequestRef)[self _CFURLRequest], (CFURLRequestNetworkServiceType)networkServiceType);
}

- (void)setAllowsCellularAccess:(BOOL)allow
{
    CFURLRequestSetAllowsCellularAccess((CFMutableURLRequestRef)[self _CFURLRequest], allow);
}

@end

@implementation NSMutableURLRequest (NSMutableHTTPURLRequest)

- (void)setHTTPMethod:(NSString *)method
{
    CFURLRequestSetHTTPMethod((CFMutableURLRequestRef)[self _CFURLRequest], (CFStringRef)method);
}

- (void)setAllHTTPHeaderFields:(NSDictionary *)headerFields
{
    CFURLRequestSetHTTPFields((CFMutableURLRequestRef)[self _CFURLRequest], (CFArrayRef)[headerFields allKeys], (CFArrayRef)[headerFields allValues]);
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    CFMutableURLRequestRef req = (CFMutableURLRequestRef)[self _CFURLRequest];
    CFIndex idx = CFURLRequestFirstFieldIndex(req, (CFStringRef)field, 0);
    if (idx != kCFNotFound)
    {
        CFURLRequestReplaceHTTPField(req, idx, (CFStringRef)value);
    }
    else
    {
        CFURLRequestAddValueForHTTPField(req, (CFStringRef)field, (CFStringRef)value);
    }
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    CFURLRequestAddValueForHTTPField((CFMutableURLRequestRef)[self _CFURLRequest], (CFStringRef)field, (CFStringRef)value);
}

- (void)setHTTPBody:(NSData *)data
{
    CFURLRequestSetHTTPBody((CFMutableURLRequestRef)[self _CFURLRequest], (CFDataRef)data);
}

- (void)setHTTPBodyStream:(NSInputStream *)inputStream
{
    CFURLRequestSetHTTPBodyStream((CFMutableURLRequestRef)[self _CFURLRequest], (CFReadStreamRef)inputStream);
}

- (void)setHTTPShouldHandleCookies:(BOOL)should
{
    CFURLRequestHandleCookies((CFMutableURLRequestRef)[self _CFURLRequest], should);
}

- (void)setHTTPShouldUsePipelining:(BOOL)shouldUsePipelining
{
    CFURLRequestUseHTTPPipelining((CFMutableURLRequestRef)[self _CFURLRequest], shouldUsePipelining);
}

@end
