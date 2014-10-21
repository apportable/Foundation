#import <Foundation/NSObject.h>

#import <Foundation/NSComparisonPredicate.h>
#import "NSPredicateInternal.h"

@interface NSPredicateOperator : NSObject <NSSecureCoding, NSCopying>

+ (id)operatorWithCustomSelector:(SEL)customSelector modifier:(NSComparisonPredicateModifier)modifier;
+ (id)_newOperatorWithType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options;
+ (id)operatorWithType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options;
+ (SEL)_getSelectorForType:(NSPredicateOperatorType)type;
+ (id)_getSymbolForType:(NSPredicateOperatorType)type;

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options;
- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier;
- (id)initWithOperatorType:(NSPredicateOperatorType)type;

- (NSComparisonPredicateOptions)options;
- (void)_setOptions:(NSComparisonPredicateOptions)options;
- (NSComparisonPredicateModifier)modifier;
- (void)_setModifier:(NSComparisonPredicateModifier)modifier;
- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags;
- (BOOL)performOperationUsingObject:(id)lhs andObject:(id)rhs;
- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs;
- (NSString *)symbol;
- (NSPredicateOperatorType)operatorType;
- (SEL)selector;
- (NSString *)predicateFormat;

@end

static inline NSString *comparisonPredicateOptionDescription(NSComparisonPredicateOptions options)
{
    if (options == 0)
    {
        return @"";
    }

    NSMutableString *desc = [NSMutableString stringWithString:@"["];

    if ((options & NSCaseInsensitivePredicateOption) != 0)
    {
        [desc appendString:@"c"];
    }
    if ((options & NSDiacriticInsensitivePredicateOption) != 0)
    {
        [desc appendString:@"d"];
    }
    if ((options & NSNormalizedPredicateOption) != 0)
    {
        [desc appendString:@"n"];
    }
    if ((options & NSLocaleSensitivePredicateOption) != 0)
    {
        [desc appendString:@"l"];
    }

    [desc appendString:@"]"];

    return desc;
}
