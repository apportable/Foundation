#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSOrderedSet.h>

@interface NSPredicate : NSObject <NSCoding, NSCopying>

+ (NSPredicate *)predicateWithFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments;
+ (NSPredicate *)predicateWithFormat:(NSString *)predicateFormat, ...;
+ (NSPredicate *)predicateWithFormat:(NSString *)predicateFormat arguments:(va_list)args;
+ (NSPredicate *)predicateWithValue:(BOOL)value;
#if NS_BLOCKS_AVAILABLE
+ (NSPredicate*)predicateWithBlock:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block;
#endif

- (NSString *)predicateFormat;
- (NSPredicate *)predicateWithSubstitutionVariables:(NSDictionary *)variables;
- (BOOL)evaluateWithObject:(id)object;
- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)bindings;

@end

@interface NSArray (NSPredicateSupport)

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate;

@end

@interface NSMutableArray (NSPredicateSupport)

- (void)filterUsingPredicate:(NSPredicate *)predicate;

@end

@interface NSSet (NSPredicateSupport)

- (NSSet *)filteredSetUsingPredicate:(NSPredicate *)predicate;

@end

@interface NSOrderedSet (NSPredicateSupport)

- (NSOrderedSet *)filteredOrderedSetUsingPredicate:(NSPredicate *)predicate;

@end

@interface NSMutableSet (NSPredicateSupport)

- (void)filterUsingPredicate:(NSPredicate *)predicate;

@end
