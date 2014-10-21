#import "NSPredicateOperator.h"

@interface NSComparisonPredicateOperator : NSPredicateOperator

- (NSPredicateOperatorType)variant;
- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSPredicateOperatorType)variant options:(NSComparisonPredicateOptions)options;
- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSPredicateOperatorType)variant;

@end
