#import <Foundation/NSObject.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSObjCRuntime.h>

typedef NS_OPTIONS(NSUInteger, NSBinarySearchingOptions) {
    NSBinarySearchingFirstEqual     = (1UL << 8),
    NSBinarySearchingLastEqual      = (1UL << 9),
    NSBinarySearchingInsertionIndex = (1UL << 10),
};

@class NSData, NSIndexSet, NSString, NSURL;

@interface NSArray : NSObject <NSCopying, NSMutableCopying, NSSecureCoding, NSFastEnumeration>

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)idx;

@end

@interface NSArray (NSExtendedArray)

- (NSArray *)arrayByAddingObject:(id)obj;
- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)other;
- (NSString *)componentsJoinedByString:(NSString *)sep;
- (BOOL)containsObject:(id)obj;
- (NSString *)description;
- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
- (id)firstObjectCommonWithArray:(NSArray *)other;
- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range;
- (NSUInteger)indexOfObject:(id)obj;
- (NSUInteger)indexOfObject:(id)obj inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(id)obj;
- (NSUInteger)indexOfObjectIdenticalTo:(id)obj inRange:(NSRange)range;
- (BOOL)isEqualToArray:(NSArray *)other;
- (id)firstObject;
- (id)lastObject;
- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;
- (NSData *)sortedArrayHint;
- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context;
- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint;
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray *)subarrayWithRange:(NSRange)range;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;
- (void)makeObjectsPerformSelector:(SEL)sel;
- (void)makeObjectsPerformSelector:(SEL)sel withObject:(id)aeg;
- (NSArray *)objectsAtIndexes:(NSIndexSet *)indices;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
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
- (NSArray *)sortedArrayUsingComparator:(NSComparator)comparator;
- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparator;
- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)comparator;
#endif

@end

@interface NSArray (NSArrayCreation)

+ (instancetype)array;
+ (instancetype)arrayWithObject:(id)obj;
+ (instancetype)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt;
+ (instancetype)arrayWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)arrayWithArray:(NSArray *)array;

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt;
- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)flag;
+ (instancetype)arrayWithContentsOfFile:(NSString *)path;
+ (instancetype)arrayWithContentsOfURL:(NSURL *)url;
- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)initWithContentsOfURL:(NSURL *)url;

@end

@interface NSArray (NSDeprecated)

- (void)getObjects:(id __unsafe_unretained [])objects;

@end

@interface NSMutableArray : NSArray

- (void)addObject:(id)obj;
- (void)insertObject:(id)obj atIndex:(NSUInteger)idx;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)idx;
- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj;

@end

@interface NSMutableArray (NSExtendedMutableArray)

- (void)addObjectsFromArray:(NSArray *)other;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(id)obj inRange:(NSRange)range;
- (void)removeObject:(id)obj;
- (void)removeObjectIdenticalTo:(id)obj inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(id)obj;
- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt;
- (void)removeObjectsInArray:(NSArray *)other;
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)other range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)other;
- (void)setArray:(NSArray *)other;
- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (void)sortUsingSelector:(SEL)comparator;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indices;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indices;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indices withObjects:(NSArray *)objects;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
#if NS_BLOCKS_AVAILABLE
- (void)sortUsingComparator:(NSComparator)comparator;
- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparator;
#endif

@end

@interface NSMutableArray (NSMutableArrayCreation)

+ (instancetype)arrayWithCapacity:(NSUInteger)numItems;
- (instancetype)init;
- (instancetype)initWithCapacity:(NSUInteger)numItems;

@end
