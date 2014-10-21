//
//  NSRunLoop.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSRunLoop.h>
#import <Foundation/NSException.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSPort.h>
#import <Foundation/NSNotification.h>
#import "CFInternal.h"
#import <libkern/OSAtomic.h>

CF_EXPORT CFTypeRef _CFRunLoopGet2(CFRunLoopRef rl); //locking version
CF_EXPORT CFTypeRef _CFRunLoopGet2b(CFRunLoopRef rl); //non locking version
CF_EXPORT CFTypeRef _CFRunLoopSet2(CFRunLoopRef rl, CFTypeRef (*counterpartProvider)(CFRunLoopRef));
CF_EXPORT Boolean _CFRunLoopFinished(CFRunLoopRef rl, CFStringRef modeName);

typedef struct {
    id object;
    SEL selector;
    id argument;
    CFRunLoopTimerRef timer;
    NSArray *modes;
    int retainCount;
} NSDelayedPerformer;

static const void *NSDelayedPerformerRetain(const void *info)
{
    NSDelayedPerformer *performer = (NSDelayedPerformer *)info;
    performer->retainCount = OSAtomicIncrement32(&performer->retainCount);
    return performer;
}

static void NSDelayedPerformerRelease(const void *info)
{
    NSDelayedPerformer *performer = (NSDelayedPerformer *)info;
    if (OSAtomicDecrement32(&performer->retainCount) <= 0) {
        [performer->modes release];
        [performer->object release];
        [performer->argument release];
        free(performer);
    }
}

static CFStringRef NSDelayedPerformerCopyDescription(const void *info)
{
    return CFSTR("NSDelayedPerformer");
}

@interface _NSRunLoopInfo : NSObject
@property (nonatomic, retain) NSPort *port;
@property (nonatomic, copy) NSString *mode;
@end

@implementation _NSRunLoopInfo

- (void)dealloc
{
    self.port = nil;
    self.mode = nil;
    [super dealloc];
}

@end

@implementation NSRunLoop

static CFTypeRef NSRunLoopProvider(CFRunLoopRef rl)
{
    return [NSRunLoop _new:rl];
}

+ (NSRunLoop *)currentRunLoop
{
    NSRunLoop *runLoop = nil;
    @autoreleasepool {
        CFRunLoopRef rl = CFRunLoopGetCurrent();
        runLoop = (NSRunLoop *)_CFRunLoopSet2(rl, &NSRunLoopProvider);
    }
    return runLoop;
}

+ (NSRunLoop *)mainRunLoop
{
    NSRunLoop *runLoop = nil;
    @autoreleasepool {
        CFRunLoopRef rl = CFRunLoopGetMain();
        runLoop = (NSRunLoop *)_CFRunLoopSet2(rl, &NSRunLoopProvider);
    }
    return runLoop;
}

+ (id)_new:(CFRunLoopRef)loop
{
    NSRunLoop *rl = [NSRunLoop alloc];
    rl->_rl = loop;
    rl->_dperf = [[NSMutableArray alloc] init];
    rl->_perft = [[NSMutableArray alloc] init];
    rl->_info = [[NSMutableArray alloc] init];
    rl->_ports = [[NSCountedSet alloc] init];
    return rl;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dperf release];
    _dperf = nil;
    [_perft release];
    _perft = nil;
    [_info release];
    _info = nil;
    [_ports release];
    _ports = nil;
    [super dealloc];
}

- (NSString *)currentMode
{
    return [(NSString *)CFRunLoopCopyCurrentMode(_rl) autorelease];
}

- (NSArray *)allModes
{
    return [(NSArray *)CFRunLoopCopyAllModes(_rl) autorelease];
}

- (void)_wakeup
{
    CFRunLoopStop(_rl);
    CFRunLoopWakeUp(_rl);
}

- (CFRunLoopRef)getCFRunLoop
{
    return _rl;
}

- (void)addTimer:(NSTimer *)timer forMode:(NSString *)mode
{
    if (mode == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Mode cannot be nil"];
        return;
    }

    if ([mode isEqual:@"NSDefaultRunLoopMode"]) // Forgives mistakes of old APIs
    {
        mode = NSDefaultRunLoopMode;
    }

    CFRunLoopAddTimer(_rl, (CFRunLoopTimerRef)timer, (CFStringRef)mode);
}

- (void)_enumerateInfoPairsWithBlock:(BOOL(^)(_NSRunLoopInfo *info))block
{
    // this probably could be done via a faster storage tactic; however it is a NSMutableArray backing so we are somewhat limited
    for (_NSRunLoopInfo *info in _info)
    {
        if (block(info))
        {
            break;
        }
    }
}

- (BOOL)_containsPort:(NSPort *)aPort forMode:(NSString *)mode
{
    __block BOOL contained = NO;
    @synchronized(self)
    {
        [self _enumerateInfoPairsWithBlock:^(_NSRunLoopInfo *info){
            contained = (info.port == aPort && [mode isEqualToString:info.mode]);
            return contained;
        }];
    }
    return contained;
}

