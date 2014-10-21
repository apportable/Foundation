#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSArray.h>

@class NSArray, NSIndexSet, NSLocale, NSSet, NSString;

@interface NSOrderedSet : NSObject <NSCopying, NSMutableCopying, NSSecureCoding, NSFastEnumeration>

+ (instancetype)orderedSet;
+ (instancetype)orderedSetWithObject:(id)object;
+ (instancetype)orderedSetWithObjects:(const id [])objects count:(NSUInteger)count;
+ (instancetype)orderedSetWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)orderedSetWithOrderedSet:(NSOrderedSet *)set;
+ (instancetype)orderedSetWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(BOOL)flag;
+ (instancetype)orderedSetWithArray:(NSArray *)array;
+ (instancetype)orderedSetWithArray:(NSArray *)array range:(NSRange)range copyItems:(BOOL)flag;
+ (instancetype)orderedSetWithSet:(NSSet *)set;
+ (instancetype)orderedSetWithSet:(NSSet *)set copyItems:(BOOL)flag;
- (instancetype)init;
- (instancetype)initWithObject:(id)object;
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count;
- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithOrderedSet:(NSOrderedSet *)set;
- (instancetype)initWithOrderedSet:(NSOrderedSet *)set copyItems:(BOOL)flag;
- (instancetype)initWithOrderedSet:(NSOrderedSet *)set range:(NSRange)range copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)set copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray *)set range:(NSRange)range copyItems:(BOOL)flag;
- (instancetype)initWithSet:(NSSet *)set;
- (instancetype)initWithSet:(NSSet *)set copyItems:(BOOL)flag;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)idx;
- (NSUInteger)indexOfObject:(id)object;
- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes;
- (id)firstObject;
- (id)lastObject;
- (BOOL)isEqualToOrderedSet:(NSOrderedSet *)other;
- (BOOL)containsObject:(id)object;
- (BOOL)intersectsOrderedSet:(NSOrderedSet *)other;
- (BOOL)intersectsSet:(NSSet *)set;
- (BOOL)isSubsetOfOrderedSet:(NSOrderedSet *)other;
- (BOOL)isSubsetOfSet:(NSSet *)set;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;
- (NSOrderedSet *)reversedOrderedSet;
- (NSArray *)array;
- (NSSet *)set;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (NSUInteger)indexOfObject:(id)object inSortedRange:(NSRange)range options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)comparator; // binary search
- (NSArray *)sortedArrayUsingComparator:(NSComparator)comparator;
- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparator;
#endif
- (NSString *)description;
- (NSString *)descriptionWithLocale:(NSLocale *)locale;
- (NSString *)descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)level;

@end

@interface NSMutableOrderedSet : NSOrderedSet

- (void)insertObject:(id)object atIndex:(NSUInteger)idx;
- (void)removeObjectAtIndex:(NSUInteger)idx;
- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object;
- (void)addObject:(id)object;
- (void)addObjects:(const id [])objects count:(NSUInteger)count;
- (void)addObjectsFromArray:(NSArray *)array;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)setObject:(id)obj atIndex:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (void)replaceObjectsInRange:(NSRange)range withObjects:(const id [])objects count:(NSUInteger)count;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;
- (void)removeObjectsInRange:(NSRange)range;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)removeAllObjects;
- (void)removeObject:(id)object;
- (void)removeObjectsInArray:(NSArray *)array;
- (void)intersectOrderedSet:(NSOrderedSet *)other;
- (void)minusOrderedSet:(NSOrderedSet *)other;
- (void)unionOrderedSet:(NSOrderedSet *)other;
- (void)intersectSet:(NSSet *)other;
- (void)minusSet:(NSSet *)other;
- (void)unionSet:(NSSet *)other;
#if NS_BLOCKS_AVAILABLE
- (void)sortUsingComparator:(NSComparator)comparitor;
- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparitor;
- (void)sortRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)comparator;
#endif
+ (instancetype)orderedSetWithCapacity:(NSUInteger)capacity;
- (instancetype)initWithCapacity:(NSUInteger)capacity;
- (instancetype)init;

@end
