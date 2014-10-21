#import <Foundation/NSPointerFunctions.h>
#import <Foundation/NSString.h>
#import <Foundation/NSEnumerator.h>

#if !defined(__FOUNDATION_NSHASHTABLE__)
#define __FOUNDATION_NSHASHTABLE__ 1

@class NSArray, NSSet, NSHashTable;

enum {
    NSHashTableStrongMemory NS_ENUM_AVAILABLE(10_5, 6_0) = 0,
    NSHashTableCopyIn NS_ENUM_AVAILABLE(10_5, 6_0) = NSPointerFunctionsCopyIn,
    NSHashTableObjectPointerPersonality NS_ENUM_AVAILABLE(10_5, 6_0) = NSPointerFunctionsObjectPointerPersonality,
    NSHashTableWeakMemory NS_ENUM_AVAILABLE(10_8, 6_0) = NSPointerFunctionsWeakMemory,
};

typedef NSUInteger NSHashTableOptions;

@interface NSHashTable : NSObject <NSCopying, NSCoding, NSFastEnumeration>

+ (id)hashTableWithOptions:(NSPointerFunctionsOptions)options;
+ (id)weakObjectsHashTable;

- (id)initWithOptions:(NSPointerFunctionsOptions)options capacity:(NSUInteger)initialCapacity;
- (id)initWithPointerFunctions:(NSPointerFunctions *)functions capacity:(NSUInteger)initialCapacity;
- (NSPointerFunctions *)pointerFunctions;
- (NSUInteger)count;
- (id)member:(id)object;
- (NSEnumerator *)objectEnumerator;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeAllObjects;
- (NSArray *)allObjects;
- (id)anyObject;
- (BOOL)containsObject:(id)anObject;
- (BOOL)intersectsHashTable:(NSHashTable *)other;
- (BOOL)isEqualToHashTable:(NSHashTable *)other;
- (BOOL)isSubsetOfHashTable:(NSHashTable *)other;
- (void)intersectHashTable:(NSHashTable *)other;
- (void)unionHashTable:(NSHashTable *)other;
- (void)minusHashTable:(NSHashTable *)other;
- (NSSet *)setRepresentation;

@end

#endif
