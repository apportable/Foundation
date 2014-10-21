//
//  NSThread.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSThread.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <CoreFoundation/CFRunLoop.h>
#import <CoreFoundation/CFNumber.h>
#import <pthread.h>
#import <unistd.h>
#import <objc/message.h>
#import <execinfo.h>

CFRunLoopRef _CFRunLoopGet0(pthread_t t);
CFTypeRef _CFRunLoopGet2(CFRunLoopRef rl);

NSString *const NSWillBecomeMultiThreadedNotification = @"NSWillBecomeMultiThreadedNotification";
NSString *const NSDidBecomeSingleThreadedNotification = @"NSDidBecomeSingleThreadedNotification";
NSString *const NSThreadWillExitNotification = @"NSThreadWillExitNotification";

typedef enum {
    NSThreadCreated,
    NSThreadStarted,
    NSThreadRunning,
    NSThreadCancelling,
    NSThreadEnding,
    NSThreadFinished
} NSThreadState;

static pthread_key_t NSThreadKey;

static NSThread *NSMainThread = nil;
static BOOL _NSIsMultiThreaded = NO;

static void NSThreadEnd(NSThread *thread);

static void NSThreadInitialize() __attribute__((constructor));
static void NSThreadInitialize()
{
    pthread_key_create(&NSThreadKey, (void (*)(void *))&NSThreadEnd);
    NSMainThread = [NSThread currentThread];
}

extern void __do_backtrace(int, int, int, int(*)(int, void *, char *, int, void *), void *);


CF_PRIVATE
@interface _NSThreadPerformInfo : NSObject
@end

@implementation _NSThreadPerformInfo {
@package
    id target;
    SEL selector;
    id argument;
    NSMutableArray *modes;
    NSCondition *waiter;
    BOOL *signalled;
    CFRunLoopSourceRef source;
}

- (void)dealloc
{
    [target release];
    target = nil;
    [argument release];
    argument = nil;
    [modes release];
    modes = nil;
    [waiter release];
    waiter = nil;
    if (source != NULL)
    {
        CFRelease(source);
        source = NULL;
    }
    [super dealloc];
}

@end


@interface NSThread (Internal)
- (BOOL)_setThreadPriority:(double)p;
@end

@implementation NSThread {
@package
    pthread_t _thread;
    pthread_attr_t _attr;
    NSString *_name;
    NSMutableDictionary *_threadDictionary;
    NSThreadState _state;
    NSMutableArray *_performers;
    id _target;
    SEL _selector;
    id _argument;
}

static void NSThreadEnd(NSThread *thread)
{
    @autoreleasepool {
       [[NSNotificationCenter defaultCenter] postNotificationName:NSThreadWillExitNotification object:nil userInfo:nil];
    }
    thread->_state = NSThreadFinished;
    [thread release];
}

+ (NSThread *)currentThread
{
    NSThread *thread = pthread_getspecific(NSThreadKey);
    if (thread == nil)
    {
        thread = [[NSThread alloc] init];
        thread->_thread = pthread_self();
        pthread_setspecific(NSThreadKey, thread);
    }
    return thread;
}

+ (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(id)argument
{
    NSThread *thread = [[NSThread alloc] initWithTarget:target selector:selector object:argument];
    [thread start];
    [thread release];
}

+ (BOOL)isMultiThreaded
{
    return _NSIsMultiThreaded;
}

+ (void)sleepUntilDate:(NSDate *)date
{
    [self sleepForTimeInterval:[date timeIntervalSinceNow]];
}

+ (void)sleepForTimeInterval:(NSTimeInterval)ti
{
    usleep(1000000ULL * ti);
}

+ (void)exit
{
    pthread_exit(NULL);
}

+ (double)threadPriority
{
    return [[NSThread currentThread] threadPriority];
}

+ (BOOL)setThreadPriority:(double)p
{
    return [[NSThread currentThread] _setThreadPriority:p];
}

+ (NSArray *)callStackReturnAddresses
{
    void *stack[128] = { NULL };
    int count = backtrace(stack, sizeof(stack)/sizeof(stack[0]));
    CFNumberRef returnAddresses[128] = { nil };
    for (int i = 1; i < count; i++)
    {
        returnAddresses[i - 1] = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &stack[i]);
    }

    NSArray *callStackReturnAddresses = [[NSArray alloc] initWithObjects:(id *)returnAddresses count:count - 1];

    for (int i = 1; i < count; i++) {
        CFRelease(returnAddresses[i - 1]);
    }

    return [callStackReturnAddresses autorelease];
}

