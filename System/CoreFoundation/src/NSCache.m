//
//  NSCache.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFNotificationCenter.h>
#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

@interface _NSCacheObject : NSObject {
@public
    id _object;
    NSInteger _accessCount;
    NSInteger _cost;
    BOOL _discardable;
    id _key;
}

- (id)initWithObject:(id)object key:(id)key;

@property (retain,nonatomic) id object;
@property (retain,nonatomic) id key;

@end

@implementation _NSCacheObject

@synthesize object=_object;
@synthesize key=_key;

- (id)initWithObject:(id)object key:(id)key
{
    self = [super init];

    if (self)
    {
        _object = [object retain];
        _key = [key retain];
        _cost = 0;
        _accessCount = 0;
        _discardable = NO;
    }

    return self;
}

- (void)dealloc
{
    [_key release];
    _key = nil;
    [_object release];
    _object = nil;
    [super dealloc];
}

@end



@implementation NSCache {
    CFMutableDictionaryRef _objects;
    NSMutableSet *_discardableObjects;
    NSString *_cacheName;
    NSInteger _countLimit;
    NSInteger _costLimit;
    NSInteger _currentCost;
    BOOL _evictsContent;
    OSSpinLock _accessLock;
    id _delegate;
    
    struct {
        unsigned willEvictObject : 1;
    } _delegateHas;
}

- (id)init
{
    self = [super init];

    if (self)
    {
        _cacheName = [@"" copy];
        _countLimit = 0;
        _costLimit = 0;
        _currentCost = 0;
        _evictsContent = YES;
        _accessLock = OS_SPINLOCK_INIT;
        _delegate = nil;
        _discardableObjects = [[NSMutableSet alloc] init];
        _objects = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _delegateHas.willEvictObject = 0;
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), self, &didReceiveMemoryWarning, CFSTR("UIApplicationDidReceiveMemoryWarningNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }

    return self;
}

- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetLocalCenter(), self, CFSTR("UIApplicationDidReceiveMemoryWarningNotification"), NULL);
    [_discardableObjects release];
    _discardableObjects = nil;
    CFRelease(_objects);
    _objects = NULL;
    _delegate = nil;
    [super dealloc];
}


/** properties */

- (NSString *)name {
    return [[_cacheName retain] autorelease];
}

- (void)setName:(NSString *)name {
    if (!name)
        return;
    
    if (_cacheName)
    {
        if ([name isEqualToString:_cacheName])
        {
            return;
        }
        [_cacheName release];
    }
    
    _cacheName = [name copy];
}

- (void)setEvictsObjectsWithDiscardedContent:(BOOL)b
{
    _evictsContent = b;
}

