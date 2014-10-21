#import "NSPredicateOperator.h"

@interface NSEqualityPredicateOperator : NSPredicateOperator

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier negate:(BOOL)negate options:(NSComparisonPredicateOptions)options;
- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier negate:(BOOL)negate;
- (void)setNegation:(BOOL)negation;
- (BOOL)isNegation;

@end