static int array_add_backtrace_step(int depth, void *pc, char *cfname, int offset, void *data) 
{
    NSMutableArray *array = (NSMutableArray *)data;
    NSString *str = [[NSString alloc] initWithFormat:@"%x : (%s+0x%x)", (int)pc, cfname, offset];
    [array addObject:str];
    [str release];
    return 1;
}

+ (NSArray *)callStackSymbols
{
    NSMutableArray *array = [NSMutableArray array];
    __do_backtrace(50, 2, 1, &array_add_backtrace_step, array);
    return array;
}

+ (BOOL)isMainThread
{
    return [[NSThread currentThread] isMainThread];
}

+ (NSThread *)mainThread
{
    return NSMainThread;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _performers = [[NSMutableArray alloc] init];
        _threadDictionary = [[NSMutableDictionary alloc] init];
        _state = NSThreadCreated;
        pthread_attr_init(&_attr);
        // this is what iOS/Mac OS X seem to do, is this right for other operating systems?
        pthread_attr_setscope(&_attr, PTHREAD_SCOPE_SYSTEM);
        pthread_attr_setdetachstate(&_attr, PTHREAD_CREATE_DETACHED);
    }
    return self;
}

- (id)initWithTarget:(id)target selector:(SEL)selector object:(id)argument
{
    self = [self init];
    if (self)
    {
        _target = [target retain];
        _selector = selector;
        _argument = [argument retain];
    }
    return self;
}

- (void)dealloc
{
    [_target release];
    [_argument release];
    [_threadDictionary release];
    [_name release];
    pthread_attr_destroy(&_attr);
    [super dealloc];
}

- (NSMutableDictionary *)threadDictionary
{
    return _threadDictionary;
}

- (double)threadPriority
{
    int policy = SCHED_FIFO;
    struct sched_param schedule;
    if (pthread_getschedparam(_thread, &policy, &schedule) != 0)
    {
        return 1.0;
    }
    else
    {
        int min_priority = sched_get_priority_min(policy);
        int max_priority = sched_get_priority_max(policy);
        return (double)(schedule.sched_priority - min_priority) / (double)(max_priority - min_priority);
    }
}

- (BOOL)_setThreadPriority:(double)p
{
    int policy = SCHED_FIFO;
    struct sched_param schedule;
    if (pthread_getschedparam(_thread, &policy, &schedule) != 0)
    {
        return NO;
    }
    else
    {
        if (p > 1.0)
        {
            p = 1.0;
        }
        if (p < 0.0)
        {
            p = 0.0;
        }

        int min_priority = sched_get_priority_min(policy);
        int max_priority = sched_get_priority_max(policy);

        schedule.sched_priority = (int)p * (max_priority - min_priority) + min_priority;
        return pthread_setschedparam(_thread, policy, &schedule) == 0;
    }
}

- (void)setThreadPriority:(double)p
{
    [self _setThreadPriority:p];
}

- (void)setName:(NSString *)n
{
    if (![_name isEqualToString:n])
    {
        [_name release];
        _name = [n copy];
        if (_thread == pthread_self())
        {
            pthread_setname_np([_name UTF8String]);
        }
    }
}

- (NSString *)name
{
    if (_name == nil)
    {
        char name[17] = { '\0' };
        pthread_getname_np(_thread, name, sizeof(name) - 1);
        _name = [[NSString alloc] initWithUTF8String:name];
    }
    return _name;
}

- (NSUInteger)stackSize
{
    size_t sz = 0;
    pthread_attr_getstacksize(&_attr, &sz);
    return sz;
}

- (void)setStackSize:(NSUInteger)s
{
    if (s >= 0x40000000)
    {
        s = 0x40000000;
    }
    pthread_attr_setstacksize(&_attr, s);
}

- (BOOL)isMainThread
{
    return self == NSMainThread;
}

- (BOOL)isExecuting
{
    return _state == NSThreadRunning;
}

- (BOOL)isFinished
{
    return _state == NSThreadFinished;
}

- (BOOL)isCancelled
{
    return _state == NSThreadCancelling;
}

- (void)cancel
{
    _state = NSThreadCancelling;
}

static void *__NSThread__main__(NSThread *thread)
{
    @autoreleasepool {
        thread->_state = NSThreadRunning;
        pthread_setspecific(NSThreadKey, thread);
        [thread main];
        thread->_state = NSThreadFinished;
    }
    return NULL;
}

