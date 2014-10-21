#import <Foundation/NSArray.h>
#import "NSKeyValueAccessor.h"
#import "NSKeyValueObservingInternal.h"
#import <Foundation/NSObject.h>
#import <Foundation/NSOrderedSet.h>
#import <Foundation/NSSet.h>

@class NSEnumerator;
@class NSHashTable;
@class NSIndexSet;

typedef struct {
    id container;
    NSString *key;
} NSKeyValueProxyLocator;

struct NSKeyValueProxyPool;

@class NSKeyValueCollectionGetter;

@protocol NSKeyValueProxyCaching
+ (NSHashTable *)_proxyShare;
+ (struct NSKeyValueProxyPool *)_proxyNonGCPoolPointer;
- (void)_proxyNonGCFinalize;
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
- (NSKeyValueProxyLocator)_proxyLocator;
@end

#define PROXY_POOLS 4

typedef struct NSKeyValueProxyPool {
    NSUInteger idx;
    id<NSKeyValueProxyCaching> proxy[PROXY_POOLS];
} NSKeyValueProxyPool;

CF_PRIVATE
@interface NSKeyValueNonmutatingCollectionMethodSet : NSObject
@end

CF_PRIVATE
@interface NSKeyValueNonmutatingArrayMethodSet : NSKeyValueNonmutatingCollectionMethodSet
@end

CF_PRIVATE
@interface NSKeyValueNonmutatingOrderedSetMethodSet : NSKeyValueNonmutatingCollectionMethodSet
@end

CF_PRIVATE
@interface NSKeyValueNonmutatingSetMethodSet : NSKeyValueNonmutatingCollectionMethodSet
@end

CF_PRIVATE
@interface NSKeyValueMutatingCollectionMethodSet : NSObject
@end

CF_PRIVATE
@interface NSKeyValueMutatingArrayMethodSet : NSKeyValueMutatingCollectionMethodSet
{
@public
    Method insertObjectAtIndex;
    Method insertObjectsAtIndexes;
    Method removeObjectAtIndex;
    Method removeObjectsAtIndexes;
    Method replaceObjectAtIndex;
    Method replaceObjectsAtIndexes;
}
@end

CF_PRIVATE
@interface NSKeyValueMutatingOrderedSetMethodSet : NSKeyValueMutatingCollectionMethodSet
{
@public
    Method insertObjectAtIndex;
    Method removeObjectAtIndex;
    Method replaceObjectAtIndex;
    Method insertObjectsAtIndexes;
    Method removeObjectsAtIndexes;
    Method replaceObjectsAtIndexes;
}
@end

CF_PRIVATE
@interface NSKeyValueMutatingSetMethodSet : NSKeyValueMutatingCollectionMethodSet
{
@public
    Method addObject;
    Method removeObject;
    Method intersectSet;
    Method minusSet;
    Method unionSet;
    Method setSet;
}
@end

CF_PRIVATE
@interface NSKeyValueNilOrderedSetEnumerator : NSEnumerator
@end

CF_PRIVATE
@interface NSKeyValueNilSetEnumerator : NSEnumerator
@end

CF_PRIVATE
@interface NSKeyValueSlowGetter : NSKeyValueGetter
@end

CF_PRIVATE
@interface NSKeyValueSlowSetter : NSKeyValueSetter
@end

CF_PRIVATE
@interface NSKeyValueProxyGetter : NSKeyValueGetter
@end

CF_PRIVATE
@interface NSKeyValueCollectionGetter : NSKeyValueProxyGetter
- (NSKeyValueNonmutatingCollectionMethodSet *)methods;
@end

CF_PRIVATE
@interface NSKeyValueSlowMutableCollectionGetter : NSKeyValueProxyGetter
- (id)initWithContainerClassID:(Class)cls key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter baseSetter:(NSKeyValueSetter *)baseSetter containerIsa:(Class)containerIsa proxyClass:(Class)proxyClass;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableCollection1Getter : NSKeyValueProxyGetter
- (id)initWithContainerClassID:(Class)cls key:(NSString *)key nonmutatingMethods:(NSKeyValueNonmutatingCollectionMethodSet *)nonmutatingMethods mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableCollection2Getter : NSKeyValueProxyGetter
- (id)initWithContainerClassID:(Class)cls key:(NSString *)key baseGetter:(NSKeyValueGetter *)baseGetter mutatingMethods:(NSKeyValueMutatingCollectionMethodSet *)mutatingMethods proxyClass:(Class)proxyClass;
@end

CF_PRIVATE
@interface NSKeyValueIvarMutableCollectionGetter : NSKeyValueProxyGetter
- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)containerIsa ivar:(Ivar)ivar proxyClass:(Class)proxyClass;
@end

CF_PRIVATE
@interface NSKeyValueNotifyingMutableCollectionGetter : NSKeyValueProxyGetter
- (id)initWithContainerClassID:(Class)cls key:(NSString*)key mutableCollectionGetter:(NSKeyValueProxyGetter*)getter proxyClass:(Class)proxyClass;
@end

CF_PRIVATE
@interface NSKeyValueProxyShareKey : NSObject <NSKeyValueProxyCaching>
{
@public
    NSObject *_container;
    NSString *_key;
}
@end

CF_PRIVATE
@interface NSKeyValueArray : NSArray <NSKeyValueProxyCaching>
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueOrderedSet : NSOrderedSet <NSKeyValueProxyCaching>
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueSet : NSSet <NSKeyValueProxyCaching>
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueMutableArray : NSMutableArray <NSKeyValueProxyCaching>
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueMutableOrderedSet : NSMutableOrderedSet <NSKeyValueProxyCaching>
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueMutableSet : NSMutableSet <NSKeyValueProxyCaching>
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueSlowMutableArray : NSKeyValueMutableArray
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueSlowMutableOrderedSet : NSKeyValueMutableOrderedSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueSlowMutableSet : NSKeyValueMutableSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueSlowMutableCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableArray : NSKeyValueMutableArray
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueProxyGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableArray1 : NSKeyValueFastMutableArray
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection1Getter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableArray2 : NSKeyValueFastMutableArray
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection2Getter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableOrderedSet : NSKeyValueMutableOrderedSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueProxyGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableOrderedSet1 : NSKeyValueFastMutableOrderedSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection1Getter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableOrderedSet2 : NSKeyValueFastMutableOrderedSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection2Getter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableSet : NSKeyValueMutableSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueProxyGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableSet1 : NSKeyValueFastMutableSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection1Getter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueFastMutableSet2 : NSKeyValueFastMutableSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueFastMutableCollection2Getter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueIvarMutableArray : NSKeyValueMutableArray
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueIvarMutableCollectionGetter*)getter;
@end

CF_PRIVATE
@interface NSKeyValueIvarMutableOrderedSet : NSKeyValueMutableOrderedSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueIvarMutableCollectionGetter*)getter;
@end

CF_PRIVATE
@interface NSKeyValueIvarMutableSet : NSKeyValueMutableSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueIvarMutableCollectionGetter*)getter;
@end

CF_PRIVATE
@interface NSKeyValueNotifyingMutableArray : NSKeyValueMutableArray
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueNotifyingMutableCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueNotifyingMutableOrderedSet : NSKeyValueMutableOrderedSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueNotifyingMutableCollectionGetter *)getter;
@end

CF_PRIVATE
@interface NSKeyValueNotifyingMutableSet : NSKeyValueMutableSet
- (id)_proxyInitWithContainer:(NSObject *)container getter:(NSKeyValueNotifyingMutableCollectionGetter *)getter;
@end
