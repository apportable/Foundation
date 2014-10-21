//
//  NSTimer.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSTimer.h>

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSRunLoop.h>

#import <objc/message.h>

#import "NSObjectInternal.h"

@implementation NSTimer

@end

CF_PRIVATE
@interface _NSTimerInfo : NSObject {
@package
    id target;
    SEL selector;
    id userInfo;
}
@end

@implementation _NSTimerInfo

- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector userInfo:(id)info
{
    self = [super init];

    if (self)
    {
        target = [aTarget retain];
        userInfo = [info retain];
        selector = aSelector;
    }

    return self;
}

- (void)dealloc
{
    [target release];
    [userInfo release];
    [super dealloc];
}

@end

CF_PRIVATE
@interface __NSCFTimer : NSTimer
@end

@implementation __NSCFTimer

+ (id)allocWithZone:(NSZone *)zone
{
    static __NSCFTimer *sharedTimer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTimer = [super allocWithZone:zone];
    });
    return sharedTimer;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (id)init
{
    return nil;
}

static void __NSFireTimer(__NSCFTimer *timer, _NSTimerInfo *info)
{
    @autoreleasepool
    {
        [timer retain];
        [info->target retain];
        [timer fire];
        [info->target release];
        [timer release];
    }
}

- (id)initWithFireDate:(NSDate *)fireDate interval:(NSTimeInterval)ti target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats
{
    _NSTimerInfo *timerInfo = [[_NSTimerInfo alloc] initWithTarget:target selector:selector userInfo:userInfo];

    CFRunLoopTimerContext ctx = {
        .version = 0,
        .info = timerInfo,
        .retain = &_NSCFRetain,
        .release = &_NSCFRelease,
    };

    if (repeats == NO)
    {
        ti = 0;
    }
    else if (ti < 0.0)
    {
        ti = 0.0001; // If [ti] is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
    }

    id timer = (id)CFRunLoopTimerCreate(kCFAllocatorDefault, [fireDate timeIntervalSinceReferenceDate], ti, 0, 0, (void (*)(CFRunLoopTimerRef, void *))&__NSFireTimer, &ctx);
    [timerInfo release];
    return timer;
}

- (void)fire
{
    CFRunLoopTimerContext ctx = {0};
    CFRunLoopTimerGetContext((CFRunLoopTimerRef)self, &ctx);
    ((void (*)(id, SEL, id))objc_msgSend)(((_NSTimerInfo *)ctx.info)->target, ((_NSTimerInfo *)ctx.info)->selector, self);

    if (CFRunLoopTimerDoesRepeat((CFRunLoopTimerRef)self) == NO)
    {
        CFRunLoopTimerInvalidate((CFRunLoopTimerRef)self);
    }
}

- (id)userInfo
{
    CFRunLoopTimerContext ctx = {0};
    CFRunLoopTimerGetContext((CFRunLoopTimerRef)self, &ctx);
    _NSTimerInfo *timerInfo = (_NSTimerInfo *)ctx.info;
    return timerInfo->userInfo;
}

- (void)setFireDate:(NSDate *)date
{
    CFRunLoopTimerSetNextFireDate((CFRunLoopTimerRef)self, [date timeIntervalSinceReferenceDate]);
}

- (NSDate *)fireDate
{
    CFAbsoluteTime t = CFRunLoopTimerGetNextFireDate((CFRunLoopTimerRef)self);
    return [NSDate dateWithTimeIntervalSinceReferenceDate:t];
}

- (void)invalidate
{
    CFRunLoopTimerInvalidate((CFRunLoopTimerRef)self);
}

- (NSTimeInterval)timeInterval
{
    return CFRunLoopTimerGetInterval((CFRunLoopTimerRef)self);
}

- (BOOL)isValid
{
    return CFRunLoopTimerIsValid((CFRunLoopTimerRef)self);
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating((CFTypeRef)self);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain((CFTypeRef)self) != NULL;
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)retain
{
    return (id)CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }

    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

- (NSTimeInterval)tolerance
{
    return CFRunLoopTimerGetTolerance((CFRunLoopTimerRef)self);
}

- (void)setTolerance:(NSTimeInterval)tolerance
{
    CFRunLoopTimerSetTolerance((CFRunLoopTimerRef)self, tolerance);
}

@end
