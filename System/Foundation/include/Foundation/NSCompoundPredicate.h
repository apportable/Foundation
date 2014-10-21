#import <Foundation/NSPredicate.h>

@class NSArray;

typedef NS_ENUM(NSUInteger, NSCompoundPredicateType) {
    NSNotPredicateType = 0,

    NSAndPredicateType,
    NSOrPredicateType,
};

@interface NSCompoundPredicate : NSPredicate

+ (NSPredicate *)andPredicateWithSubpredicates:(NSArray *)subpredicates;
+ (NSPredicate *)orPredicateWithSubpredicates:(NSArray *)subpredicates;
+ (NSPredicate *)notPredicateWithSubpredicate:(NSPredicate *)predicate;
- (id)initWithType:(NSCompoundPredicateType)type subpredicates:(NSArray *)subpredicates;
- (NSCompoundPredicateType)compoundPredicateType;
- (NSArray *)subpredicates;

@end
