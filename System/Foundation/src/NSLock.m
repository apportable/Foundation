//
//  NSLock.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSLock.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDate.h>
#import "NSObjectInternal.h"
#import <pthread.h>
#import <errno.h>

static inline void __NSLockError(id lock, SEL cmd, const char *problem)
{
    NSLog(@"Called -[%@ %@] on %@ while %s. Break on %s to debug.", [lock class], NSStringFromSelector(cmd), lock, problem, __FUNCTION__);
}

static inline void whileLocked(id lock, SEL cmd)
{
    __NSLockError(lock, cmd, "locked");
}

static inline void whileUnlocked(id lock, SEL cmd)
{
    __NSLockError(lock, cmd, "not locked");
}

static inline void sameThread(id lock, SEL cmd)
{
    __NSLockError(lock, cmd, "already locked from the same thread");
}

static inline void differentThread(id lock, SEL cmd)
{
    __NSLockError(lock, cmd, "locked from another thread");
}

static inline void lockCheck(id lock, SEL cmd, pthread_t thread)
{
    if (UNLIKELY(pthread_equal(thread, pthread_self()) != 0))
    {
        sameThread(lock, cmd);
    }
}

static inline void unlockCheck(id lock, SEL cmd, pthread_t thread)
{
    if (UNLIKELY(pthread_equal(thread, 0) != 0))
    {
        whileUnlocked(lock, cmd);
    }
    else if (UNLIKELY(pthread_equal(thread, pthread_self()) == 0))
    {
        differentThread(lock, cmd);
    }
}

static inline void waitCheck(id lock, SEL cmd, pthread_t thread)
{
    if (UNLIKELY(pthread_equal(thread, 0) != 0))
    {
        whileUnlocked(lock, cmd);
    }
    else if (UNLIKELY(pthread_equal(thread, pthread_self()) == 0))
    {
        differentThread(lock, cmd);
    }
}

@implementation NSLock {
    pthread_t _thread;
    pthread_mutex_t _lock;
    NSString *_name;
    BOOL _isInitialized;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _isInitialized = YES;
        if (UNLIKELY(pthread_mutex_init(&_lock, NULL) != 0))
        {
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_isInitialized)
    {
        if (UNLIKELY(pthread_mutex_destroy(&_lock) == EBUSY))
        {
            whileLocked(self, _cmd);
        }
    }
    [_name release];
    [super dealloc];
}

- (void)lock
{
    lockCheck(self, _cmd, _thread);

    if (!_isInitialized)
    {
        _thread = pthread_self();
        return;
    }

    pthread_mutex_lock(&_lock);
    _thread = pthread_self();
}

- (void)unlock
{
    unlockCheck(self, _cmd, _thread);

    if (!_isInitialized)
    {
        _thread = 0;
        return;
    }

    _thread = 0;

    if (UNLIKELY(pthread_mutex_unlock(&_lock) == EPERM))
    {
        whileUnlocked(self, _cmd);
    }
}

- (BOOL)tryLock
{
    if (!_isInitialized)
    {
        return NO;
    }
    BOOL success = pthread_mutex_trylock(&_lock) == 0;
    if (success)
    {
        _thread = pthread_self();
    }
    return success;
}

- (BOOL)lockBeforeDate:(NSDate *)limit
{
    lockCheck(self, _cmd, _thread);

    if (!_isInitialized)
    {
        return YES;
    }
    BOOL success = NO;
    do {
        success = pthread_mutex_trylock(&_lock) == 0;
        sched_yield();
    } while ([limit timeIntervalSinceNow] < 0.0 && !success);
    if (success)
    {
        _thread = pthread_self();
    }
    return success;
}

- (void)setName:(NSString *)n
{
    if (![_name isEqualToString:n])
    {
        [_name release];
        _name = [n copy];
    }
}

- (NSString *)name
{
    return _name;
}

- (NSString *)description
{
    NSString *superDesc = [super description];
    NSString *locked = pthread_equal(_thread, 0) ? @"NO" : @"YES";
    return [NSString stringWithFormat:@"%@{locked = %@, thread = %lx, name = %@}", superDesc, locked, _thread, _name];
}

@end

// Note that the NSConditionLock being locked does NOT mean that
// internal NSCondition is locked. Rather, the first thread to get the
// NSCondition lock after a broadcast gets to acquire the
// NSConditionLock lock, by writing in its pthread_t id. The _cond
// lock is only ever acquired for a bounded amount of time.

// All reads or writes to _value, _thread, and _locked (outside of
// init) must be guarded by the _cond lock.

@implementation NSConditionLock {
    NSCondition *_cond;
    NSInteger _value;
    pthread_t _thread;
    BOOL _locked;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _cond = [[NSCondition alloc] init];
        _value = 0;
        _locked = NO;
    }
    return self;
}

