#import "NSPredicateOperator.h"

@class NSDictionary;

@interface NSCompoundPredicateOperator : NSPredicateOperator

+ (id)notPredicateOperator;
+ (id)orPredicateOperator;
+ (id)andPredicateOperator;

- (BOOL)evaluatePredicates:(NSArray *)predicates withObject:(id)object substitutionVariables:(NSDictionary *)variables;
- (BOOL)evaluatePredicates:(NSArray *)predicates withObject:(id)object;

@end
