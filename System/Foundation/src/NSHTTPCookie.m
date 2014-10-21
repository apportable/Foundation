//
//  NSHTTPCookie.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSHTTPCookie.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSRegularExpression.h>
#import <CFNetwork/CFHTTPCookie.h>
#import "NSHTTPCookie+private.h"

NSString * const NSHTTPCookieName = @"Name";
NSString * const NSHTTPCookieValue = @"Value";
NSString * const NSHTTPCookieOriginURL = @"OriginURL";
NSString * const NSHTTPCookieVersion = @"Version";
NSString * const NSHTTPCookieDomain = @"Domain";
NSString * const NSHTTPCookiePath = @"Path";
NSString * const NSHTTPCookieSecure = @"Secure";
NSString * const NSHTTPCookieExpires = @"Expires";
NSString * const NSHTTPCookieComment = @"Comment";
NSString * const NSHTTPCookieCommentURL = @"CommentURL";
NSString * const NSHTTPCookieDiscard = @"Discard";
NSString * const NSHTTPCookieMaximumAge = @"Max-Age";
NSString * const NSHTTPCookiePort = @"Port";


@implementation NSHTTPCookie {
    CFHTTPCookieRef  _cookiePrivate;
}

+ (id)cookieWithProperties:(NSDictionary *)properties
{
    return [[[self alloc] initWithProperties:properties] autorelease];
}

+ (NSDictionary *)requestHeaderFieldsWithCookies:(NSArray *)cookies
{
    NSMutableArray *cfCookies = [NSMutableArray arrayWithCapacity:[cookies count]];
    
    for (NSHTTPCookie *cookie in cookies) {
        CFHTTPCookieRef cfCookie = [cookie privateCookie];
        [cfCookies addObject:(id)cfCookie];
    }
    
    NSDictionary *result = [(NSDictionary *)CFHTTPCookieCopyRequestHeaderFields((CFArrayRef)cfCookies) autorelease];
    return result;
}

+ (NSArray *)cookiesWithResponseHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)URL
{
    NSArray * cfCookies = (NSArray *)CFHTTPCookieCreateWithResponseHeaderFields((CFDictionaryRef)headerFields, (CFURLRef)URL);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[cfCookies count]];
    
    
    for (id cfCookie in cfCookies) {
        NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithCookie:(CFHTTPCookieRef)cfCookie];
        [result addObject:cookie];
        [cookie release];
    }
    
    [cfCookies release];
    return [NSArray arrayWithArray:result];
    
}

- (id)initWithCookie:(CFHTTPCookieRef)cookie
{
    self = [super init];
    if (self)
    {
        _cookiePrivate = (CFHTTPCookieRef)CFRetain(cookie);
    }
    return self;
}

- (id)initWithProperties:(NSDictionary *)properties
{
    self = [super init];
    if (self)
    {
        _cookiePrivate = CFHTTPCookieCreateWithProperties((CFDictionaryRef)properties);
    }
    if (_cookiePrivate == NULL) {
        [self release];
        self = nil;
    }
    return self;
}

- (void)dealloc
{
    if (_cookiePrivate != NULL) {
        CFRelease(_cookiePrivate);
    }
    [super dealloc];
}

-(CFHTTPCookieRef)privateCookie {
    return _cookiePrivate;
}

- (NSDictionary *)properties
{
    return [(NSDictionary *)CFHTTPCookieCopyProperties(_cookiePrivate) autorelease];
}

- (NSUInteger)version
{
    return [(NSNumber*)CFHTTPCookieGetVersion(_cookiePrivate) unsignedIntegerValue];
}

- (NSString *)name
{
    return (NSString *)CFHTTPCookieGetName(_cookiePrivate);
}

- (NSString *)value
{
    return (NSString *)CFHTTPCookieGetValue(_cookiePrivate);
}

- (NSDate *)expiresDate
{
    return (NSDate *)CFHTTPCookieGetExpirationDate(_cookiePrivate);
}

- (BOOL)isSessionOnly
{
    return CFHTTPCookieIsSessionOnly(_cookiePrivate);
}

- (NSString *)domain
{
    return (NSString *)CFHTTPCookieGetDomain(_cookiePrivate);
}

- (NSString *)path
{
    return (NSString *)CFHTTPCookieGetPath(_cookiePrivate);
}

- (BOOL)isSecure
{
    return CFHTTPCookieIsSecure(_cookiePrivate);
}

- (BOOL)isHTTPOnly
{
    return CFHTTPCookieIsHTTPOnly(_cookiePrivate);
}

- (NSString *)comment
{
    return (NSString *)CFHTTPCookieGetComment(_cookiePrivate);
}

- (NSURL *)commentURL
{
    return (NSURL *)CFHTTPCookieGetCommentURL(_cookiePrivate);
}

- (NSArray *)portList
{
    return (NSArray *)CFHTTPCookieGetPortArray(_cookiePrivate);
}

- (BOOL)isEqual:(id)object {
    return [[self properties] isEqual:[object properties]];
}


@end
