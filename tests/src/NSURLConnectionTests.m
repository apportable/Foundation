//
//  NSURLConnectionTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import "ConnectionDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

#define HOST @"http://apportableplayground.herokuapp.com"
#define ALBIE_PROFILE_ORIGINAL_URL @"https://graph.facebook.com/100004655439664/picture?type=square&return_ssl_resources=1"
#define TIMEOUT 50

@testcase(NSURLConnection)
/* pulled from Crypto Exercise
 * https://developer.apple.com/library/ios/samplecode/CryptoExercise/Introduction/Intro.html#//apple_ref/doc/uid/DTS40008019
 */
- (BOOL)isNetworkAvailableFlags:(SCNetworkReachabilityFlags *)outFlags {
	SCNetworkReachabilityRef	defaultRouteReachability;
	struct sockaddr_in			zeroAddress;
	
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	
	SCNetworkReachabilityFlags flags;
	BOOL gotFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	if (!gotFlags) {
        return NO;
    }
    
    // kSCNetworkReachabilityFlagsReachable indicates that the specified nodename or address can
	// be reached using the current network configuration.
	BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
	
	// This flag indicates that the specified nodename or address can
	// be reached using the current network configuration, but a
	// connection must first be established.
	//
	// If the flag is false, we don't have a connection. But because CFNetwork
    // automatically attempts to bring up a WWAN connection, if the WWAN reachability
    // flag is present, a connection is not required.
	BOOL noConnectionRequired = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
		noConnectionRequired = YES;
	}
	
	// Callers of this method might want to use the reachability flags, so if an 'out' parameter
	// was passed in, assign the reachability flags to it.
	if (outFlags) {
		*outFlags = flags;
	}
	
	return isReachable && noConnectionRequired;
}

//this will say it passes when online, 100% of the time, to really test it turn off wifi
test(testOfflineMode)
{
    //only run this test if there is no network connection
    if (![self isNetworkAvailableFlags:NULL])
    {
        ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressed", HOST]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
        [connection start];
        NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
        NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
        
        testassert(delegate.error != nil);
    }
    return YES;
}

test(nullURLinRequest)
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nil];
    NSURLResponse *resp = nil;
    NSError *err = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    testassert(result == nil);
    testassert(resp == nil);
    testassert(err != nil);
#if defined(__IPHONE_8_0)
    testassert(err.code == NSURLErrorUnsupportedURL);
#else
    testassert(err.code == NSURLErrorBadURL);
#endif
    testassert([[err domain] isEqualToString:NSURLErrorDomain]);
    return YES;
}

test(Synchronous)
{
    NSString *urlStr = [NSString stringWithFormat:@"http://www.apportable.com"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    testassert([data length] > 0);
    return YES;
}

test(SSL3TLS1)
{
    NSString *urlStr = [NSString stringWithFormat:@"https://www.google.com"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    testassert([data length] > 0);
    return YES;
}

#ifdef CRASH_TODO

test(SynchronousHTTPS)
{
    NSString *urlStr = [NSString stringWithFormat:@"https://apportableplayground.herokuapp.com/hamletInTheRaw"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    NSString *hamlet = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
#if __LP64__
    testassert([hamlet hash] == 14636902918340609984ull);
#else
    testassert([hamlet hash] == 2475820992u);
#endif
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(GZip)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressed", HOST]];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);

    NSData *expectedData = [@"Hello World" dataUsingEncoding:NSUTF8StringEncoding];
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    testassert([delegate.resultData isEqualToData:expectedData]);
    return YES;
}

#endif

/* This test is a bit abusive and takes some time so it should stay commented out unless you want to test is outright
test(LargeNumberofRequestsInSuccession)
{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apportableplayground.herokuapp.com/hamletInTheRaw"]];

    for(int i = 0; i < 1030; i++)
    {
        @autoreleasepool {
            ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
            NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:5];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
            [connection start];
            NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
            } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
        }
    }
    return YES;
}*/

test(HamletRaw)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/hamletInTheRaw", HOST]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
#if __LP64__
    testassert([hamlet hash] == 14636902918340609984ull);
#else
    testassert([hamlet hash] == 2475820992u);
#endif
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

#ifdef LONG_RUNNING

test(HamletRawWithDelay)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/hamletInTheRawWithKeepAliveAndDelay", HOST]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
#if __LP64__
    testassert([hamlet hash] == 14636902918340609984ull);
#else
    testassert([hamlet hash] == 2475820992u);
#endif
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

#endif

test(HamletGzipped)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressedHamlet", HOST]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
#if __LP64__
    testassert([hamlet hash] == 14636902918340609984ull);
#else
    testassert([hamlet hash] == 2475820992u);
#endif
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(HamletGzipped2)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderCompressedHamletWithKeepAliveAndDelay", HOST]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
    
    testassert(delegate.done == YES);
    testassert(delegate.error == nil);
    
    NSString *hamlet = [[[NSString alloc] initWithData:[delegate resultData] encoding:NSUTF8StringEncoding] autorelease];
    
    testassert([hamlet length] == 193080);
#if __LP64__
    testassert([hamlet hash] == 14636902918340609984ull);
#else
    testassert([hamlet hash] == 2475820992u);
#endif
    NSString *thouArtSlain = [hamlet substringWithRange:NSMakeRange(188534, 14)];
    
    testassert([thouArtSlain isEqualToString:@"thou art slain"]);
    return YES;
}

test(GZipDecodeFail)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gzipHeaderUnCompressed", HOST]];
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);

    testassert(delegate.done == YES);
    testassert(delegate.error != nil);
    testassert(delegate.error.code == -1015);
    testassert(delegate.resultData.length == 0);
    return YES;
}

