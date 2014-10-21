//
//  ConnectionDelegate.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ConnectionDelegate.h"


@implementation ConnectionDelegate

- (id)init
{
    self = [super init];
    if (self) {
        _resultData = [[NSMutableData alloc] init];
        _didRedirect = NO;
        _done = NO;
        _error = nil;
    }
    return self;
}

- (void)dealloc
{
    [_resultData release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (![[[connection originalRequest] URL] isEqual:[response URL]])
    {
        _didRedirect = YES;
    }
    [_resultData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_resultData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _error = [error copy];
    _done = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _done = YES;
}

@end

@implementation FullConnectionDelegate
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _willSendRequestCount = 0;
        _shouldAlterCachedResponseData = NO;
        _shouldKillCachedResponse = NO;
        _shouldKillRedirectRequest = NO;
        _didAlterCachedResponseData = NO;
        _didKillCachedResponse = NO;
        _cachedURLResponse = nil;
        _firstRedirectResponseReceived = nil;
    }
    return self;
}
- (void)dealloc
{
    [_cachedURLResponse release];
    [_firstRedirectResponseReceived release];
    [super dealloc];
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        _willSendRequestCount++;
    }
    
    if (response != nil && _shouldKillRedirectRequest) // don't want to kill the request if it's not a redirect
    {
        _didKillRedirectRequest = YES;
        return nil;
    }
    return request;
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    if (_shouldKillCachedResponse)
    {
        _didKillCachedResponse = YES;
        return nil;
    }
    if (_shouldAlterCachedResponseData)
    {
        _didAlterCachedResponseData = YES;
        NSData *replacementData = [[NSData alloc] initWithBytes:[@"Hello World!" UTF8String]
                                                         length:[@"Hello World!" length]];
        NSCachedURLResponse *replacementResponse = [[NSCachedURLResponse alloc] initWithResponse:[cachedResponse response] data:replacementData userInfo:[cachedResponse userInfo] storagePolicy:[cachedResponse storagePolicy]];
        [replacementData release];
        return [replacementResponse autorelease];
    }
    return cachedResponse;
}
@end

