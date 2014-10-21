#import "NSStringPredicateOperator.h"

#import <unicode/uregex.h>

struct regexContext {
    NSString *_field1;
    URegularExpression *_field2;
};

CF_PRIVATE
@interface NSMatchingPredicateOperator : NSStringPredicateOperator

- (BOOL)_shouldEscapeForLike;
- (void)_clearContext;

@end