- (void)start
{
    if (_state > NSThreadCreated)
    {
        [NSException raise:NSInvalidArgumentException format:@"Attempting to start a thread more than once"];
        return;
    }
    _state = NSThreadStarted;
    [self retain];
    if (!_NSIsMultiThreaded)
    {
        _NSIsMultiThreaded = 1;
       [[NSNotificationCenter defaultCenter] postNotificationName:NSWillBecomeMultiThreadedNotification object:nil userInfo:nil];
    }
    pthread_create(&_thread, NULL, (void *(*)(void *))&__NSThread__main__, self);
    while (_state <= NSThreadStarted)
    {
        sched_yield();
    }
}

- (void)main
{
    if (_target && _selector)
    {
        objc_msgSend(_target, _selector, _argument);
    }
}

static void __NSThreadInfoPerformer(void *info)
{
    _NSThreadPerformInfo *performInfo = (_NSThreadPerformInfo *)info;
    @autoreleasepool {
        NSThread *t = [NSThread currentThread];
        [performInfo->target performSelector:performInfo->selector withObject:performInfo->argument];
        if (performInfo->waiter) // this check is to ensure that the signaled variable will not be stale (without interfering with a potentially dead object for the waiter)
        {
            [performInfo->waiter lock];
            *performInfo->signalled = YES;
            [performInfo->waiter signal];
            [performInfo->waiter unlock];
        }
        for (NSString *mode in performInfo->modes)
        {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), performInfo->source, (CFStringRef)mode);
        }
        performInfo->source = NULL;
        @synchronized(t) {
            [t->_performers removeObject:performInfo];
        }
    }
}

- (void)_nq:(_NSThreadPerformInfo *)info
{
    @synchronized(self) {
        [_performers addObject:info];
    }
    CFRunLoopRef rl = _CFRunLoopGet0(_thread);
    for (NSString *mode in info->modes)
    {
        CFRunLoopSourceContext ctx = {
            .version = 0,
            .info = info,
            .perform = &__NSThreadInfoPerformer,
        };
        info->source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &ctx);
        CFRunLoopAddSource(rl, info->source, (CFStringRef)mode);
        CFRelease(info->source);
        CFRunLoopSourceSignal(info->source);
    }
    CFRunLoopWakeUp(rl);
}

@end

@implementation NSObject (NSThreadPerformAdditions)

- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone modes:(NSArray *)modes
{
    [self performSelector:aSelector onThread:[NSThread mainThread] withObject:arg waitUntilDone:waitUntilDone modes:modes];
}

+ (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone modes:(NSArray *)modes
{
    [self performSelector:aSelector onThread:[NSThread mainThread] withObject:arg waitUntilDone:waitUntilDone modes:modes];   
}

- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone
{
    [self performSelector:aSelector onThread:[NSThread mainThread] withObject:arg waitUntilDone:waitUntilDone modes:@[(id)kCFRunLoopCommonModes]];
}

+ (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone
{
    [self performSelector:aSelector onThread:[NSThread mainThread] withObject:arg waitUntilDone:waitUntilDone modes:@[(id)kCFRunLoopCommonModes]];   
}

static void NSThreadPerform(id self, SEL aSelector, NSThread *thr, id arg, BOOL waitUntilDone, NSArray *modes)
{
    if ([NSThread currentThread] == thr && waitUntilDone)
    {
        objc_msgSend(self, aSelector, arg);
        return;
    }
    BOOL signalled = NO;
    _NSThreadPerformInfo *info = [[_NSThreadPerformInfo alloc] init];
    info->target = [self retain];
    info->selector = aSelector;
    info->argument = [arg retain];
    info->modes = [modes copy];
    info->signalled = &signalled;
    if (waitUntilDone)
    {
        info->waiter = [[NSCondition alloc] init];
    }
    else
    {
        info->waiter = NULL;
    }
    [thr _nq:info];
    if (waitUntilDone)
    {
        [info->waiter lock];
        if (!signalled)
        {
            [info->waiter wait];
        }
        [info->waiter unlock];
    }
    [info release];
}

- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone modes:(NSArray *)modes
{
    NSThreadPerform(self, aSelector, thr, arg, waitUntilDone, modes);
}

+ (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone modes:(NSArray *)modes
{
    NSThreadPerform(self, aSelector, thr, arg, waitUntilDone, modes);
}

- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)waitUntilDone
{
    [self performSelector:aSelector onThread:thr withObject:arg waitUntilDone:waitUntilDone modes:@[(id)kCFRunLoopCommonModes]];
}

- (void)performSelectorInBackground:(SEL)aSelector withObject:(id)arg
{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:aSelector object:arg];
    [thread start];
    [thread autorelease];
}

@end