- (BOOL)evictsObjectsWithDiscardedContent
{
    return _evictsContent;
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;

    if (_delegate)
    {
        _delegateHas.willEvictObject = [_delegate respondsToSelector:@selector(cache:willEvictObject:)];
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)setCountLimit:(NSUInteger)limit
{
    OSSpinLockLock(&_accessLock);
    _countLimit = limit;
    OSSpinLockUnlock(&_accessLock);
}

- (NSUInteger)countLimit
{
    return _countLimit;
}


/** guts */

void didReceiveMemoryWarning (CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) 
{
    [((NSCache *)observer) removeAllObjects];
}

- (void)_trimIfNecessaryWithIncomingObject:(BOOL)incomingObject ofCost:(NSUInteger)incomingCost
{
    //should favor not removing recently added items the cache some how. no order is guaranteed
    
    if(_evictsContent)
    {
        @autoreleasepool {
            OSSpinLockLock(&_accessLock);
            NSMutableSet *discardable = [_discardableObjects mutableCopy];
            OSSpinLockUnlock(&_accessLock);
            NSMutableArray *keysToRemove = [[NSMutableArray alloc] initWithCapacity:[discardable count]];
            
            for (_NSCacheObject *cacheObject in discardable)
            {
                [cacheObject->_object discardContentIfPossible];
                if (![cacheObject->_object isContentDiscarded])
                {
                    [keysToRemove addObject:cacheObject.key];
                }
            }

            for (id key in keysToRemove)
            {
                [self removeObjectForKey:key];
            }

            [keysToRemove release];
            [discardable release];
        }
    }
    
    CFIndex count = 0;
    id *keys;
    _NSCacheObject **caches;
    OSSpinLockLock(&_accessLock);
    if (_costLimit == 0 && _countLimit == 0)
    {
        OSSpinLockUnlock(&_accessLock);
        return;
    }
    
    count = CFDictionaryGetCount(_objects);
    if (count == 0)
    {
        OSSpinLockUnlock(&_accessLock);
        return;
    }

    if (incomingObject)
    {
        _currentCost += incomingCost;
        count++;
    }
    
    if ((_countLimit == 0 || _countLimit >= count) && (_costLimit == 0 || _costLimit >= _currentCost))
    {
        if (incomingObject)
        {
            _currentCost -= incomingCost;
        }
        OSSpinLockUnlock(&_accessLock);
        return;
    }
    
    NSMutableArray *keysToRemove = [[NSMutableArray alloc] initWithCapacity:count];
    
    keys = malloc(sizeof(id) * count);
    caches = malloc(sizeof(_NSCacheObject *) * count);
    CFDictionaryGetKeysAndValues(_objects, (const void **)keys, (const void **)caches);
    
    NSInteger countToRemove = 0;

    if (_countLimit != 0 &&  count > _countLimit)
    {
        countToRemove = count - _countLimit;
    }
    
    NSInteger costToRemove = 0;

    if (_costLimit != 0 &&  _currentCost > _costLimit)
    {
        costToRemove = _currentCost - _costLimit;
    }
    
    for(int i = 0; i < count; i++)
    {
        _NSCacheObject *cacheObject = caches[i];

        if (countToRemove > 0)
        {
            countToRemove--;
            costToRemove -= cacheObject->_cost;
            [keysToRemove addObject:cacheObject.key];
        }
        else if (costToRemove > 0)
        {
            costToRemove -= cacheObject->_cost;
            [keysToRemove addObject:cacheObject.key];
        }
        else
        {
            break;
        }
    }
    
    free(keys);
    free(caches);
    
    OSSpinLockUnlock(&_accessLock);
    
    for (id key in keysToRemove)
    {
        [self removeObjectForKey:key];
    }

    [keysToRemove release];

    if (incomingObject)
    {
        _currentCost -= incomingCost;
    }
}

- (void)_sendWillEvictObject:(id)key
{
    if (_delegate && _delegateHas.willEvictObject)
    {
        _NSCacheObject *cacheObject = nil;
        OSSpinLockLock(&_accessLock);
        
        if (CFDictionaryGetValueIfPresent(_objects,key,(const void **)&cacheObject))
        {
            cacheObject = [cacheObject retain]; //prevent a little race in case setObject is called on two threads.
        }
        
        OSSpinLockUnlock(&_accessLock);
        if (cacheObject)
        {
            [_delegate cache:self willEvictObject:cacheObject.object];
            [cacheObject release];
        }
    }
}


- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)num
{
    if (key == nil)
    {
        return;
    }

    if (obj == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to cache %@ for key: %@", self, key];
        return;
    }

    _NSCacheObject *cacheObject = nil;
    _NSCacheObject *newObject = [[_NSCacheObject alloc] initWithObject:obj key:key];
    newObject->_cost = num;
    newObject->_discardable = [obj conformsToProtocol:@protocol(NSDiscardableContent)];
    [self _trimIfNecessaryWithIncomingObject:YES ofCost:num];
    [self _sendWillEvictObject:key];
    
    OSSpinLockLock(&_accessLock);

    if (CFDictionaryGetValueIfPresent(_objects,key,(const void **)&cacheObject))
    {
        if (cacheObject->_discardable)
        {
            if (cacheObject->_object != obj)
            {
                [((id<NSDiscardableContent>)cacheObject->_object) discardContentIfPossible];
            }
            [_discardableObjects removeObject:cacheObject];
        }
        _currentCost -= cacheObject->_cost;
    }

    if (_costLimit == 0 || num <= _costLimit)
    {
        CFDictionarySetValue(_objects,key,newObject);
        _currentCost += num;
        if (newObject->_discardable)
        {
            [_discardableObjects addObject:newObject];
        }
    }
    else
    {
        if (_delegate != nil && _delegateHas.willEvictObject)
        {
            [_delegate cache:self willEvictObject:obj];
        }
        if (newObject->_discardable)
        {
            [obj discardContentIfPossible];
        }
    }

    OSSpinLockUnlock(&_accessLock);
    [newObject release];
}