test(SimplePost)
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/simplePost", HOST]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:@"POST"];
    NSError *err = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
    testassert(data.length > 0);
    testassert(response != nil);
    testassert(err == nil);
    testassert([[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] isEqualToString:@"Hello World"]);
    return YES;
}

test(PostWithBodyFromData)
{
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/postWithFormBody", HOST]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    [theRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:@"POST"];
    const char *body = "uuid=BFFC8B8B-C0B9-4C87-8AC3-E1B53469B642&happendtime=1390104433&modtime=1390104433&rectime=1390104433&myrefercode=BJZZZv&refereecode=3333";
    [theRequest setHTTPBody:[NSData dataWithBytes:body length:strlen(body)]];
    NSError *err = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&err];
    testassert(data.length > 0);
    testassert(response != nil);
    testassert(err == nil);
    testassert([[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] isEqualToString:@"{\"uuid\":\"BFFC8B8B-C0B9-4C87-8AC3-E1B53469B642\",\"happendtime\":\"1390104433\",\"modtime\":\"1390104433\",\"rectime\":\"1390104433\",\"myrefercode\":\"BJZZZv\",\"refereecode\":\"3333\"}"]);
    return YES;
}

test(Redirection)
{
    ConnectionDelegate *delegate = [[[ConnectionDelegate alloc] init] autorelease];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ALBIE_PROFILE_ORIGINAL_URL]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:theRequest delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);

    testassert(delegate.done);
    testassert(delegate.didRedirect);
    testassert(delegate.resultData.length != 0);
    
    return YES;
}


test(KillRequestRedirect)
{
    FullConnectionDelegate *delegate = [[[FullConnectionDelegate alloc] init] autorelease];
    delegate.shouldKillRedirectRequest = YES;
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ALBIE_PROFILE_ORIGINAL_URL]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:theRequest delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while (!delegate.done && [NSDate timeIntervalSinceReferenceDate] < TIMEOUT + start);
    
    testassert(delegate.done);
    testassert(delegate.didKillRedirectRequest);
    testassert(delegate.didRedirect == NO);
    testassert(delegate.resultData.length == 0);
    
    return YES;
}

#ifdef LONG_RUNNING
test(CancelHTTPSConnection)
{
    FullConnectionDelegate *delegate = [[[FullConnectionDelegate alloc] init] autorelease];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ALBIE_PROFILE_ORIGINAL_URL]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:TIMEOUT];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:theRequest delegate:delegate];
    [connection start];
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT];
    [connection performSelector:@selector(cancel) withObject:nil afterDelay:0.1];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
    } while ([timeoutDate laterDate:[NSDate date]] == timeoutDate); // no other way to prevent
                                                                      // the connection from going into limbo
    return YES;
}
#endif

@end
