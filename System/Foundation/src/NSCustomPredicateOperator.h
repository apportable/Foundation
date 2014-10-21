#import "NSPredicateOperator.h"

CF_PRIVATE
@interface NSCustomPredicateOperator : NSPredicateOperator

- (id)initWithCustomSelector:(SEL)customSelector modifier:(NSComparisonPredicateModifier)modifier;

@end
