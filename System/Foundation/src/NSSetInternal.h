#import <Foundation/NSSet.h>
#import "NSObjectInternal.h"
#import "NSFastEnumerationEnumerator.h"
#import "CFInternal.h"

CF_EXPORT Boolean _CFSetIsMutable(CFSetRef hc);
CF_EXPORT NSUInteger _CFSetFastEnumeration(CFSetRef set, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);
CF_EXPORT NSUInteger _CFBagFastEnumeration(CFBagRef hc, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);

@interface NSSet (Internal)
- (void)getObjects:(id *)objects count:(NSUInteger)count;
- (NSUInteger)countForObject:(id)obj;
@end

@interface __NSPlaceholderSet : NSMutableSet

+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;

- (id)initWithCapacity:(NSUInteger)capacity;
- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt;

@end

__attribute__((visibility("hidden")))
@interface __NSCFSet : NSMutableSet {
    unsigned char _cfinfo[4];
    unsigned int _bits[4];
    void *_callbacks;
    id *_values;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (void)getObjects:(id *)objects;
- (void)removeAllObjects;
- (void)removeObject:(id)object;
- (void)addObject:(id)object;
- (NSEnumerator *)objectEnumerator;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (NSUInteger)_trueCount;
- (id)member:(id)object;
- (NSUInteger)count;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (Class)classForCoder;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)object;

@end

@interface NSSet (NSKeyValueInternalCoding)

- (id)_minForKeyPath:(id)keyPath;
- (id)_maxForKeyPath:(id)keyPath;
- (id)_avgForKeyPath:(id)keyPath;
- (id)_sumForKeyPath:(id)keyPath;
- (id)_countForKeyPath:(id)keyPath;
- (id)_distinctUnionOfSetsForKeyPath:(id)keyPath;
- (id)_distinctUnionOfObjectsForKeyPath:(id)keyPath;
- (id)_distinctUnionOfArraysForKeyPath:(id)keyPath;

@end
