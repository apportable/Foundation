#import "NSPredicateOperator.h"

@interface NSInPredicateOperator : NSPredicateOperator

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options;
- (NSComparisonPredicateOptions)flags;
- (id)stringVersion;

@end