- (void)setObject:(id)obj forKey:(id)key
{
    [self setObject:obj forKey:key cost:0];
}

- (id)objectForKey:(id)key
{
    if (key == nil)
    {
        return nil;
    }

    _NSCacheObject *cacheObject = nil;
    id returnValue = nil;

    OSSpinLockLock(&_accessLock);

    if (CFDictionaryGetValueIfPresent(_objects,key,(const void **)&cacheObject))
    {
        returnValue = [cacheObject.object retain];
    }

    if (cacheObject != nil &&
        _evictsContent &&
        cacheObject->_discardable &&
        [returnValue isContentDiscarded])
    {
        [_discardableObjects removeObject:cacheObject];
        _currentCost -= cacheObject->_cost;
        CFDictionaryRemoveValue(_objects, key);
        [returnValue release];
        OSSpinLockUnlock(&_accessLock);
        return nil;
    }

    OSSpinLockUnlock(&_accessLock);

    return [returnValue autorelease];
}

- (void)setTotalCostLimit:(NSUInteger)lim
{
    _costLimit = lim;
}

- (NSUInteger)totalCostLimit
{
    return _costLimit;
}

- (void)removeObjectForKey:(id)key
{
    if (key == nil)
    {
        return;
    }

    [self _sendWillEvictObject:key];
    BOOL sendDiscard = NO;
    OSSpinLockLock(&_accessLock);
    _NSCacheObject *cacheObject = nil;

    if (CFDictionaryGetValueIfPresent(_objects,key,(const void **)&cacheObject))
    {
        if (cacheObject->_discardable)
        {
            sendDiscard = YES;
            cacheObject = [cacheObject retain];
            [_discardableObjects removeObject:cacheObject];
        }

        _currentCost -= cacheObject->_cost;
        CFDictionaryRemoveValue(_objects, key);
    }

    OSSpinLockUnlock(&_accessLock);

    if (sendDiscard)
    {
        // Do this work out side the lock (no idea how long it will take so don't hold up the cache)
        [((id<NSDiscardableContent>)cacheObject->_object) discardContentIfPossible];
        [cacheObject release];
    }
}

- (void)removeAllObjects
{
    if (_delegate && _delegateHas.willEvictObject)
    {
        int i = 0;
        OSSpinLockLock(&_accessLock);
        CFIndex count = CFDictionaryGetCount(_objects);

        if (count == 0)
        {
            [_discardableObjects removeAllObjects];
            _currentCost = 0;
            OSSpinLockUnlock(&_accessLock);
            return;
        }

        id *keys = malloc(sizeof(id) * count);
        _NSCacheObject **caches = malloc(sizeof(_NSCacheObject *) * count);
        CFDictionaryGetKeysAndValues(_objects, (const void **)keys, (const void **)caches);
        
        for(i = 0; i < count; i++)
        {
            //BEING REALLY SAFE for re-entrancy or people calling remove as we are editing.
            //apple claims you shouldn't modify but no reason we can't be careful.
            [keys[i] retain];
            [caches[i] retain];
        }

        OSSpinLockUnlock(&_accessLock);
        
        for(i = 0; i < count; i++)
        {
            [self _sendWillEvictObject:keys[i]];
            if (caches[i]->_discardable)
            {
                [((id<NSDiscardableContent>)caches[i]->_object) discardContentIfPossible];
            }
        }
        
        for(i = 0; i < count; i++)
        {
            //BEING REALLY SAFE for re-entrancy or people calling remove as we are editing.
            [keys[i] release];
            [caches[i] release];
        }
        free(keys);
        free(caches);
    }
    
    OSSpinLockLock(&_accessLock);
    CFDictionaryRemoveAllValues(_objects);
    [_discardableObjects removeAllObjects];
    _currentCost = 0;
    OSSpinLockUnlock(&_accessLock);
}

@end
