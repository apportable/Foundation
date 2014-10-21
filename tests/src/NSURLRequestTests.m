//
//  NSURLRequestTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface NSURLRequest (internal)
+ (NSTimeInterval)defaultTimeoutInterval;
+ (void)setDefaultTimeoutInterval:(NSTimeInterval)ti;
@end

@testcase(NSURLRequest)

test(SingletonFactoryPattern)
{
    testassert([NSURLRequest alloc] != [NSURLRequest alloc]);

    return YES;
}

test(DefaultTimeout)
{
    testassert([NSURLRequest defaultTimeoutInterval] == 60.0);
    return YES;
}

test(SetDefaultTimeout)
{
    NSTimeInterval ti = [NSURLRequest defaultTimeoutInterval];
    [NSURLRequest setDefaultTimeoutInterval:30.0];

    testassert([NSURLRequest defaultTimeoutInterval] == 30.0);

    [NSURLRequest setDefaultTimeoutInterval:ti]; // restore it for other tests

    return YES;
}


test(DefaultInit)
{
    NSURLRequest *request = [[NSURLRequest alloc] init];

    testassert(request != nil);

    testassert([request URL] == nil);

    testassert([request cachePolicy] == NSURLRequestUseProtocolCachePolicy);

    testassert([request timeoutInterval] == 60.0);

    testassert([request mainDocumentURL] == nil);

    testassert([request networkServiceType] == NSURLNetworkServiceTypeDefault);

    testassert([request allowsCellularAccess] == YES);

    testassert([[request HTTPMethod] isEqualToString:@"GET"]);

    testassert([request allHTTPHeaderFields] == nil);

    testassert([request HTTPBody] == nil);

    testassert([request HTTPBodyStream] == nil);

    // radar://15366677
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    testassert([request HTTPShouldHandleCookies] == YES);
#elif __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
    testassert([request HTTPShouldHandleCookies] == YES);
#endif

    testassert([request HTTPShouldUsePipelining] == NO);

    [request release];
    return YES;
}

test(URLConstruction)
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    testassert([[request URL] isEqual:url]);
    testassert([request mainDocumentURL] == nil);

    [request release];

    return YES;
}

test(AdvancedConstruction)
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:42.5];

    testassert([request cachePolicy] == NSURLRequestReturnCacheDataElseLoad);

    testassert([request timeoutInterval] == 42.5);

    [request release];
    return YES;
}

test(DefaultMutableInit)
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    testassert(request != nil);

    testassert([request URL] == nil);

    testassert([request cachePolicy] == NSURLRequestUseProtocolCachePolicy);

    testassert([request timeoutInterval] == 60.0);

    testassert([request mainDocumentURL] == nil);

    testassert([request networkServiceType] == NSURLNetworkServiceTypeDefault);

    testassert([request allowsCellularAccess] == YES);

    testassert([[request HTTPMethod] isEqualToString:@"GET"]);

    testassert([request allHTTPHeaderFields] == nil);

    testassert([request HTTPBody] == nil);

    testassert([request HTTPBodyStream] == nil);
    // radar://15366677
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
    testassert([request HTTPShouldHandleCookies] == YES);
#elif __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_1
    testassert([request HTTPShouldHandleCookies] == YES);
#endif

    testassert([request HTTPShouldUsePipelining] == NO);

    [request release];
    return YES;
}

