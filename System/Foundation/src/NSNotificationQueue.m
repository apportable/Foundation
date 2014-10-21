//
//  NSNotificationQueue.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSNotificationQueue.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>

static NSString *NSDefaultNotificationQueue = @"NSDefaultNotificationQueue";

@implementation NSNotificationQueue {
    NSNotificationCenter *_notificationCenter;
    NSMutableArray *_asapQueue;
    NSMutableArray *_asapObs;
    NSMutableArray *_idleQueue;
    NSMutableArray *_idleObs;
}

+ (id)defaultQueue
{
    NSMutableDictionary *tls = [[NSThread currentThread] threadDictionary];
    NSNotificationQueue *queue = [tls objectForKey:NSDefaultNotificationQueue];
    if (queue == nil)
    {
        queue = [[NSNotificationQueue alloc] init];
        [tls setObject:queue forKey:NSDefaultNotificationQueue];
        [queue release];
    }
    return queue;
}

- (id)init
{
    return [self initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
}

- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = [super init];
    if (self)
    {
        _notificationCenter = [notificationCenter retain];
        _asapQueue = [[NSMutableArray alloc] init];
        _asapObs = nil;
        _idleQueue = [[NSMutableArray alloc] init];
        _idleObs = nil;
    }
    return self;
}

- (void)dealloc
{
    [self _flushNotificationQueue];
    [_notificationCenter release];
    [super dealloc];
}

- (void)enqueueNotification:(NSNotification *)notification postingStyle:(NSPostingStyle)postingStyle
{
    [self enqueueNotification:notification postingStyle:postingStyle coalesceMask:NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender forModes:@[NSDefaultRunLoopMode]];
}

static BOOL coalesceNotification(NSNotification *notification, NSUInteger coalesceMask, NSMutableArray *array, BOOL remove)
{
    if (coalesceMask == NSNotificationNoCoalescing)
    {
        return NO;
    }

    NSString *name = notification.name;
    id object = notification.object;
    for (NSNotification *notif in array)
    {
        if ((coalesceMask & NSNotificationCoalescingOnName) &&
            ![notif.name isEqualToString:name])
        {
            continue;
        }
        if ((coalesceMask & NSNotificationCoalescingOnSender) &&
            notif.object != object) // not-a-bug: no isEqual is called here.
        {
            continue;
        }

        if (remove)
        {
            [array removeObject:notif];
        }
        return YES;
    }

    return NO;
}

static void postNotifications(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    NSMutableArray *queue = (NSMutableArray *)info;
    while ([queue count])
    {
        // Investigate: where is the _notificationCenter used?
        // it does not seem to be referenced out side of init/dealloc...
        // would have expected it to be used here
        [[NSNotificationCenter defaultCenter] postNotification:[queue firstObject]];
        [queue removeObjectAtIndex:0];
    }
}

- (void)enqueueNotification:(NSNotification *)notification postingStyle:(NSPostingStyle)postingStyle coalesceMask:(NSUInteger)coalesceMask forModes:(NSArray *)modes
{
    if (modes == nil)
    {
        modes = @[NSDefaultRunLoopMode];
    }

    if (_asapQueue == nil)
    {
        _asapQueue = [[NSMutableArray alloc] init];
    }

    if (_idleQueue == nil)
    {
        _idleQueue = [[NSMutableArray alloc] init];
    }

    switch (postingStyle)
    {
        case NSPostWhenIdle:
            if (coalesceNotification(notification, coalesceMask, _asapQueue, NO) ||
                coalesceNotification(notification, coalesceMask, _idleQueue, NO))
            {
                return;
            }
            break;
        case NSPostASAP:
            coalesceNotification(notification, coalesceMask, _idleQueue, YES);
            if (coalesceNotification(notification, coalesceMask, _asapQueue, NO))
            {
                return;
            }
            break;
        case NSPostNow:
            coalesceNotification(notification, coalesceMask, _asapQueue, YES);
            coalesceNotification(notification, coalesceMask, _idleQueue, YES);
            break;
    }

    CFRunLoopObserverRef observer = NULL;
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFRunLoopObserverContext ctx = {
        .version = 0,
        .retain = &CFRetain,
        .release = &CFRelease,
        .copyDescription = &CFCopyDescription
    };
    switch (postingStyle)
    {
        case NSPostWhenIdle:
            ctx.info = _idleQueue;
            [_idleQueue addObject:notification];
            observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, false, 0, &postNotifications, &ctx);
            for (NSString *mode in modes)
            {
                CFRunLoopAddObserver(rl, observer, (CFStringRef)mode);
            }
            break;
        case NSPostASAP:
            ctx.info = _asapQueue;
            [_asapQueue addObject:notification];
            observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, false, 0, &postNotifications, &ctx);
            for (NSString *mode in modes)
            {
                CFRunLoopAddObserver(rl, observer, (CFStringRef)mode);
            }
            break;
        case NSPostNow:
            postNotifications(NULL, 0, [NSMutableArray arrayWithObject:notification]);
            break;
    }
    if (observer != NULL)
    {
        CFRelease(observer);
    }
}

- (void)dequeueNotificationsMatching:(NSNotification *)notification coalesceMask:(NSUInteger)coalesceMask
{
    coalesceNotification(notification, coalesceMask, _asapQueue, YES);
    coalesceNotification(notification, coalesceMask, _idleQueue, YES);
}


- (void)_flushNotificationQueue
{
    [_asapQueue release];
    [_idleQueue release];
    _asapQueue = nil;
    _idleQueue = nil;
}


@end
