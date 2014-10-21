//
//  NSAutoreleasePool.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSAutoreleasePool.h>
#import "ForFoundationOnly.h"

@implementation NSAutoreleasePool {
    void *context;
}

+ (id)allocWithZone:(NSZone *)zone
{
    NSAutoreleasePool *pool = [super allocWithZone:zone];
    pool->context = _CFAutoreleasePoolPush();
    return pool;
}

+ (void)addObject:(id)anObject
{
    [anObject autorelease];
}

- (void)addObject:(id)anObject
{
    CFAutorelease((CFTypeRef)anObject);
}

- (id)retain
{
    return self; // retaining an autoreleasepool makes little sense
}

- (id)autorelease
{
    return self; // makes even less sense than retaining
}

- (void)drain
{
    _CFAutoreleasePoolPop(context);
    [self dealloc];
}

- (oneway void)release
{
    [self drain];
}

- (void)emptyPool
{
    _CFAutoreleasePoolPop(context);
}

@end
