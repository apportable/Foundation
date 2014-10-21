#import <Foundation/NSObject.h>
#import <Foundation/NSEnumerator.h>

@class NSArray, NSDictionary, NSString;

@interface NSSet : NSObject <NSCopying, NSMutableCopying, NSSecureCoding, NSFastEnumeration>

- (NSUInteger)count;
- (id)member:(id)object;
- (NSEnumerator *)objectEnumerator;

@end

@interface NSSet (NSExtendedSet)

- (NSArray *)allObjects;
- (id)anyObject;
- (BOOL)containsObject:(id)anObject;
- (NSString *)description;
- (NSString *)descriptionWithLocale:(id)locale;
- (BOOL)intersectsSet:(NSSet *)other;
- (BOOL)isEqualToSet:(NSSet *)other;
- (BOOL)isSubsetOfSet:(NSSet *)other;
- (void)makeObjectsPerformSelector:(SEL)sel;
- (void)makeObjectsPerformSelector:(SEL)sel withObject:(id)argument;
- (NSSet *)setByAddingObject:(id)anObject;
- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other;
- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, BOOL *stop))block;
- (NSSet *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate;
- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, BOOL *stop))predicate;
#endif

@end

@interface NSSet (NSSetCreation)

+ (instancetype)set;
+ (instancetype)setWithObject:(id)object;
+ (instancetype)setWithObjects:(const id [])objects count:(NSUInteger)cnt;
+ (instancetype)setWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)setWithSet:(NSSet *)set;
+ (instancetype)setWithArray:(NSArray *)array;
- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt;
- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithSet:(NSSet *)set;
- (instancetype)initWithSet:(NSSet *)set copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray *)array;

@end

@interface NSMutableSet : NSSet

- (void)addObject:(id)object;
- (void)removeObject:(id)object;

@end

@interface NSMutableSet (NSExtendedMutableSet)

- (void)addObjectsFromArray:(NSArray *)array;
- (void)intersectSet:(NSSet *)other;
- (void)minusSet:(NSSet *)other;
- (void)removeAllObjects;
- (void)unionSet:(NSSet *)other;

- (void)setSet:(NSSet *)other;

@end

@interface NSMutableSet (NSMutableSetCreation)

+ (id)setWithCapacity:(NSUInteger)numItems;
- (id)initWithCapacity:(NSUInteger)numItems;

@end

@interface NSCountedSet : NSMutableSet

- (instancetype)initWithCapacity:(NSUInteger)numItems;
- (instancetype)initWithArray:(NSArray *)array;
- (instancetype)initWithSet:(NSSet *)set;
- (NSUInteger)countForObject:(id)object;
- (NSEnumerator *)objectEnumerator;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;

@end
