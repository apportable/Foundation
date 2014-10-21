//
//  NSHTTPCookieStorageTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSHTTPCookieStorage)


test(NSHTTPCookieCreation)
{
    NSHTTPCookie *cookie1 = [[NSHTTPCookie alloc] initWithProperties:
                             @{
                               NSHTTPCookieValue:@"some",
                               NSHTTPCookieName:@"name",
                               NSHTTPCookieOriginURL:@"http://apportable.com",
                               NSHTTPCookiePath: @"/",
                               }];

    testassert(cookie1!=nil);
    
    NSHTTPCookie *cookie2 = [[NSHTTPCookie alloc] initWithProperties:
                             @{
                               NSHTTPCookieValue:@"some",
                               NSHTTPCookieName:@"name",
                               NSHTTPCookiePath: @"/",
                               }];

    testassert(cookie2==nil);

    return YES;
}


test(NSHTTPCookieStorageTest)
{
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    testassert(storage!=nil);
    
    for (NSHTTPCookie* cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    testassert([storage cookies].count==0);
    
    NSHTTPCookie *cookie1 = [[NSHTTPCookie alloc] initWithProperties:
                             @{
                               NSHTTPCookieValue:@"some",
                               NSHTTPCookieName:@"name",
                               NSHTTPCookieOriginURL:@"http://apportable.com",
                               NSHTTPCookiePath: @"/",
                               }];
    [storage setCookie:cookie1];
    testassert([storage cookies].count==1);
    
    
    NSHTTPCookie *storedCookie =[[storage cookies] lastObject];
    
    testassert([cookie1 isEqual:storedCookie]);
    
    
    NSHTTPCookie *cookie1new = [[NSHTTPCookie alloc] initWithProperties:
                             @{
                               NSHTTPCookieValue:@"some other",
                               NSHTTPCookieName:@"name",
                               NSHTTPCookieOriginURL:@"http://apportable.com",
                               NSHTTPCookiePath: @"/",
                               }];
    
    [storage setCookie:cookie1new];
    testassert([storage cookies].count==1);
    
    
    NSHTTPCookie *storedCookieNew =[[storage cookies] lastObject];
    
    testassert([cookie1new isEqual:storedCookieNew]);
    testassert(![cookie1 isEqual:storedCookieNew]);

    
    return YES;
}



test(NSHTTPCookieRequestTest)
{
    NSHTTPCookie *cookie1 = [[NSHTTPCookie alloc] initWithProperties:
                             @{
                               NSHTTPCookieValue:@"1",
                               NSHTTPCookieName:@"cookie1",
                               NSHTTPCookieOriginURL:@"http://apportable.com",
                               NSHTTPCookiePath: @"/",
                               }];
    NSHTTPCookie *cookie2 = [[NSHTTPCookie alloc] initWithProperties:
                             @{
                               NSHTTPCookieValue:@"2",
                               NSHTTPCookieName:@"cookie2",
                               NSHTTPCookieOriginURL:@"http://apportable.com",
                               NSHTTPCookiePath: @"/",
                               }];
    
    NSDictionary *requestHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:@[cookie1, cookie2]];
    testassert([requestHeaders isEqual:@{@"Cookie": @"cookie1=1; cookie2=2"}]);

    return YES;
}

test(NSHTTPCookieResponseTest)
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    testassert(storage!=nil);
    
    for (NSHTTPCookie* cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }

    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:@{@"Set-Cookie": @"cookie1=\"[COOKIE_1]\", cookie2=\"[COOKIE_2]\"; Path=/; Secure; HttpOnly"} forURL:[NSURL URLWithString:@"http://apportable.com"]];
    
    testassert([cookies count]==2);
    
    NSHTTPCookie *cookie1 = [cookies objectAtIndex:0];
    NSHTTPCookie *cookie2 = [cookies objectAtIndex:1];
    
    
    testassert([cookie1.properties[NSHTTPCookieName] isEqual:@"cookie1"]);
    testassert([cookie1.properties[NSHTTPCookieValue] isEqual:@"\"[COOKIE_1]\""]);
//    testassert([cookie1.properties[NSHTTPCookieDomain] isEqual:@"apportable.com"]);
    testassert([cookie2.properties[NSHTTPCookieName] isEqual:@"cookie2"]);
    testassert([cookie2.properties[NSHTTPCookieValue] isEqual:@"\"[COOKIE_2]\""]);
//    testassert([cookie2.properties[NSHTTPCookieDomain] isEqual:@"apportable.com"]);

    
    return YES;
}

test(NSHTTPCookieNSURLConnectionTest)
{
    
    NSURLResponse *response;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://google.com"]];
    
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    testassert(storage!=nil);
    
    for (NSHTTPCookie* cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    testassert([storage cookies].count==0);

    
    [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:NULL];
    
    
    testassert([storage cookies].count==2);
    
    [NSURLConnection sendSynchronousRequest:request returningResponse: &response error:NULL];

    
    return YES;

}


@end
