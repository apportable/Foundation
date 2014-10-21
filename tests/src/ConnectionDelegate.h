//
//  ConnectionDelegate.h
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionDelegate : NSObject<NSURLConnectionDelegate>

@property (nonatomic, retain) NSMutableData *resultData;

@property (nonatomic, retain) NSError *error;

@property (nonatomic, assign) BOOL done;

@property (nonatomic, assign) BOOL didRedirect;

@end

@interface FullConnectionDelegate : ConnectionDelegate
@property (nonatomic, assign) NSInteger willSendRequestCount;
@property (nonatomic, assign, readwrite) BOOL shouldAlterCachedResponseData;
@property (nonatomic, assign, readwrite) BOOL shouldKillCachedResponse;
@property (nonatomic, assign, readwrite) BOOL shouldKillRedirectRequest;
@property (nonatomic, assign) BOOL didKillCachedResponse;
@property (nonatomic, assign) BOOL didAlterCachedResponseData;
@property (nonatomic, assign) BOOL didKillRedirectRequest;
@property (nonatomic, retain) NSCachedURLResponse *cachedURLResponse;
@property (nonatomic, retain) NSURLResponse *firstRedirectResponseReceived;
@end

