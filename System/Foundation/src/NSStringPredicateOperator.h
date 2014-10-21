#import "NSPredicateOperator.h"

@interface NSStringPredicateOperator : NSPredicateOperator

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSUInteger)variant;
- (NSComparisonPredicateOptions)flags;
- (NSString *)_modifierString;

@end