- (void)_portInvalidated:(NSNotification *)notif
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPortDidBecomeInvalidNotification object:[notif object]];
}

- (void)_addPort:(NSPort *)aPort forMode:(NSString *)mode
{
    @synchronized(self)
    {
        BOOL scheduled = [self _containsPort:aPort forMode:mode];
        [_ports addObject:aPort];
        if (!scheduled)
        {
            [aPort scheduleInRunLoop:self forMode:mode];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_portInvalidated:) name:NSPortDidBecomeInvalidNotification object:aPort];
}

- (void)addPort:(NSPort *)aPort forMode:(NSString *)mode
{
    if (mode == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Mode cannot be nil"];
        return;
    }

    if (aPort == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"port cannot be nil"];
        return;
    }

    if ([mode isEqual:@"NSDefaultRunLoopMode"])
    {
        mode = NSDefaultRunLoopMode;
    }

    [self _addPort:aPort forMode:mode];
}

- (void)_removePort:(NSPort *)aPort forMode:(NSString *)mode
{
    @synchronized(self)
    {
        __block _NSRunLoopInfo *found = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPortDidBecomeInvalidNotification object:aPort];
        [self _enumerateInfoPairsWithBlock:^(_NSRunLoopInfo *info){
            BOOL contained = (info.port == aPort && [mode isEqualToString:info.mode]);
            if (contained)
            {
                found = info;
            }
            return contained;
        }];
        [_info removeObject:found];
    }
}

- (void)removePort:(NSPort *)aPort forMode:(NSString *)mode
{
    if (mode == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Mode cannot be nil"];
        return;
    }

    if ([mode isEqual:@"NSDefaultRunLoopMode"])
    {
        mode = NSDefaultRunLoopMode;
    }

    [self _removePort:aPort forMode:mode];
}

- (NSDate *)limitDateForMode:(NSString *)mode
{
    if (mode == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Mode cannot be nil"];
        return nil;
    }

    if (CFRunLoopGetCurrent() != _rl) // Tsk tsk... sweeping errors under the rug?
    {
        return nil;
    }

    if ([mode isEqual:@"NSDefaultRunLoopMode"])
    {
        mode = NSDefaultRunLoopMode;
    }

    CFRunLoopRunInMode((CFStringRef)mode, 0, true);
    if (_CFRunLoopFinished(_rl, (CFStringRef)mode))
    {
        return nil;
    }

    CFAbsoluteTime t = CFRunLoopGetNextTimerFireDate(_rl, (CFStringRef)mode);

    return [NSDate dateWithTimeIntervalSinceReferenceDate:t];
}

- (void)acceptInputForMode:(NSString *)mode beforeDate:(NSDate *)limitDate
{
    if (mode == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Mode cannot be nil"];
        return;
    }

    if (CFRunLoopGetCurrent() != _rl)
    {
        return;
    }

    if ([mode isEqual:@"NSDefaultRunLoopMode"])
    {
        mode = NSDefaultRunLoopMode;
    }

    CFRunLoopRunInMode((CFStringRef)mode, [limitDate timeIntervalSinceReferenceDate], true);
}


@end

@implementation NSRunLoop (NSRunLoopConveniences)

- (void)run
{
    BOOL moreWork = YES;
    do {
        moreWork = [self runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (moreWork);

}

- (void)runUntilDate:(NSDate *)limitDate
{
    NSDate *date = [limitDate retain];
    BOOL moreWork = YES;
    while (CFAbsoluteTimeGetCurrent() < [date timeIntervalSinceReferenceDate] && moreWork)
    {
        moreWork = [self runMode:NSDefaultRunLoopMode beforeDate:date];
    }
    [date release];
}

- (BOOL)runMode:(NSString *)mode beforeDate:(NSDate *)limitDate
{
    if (mode == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Mode cannot be nil"];
        return NO;
    }

    if ([mode isEqual:@"NSDefaultRunLoopMode"])
    {
        mode = NSDefaultRunLoopMode;
    }

    BOOL moreWork = NO;

    if (!_CFRunLoopFinished(_rl, (CFStringRef)mode))
    {
        CFTimeInterval t = [limitDate timeIntervalSinceNow];
        @autoreleasepool {
            moreWork = CFRunLoopRunInMode((CFStringRef)mode, t, true) == kCFRunLoopRunHandledSource;
        }
    }

    return moreWork;
}

@end

/*
 1) These methods mutate in a thread safe manner; it seems that they are synchronized to the array of performer timers.
 2) There is no class that contains the performer (it appears to be just a struct)
 3) There looks to be exception swallowing here too; perhaps it is handled somehow?
 4) delayed performers and timed performers do not contend on each other
 */

@implementation NSObject (NSDelayedPerforming)

static void __NSFireDelayedPerform(CFRunLoopTimerRef timer, void *info)
{
    NSDelayedPerformer *performer = (NSDelayedPerformer *)info;
    @autoreleasepool {
        [performer->object performSelector:performer->selector withObject:performer->argument];
    }
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    @synchronized(rl->_perft) {
        [rl->_perft removeObject:(id)performer->timer];
        for (NSString *mode in performer->modes)
        {
            CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), performer->timer, (CFStringRef)mode);
        }
    }
}

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes
{
    NSDelayedPerformer *performer = malloc(sizeof(NSDelayedPerformer));
    performer->object = [self retain];
    performer->selector = aSelector;
    performer->argument = [anArgument retain];
    performer->modes = [modes copy];
    performer->retainCount = 1;

    CFRunLoopTimerContext ctx = {
        0,
        performer,
        &NSDelayedPerformerRetain,
        &NSDelayedPerformerRelease,
        &NSDelayedPerformerCopyDescription
    };

    performer->timer= CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + delay, delay, 0, 0, &__NSFireDelayedPerform, &ctx);
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    CFRunLoopRef loop = [rl getCFRunLoop];
    @synchronized(rl->_perft) {
        [rl->_perft addObject:(id)performer->timer];
        for (NSString *mode in modes)
        {
            CFRunLoopAddTimer(loop, performer->timer, (CFStringRef)mode);
        }
    }
    NSDelayedPerformerRelease(performer);
    CFRelease(performer->timer);
}

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay
{
    [self performSelector:aSelector withObject:anArgument afterDelay:delay inModes:@[NSDefaultRunLoopMode]];
}

