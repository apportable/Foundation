//
//  NSNotificationCenter.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSNotification.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSOperation.h>
#import "NSNotificationInternal.h"
#import <dispatch/dispatch.h>
#import <pthread.h>

@interface _NSNotificationObserver : NSObject

@property (nonatomic, readonly) id observer;
@property (nonatomic, readonly) SEL selector;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) NSOperationQueue *queue;
@property (nonatomic, readonly) void (^block)(NSNotification *note);

- (id)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object queue:(NSOperationQueue *)queue block:(void (^)(NSNotification *note))block;
@end

@implementation _NSNotificationObserver

- (id)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object queue:(NSOperationQueue *)queue block:(void (^)(NSNotification *note))block
{
    self = [super init];
    if (self)
    {
        _observer = observer;
        _selector = selector;
        _name = [name copy];
        _object = object;
        _queue = [queue retain];
        _block = Block_copy(block);
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_queue release];
    [_block release];
    [super dealloc];
}

- (void)postNotification:(NSNotification *)notif
{
    if (_queue != nil && _block != NULL)
    {
        #warning TODO: Should not copy. If you post an NSNotification, you should get the same object on all listeners, regardless of thread
        // make a copy for now, as recycling needs a bit of reworking
        NSConcreteNotification *notifCopy = [NSConcreteNotification newTempNotificationWithName:notif.name object:notif.object userInfo:notif.userInfo];
        [_queue addOperationWithBlock:^{
            _block(notifCopy);
            [notifCopy recycle];
        }];
    }
    else if (_block != NULL)
    {
        _block(notif);
    }
    else if (_observer != nil && _selector != NULL)
    {
        [_observer performSelector:_selector withObject:notif];
    }
}

@end

@implementation NSNotificationCenter {
    NSMutableArray *_observers;
    pthread_mutex_t _observersLock;
}

+ (id)defaultCenter
{
    static NSNotificationCenter *defaultCenter = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        defaultCenter = [[NSNotificationCenter alloc] init];
    });
    return defaultCenter;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        pthread_mutexattr_t attrs;
        pthread_mutexattr_init(&attrs);
        pthread_mutexattr_settype(&attrs, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_observersLock, &attrs);
        pthread_mutexattr_destroy(&attrs);

        _observers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_observers release];
    [super dealloc];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject
{
    _NSNotificationObserver *notifObserver = [[_NSNotificationObserver alloc] initWithObserver:observer selector:aSelector name:aName object:anObject queue:nil block:NULL];
    pthread_mutex_lock(&_observersLock);
    [_observers addObject:notifObserver];
    pthread_mutex_unlock(&_observersLock);
    [notifObserver release];
}

- (void)postNotification:(NSNotification *)notification
{
    NSString *name = [notification name];
    id object = [notification object];
    
    pthread_mutex_lock(&_observersLock);
    NSArray *observers = [_observers copy];
    pthread_mutex_unlock(&_observersLock);

    for (_NSNotificationObserver *observer in observers)
    {
        if (name == nil || observer.name == nil || [observer.name isEqualToString:name])
        {
            id obj = observer.object;
            if (object == nil || obj == nil || object == obj)
            {
                [observer postNotification:notification];
            }
        }
    }
    [observers release];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject
{
    [self postNotificationName:aName object:anObject userInfo:nil];
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    NSConcreteNotification *notif = [NSConcreteNotification newTempNotificationWithName:aName object:anObject userInfo:aUserInfo];
    [self postNotification:notif];
    [notif recycle];
}

- (void)removeObserver:(id)observer
{
    pthread_mutex_lock(&_observersLock);
    NSIndexSet *indicies = [_observers indexesOfObjectsPassingTest:^BOOL(_NSNotificationObserver *notifObserver, NSUInteger idx, BOOL *stop) {
        // observer may be a user controlled object, or an instance of _NSNotificationObserver if the block version of 
        // addObserverForName was used
        return notifObserver == observer || notifObserver.observer == observer;
    }];
    [_observers removeObjectsAtIndexes:indicies];
    pthread_mutex_unlock(&_observersLock);
}

- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject
{
    pthread_mutex_lock(&_observersLock);
    NSIndexSet *indicies = [_observers indexesOfObjectsPassingTest:^BOOL(_NSNotificationObserver *notifObserver, NSUInteger idx, BOOL *stop) {
        BOOL matchesObject = YES;
        if (anObject != nil)
        {
            matchesObject = notifObserver.object == anObject;
        }
        return notifObserver.observer == observer && matchesObject && [notifObserver.name isEqualToString:aName];
    }];
    [_observers removeObjectsAtIndexes:indicies];
    pthread_mutex_unlock(&_observersLock);
}

- (id)addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block
{
    _NSNotificationObserver *notifObserver = [[_NSNotificationObserver alloc] initWithObserver:nil selector:NULL name:name object:obj queue:queue block:block];
    pthread_mutex_lock(&_observersLock);
    [_observers addObject:notifObserver];
    pthread_mutex_unlock(&_observersLock);
    [notifObserver release];
    return notifObserver;
}

@end