test(MutableRequest)
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSString *shoes = @"Wearing";
    NSString *mayhem = @("ß!:\n\n\r;;\r\n\r\n\n\n\\\\ \\ '\"\\012345");

    [req setValue:shoes forHTTPHeaderField:@"Shoes"];
    [req setValue:mayhem forHTTPHeaderField:@"Mayhem"]; // This should fail to set
    [req setValue:@"ShoesValue" forHTTPHeaderField:shoes];
    [req setValue:@"MayhemValue" forHTTPHeaderField:mayhem]; // This should set successfully

    NSDictionary *dict =
    @{
        @"Shoes" : shoes,
        shoes: @"ShoesValue",
        mayhem: @"MayhemValue",
        @"Mayhem": mayhem
    };
    // This test is not really that definitive of the true backing, it should be re-written to be more isolated.
    testassert(![req.allHTTPHeaderFields isEqual:dict]);

    [req setHTTPMethod:shoes];
    testassert([req.HTTPMethod isEqual:shoes]);
    [req setHTTPMethod:mayhem];
    testassert([req.HTTPMethod isEqual:mayhem]);

    testassert([req.URL isEqual:url]);

    NSData *weirdData = [mayhem dataUsingEncoding:NSUTF8StringEncoding];

    req.HTTPBody = weirdData;

    testassert([req.HTTPBody isEqual:weirdData]);

    return YES;
}

test(AllHeaderFieldsIsCopied)
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dict = @{@"foo": @"bar"};
    [req setAllHTTPHeaderFields:dict];
    testassert(dict != [req allHTTPHeaderFields]);
    return YES;
}

test(AllHeaderFieldsIsCFDictionary)
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dict = @{@"foo": @"bar"};
    [req setAllHTTPHeaderFields:dict];
    testassert([[req allHTTPHeaderFields] isKindOfClass:[NSMutableDictionary class]]);
    BOOL thrown = NO;
    @try {
        [(NSMutableDictionary *)[req allHTTPHeaderFields] setObject:@"baz" forKey:@"foo"];
    } @catch(NSException *e) {
        thrown = YES;
        testassert([e.name isEqualToString:@"NSInternalInconsistencyException"]);
    }
    testassert(thrown);
    return YES;
}

test(CopyURLRequest)
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *dict = @{@"foo": @"bar"};
    [req setAllHTTPHeaderFields:dict];
    [req setHTTPMethod:@"POST"];
    NSData *bodyData = [@"My life for aiur" dataUsingEncoding:NSUTF8StringEncoding];
    [req setHTTPBody:bodyData];
    NSMutableURLRequest *copiedReq = [req copy];
    testassert(req != copiedReq);
    testassert([req.URL isEqual:copiedReq.URL]);
    testassert(req.URL == copiedReq.URL);
    testassert([req.HTTPMethod isEqualToString:copiedReq.HTTPMethod]);
    testassert(req.HTTPMethod == copiedReq.HTTPMethod);
    testassert([req.allHTTPHeaderFields isEqual:copiedReq.allHTTPHeaderFields]);
    testassert(req.allHTTPHeaderFields != copiedReq.allHTTPHeaderFields);
    testassert(req.HTTPBody == copiedReq.HTTPBody);
    testassert([req.HTTPBody isEqual:copiedReq.HTTPBody]);
    return YES;
}

test(Percent2BInURLRequest)
{
    // TODO: It would be nice to be able to repro this issue without relying on requesting igunpro assests.
    NSURL *url = [NSURL URLWithString:@"https://s3.amazonaws.com/igunpro/10-22%2bb78ddb3e%2bPackage.zip"];
    testassert([[url description] isEqualToString:@"https://s3.amazonaws.com/igunpro/10-22%2bb78ddb3e%2bPackage.zip"]);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    testassert(responseData.length > 10000);
    return YES;
}

test(StatusCodeAvailableInNSURLResponse)
{
    NSURLResponse* resp = [[NSURLResponse alloc] init];
    testassert(![resp respondsToSelector:@selector(statusCode)]);
    
    NSHTTPURLResponse* httpResp = [[NSHTTPURLResponse alloc] init];
    testassert([httpResp respondsToSelector:@selector(statusCode)]);
    
    return YES;
}

test(CopyNSURLResponse)
{
    NSURLResponse* resp = [[NSURLResponse alloc] init];
    testassert(resp == [resp copy]);
    
    return YES;
}

test(nullCreationOfURLRequest)
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nil];
    testassert(request != nil);
    return YES;
}

test(RequestWithNilMethod)
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apportable.com"]];
    [request setHTTPMethod:nil];
    return YES;
}

@end
