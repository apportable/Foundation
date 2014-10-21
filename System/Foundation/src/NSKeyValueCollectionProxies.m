//
//  NSKeyValueCollectionProxies.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueCollectionProxies.h"

#import "NSKeyValueCodingInternal.h"
#import "NSObjectInternal.h"

#import <Foundation/NSException.h>
#import <Foundation/NSHashTable.h>
#import <Foundation/NSIndexSet.h>

#import <dispatch/dispatch.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

static NSKeyValueProxyShareKey* _NSKeyValueProxyShareKey = nil;
static OSSpinLock _NSKeyValueProxySpinlock = OS_SPINLOCK_INIT;

@implementation NSKeyValueNonmutatingCollectionMethodSet
@end

@implementation NSKeyValueNonmutatingArrayMethodSet
{
@public
    Method count;
    Method objectAtIndex;
    Method getObjectsRange;
    Method objectsAtIndexes;
}
@end

@implementation NSKeyValueNonmutatingOrderedSetMethodSet
{
@public
    Method count;
    Method objectAtIndex;
    Method indexOfObject;
    Method getObjectsRange;
    Method objectsAtIndexes;
}
@end

@implementation NSKeyValueNonmutatingSetMethodSet
{
@public
    Method count;
    Method enumerator;
    Method member;
}
@end

@implementation NSKeyValueMutatingCollectionMethodSet
@end

@implementation NSKeyValueMutatingArrayMethodSet
@end

@implementation NSKeyValueMutatingOrderedSetMethodSet
@end

@implementation NSKeyValueMutatingSetMethodSet
@end

@implementation NSKeyValueNilOrderedSetEnumerator

- (id)nextObject
{
    return nil;
}

@end

@implementation NSKeyValueNilSetEnumerator

- (id)nextObject
{
    return nil;
}

@end

@implementation NSKeyValueSlowGetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)containerIsa
{
    SEL valueForKeySelector = @selector(valueForKey:);
    Method valueForKeyMethod = class_getInstanceMethod(containerIsa, valueForKeySelector);
    IMP valueForKeyIMP = method_getImplementation(valueForKeyMethod);
    void *extra[1] = {
        key
    };
    return [super initWithContainerClassID:cls key:key implementation:valueForKeyIMP selector:valueForKeySelector extraArguments:extra count:1];
}

@end

@implementation NSKeyValueSlowSetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)containerIsa
{
    SEL setValueForKeySelector = @selector(setValue:forKey:);
    Method setValueForKeyMethod = class_getInstanceMethod(containerIsa, setValueForKeySelector);
    IMP setValueForKeyIMP = method_getImplementation(setValueForKeyMethod);
    void *extra[1] = {
        key
    };
    return [super initWithContainerClassID:cls key:key implementation:setValueForKeyIMP selector:setValueForKeySelector extraArguments:extra count:1];
}

@end

@implementation NSKeyValueProxyGetter
{
    Class _proxyClass;
}

static id _NSGetProxyValueWithGetterNoLock(id obj, NSKeyValueProxyGetter* getter)
{
    Class proxyClass = [getter proxyClass];
    NSHashTable *proxyShare = [proxyClass _proxyShare];
    
    if (_NSKeyValueProxyShareKey == nil)
    {
        _NSKeyValueProxyShareKey = [[NSKeyValueProxyShareKey alloc] init];
    }
    
    _NSKeyValueProxyShareKey->_container = obj;
    _NSKeyValueProxyShareKey->_key = [getter key];
    
    id proxy = [proxyShare member:_NSKeyValueProxyShareKey];
    if (proxy)
    {
        proxy = [proxy retain];
    }
    else
    {
        proxy = [[proxyClass alloc] _proxyInitWithContainer:obj getter:(id)getter];
        [proxyShare addObject:proxy];
    }
    
    [proxy autorelease];
    return proxy;
}

