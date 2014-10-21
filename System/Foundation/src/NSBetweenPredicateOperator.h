#import "NSPredicateOperator.h"

CF_PRIVATE
@interface NSBetweenPredicateOperator : NSPredicateOperator
- (BOOL)performPrimitiveOperationUsingObject:(id)obj andObject:(NSArray *)array;
@end
