//
//  NSTimer.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSTimer.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSRunLoop.h>
#import "NSObjectInternal.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

@implementation NSTimer (NSTimer)

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSTimer class])
    {
        static dispatch_once_t once = 0L;
        static NSTimer *placeholder = nil;
        dispatch_once(&once, ^{
            placeholder = [objc_getClass("__NSCFTimer") allocWithZone:zone];
        });
        return placeholder;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

OBJC_PROTOCOL_IMPL_PUSH
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
{
    [invocation retainArguments];
    return [[[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:invocation selector:@selector(invoke) userInfo:nil repeats:yesOrNo] autorelease];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
{
    [invocation retainArguments];
    NSTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:invocation selector:@selector(invoke) userInfo:nil repeats:yesOrNo];
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), (CFRunLoopTimerRef)timer, kCFRunLoopDefaultMode);
    return [timer autorelease];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    return [[[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:aTarget selector:sel userInfo:userInfo repeats:yesOrNo] autorelease];
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    NSTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:aTarget selector:sel userInfo:userInfo repeats:yesOrNo];
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), (CFRunLoopTimerRef)timer, kCFRunLoopDefaultMode);
    return [timer autorelease];
}

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (void)fire
{
    NSRequestConcreteImplementation();
}

- (NSDate *)fireDate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)setFireDate:(NSDate *)date
{
    NSRequestConcreteImplementation();
}

- (NSTimeInterval)timeInterval
{
    NSRequestConcreteImplementation();
    return 0.0;
}

- (void)invalidate
{
    NSRequestConcreteImplementation();
}

- (BOOL)isValid
{
    NSRequestConcreteImplementation();
    return NO;
}

- (id)userInfo
{
    NSRequestConcreteImplementation();
    return nil;
}
OBJC_PROTOCOL_IMPL_POP

- (CFTypeID)_cfTypeID
{
    return CFRunLoopTimerGetTypeID();
}

@end