- (id)initWithCondition:(NSInteger)condition
{
    self = [super init];
    if (self)
    {
        _cond = [[NSCondition alloc] init];
        _value = condition;
        _locked = NO;
    }
    return self;
}

- (void)dealloc
{
    [_cond release];
    [super dealloc];
}

- (NSString *)name
{
    return [_cond name];
}

- (void)setName:(NSString *)n
{
    [_cond setName:n];
}

- (NSString *)description
{
    NSString *superDesc = [super description];
    NSString *locked = _locked ? @"YES" : @"NO";
    return [NSString stringWithFormat:@"%@{locked = %@, thread = %lx, name = %@}", superDesc, locked, _thread, [_cond name]];
}

- (void)unlockWithCondition:(NSInteger)condition
{
    [_cond lock];

    unlockCheck(self, _cmd, _thread);

    _value = condition;
    _locked = NO;
    _thread = 0;

    [_cond broadcast];
    [_cond unlock];
}

- (void)unlock
{
    [_cond lock];

    unlockCheck(self, _cmd, _thread);

    _locked = NO;
    _thread = 0;

    [_cond broadcast];
    [_cond unlock];
}

- (BOOL)tryLockWhenCondition:(NSInteger)condition
{
    BOOL gotLock = NO;

    [_cond lock];

    if (!_locked && _value == condition)
    {
        gotLock = YES;
        _locked = YES;
        _thread = pthread_self();
    }

    [_cond unlock];
    return gotLock;
}

- (BOOL)tryLock
{
    BOOL gotLock = NO;

    [_cond lock];

    if (!_locked)
    {
        gotLock = YES;
        _locked = YES;
        _thread = pthread_self();
    }

    [_cond unlock];
    return gotLock;
}

- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)date
{
    BOOL gotLock = NO;

    [_cond lock];

    lockCheck(self, _cmd, _thread);

    do {
        if (!_locked && _value == condition)
        {
            gotLock = YES;
            _locked = YES;
            _thread = pthread_self();
            break;
        }
    } while ([_cond waitUntilDate:date]);

    [_cond unlock];
    return gotLock;
}

- (void)lockWhenCondition:(NSInteger)condition
{
    [_cond lock];

    lockCheck(self, _cmd, _thread);

    while (YES)
    {
        if (!_locked && _value == condition)
        {
            _locked = YES;
            _thread = pthread_self();
            [_cond unlock];
            return;
        }
        [_cond wait];
    }
}

- (BOOL)lockBeforeDate:(NSDate *)date
{
    BOOL gotLock = NO;

    [_cond lock];

    lockCheck(self, _cmd, _thread);

    do {
        if (!_locked)
        {
            gotLock = YES;
            _locked = YES;
            _thread = pthread_self();
            break;
        }
    } while ([_cond waitUntilDate:date]);

    [_cond unlock];
    return gotLock;
}

- (void)lock
{
    [_cond lock];

    lockCheck(self, _cmd, _thread);

    while (_locked)
    {
        [_cond wait];
    }

    _locked = YES;
    _thread = pthread_self();
    [_cond unlock];
    return;
}

- (NSInteger)condition
{
    [_cond lock];
    NSInteger condition = _value;
    [_cond unlock];
    return condition;
}

@end

@implementation NSRecursiveLock {
    pthread_mutex_t _lock;
    pthread_mutexattr_t _attrs;
    pthread_t _thread;
    int _locks;
    NSString *_name;
    BOOL _lockIsInitialized;
    BOOL _mutexAttrsInitialized;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        if (UNLIKELY(pthread_mutexattr_init(&_attrs) != 0))
        {
            [self release];
            return nil;
        }
        _mutexAttrsInitialized = YES;
        if (UNLIKELY(pthread_mutexattr_settype(&_attrs, PTHREAD_MUTEX_RECURSIVE) != 0))
        {
            [self release];
            return nil;
        }
        if (UNLIKELY(pthread_mutex_init(&_lock, &_attrs) != 0))
        {
            [self release];
            return nil;
        }
        _lockIsInitialized = YES;
        _thread = 0;
    }
    return self;
}

- (void)dealloc
{
    if (_mutexAttrsInitialized)
    {
        pthread_mutexattr_destroy(&_attrs);
        if (_lockIsInitialized)
        {
            if (UNLIKELY(pthread_mutex_destroy(&_lock) == EBUSY))
            {
                whileLocked(self, _cmd);
            }
        }
    }
    [_name release];
    [super dealloc];
}

- (void)lock
{
    pthread_mutex_lock(&_lock);
    if (_locks == 0)
    {
        _thread = pthread_self();
    }
    _locks++;
}

