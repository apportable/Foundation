//
//  NSHTTPCookieStorage.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSHTTPCookieStorage.h>
#import <dispatch/dispatch.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSHTTPCookie.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSURL.h>
#import <CFNetwork/CFHTTPCookieStorage.h>
#import "NSHTTPCookie+private.h"

@implementation NSHTTPCookieStorage {
    CFHTTPCookieStorageRef _storage;
    NSHTTPCookieAcceptPolicy _acceptPolicy;
}

+ (NSHTTPCookieStorage *)sharedHTTPCookieStorage
{
    static NSHTTPCookieStorage *sharedStorage = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        sharedStorage = [[NSHTTPCookieStorage alloc] initWithStorage:CFHTTPCookieStorageGetDefault()];
    });
    return sharedStorage;
}

- (id)initWithStorage:(CFHTTPCookieStorageRef) storage
{
    self = [super init];
    
    if (self)
    {
        _storage = (CFHTTPCookieStorageRef)CFRetain(storage);
    }
    
    return self;
}



- (NSArray *)cookies
{
    NSArray * cfCookies = (NSArray *)CFHTTPCookieStorageCopyCookies(_storage);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[cfCookies count]];
    
    
    for (id cfCookie in cfCookies) {
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithCookie:(CFHTTPCookieRef)cfCookie];
        [result addObject:cookie];
        [cookie release];
    }
    
    [cfCookies release];
    return [NSArray arrayWithArray:result];

}

- (void)setCookie:(NSHTTPCookie *)cookie
{
    CFHTTPCookieStorageSetCookie(_storage, [cookie privateCookie]);
}

- (void)deleteCookie:(NSHTTPCookie *)cookie
{
    CFHTTPCookieStorageDeleteCookie(_storage, [cookie privateCookie]);
}


#warning TODO implement NSHTTPCookieStorage

- (NSArray *)cookiesForURL:(NSURL *)URL
{
    CFArrayRef cfCookies = CFHTTPCookieStorageCopyCookiesForURL(_storage, (CFURLRef)URL);
    NSMutableArray *nsCookies = [NSMutableArray array];

    for (id cfCookie in (NSArray *)cfCookies)
    {
        NSHTTPCookie *nsCookie = [[NSHTTPCookie alloc] initWithCookie:(CFHTTPCookieRef)cfCookie];
        [nsCookies addObject:nsCookie];
        [nsCookie release];
    }

    CFRelease(cfCookies);

    return nsCookies;
}

- (void)setCookies:(NSArray *)cookies forURL:(NSURL *)URL mainDocumentURL:(NSURL *)mainDocumentURL
{

}

- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy
{
    return _acceptPolicy;
}

- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)cookieAcceptPolicy
{
    _acceptPolicy = cookieAcceptPolicy;
}

- (NSArray*)sortedCookiesUsingDescriptors:(NSArray*)sortOrder
{
    return @[];
}

@end