static id _NSGetProxyValueWithGetter(id obj, SEL sel, NSKeyValueProxyGetter* getter)
{
    OSSpinLockLock(&_NSKeyValueProxySpinlock);
    id ret = _NSGetProxyValueWithGetterNoLock(obj, getter);
    OSSpinLockUnlock(&_NSKeyValueProxySpinlock);
    return ret;
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key proxyClass:(Class)proxyClass
{
    void *extraArguments[1] = {
        self
    };
    self = [super initWithContainerClassID:cls key:key implementation:(IMP)_NSGetProxyValueWithGetter selector:NULL extraArguments:extraArguments count:1];
    if (self != nil)
    {
        _proxyClass = proxyClass;
    }
    return self;
}

- (Class)proxyClass
{
    return _proxyClass;
}

@end

@implementation NSKeyValueCollectionGetter
{
    NSKeyValueNonmutatingCollectionMethodSet *_methods;
}

- (NSKeyValueNonmutatingCollectionMethodSet *)methods
{
    return _methods;
}

- (void)dealloc
{
    [_methods release];
    [super dealloc];
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key methods:(NSKeyValueNonmutatingCollectionMethodSet *)methods proxyClass:(Class)proxyClass
{
    self = [super initWithContainerClassID:cls key:key proxyClass:proxyClass];
    if (self != nil)
    {
        _methods = [methods retain];
    }
    return self;
}

@end

@implementation NSKeyValueSlowMutableCollectionGetter
{
    NSKeyValueGetter *_baseGetter;
    NSKeyValueSetter *_baseSetter;
}

- (void)dealloc
{
    [_baseGetter release];
    [_baseSetter release];
    [super dealloc];
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter baseSetter:(NSKeyValueSetter *)baseSetter containerIsa:(Class)containerIsa proxyClass:(Class)proxyClass
{
    self = [super initWithContainerClassID:cls key:key proxyClass:proxyClass];
    if (self != nil)
    {
        if ([baseGetter isKindOfClass:[NSKeyValueUndefinedGetter self]])
        {
            _baseGetter = [[NSKeyValueSlowGetter alloc] initWithContainerClassID:cls key:key containerIsa:containerIsa];
        }
        else
        {
            _baseGetter = [baseGetter retain];
        }

        if ([baseSetter isKindOfClass:[NSKeyValueUndefinedSetter self]])
        {
            _baseSetter = [[NSKeyValueSlowSetter alloc] initWithContainerClassID:cls key:key containerIsa:containerIsa];
        }
        else
        {
            _baseSetter = [baseSetter retain];
        }

    }
    return self;
}

- (BOOL)treatNilValuesLikeEmptyCollections
{
    if ([self isKindOfClass:[NSKeyValueSlowGetter self]] || [self isKindOfClass:[NSKeyValueUndefinedGetter self]])
    {
        return YES;
    }

    return NO;
}

- (NSKeyValueSetter *)baseSetter
{
    return _baseSetter;
}

- (NSKeyValueGetter *)baseGetter
{
    return _baseGetter;
}

@end

@implementation NSKeyValueFastMutableCollection1Getter
{
    NSKeyValueNonmutatingCollectionMethodSet *_nonmutatingMethods;
    NSKeyValueMutatingCollectionMethodSet *_mutatingMethods;
}

- (void)dealloc
{
    [_nonmutatingMethods release];
    [_mutatingMethods release];
    [super dealloc];
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key nonmutatingMethods:(NSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass
{
    self = [super initWithContainerClassID:cls key:key proxyClass:proxyClass];
    if (self != nil)
    {
        _nonmutatingMethods = [nonmutatingMethods retain];
        _mutatingMethods = [mutatingMethods retain];
    }
    return self;
}

- (NSKeyValueMutatingCollectionMethodSet *)mutatingMethods
{
    return _mutatingMethods;
}

- (NSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods
{
    return _nonmutatingMethods;
}

@end

@implementation NSKeyValueFastMutableCollection2Getter
{
    NSKeyValueGetter *_baseGetter;
    NSKeyValueMutatingCollectionMethodSet *_mutatingMethods;
}

- (void)dealloc
{
    [_baseGetter release];
    [_mutatingMethods release];
    [super dealloc];
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass
{
    self = [super initWithContainerClassID:cls key:key proxyClass:proxyClass];
    if (self != nil)
    {
        _baseGetter = [baseGetter retain];
        _mutatingMethods = [mutatingMethods retain];
    }
    return self;
}

- (NSKeyValueMutatingCollectionMethodSet *)mutatingMethods
{
    return _mutatingMethods;
}

- (NSKeyValueGetter *)baseGetter
{
    return _baseGetter;
}

@end

@implementation NSKeyValueIvarMutableCollectionGetter
{
    Ivar _ivar;
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar proxyClass:(Class)proxyClass
{
    self = [super initWithContainerClassID:cls key:key proxyClass:proxyClass];
    if (self != nil)
    {
        _ivar = ivar;
    }
    return self;
}

- (Ivar)ivar
{
    return _ivar;
}
@end

@implementation NSKeyValueNotifyingMutableCollectionGetter
{
    NSKeyValueProxyGetter *_mutableCollectionGetter;
}

- (void)dealloc
{
    [_mutableCollectionGetter release];
    
    [super dealloc];
}

- (id)initWithContainerClassID:(Class)cls key:(NSString*)key mutableCollectionGetter:(NSKeyValueProxyGetter*)getter proxyClass:(Class)proxyClass
{
    self = [super initWithContainerClassID:cls key:key proxyClass:proxyClass];
    if (self != nil)
    {
        _mutableCollectionGetter = [getter retain];
    }
    return self;
}

- (NSKeyValueProxyGetter*)mutableCollectionGetter
{
    return _mutableCollectionGetter;
}

@end

@implementation NSKeyValueProxyShareKey

+ (NSHashTable *)_proxyShare
{
    return nil;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    return NULL;
}

- (void)_proxyNonGCFinalize
{
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    return nil;
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

extern Class NSClassFromObject(id object);

static NSUInteger NSKeyValueProxyHash(const void *item, NSUInteger (*size)(const void *))
{
    id<NSKeyValueProxyCaching> proxy = (id<NSKeyValueProxyCaching>)item;
    NSKeyValueProxyLocator proxyLocator = [proxy _proxyLocator];
    return [proxyLocator.key hash] ^ (NSUInteger)proxyLocator.container;
}

static BOOL NSKeyValueProxyIsEqual(const void *item1, const void *item2, NSUInteger (*size)(const void *))
{
    id<NSKeyValueProxyCaching> proxy1 = (id<NSKeyValueProxyCaching>)item1;
    id<NSKeyValueProxyCaching> proxy2 = (id<NSKeyValueProxyCaching>)item2;

    NSKeyValueProxyLocator proxyLocator1 = [proxy1 _proxyLocator];
    NSKeyValueProxyLocator proxyLocator2 = [proxy2 _proxyLocator];

    return proxyLocator1.container == proxyLocator2.container && [proxyLocator1.key isEqualToString:proxyLocator2.key];
}

static NSHashTable *_NSKeyValueProxyShareCreate(void)
{
    NSPointerFunctions *pf = [[[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory] autorelease];
    [pf setHashFunction:NSKeyValueProxyHash];
    [pf setIsEqualFunction:NSKeyValueProxyIsEqual];

    return [[NSHashTable alloc] initWithPointerFunctions:pf capacity:0];
}

static BOOL _NSKeyValueProxyDeallocate(id <NSKeyValueProxyCaching>proxy)
{
    BOOL dealloced = YES;

    OSSpinLockLock(&_NSKeyValueProxySpinlock);
    if (NSExtraRefCount(proxy) > 0)
    {
        OSSpinLockUnlock(&_NSKeyValueProxySpinlock);
        return NO;
    }

    Class proxyClass = NSClassFromObject(proxy);
    [[proxyClass _proxyShare] removeObject:proxy];
    OSSpinLockUnlock(&_NSKeyValueProxySpinlock);

    [proxy _proxyNonGCFinalize];

#warning Disable pooling of proxies until it we actually enable reuse.
/*
    OSSpinLockLock(&_NSKeyValueProxySpinlock);
    NSKeyValueProxyPool *proxyPool = [proxyClass _proxyNonGCPoolPointer];
    if (proxyPool->idx < PROXY_POOLS)
    {
        dealloced = NO;
        proxyPool->proxy[proxyPool->idx] = proxy;
        proxyPool->idx++;
    }
    OSSpinLockUnlock(&_NSKeyValueProxySpinlock);
 */
    
    return dealloced;
}

@implementation NSKeyValueArray
{
    NSObject *_container;
    NSString *_key;
    NSKeyValueNonmutatingArrayMethodSet *_methods;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (void)dealloc
{
    if (_NSKeyValueProxyDeallocate(self))
    {
        [super dealloc];
    }
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    self = [super init];
    if (self != nil)
    {
        _container = [container retain];
        _key = [[getter key] copy];
        _methods = [(NSKeyValueNonmutatingArrayMethodSet *)[getter methods] retain];
    }
    return self;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexSet
{
    Method objectsAtIndexes = _methods->objectsAtIndexes;
    if (objectsAtIndexes != NULL)
    {
        return ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, objectsAtIndexes, indexSet);
    }
    else
    {
        return [super objectsAtIndexes:indexSet];
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if (_methods->objectAtIndex != NULL)
    {
        return ((id(*)(id, Method, NSUInteger))method_invoke)(_container, _methods->objectAtIndex, idx);
    }

    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    NSArray *objects = ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _methods->objectsAtIndexes, indexes);

    [indexes release];

    return [objects objectAtIndex:0];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    Method getObjectsRange = _methods->getObjectsRange;
    if (getObjectsRange != NULL)
    {
        ((void(*)(id, Method, id*, NSRange))method_invoke)(_container, getObjectsRange, objects, range);
    }
    else
    {
        [super getObjects:objects range:range];
    }
}

- (NSUInteger)count
{
    return ((NSUInteger(*)(id, Method))method_invoke)(_container, _methods->count);
}

- (void)_proxyNonGCFinalize
{
    [_container release];
    [_key release];
    [_methods release];
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

@implementation NSKeyValueOrderedSet
{
    NSObject *_container;
    NSString *_key;
    NSKeyValueNonmutatingOrderedSetMethodSet *_methods;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (void)dealloc
{
    if (_NSKeyValueProxyDeallocate(self))
    {
        [super dealloc];
    }
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    self = [super init];
    if (self != nil)
    {
        _container = [container retain];
        _key = [[getter key] copy];
        _methods = [(NSKeyValueNonmutatingOrderedSetMethodSet *)[getter methods] retain];
    }
    return self;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexSet
{
    if (_methods->objectsAtIndexes != NULL)
    {
        return ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _methods->objectsAtIndexes, indexSet);
    }
    else
    {
        return [super objectsAtIndexes:indexSet];
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if (_methods->objectAtIndex != NULL)
    {
        return ((id(*)(id, Method, NSUInteger))method_invoke)(_container, _methods->objectAtIndex, idx);
    }

    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    NSArray *objects = ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _methods->objectsAtIndexes, indexes);

    [indexes release];

    return [objects objectAtIndex:0];
}

- (NSUInteger)indexOfObject:(id)object
{
    return ((NSUInteger(*)(id, Method, id))method_invoke)(_container, _methods->indexOfObject, object);
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    if (_methods->getObjectsRange != NULL)
    {
        ((void(*)(id, Method, id*, NSRange))method_invoke)(_container, _methods->getObjectsRange, objects, range);
    }
    else
    {
        [super getObjects:objects range:range];
    }
}

- (NSUInteger)count
{
    return ((NSUInteger(*)(id, Method))method_invoke)(_container, _methods->count);
}

- (void)_proxyNonGCFinalize
{
    [_container release];
    [_key release];
    [_methods release];
    _container = nil;
    _key = nil;
    _methods = nil;
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

@implementation NSKeyValueSet
{
    NSObject *_container;
    NSString *_key;
    NSKeyValueNonmutatingSetMethodSet *_methods;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (void)dealloc
{
    if (_NSKeyValueProxyDeallocate(self))
    {
        [super dealloc];
    }
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    self = [super init];
    if (self != nil)
    {
        _container = [container retain];
        _key = [[getter key] copy];
        _methods = [(NSKeyValueNonmutatingSetMethodSet *)[getter methods] retain];
    }
    return self;
}

- (NSEnumerator *)objectEnumerator
{
    return ((NSEnumerator*(*)(id, Method))method_invoke)(_container, _methods->enumerator);
}

- (id)member:(id)object
{
    return ((id(*)(id, Method, id))method_invoke)(_container, _methods->count, object);
}

- (NSUInteger)count
{
    return ((NSUInteger(*)(id, Method))method_invoke)(_container, _methods->count);
}

- (void)_proxyNonGCFinalize
{
    [_container release];
    [_key release];
    [_methods release];
    _container = nil;
    _key = nil;
    _methods = nil;
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

@implementation NSKeyValueMutableArray
{
@public
    NSObject *_container;
    NSString *_key;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)dealloc
{
    if (_NSKeyValueProxyDeallocate(self))
    {
        [super dealloc];
    }
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    self = [super init];
    if (self != nil)
    {
        _container = [container retain];
        _key = [[getter key] copy];
    }
    return self;
}

- (void)setArray:(NSArray *)array
{
    [self removeAllObjects];
    for (id obj in array)
    {
        [self addObject:obj];
    }
}

- (void)_proxyNonGCFinalize
{
    [_container release];
    [_key release];
    _container = nil;
    _key = nil;
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

@implementation NSKeyValueMutableOrderedSet
{
@public
    NSObject *_container;
    NSString *_key;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)dealloc
{
    if (_NSKeyValueProxyDeallocate(self))
    {
        [super dealloc];
    }
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    self = [super init];
    if (self != nil)
    {
        _container = [container retain];
        _key = [[getter key] copy];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [_container release];
    [_key release];
    _container = nil;
    _key = nil;
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

@implementation NSKeyValueMutableSet
{
@public
    NSObject *_container;
    NSString *_key;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)dealloc
{
    if (_NSKeyValueProxyDeallocate(self))
    {
        [super dealloc];
    }
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter
{
    self = [super init];
    if (self != nil)
    {
        _container = [container retain];
        _key = [[getter key] copy];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [_container release];
    [_key release];
    _container = nil;
    _key = nil;
}

- (NSKeyValueProxyLocator)_proxyLocator
{
    return (NSKeyValueProxyLocator) {
        .container = _container,
        .key = _key,
    };
}

@end

@implementation NSKeyValueSlowMutableArray
{
    NSKeyValueGetter *_valueGetter;
    NSKeyValueSetter *_valueSetter;
    BOOL _treatNilValuesLikeEmptyArrays;
    char _padding[3];
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter *)getter];
    if (self != nil)
    {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptyArrays = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    NSMutableArray *array = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [array replaceObjectsAtIndexes:indexes withObjects:objects];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, array);
    [array release];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSMutableArray *array = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [array replaceObjectAtIndex:idx withObject:object];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, array);
    [array release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *array = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [array removeObjectsAtIndexes:indexes];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, array);
    [array release];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSMutableArray *array = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [array removeObjectAtIndex:idx];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, array);
    [array release];
}

- (void)removeLastObject
{
    NSMutableArray *array = [self _createNonNilMutableArrayValueWithSelector:_cmd];
    [array removeLastObject];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, array);
    [array release];
}

- (NSMutableArray *)_createNonNilMutableArrayValueWithSelector:(SEL)selector
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (array == nil)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
        return nil;
    }
    return [array mutableCopy];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    NSMutableArray *copy;

    if (array == nil)
    {
        if (_treatNilValuesLikeEmptyArrays &&
            [objects count] == [indexes count] &&
            [indexes lastIndex] + 1 == [objects count])
        {
            copy = [objects mutableCopy];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
    else
    {
        copy = [array mutableCopy];
        [copy insertObjects:objects atIndexes:indexes];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, copy);
    [copy release];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    NSMutableArray *copy;

    if (array == nil)
    {
        if (_treatNilValuesLikeEmptyArrays && idx == 0)
        {
            copy = [[NSMutableArray alloc] initWithObjects:&object count:1];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
    else
    {
        copy = [array mutableCopy];
        [copy insertObject:object atIndex:idx];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, copy);
    [copy release];
}

- (void)addObject:(id)object
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    NSMutableArray *copy;

    if (array == nil)
    {
        if (_treatNilValuesLikeEmptyArrays)
        {
            copy = [[NSMutableArray alloc] initWithObjects:&object count:1];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
    else
    {
        copy = [array mutableCopy];
        [copy addObject:object];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, copy);
    [copy release];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    return [[self _nonNilArrayValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [[self _nonNilArrayValueWithSelector:_cmd] objectAtIndex:idx];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    [[self _nonNilArrayValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSArray *)_nonNilArrayValueWithSelector:(SEL)selector
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (array == nil)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
        return nil;
    }
    return array;
}

- (NSUInteger)count
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (array == nil)
    {
        if (!_treatNilValuesLikeEmptyArrays)
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
        }
        return 0;
    }
    return [array count];
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector
{
    [NSException raise:_treatNilValuesLikeEmptyArrays ? NSInternalInconsistencyException : NSRangeException
                format:@"key %@ of array %@ is nil for selector %s", _key, _container, sel_getName(selector)];
}

- (void)_proxyNonGCFinalize
{
    [_valueGetter release];
    [_valueSetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
    _valueSetter = nil;
}

@end

@implementation NSKeyValueSlowMutableOrderedSet
{
    NSKeyValueGetter *_valueGetter;
    NSKeyValueSetter *_valueSetter;
    BOOL _treatNilValuesLikeEmptyOrderedSets;
    char _padding[3];
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter *)getter];
    if (self != nil)
    {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptyOrderedSets = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    NSMutableOrderedSet *orderedSet = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [orderedSet replaceObjectsAtIndexes:indexes withObjects:objects];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, orderedSet);
    [orderedSet release];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSMutableOrderedSet *orderedSet = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [orderedSet replaceObjectAtIndex:idx withObject:object];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, orderedSet);
    [orderedSet release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableOrderedSet *orderedSet = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [orderedSet removeObjectsAtIndexes:indexes];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, orderedSet);
    [orderedSet release];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSMutableOrderedSet *orderedSet = [self _createNonNilMutableOrderedSetValueWithSelector:_cmd];
    [orderedSet removeObjectAtIndex:idx];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, orderedSet);
    [orderedSet release];
}

- (NSMutableOrderedSet *)_createNonNilMutableOrderedSetValueWithSelector:(SEL)selector
{
    NSOrderedSet *orderedSet = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (orderedSet == nil)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
        return nil;
    }
    return [orderedSet mutableCopy];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    NSOrderedSet *orderedSet = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    NSMutableOrderedSet *copy;

    if (orderedSet == nil)
    {
        if (_treatNilValuesLikeEmptyOrderedSets &&
            [objects count] == [indexes count] &&
            [indexes lastIndex] + 1 == [objects count])
        {
            copy = [[NSMutableOrderedSet alloc] initWithArray:objects];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
    else
    {
        copy = [orderedSet mutableCopy];
        [copy insertObjects:objects atIndexes:indexes];
    }

    
    _NSSetUsingKeyValueSetter(_container, _valueSetter, copy);
    [copy release];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSOrderedSet *orderedSet = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    NSMutableOrderedSet *copy;

    if (orderedSet == nil)
    {
        if (_treatNilValuesLikeEmptyOrderedSets && idx == 0)
        {
            copy = [[NSMutableOrderedSet alloc] initWithObjects:&object count:1];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
    else
    {
        copy = [orderedSet mutableCopy];
        [copy insertObject:object atIndex:idx];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, copy);
    [copy release];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] indexOfObject:object];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    [[self _nonNilOrderedSetValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSOrderedSet *)_nonNilOrderedSetValueWithSelector:(SEL)selector
{
    NSOrderedSet *orderedSet = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (orderedSet == nil)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
        return nil;
    }
    return orderedSet;
}

- (NSUInteger)count
{
    NSOrderedSet *orderedSet = _NSGetUsingKeyValueGetter(_container, _valueGetter);

    if (orderedSet == nil)
    {
        if (_treatNilValuesLikeEmptyOrderedSets)
        {
            return 0;
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return 0;
        }
    }

    return [orderedSet count];
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector
{
    [NSException raise:_treatNilValuesLikeEmptyOrderedSets ? NSInternalInconsistencyException : NSRangeException
                format:@"key %@ of ordered set %@ is nil for selector %s", _key, _container, sel_getName(selector)];
}

- (void)_proxyNonGCFinalize
{
    [_valueGetter release];
    [_valueSetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
    _valueSetter = nil;
}

@end

@implementation NSKeyValueSlowMutableSet
{
    NSKeyValueGetter *_valueGetter;
    NSKeyValueSetter *_valueSetter;
    BOOL _treatNilValuesLikeEmptySets;
    char _padding[3];
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter *)getter];
    if (self != nil)
    {
        _valueGetter = [[getter baseGetter] retain];
        _valueSetter = [[getter baseSetter] retain];
        _treatNilValuesLikeEmptySets = [getter treatNilValuesLikeEmptyCollections];
    }
    return self;
}

- (void)unionSet:(NSSet *)otherSet
{
    NSMutableSet *set = [self _createMutableSetValueWithSelector:_cmd];
    if (set != nil)
    {
        [set unionSet:otherSet];
    }
    else
    {
        set = [otherSet mutableCopy];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, set);

    [set release];
}

- (void)setSet:(NSSet *)otherSet
{
    if (_treatNilValuesLikeEmptySets ||
        _NSGetUsingKeyValueGetter(_container, _valueGetter) != nil)
    {
        _NSSetUsingKeyValueSetter(_container, _valueSetter, otherSet);
    }
    else
    {
        [self _raiseNilValueExceptionWithSelector:_cmd];
    }
}

- (void)removeObject:(id)object
{
    NSMutableSet *set = [self _createMutableSetValueWithSelector:_cmd];

    if (set != nil)
    {
        [set removeObject:object];
        _NSSetUsingKeyValueSetter(_container, _valueSetter, set);
        [set release];
    }
}

- (void)removeAllObjects
{
    NSSet *set = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (set == nil)
    {
        if (!_treatNilValuesLikeEmptySets)
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
    
    NSSet *emptySet = [[NSSet alloc] init];
    _NSSetUsingKeyValueSetter(_container, _valueSetter, emptySet);
    [emptySet release];
}

- (void)minusSet:(NSSet *)otherSet
{
    NSMutableSet *set = [self _createMutableSetValueWithSelector:_cmd];

    if (set != nil)
    {
        [set minusSet:otherSet];
        _NSSetUsingKeyValueSetter(_container, _valueSetter, set);
        [set release];
    }
}

- (void)intersectSet:(NSSet *)otherSet
{
    NSMutableSet *set = [self _createMutableSetValueWithSelector:_cmd];

    if (set != nil)
    {
        [set intersectSet:otherSet];
        _NSSetUsingKeyValueSetter(_container, _valueSetter, set);
        [set release];
    }
}

- (void)addObjectsFromArray:(NSArray *)array
{
    NSMutableSet *set = [self _createMutableSetValueWithSelector:_cmd];

    if (set == nil)
    {
        set = [[NSMutableSet alloc] initWithArray:array];
    }
    else
    {
        [set addObjectsFromArray:array];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, set);

    [set release];
}

- (void)addObject:(id)object
{
    NSMutableSet *set = [self _createMutableSetValueWithSelector:_cmd];

    if (set == nil)
    {
        set = [[NSMutableSet alloc] initWithObjects:&object count:1];
    }
    else
    {
        [set addObject:object];
    }

    _NSSetUsingKeyValueSetter(_container, _valueSetter, set);

    [set release];
}

- (NSMutableSet *)_createMutableSetValueWithSelector:(SEL)selector
{
    NSSet *set = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (set == nil)
    {
        if (!_treatNilValuesLikeEmptySets)
        {
            [self _raiseNilValueExceptionWithSelector:selector];
        }
        return nil;
    }
    return [set mutableCopy];
}

- (NSEnumerator *)objectEnumerator
{
    NSSet *set = [self _setValueWithSelector:_cmd];

    if (set == nil)
    {
        return [[[NSKeyValueNilSetEnumerator alloc] init] autorelease];
    }
    else
    {
        return [set objectEnumerator];
    }
}

- (id)member:(id)object
{
    return [[self _setValueWithSelector:_cmd] member:object];
}

- (NSUInteger)count
{
    return [[self _setValueWithSelector:_cmd] count];
}

- (NSSet *)_setValueWithSelector:(SEL)selector
{
    NSSet *set = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (set == nil && !_treatNilValuesLikeEmptySets)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
        return nil;
    }
    return set;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector
{
    [NSException raise:NSInternalInconsistencyException
                format:@"key %@ of set %@ is nil for selector %s", _key, _container, sel_getName(selector)];
}

- (void)_proxyNonGCFinalize
{
    [_valueGetter release];
    [_valueSetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
    _valueSetter = nil;
}

@end

@implementation NSKeyValueFastMutableArray
{
    NSKeyValueMutatingArrayMethodSet *_mutatingMethods;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueProxyGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter *)getter];
    if (self != nil)
    {
        _mutatingMethods = [(NSKeyValueMutatingArrayMethodSet *)[getter mutatingMethods] retain];
    }
    return self;
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    if (_mutatingMethods->replaceObjectsAtIndexes != NULL)
    {
        ((void(*)(id, Method, NSIndexSet*, NSArray*))method_invoke)(_container, _mutatingMethods->replaceObjectsAtIndexes, indexes, objects);
    }
    else
    {
        [super replaceObjectsAtIndexes:indexes withObjects:objects];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    if (_mutatingMethods->replaceObjectAtIndex != NULL)
    {
        ((void(*)(id, Method, NSUInteger, id))method_invoke)(_container, _mutatingMethods->replaceObjectAtIndex, idx, object);
    }
    else if (_mutatingMethods->replaceObjectsAtIndexes != NULL)
    {
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
        NSArray *objects = [[NSArray alloc] initWithObjects:&object count:1];

        ((void(*)(id, Method, NSIndexSet*, NSArray*))method_invoke)(_container, _mutatingMethods->replaceObjectsAtIndexes, indexes, objects);

        [indexes release];
        [objects release];
    }
    else
    {
        [self removeObjectAtIndex:idx];
        [self insertObject:object atIndex:idx];
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    if (_mutatingMethods->removeObjectsAtIndexes != NULL)
    {
        ((void(*)(id, Method, NSIndexSet*))method_invoke)(_container, _mutatingMethods->removeObjectsAtIndexes, indexes);
    }
    else
    {
        [super removeObjectsAtIndexes:indexes];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    if (_mutatingMethods->removeObjectAtIndex != NULL)
    {
        ((void(*)(id, Method, NSUInteger))method_invoke)(_container, _mutatingMethods->removeObjectAtIndex, idx);
        return;
    }

    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    ((void(*)(id, Method, NSIndexSet*))method_invoke)(_container, _mutatingMethods->removeObjectsAtIndexes, indexes);

    [indexes release];
}

- (void)removeLastObject
{
    [self removeObjectAtIndex:[self count] - 1];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    if (_mutatingMethods->insertObjectsAtIndexes != NULL)
    {
        ((void(*)(id, Method, NSArray*, NSIndexSet*))method_invoke)(_container, _mutatingMethods->insertObjectsAtIndexes, objects, indexes);
    }
    else
    {
        [super insertObjects:objects atIndexes:indexes];
    }
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    if (_mutatingMethods->insertObjectAtIndex != NULL)
    {
        ((void(*)(id, Method, id, NSUInteger))method_invoke)(_container, _mutatingMethods->insertObjectAtIndex, object, idx);
        return;
    }

    NSArray *objects = [[NSArray alloc] initWithObjects:&object count:1];
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    ((void(*)(id, Method, NSArray*, NSIndexSet*))method_invoke)(_container, _mutatingMethods->insertObjectsAtIndexes, objects, indexes);

    [objects release];
    [indexes release];
}

- (void)addObject:(id)object
{
    [self insertObject:object atIndex:[self count]];
}

- (void)_proxyNonGCFinalize
{
    [_mutatingMethods release];
    [super _proxyNonGCFinalize];
    _mutatingMethods = nil;
}

@end

@implementation NSKeyValueFastMutableArray1
{
    NSKeyValueNonmutatingArrayMethodSet *_nonmutatingMethods;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection1Getter *)getter
{
    self = [super _proxyInitWithContainer:container getter:getter];
    if (self != nil)
    {
        _nonmutatingMethods = [(NSKeyValueNonmutatingArrayMethodSet *)[getter nonmutatingMethods] retain];
    }
    return self;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    if (_nonmutatingMethods->objectsAtIndexes != NULL)
    {
        return ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _nonmutatingMethods->objectsAtIndexes, indexes);
    }
    else
    {
        return [super objectsAtIndexes:indexes];
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if (_nonmutatingMethods->objectAtIndex != NULL)
    {
        return ((id(*)(id, Method, NSUInteger))method_invoke)(_container, _nonmutatingMethods->objectAtIndex, idx);
    }

    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    NSArray *objects = ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _nonmutatingMethods->objectsAtIndexes, indexes);

    [indexes release];

    return [objects objectAtIndex:0];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    if (_nonmutatingMethods->getObjectsRange != NULL)
    {
        ((void(*)(id, Method, id*, NSRange))method_invoke)(_container, _nonmutatingMethods->getObjectsRange, objects, range);
    }
    else
    {
        [super getObjects:objects range:range];
    }
}

- (NSUInteger)count
{
    return ((NSUInteger(*)(id, Method))method_invoke)(_container, _nonmutatingMethods->count);
}

- (void)_proxyNonGCFinalize
{
    [_nonmutatingMethods release];
    [super _proxyNonGCFinalize];
    _nonmutatingMethods = nil;
}

@end

@implementation NSKeyValueFastMutableArray2
{
    NSKeyValueGetter *_valueGetter;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection2Getter *)getter
{
    self = [super _proxyInitWithContainer:container getter:getter];
    if (self != nil)
    {
        _valueGetter = [[getter baseGetter] retain];
    }
    return self;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    return [[self _nonNilArrayValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [[self _nonNilArrayValueWithSelector:_cmd] objectAtIndex:idx];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    [[self _nonNilArrayValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSUInteger)count
{
    return [[self _nonNilArrayValueWithSelector:_cmd] count];
}

- (NSArray *)_nonNilArrayValueWithSelector:(SEL)selector
{
    NSArray *array = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (array == nil)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"key %@ of array %@ is nil for selector %s", _key, _container, sel_getName(selector)];
        return nil;
    }
    return array;
}

- (void)_proxyNonGCFinalize
{
    [_valueGetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
}

@end

@implementation NSKeyValueFastMutableOrderedSet
{
    NSKeyValueMutatingOrderedSetMethodSet *_mutatingMethods;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueProxyGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter *)getter];
    if (self != nil)
    {
        _mutatingMethods = [(NSKeyValueMutatingOrderedSetMethodSet *)[getter mutatingMethods] retain];
    }
    return self;
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    if (_mutatingMethods->replaceObjectsAtIndexes != NULL)
    {
        ((void(*)(id, Method, NSIndexSet*, NSArray*))method_invoke)(_container, _mutatingMethods->replaceObjectsAtIndexes, indexes, objects);
    }
    else
    {
        [super replaceObjectsAtIndexes:indexes withObjects:objects];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    if (_mutatingMethods->replaceObjectAtIndex != NULL)
    {
        ((void(*)(id, Method, NSUInteger, id))method_invoke)(_container, _mutatingMethods->replaceObjectAtIndex, idx, object);
    }
    else if (_mutatingMethods->replaceObjectsAtIndexes != NULL)
    {
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
        NSArray *objects = [[NSArray alloc] initWithObjects:&object count:1];

        ((void(*)(id, Method, NSIndexSet*, NSArray*))method_invoke)(_container, _mutatingMethods->replaceObjectsAtIndexes, indexes, objects);

        [indexes release];
        [objects release];
    }
    else
    {
        [self removeObjectAtIndex:idx];
        [self insertObject:object atIndex:idx];
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    if (_mutatingMethods->removeObjectsAtIndexes != NULL)
    {
        ((void(*)(id, Method, NSIndexSet*))method_invoke)(_container, _mutatingMethods->removeObjectsAtIndexes, indexes);
    }
    else
    {
        [super removeObjectsAtIndexes:indexes];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    if (_mutatingMethods->removeObjectAtIndex != NULL)
    {
        ((void(*)(id, Method, NSUInteger))method_invoke)(_container, _mutatingMethods->removeObjectAtIndex, idx);
        return;
    }

    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    ((void(*)(id, Method, NSIndexSet*))method_invoke)(_container, _mutatingMethods->removeObjectsAtIndexes, indexes);

    [indexes release];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    if (_mutatingMethods->insertObjectsAtIndexes != NULL)
    {
        ((void(*)(id, Method, NSArray*, NSIndexSet*))method_invoke)(_container, _mutatingMethods->insertObjectsAtIndexes, objects, indexes);
    }
    else
    {
        [super insertObjects:objects atIndexes:indexes];
    }
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    if (_mutatingMethods->insertObjectAtIndex != NULL)
    {
        ((void(*)(id, Method, id, NSUInteger))method_invoke)(_container, _mutatingMethods->insertObjectAtIndex, object, idx);
        return;
    }

    NSArray *objects = [[NSArray alloc] initWithObjects:&object count:1];
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    ((void(*)(id, Method, NSArray*, NSIndexSet*))method_invoke)(_container, _mutatingMethods->insertObjectsAtIndexes, objects, indexes);

    [objects release];
    [indexes release];
}

- (void)_proxyNonGCFinalize
{
    [_mutatingMethods release];
    [super _proxyNonGCFinalize];
    _mutatingMethods = nil;
}

@end

@implementation NSKeyValueFastMutableOrderedSet1
{
    NSKeyValueNonmutatingOrderedSetMethodSet *_nonmutatingMethods;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection1Getter *)getter
{
    self = [super _proxyInitWithContainer:container getter:getter];
    if (self != nil)
    {
        _nonmutatingMethods = [(NSKeyValueNonmutatingOrderedSetMethodSet *)[getter nonmutatingMethods] retain];
    }
    return self;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    if (_nonmutatingMethods->objectsAtIndexes != NULL)
    {
        return ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _nonmutatingMethods->objectsAtIndexes, indexes);
    }
    else
    {
        return [super objectsAtIndexes:indexes];
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if (_nonmutatingMethods->objectAtIndex != NULL)
    {
        return ((id(*)(id, Method, NSUInteger))method_invoke)(_container, _nonmutatingMethods->objectAtIndex, idx);
    }

    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];

    NSArray *objects = ((NSArray*(*)(id, Method, NSIndexSet*))method_invoke)(_container, _nonmutatingMethods->objectsAtIndexes, indexes);

    [indexes release];

    return [objects objectAtIndex:0];
}

- (NSUInteger)indexOfObject:(id)object
{
    return ((NSUInteger(*)(id, Method, id))method_invoke)(_container, _nonmutatingMethods->indexOfObject, object);
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    if (_nonmutatingMethods->getObjectsRange != NULL)
    {
        ((void(*)(id, Method, id*, NSRange))method_invoke)(_container, _nonmutatingMethods->getObjectsRange, objects, range);
    }
    else
    {
        [super getObjects:objects range:range];
    }
}

- (NSUInteger)count
{
    return ((NSUInteger(*)(id, Method))method_invoke)(_container, _nonmutatingMethods->count);
}

- (void)_proxyNonGCFinalize
{
    [_nonmutatingMethods release];
    [super _proxyNonGCFinalize];
    _nonmutatingMethods = nil;
}

@end

@implementation NSKeyValueFastMutableOrderedSet2
{
    NSKeyValueGetter *_valueGetter;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection2Getter *)getter
{
    self = [super _proxyInitWithContainer:container getter:getter];
    if (self != nil)
    {
        _valueGetter = [[getter baseGetter] retain];
    }
    return self;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] objectsAtIndexes:indexes];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] objectAtIndex:idx];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] indexOfObject:object];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    [[self _nonNilOrderedSetValueWithSelector:_cmd] getObjects:objects range:range];
}

- (NSUInteger)count
{
    return [[self _nonNilOrderedSetValueWithSelector:_cmd] count];
}

- (NSOrderedSet *)_nonNilOrderedSetValueWithSelector:(SEL)selector
{
    NSOrderedSet *orderedSet = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (orderedSet == nil)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"key %@ of ordered set %@ is nil for selector %s", _key, _container, sel_getName(selector)];
        return nil;
    }
    return orderedSet;
}

- (void)_proxyNonGCFinalize
{
    [_valueGetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
}

@end

@implementation NSKeyValueFastMutableSet
{
    NSKeyValueMutatingSetMethodSet *_mutatingMethods;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueProxyGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter *)getter];
    if (self != nil)
    {
        _mutatingMethods = [(NSKeyValueMutatingSetMethodSet *)[getter mutatingMethods] retain];
    }
    return self;
}

- (void)unionSet:(NSSet *)set
{
    if (_mutatingMethods->unionSet != NULL)
    {
        ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->unionSet, set);
    }
    else
    {
        [super unionSet:set];
    }
}

- (void)setSet:(NSSet *)set
{
    if (_mutatingMethods->setSet != NULL)
    {
        ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->setSet, set);
    }
    else
    {
        [super setSet:set];
    }
}

- (void)removeObject:(id)object
{
    if (_mutatingMethods->removeObject != NULL)
    {
        ((void(*)(id, Method, id))method_invoke)(_container, _mutatingMethods->removeObject, object);
        return;
    }

    NSSet *objects = [[NSSet alloc] initWithObjects:&object count:1];
    ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->minusSet, objects);
    [objects release];
}

- (void)removeAllObjects
{
    if (_mutatingMethods->setSet != NULL)
    {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->setSet, set);
        [set release];
    }
    else
    {
        [super removeAllObjects];
    }
}

- (void)minusSet:(NSSet *)set
{
    if (_mutatingMethods->minusSet != NULL)
    {
        ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->minusSet, set);
    }
    else
    {
        [super minusSet:set];
    }
}

- (void)intersectSet:(NSSet *)set
{
    if (_mutatingMethods->intersectSet != NULL)
    {
        ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->intersectSet, set);
    }
    else
    {
        [super intersectSet:set];
    }
}

- (void)addObjectsFromArray:(NSArray *)array
{
    if (_mutatingMethods->unionSet != NULL)
    {
        NSMutableSet *set = [[NSMutableSet alloc] initWithArray:array];
        ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->unionSet, set);
        [set release];
    }
    else
    {
        [super addObjectsFromArray:array];
    }
}

- (void)addObject:(id)object
{
    if (_mutatingMethods->addObject != NULL)
    {
        ((void(*)(id, Method, id))method_invoke)(_container, _mutatingMethods->addObject, object);
        return;
    }

    NSSet *objects = [[NSSet alloc] initWithObjects:&object count:1];
    ((void(*)(id, Method, NSSet*))method_invoke)(_container, _mutatingMethods->unionSet, objects);
    [objects release];
}

- (void)_proxyNonGCFinalize
{
    [_mutatingMethods release];
    [super _proxyNonGCFinalize];
    _mutatingMethods = nil;
}

@end

@implementation NSKeyValueFastMutableSet1
{
    NSKeyValueNonmutatingSetMethodSet *_nonmutatingMethods;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection1Getter *)getter
{
    self = [super _proxyInitWithContainer:container getter:getter];
    if (self != nil)
    {
        _nonmutatingMethods = [(NSKeyValueNonmutatingSetMethodSet *)[getter nonmutatingMethods] retain];
    }
    return self;
}

- (NSEnumerator *)objectEnumerator
{
    return ((NSEnumerator*(*)(id, Method))method_invoke)(_container, _nonmutatingMethods->enumerator);
}

- (id)member:(id)object
{
    return ((id(*)(id, Method, id))method_invoke)(_container, _nonmutatingMethods->member, object);
}

- (NSUInteger)count
{
    return ((NSUInteger(*)(id, Method))method_invoke)(_container, _nonmutatingMethods->count);
}

- (void)_proxyNonGCFinalize
{
    [_nonmutatingMethods release];
    [super _proxyNonGCFinalize];
    _nonmutatingMethods = nil;
}

@end

@implementation NSKeyValueFastMutableSet2
{
    NSKeyValueGetter *_valueGetter;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection2Getter *)getter
{
    self = [super _proxyInitWithContainer:container getter:getter];
    if (self != nil)
    {
        _valueGetter = [[getter baseGetter] retain];
    }
    return self;
}

- (NSEnumerator *)objectEnumerator
{
    return [[self _nonNilSetValueWithSelector:_cmd] objectEnumerator];
}

- (id)member:(id)object
{
    return [[self _nonNilSetValueWithSelector:_cmd] member:object];
}

- (NSUInteger)count
{
    return [[self _nonNilSetValueWithSelector:_cmd] count];
}

- (NSSet *)_nonNilSetValueWithSelector:(SEL)selector
{
    NSSet *set = _NSGetUsingKeyValueGetter(_container, _valueGetter);
    if (set == nil)
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"key %@ of set %@ is nil for selector %s", _key, _container, sel_getName(selector)];
        return nil;
    }
    return set;
}

- (void)_proxyNonGCFinalize
{
    [_valueGetter release];
    [super _proxyNonGCFinalize];
    _valueGetter = nil;
}

@end

@implementation NSKeyValueIvarMutableArray
{
    Ivar _ivar;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (NSMutableArray*)_nonNilMutableArrayValueWithSelector:(SEL)selector
{
    NSMutableArray* mutableArray = *(NSMutableArray**)((char*)_container + ivar_getOffset(_ivar));
    if (!mutableArray)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return mutableArray;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueIvarMutableCollectionGetter*)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter*)getter];
    if (self != nil)
    {
        _ivar = [getter ivar];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [super _proxyNonGCFinalize];
    _ivar = NULL;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector
{
    [NSException raise:NSRangeException format:@"%@: value for key %@ of object %p is nil",
        _NSMethodExceptionProem(_container, selector), _key, (void*)_container];
}

- (void)addObject:(id)object
{
    NSMutableArray **mutableArrayIvar = (NSMutableArray**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableArray *mutableArray = *mutableArrayIvar;
    
    if (mutableArray)
    {
        [mutableArray addObject:object];
    }
    else
    {
        *mutableArrayIvar = [[NSMutableArray alloc] initWithObjects:&object count:1];
    }
}

- (NSUInteger)count
{
    NSMutableArray *mutableArray = *(NSMutableArray**)((char*)_container + ivar_getOffset(_ivar));
    return [mutableArray count];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    [mutableArray getObjects:objects range:range];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSMutableArray **mutableArrayIvar = (NSMutableArray**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableArray *mutableArray = *mutableArrayIvar;
    
    if (mutableArray)
    {
        [mutableArray insertObject:object atIndex:idx];
    }
    else
    {
        if (idx != 0)
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
        
        *mutableArrayIvar = [[NSMutableArray alloc] initWithObjects:&object count:1];
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    NSMutableArray **mutableArrayIvar = (NSMutableArray**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableArray *mutableArray = *mutableArrayIvar;
    
    if (mutableArray)
    {
        [mutableArray insertObjects:objects atIndexes:indexes];
    }
    else
    {
        if ([objects count] == [indexes count] &&
            [indexes lastIndex] + 1 == [objects count])
        {
            *mutableArrayIvar = [objects mutableCopy];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    return [mutableArray objectAtIndex:idx];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    return [mutableArray objectsAtIndexes:indexes];
}

- (void)removeLastObject
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    [mutableArray removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    [mutableArray removeObjectAtIndex:idx];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    [mutableArray removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    [mutableArray replaceObjectAtIndex:idx withObject:object];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    NSMutableArray *mutableArray = [self _nonNilMutableArrayValueWithSelector:_cmd];
    [mutableArray replaceObjectsAtIndexes:indexes withObjects:objects];
}
@end

@implementation NSKeyValueIvarMutableOrderedSet
{
    Ivar _ivar;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (NSMutableOrderedSet*)_nonNilMutableOrderedSetValueWithSelector:(SEL)selector
{
    NSMutableOrderedSet* mutableOrderedSet = *(NSMutableOrderedSet**)((char*)_container + ivar_getOffset(_ivar));
    if (!mutableOrderedSet)
    {
        [self _raiseNilValueExceptionWithSelector:selector];
    }
    return mutableOrderedSet;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueIvarMutableCollectionGetter*)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter*)getter];
    if (self != nil)
    {
        _ivar = [getter ivar];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [super _proxyNonGCFinalize];
    _ivar = NULL;
}

- (void)_raiseNilValueExceptionWithSelector:(SEL)selector
{
    [NSException raise:NSRangeException format:@"%@: value for key %@ of object %p is nil",
     _NSMethodExceptionProem(_container, selector), _key, (void*)_container];
}

- (NSUInteger)count
{
    NSMutableOrderedSet *mutableOrderedSet = *(NSMutableOrderedSet**)((char*)_container + ivar_getOffset(_ivar));
    return [mutableOrderedSet count];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    [mutableOrderedSet getObjects:objects range:range];
}

- (NSUInteger)indexOfObject:(id)object
{
    NSMutableOrderedSet *mutableOrderedSet = *(NSMutableOrderedSet**)((char*)_container + ivar_getOffset(_ivar));
    if (mutableOrderedSet)
    {
        return [mutableOrderedSet indexOfObject:object];
    }
    return NSNotFound;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSMutableOrderedSet **mutableOrderedSetIvar = (NSMutableOrderedSet**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableOrderedSet *mutableOrderedSet = *mutableOrderedSetIvar;
    
    if (mutableOrderedSet)
    {
        [mutableOrderedSet insertObject:object atIndex:idx];
    }
    else
    {
        if (idx != 0)
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
        
        *mutableOrderedSetIvar = [[NSMutableOrderedSet alloc] initWithObjects:&object count:1];
    }
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    NSMutableOrderedSet **mutableOrderedSetIvar = (NSMutableOrderedSet**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableOrderedSet *mutableOrderedSet = *mutableOrderedSetIvar;
    
    if (mutableOrderedSet)
    {
        [mutableOrderedSet insertObjects:objects atIndexes:indexes];
    }
    else
    {
        if ([objects count] == [indexes count] &&
            [indexes lastIndex] + 1 == [objects count])
        {
            *mutableOrderedSetIvar = [objects mutableCopy];
        }
        else
        {
            [self _raiseNilValueExceptionWithSelector:_cmd];
            return;
        }
    }
}

- (id)objectAtIndex:(NSUInteger)idx
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    return [mutableOrderedSet objectAtIndex:idx];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    return [mutableOrderedSet objectsAtIndexes:indexes];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    [mutableOrderedSet removeObjectAtIndex:idx];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    [mutableOrderedSet removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    [mutableOrderedSet replaceObjectAtIndex:idx withObject:object];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    NSMutableOrderedSet *mutableOrderedSet = [self _nonNilMutableOrderedSetValueWithSelector:_cmd];
    [mutableOrderedSet replaceObjectsAtIndexes:indexes withObjects:objects];
}
@end

@implementation NSKeyValueIvarMutableSet
{
    Ivar _ivar;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueIvarMutableCollectionGetter*)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter*)getter];
    if (self != nil)
    {
        _ivar = [getter ivar];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [super _proxyNonGCFinalize];
    _ivar = NULL;
}

- (void)addObject:(id)object
{
    NSMutableSet **mutableSetIvar = (NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableSet *mutableSet = *mutableSetIvar;
    
    if (mutableSet)
    {
        [mutableSet addObject:object];
    }
    else
    {
        *mutableSetIvar = [[NSMutableSet alloc] initWithObjects:&object count:1];
    }
}

- (void)addObjectsFromArray:(NSArray *)array
{
    NSMutableSet **mutableSetIvar = (NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableSet *mutableSet = *mutableSetIvar;
    
    if (mutableSet)
    {
        [mutableSet addObjectsFromArray:array];
    }
    else
    {
        *mutableSetIvar = [[NSMutableSet alloc] initWithArray:array];
    }
}

- (NSUInteger)count
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    return [mutableSet count];
}

- (void)intersectSet:(NSSet *)set
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    [mutableSet intersectSet:set];
}

- (id)member:(id)object
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    return [mutableSet member:object];
}

- (void)minusSet:(NSSet *)set
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    [mutableSet minusSet:set];
}

- (NSEnumerator *)objectEnumerator
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    if (mutableSet)
    {
        return [mutableSet objectEnumerator];
    }
    else
    {
        return [[[NSKeyValueNilSetEnumerator alloc] init] autorelease];
    }
}

- (void)removeAllObjects
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    [mutableSet removeAllObjects];
}

- (void)removeObject:(id)object
{
    NSMutableSet *mutableSet = *(NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    [mutableSet removeObject:object];
}

- (void)setSet:(NSSet *)set
{
    NSMutableSet **mutableSetIvar = (NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableSet *mutableSet = *mutableSetIvar;
    
    if (mutableSet)
    {
        [mutableSet setSet:set];
    }
    else
    {
        *mutableSetIvar = [set mutableCopy];
    }
}

- (void)unionSet:(NSSet *)set
{
    NSMutableSet **mutableSetIvar = (NSMutableSet**)((char*)_container + ivar_getOffset(_ivar));
    NSMutableSet *mutableSet = *mutableSetIvar;
    
    if (mutableSet)
    {
        [mutableSet unionSet:set];
    }
    else
    {
        *mutableSetIvar = [set mutableCopy];
    }
}
@end

@implementation NSKeyValueNotifyingMutableArray
{
    NSMutableArray *_mutableArray;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueNotifyingMutableCollectionGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter*)getter];
    if (self != nil)
    {
        NSKeyValueProxyGetter *mutableCollectionGetter = [getter mutableCollectionGetter];
        _mutableArray = [_NSGetProxyValueWithGetterNoLock(container, mutableCollectionGetter) retain];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [_mutableArray release];
    [super _proxyNonGCFinalize];
    _mutableArray = nil;
}

- (void)addObject:(id)object
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:[_mutableArray count]];
    [_container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [_mutableArray addObject:object];
    [_container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (NSUInteger)count
{
    return [_mutableArray count];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    [_mutableArray getObjects:objects range:range];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [_container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [_mutableArray insertObject:object atIndex:idx];
    [_container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    [_container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [_mutableArray insertObjects:objects atIndexes:indexes];
    [_container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [_mutableArray objectAtIndex:idx];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    return [_mutableArray objectsAtIndexes:indexes];
}

- (void)removeLastObject
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:[_mutableArray count] - 1];
    [_container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [_mutableArray removeLastObject];
    [_container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [_container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [_mutableArray removeObjectAtIndex:idx];
    [_container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    [_container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [_mutableArray removeObjectsAtIndexes:indexes];
    [_container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [_container willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
    [_mutableArray replaceObjectAtIndex:idx withObject:object];
    [_container didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    [_container willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
    [_mutableArray replaceObjectsAtIndexes:indexes withObjects:objects];
    [_container didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
}
@end

@implementation NSKeyValueNotifyingMutableOrderedSet
{
    NSMutableOrderedSet *_mutableOrderedSet;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueNotifyingMutableCollectionGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter*)getter];
    if (self != nil)
    {
        NSKeyValueProxyGetter *mutableCollectionGetter = [getter mutableCollectionGetter];
        _mutableOrderedSet = [_NSGetProxyValueWithGetterNoLock(container, mutableCollectionGetter) retain];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [_mutableOrderedSet release];
    [super _proxyNonGCFinalize];
    _mutableOrderedSet = nil;
}

- (NSUInteger)count
{
    return [_mutableOrderedSet count];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    [_mutableOrderedSet getObjects:objects range:range];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [_mutableOrderedSet indexOfObject:object];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [_container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [_mutableOrderedSet insertObject:object atIndex:idx];
    [_container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    [_container willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
    [_mutableOrderedSet insertObjects:objects atIndexes:indexes];
    [_container didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:_key];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [_mutableOrderedSet objectAtIndex:idx];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [_container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [_mutableOrderedSet removeObjectAtIndex:idx];
    [_container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    [_container willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
    [_mutableOrderedSet removeObjectsAtIndexes:indexes];
    [_container didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:_key];
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:idx];
    [_container willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
    [_mutableOrderedSet replaceObjectAtIndex:idx withObject:object];
    [_container didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
    [indexes release];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    [_container willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
    [_mutableOrderedSet replaceObjectsAtIndexes:indexes withObjects:objects];
    [_container didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:_key];
}
@end

@implementation NSKeyValueNotifyingMutableSet
{
    NSMutableSet *_mutableSet;
}

+ (NSKeyValueProxyPool *)_proxyNonGCPoolPointer
{
    static NSKeyValueProxyPool proxyPool;
    return &proxyPool;
}

+ (NSHashTable *)_proxyShare
{
    static dispatch_once_t once;
    static NSHashTable *proxyShare;
    dispatch_once(&once, ^{
        proxyShare = [_NSKeyValueProxyShareCreate() retain];
    });
    return proxyShare;
}

- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueNotifyingMutableCollectionGetter *)getter
{
    self = [super _proxyInitWithContainer:container getter:(NSKeyValueCollectionGetter*)getter];
    if (self != nil)
    {
        NSKeyValueProxyGetter *mutableCollectionGetter = [getter mutableCollectionGetter];
        _mutableSet = [_NSGetProxyValueWithGetterNoLock(container, mutableCollectionGetter) retain];
    }
    return self;
}

- (void)_proxyNonGCFinalize
{
    [_mutableSet release];
    [super _proxyNonGCFinalize];
    _mutableSet = nil;
}

- (void)addObject:(id)object
{
    NSSet *objects = [[NSSet alloc] initWithObjects:&object count:1];
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
    [_mutableSet addObject:object];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
    [object release];
}

- (void)addObjectsFromArray:(NSArray *)array
{
    NSSet *objects = [[NSSet alloc] initWithArray:array];
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
    [_mutableSet addObjectsFromArray:array];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
    [objects release];
}

- (NSUInteger)count
{
    return [_mutableSet count];
}

- (void)intersectSet:(NSSet *)set
{
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:set];
    [_mutableSet intersectSet:set];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:set];
}

- (id)member:(id)object
{
    return [_mutableSet member:object];
}

- (void)minusSet:(NSSet *)set
{
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueMinusSetMutation usingObjects:set];
    [_mutableSet minusSet:set];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueMinusSetMutation usingObjects:set];
}

- (NSEnumerator *)objectEnumerator
{
    return [_mutableSet objectEnumerator];
}

- (void)removeAllObjects
{
    NSSet* emptySet = [NSSet set];
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:emptySet];
    [_mutableSet removeAllObjects];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueIntersectSetMutation usingObjects:emptySet];
}

- (void)removeObject:(id)object
{
    NSSet *objects = [[NSSet alloc] initWithObjects:&object count:1];
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objects];
    [_mutableSet removeObject:object];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueMinusSetMutation usingObjects:objects];
    [object release];
}

- (void)setSet:(NSSet *)set
{
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueSetSetMutation usingObjects:set];
    [_mutableSet setSet:set];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueSetSetMutation usingObjects:set];
}

- (void)unionSet:(NSSet *)set
{
    [_container willChangeValueForKey:_key withSetMutation:NSKeyValueUnionSetMutation usingObjects:set];
    [_mutableSet unionSet:set];
    [_container didChangeValueForKey:_key withSetMutation:NSKeyValueUnionSetMutation usingObjects:set];
}
@end
