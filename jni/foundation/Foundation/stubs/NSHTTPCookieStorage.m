//
//  NSHTTPCookieStorage.m
//  
//
//  Created by Philippe Hausler on 12/12/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>

#ifndef NSUIntegerMax
#define NSUIntegerMax   ULONG_MAX
#endif

@implementation NSHTTPCookieStorage
static NSHTTPCookieStorage *sharedInstance = NULL;

+ (NSHTTPCookieStorage *)sharedHTTPCookieStorage
{
    @synchronized(self) {
        if(sharedInstance == NULL) 
        {
            [[[self alloc] init] autorelease];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if(sharedInstance == NULL) 
        {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

- (NSArray *)cookies
{
    return [NSArray array];
}

@end