+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument
{
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    @synchronized(rl->_perft) {
        NSMutableArray *perfomerList = [rl->_perft copy];
        for (id timer in perfomerList)
        {
            CFRunLoopTimerContext ctx;
            CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &ctx);
            NSDelayedPerformer *performer = (NSDelayedPerformer *)ctx.info;
            if (performer->object == aTarget && performer->selector == aSelector && (performer->argument == anArgument || [performer->argument isEqual:anArgument]))
            {
                CFRunLoopTimerInvalidate((CFRunLoopTimerRef)timer);
                [rl->_perft removeObject:timer];
            }
        }
        [perfomerList release];
    }
}

+ (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget
{
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    @synchronized(rl->_perft) {
        NSMutableArray *perfomerList = [rl->_perft copy];
        for (id timer in perfomerList)
        {
            CFRunLoopTimerContext ctx;
            CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &ctx);
            NSDelayedPerformer *performer = (NSDelayedPerformer *)ctx.info;
            if (performer->object == aTarget)
            {
                CFRunLoopTimerInvalidate((CFRunLoopTimerRef)timer);
                [rl->_perft removeObject:timer];
            }
        }
        [perfomerList release];
    }
}

@end

@implementation NSRunLoop (NSOrderedPerform)

- (void)performSelector:(SEL)aSelector target:(id)target argument:(id)arg order:(NSUInteger)order modes:(NSArray *)modes
{
    NSDelayedPerformer *performer = malloc(sizeof(NSDelayedPerformer));
    performer->object = [target retain];
    performer->selector = aSelector;
    performer->argument = [arg retain];
    performer->modes = [modes copy];
    performer->retainCount = 1;

    CFRunLoopTimerContext ctx = {
        .version = 0,
        .info = performer,
        .retain = &NSDelayedPerformerRetain,
        .release = &NSDelayedPerformerRelease,
        .copyDescription = &NSDelayedPerformerCopyDescription
    };

    performer->timer= CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent(), 0.0, 0, order, &__NSFireDelayedPerform, &ctx);
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    CFRunLoopRef loop = [rl getCFRunLoop];
    @synchronized(rl->_dperf) {
        [rl->_dperf addObject:(id)performer->timer];
        for (NSString *mode in modes)
        {
            CFRunLoopAddTimer(loop, performer->timer, (CFStringRef)mode);
        }
    }
    NSDelayedPerformerRelease(performer);
    CFRelease(performer->timer);
}

- (void)cancelPerformSelector:(SEL)aSelector target:(id)target argument:(id)arg
{
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    @synchronized(rl->_dperf) {
        NSMutableArray *perfomerList = [rl->_dperf copy];
        for (id timer in perfomerList)
        {
            CFRunLoopTimerContext ctx;
            CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &ctx);
            NSDelayedPerformer *performer = (NSDelayedPerformer *)ctx.info;
            if (performer->object == target && performer->selector == aSelector && performer->argument == arg)
            {
                CFRunLoopTimerInvalidate((CFRunLoopTimerRef)timer);
                [rl->_dperf removeObject:timer];
            }
        }
        [perfomerList release];
    }
}

- (void)cancelPerformSelectorsWithTarget:(id)target
{
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    @synchronized(rl->_dperf) {
        NSMutableArray *perfomerList = [rl->_dperf copy];
        for (id timer in perfomerList)
        {
            CFRunLoopTimerContext ctx;
            CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &ctx);
            NSDelayedPerformer *performer = (NSDelayedPerformer *)ctx.info;
            if (performer->object == target)
            {
                CFRunLoopTimerInvalidate((CFRunLoopTimerRef)timer);
                [rl->_dperf removeObject:timer];
            }
        }
        [perfomerList release];
    }
}

@end
