//
//  NSURLProtocol.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSURLProtocol.h>
#import "NSURLProtocolInternal.h"
#import "NSObjectInternal.h"
#import <Foundation/NSURLRequest.h>
#import <objc/runtime.h>
#import <Foundation/NSURL.h>

static NSMutableArray *sRegisteredClasses = nil;

@implementation NSURLProtocolDefaultClient

- (void)URLProtocol:(NSURLProtocol *)protocol wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    [self.delegate connection:self.connection willSendRequest:request redirectResponse:redirectResponse];
}

- (void)URLProtocol:(NSURLProtocol *)protocol cachedResponseIsValid:(NSCachedURLResponse *)cachedResponse
{
    [self.delegate connection:self.connection willCacheResponse:cachedResponse];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveResponse:(NSURLResponse *)response cacheStoragePolicy:(NSURLCacheStoragePolicy)policy
{
    [self.delegate connection:self.connection didReceiveResponse:response];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didLoadData:(NSData *)data
{
    [self.delegate connection:self.connection didReceiveData:data];
}

- (void)URLProtocolDidFinishLoading:(NSURLProtocol *)protocol
{
    [self.delegate connectionDidFinishLoading:self.connection];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didFailWithError:(NSError *)error
{
    [self.delegate connection:self.connection didFailWithError:error];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.delegate connection:self.connection didReceiveAuthenticationChallenge:challenge];
}

- (void)URLProtocol:(NSURLProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.delegate connection:self.connection didCancelAuthenticationChallenge:challenge];
}

- (void)dealloc
{
    self.delegate = nil;
    self.connection = nil;
    [super dealloc];
}

@end

@implementation NSURLProtocol
{
    NSCachedURLResponse *_cachedResponse;
    NSURLRequest *_request;
    id <NSURLProtocolClient> _client;
}

+ (void)initialize
{
    @synchronized(self)
    {
        if (sRegisteredClasses == nil) {
            sRegisteredClasses = [[NSMutableArray alloc] init];
        }
    }
}

+ (NSArray *)_registeredClasses
{
    @synchronized(self)
    {
        return [[sRegisteredClasses copy] autorelease];
    }
}


+ (Class)_protocolClassForRequest:(NSURLRequest *)request
{
    for (Class protocolClass in [self _registeredClasses])
    {
        if ([protocolClass canInitWithRequest:request])
        {
            return protocolClass;
        }
    }
    return Nil;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return YES; //also part of workaround. Should be replaced with NSRequestConcreteImplementation();
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSRequestConcreteImplementation();
    return nil;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    BOOL ok = YES;
    if (self == [NSURLProtocol class])
    {
        ok = ![[a URL] isEqual:[b URL]];
    }
    return [self canInitWithRequest:a] && [self canInitWithRequest:b] && ok;
}

+ (id)propertyForKey:(NSString *)key inRequest:(NSURLRequest *)request
{
    return objc_getAssociatedObject(request, key);
}

+ (void)setProperty:(id)value forKey:(NSString *)key inRequest:(NSMutableURLRequest *)request
{
    objc_setAssociatedObject(request, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)removePropertyForKey:(NSString *)key inRequest:(NSMutableURLRequest *)request
{
    objc_setAssociatedObject(request, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)registerClass:(Class)protocolClass
{
    if (![protocolClass isSubclassOfClass:self])
    {
        return NO;
    }
    @synchronized(self)
    {
        [sRegisteredClasses removeObject:protocolClass];
        [sRegisteredClasses insertObject:protocolClass atIndex:0];
    }
    return YES;
}

+ (void)unregisterClass:(Class)protocolClass
{
    @synchronized(self)
    {
        [sRegisteredClasses removeObject:protocolClass];
    }
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client
{
    self = [super init];
    if (self != nil)
    {
        _request = [request retain];
        _cachedResponse = [cachedResponse retain];
        _client = [client retain];
    }
    return self;
}

- (void)dealloc
{
    [_client release];
    [_cachedResponse release];
    [_request release];
    [super dealloc];
}

- (id <NSURLProtocolClient>)client
{
    return _client;
}

- (NSURLRequest *)request
{
    return _request;
}

- (NSCachedURLResponse *)cachedResponse
{
    return _cachedResponse;
}

- (void)startLoading
{
    NSRequestConcreteImplementation();
}

- (void)stopLoading
{
    NSRequestConcreteImplementation();
}


@end