- (void)unlock
{
    unlockCheck(self, _cmd, _thread);

    if ((--_locks) == 0)
    {
        _thread = 0;
    }

    if (UNLIKELY(pthread_mutex_unlock(&_lock) == EPERM))
    {
        whileUnlocked(self, _cmd);
    }
}

- (BOOL)tryLock
{
    BOOL success = pthread_mutex_trylock(&_lock) == 0;
    if (success)
    {
        if (_locks == 0)
        {
            _thread = pthread_self();
        }
        _locks++;
    }
    return success;
}

- (BOOL)lockBeforeDate:(NSDate *)limit
{
    BOOL success = NO;
    do {
        success = pthread_mutex_trylock(&_lock) == 0;
        sched_yield();
    } while ([limit timeIntervalSinceNow] < 0.0 && !success);
    if (success)
    {
        if (_locks == 0)
        {
            _thread = pthread_self();
        }
        _locks++;
    }
    return success;
}

- (void)setName:(NSString *)n
{
    if (![_name isEqualToString:n])
    {
        [_name release];
        _name = [n copy];
    }
}

- (NSString *)name
{
    return _name;
}

- (NSString *)description
{
    NSString *superDesc = [super description];
    return [NSString stringWithFormat:@"%@{locks = %d, thread = %lx, name = %@}", superDesc, _locks, _thread, _name];
}

@end

@implementation NSCondition {
    pthread_mutex_t _lock;
    pthread_mutexattr_t _attrs;
    pthread_cond_t _cond;
    pthread_condattr_t _condAttrs;
    pthread_t _thread;
    NSString *_name;
    BOOL _isInitialized;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _isInitialized = YES;
        pthread_mutexattr_init(&_attrs);
        pthread_mutexattr_settype(&_attrs, PTHREAD_MUTEX_DEFAULT);
        pthread_mutex_init(&_lock, &_attrs);
        pthread_condattr_init(&_condAttrs);
        pthread_cond_init(&_cond, &_condAttrs);
    }
    return self;
}

- (void)dealloc
{
    pthread_condattr_destroy(&_condAttrs);
    if (pthread_cond_destroy(&_cond) == EBUSY)
    {
        whileLocked(self, _cmd);
    }
    pthread_mutexattr_destroy(&_attrs);
    if (pthread_mutex_destroy(&_lock) == EBUSY)
    {
        whileLocked(self, _cmd);
    }
    [_name release];
    [super dealloc];
}

- (void)lock
{
    lockCheck(self, _cmd, _thread);

    if (!_isInitialized)
    {
        _thread = pthread_self();
        return;
    }
    pthread_mutex_lock(&_lock);
    _thread = pthread_self();
}

- (void)unlock
{
    unlockCheck(self, _cmd, _thread);

    if (!_isInitialized)
    {
        _thread = 0;
        return;
    }

    _thread = 0;
    if (UNLIKELY(pthread_mutex_unlock(&_lock) == EPERM))
    {
        whileUnlocked(self, _cmd);
    }
}

- (void)wait
{
    waitCheck(self, _cmd, _thread);

    _thread = 0;
    if (!_isInitialized)
    {
        _thread = pthread_self();
        return;
    }

    pthread_cond_wait(&_cond, &_lock);
    _thread = pthread_self();
}

- (BOOL)waitUntilDate:(NSDate *)limit
{
    waitCheck(self, _cmd, _thread);

    if (!_isInitialized)
    {
        return YES;
    }

    NSTimeInterval t = [limit timeIntervalSinceNow];
    if (t < 0)
    {
        return NO;
    }

    pthread_t oldThread = _thread;
    _thread = 0;

    struct timespec timeout = {
        .tv_sec = t,
        .tv_nsec = fmod(t * NSEC_PER_SEC, NSEC_PER_SEC),
    };
    BOOL success = pthread_cond_timedwait_relative_np(&_cond, &_lock, &timeout) == 0;

    _thread = oldThread;

    return success;
}

- (void)signal
{
    if (!_isInitialized)
    {
        return;
    }
    pthread_cond_signal(&_cond);
}

- (void)broadcast
{
    if (!_isInitialized)
    {
        return;
    }
    pthread_cond_broadcast(&_cond);
}

- (void)setName:(NSString *)n
{
    if (![_name isEqualToString:n])
    {
        [_name release];
        _name = [n copy];
    }
}

- (NSString *)name
{
    return _name;
}

- (NSString *)description
{
    NSString *superDesc = [super description];
    NSString *locked = pthread_equal(_thread, 0) ? @"NO" : @"YES";
    return [NSString stringWithFormat:@"%@{locked = %@, thread = %lx, name = %@}", superDesc, locked, _thread, _name];
}

@end
