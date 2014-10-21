#import <Foundation/NSPredicate.h>

typedef NS_OPTIONS(NSUInteger, NSComparisonPredicateOptions) {
    NSCaseInsensitivePredicateOption      = 0x01,
    NSDiacriticInsensitivePredicateOption = 0x02,
    NSNormalizedPredicateOption           = 0x04,
    NSLocaleSensitivePredicateOption      = 0x08,
};

typedef NS_ENUM(NSUInteger, NSComparisonPredicateModifier) {
    NSDirectPredicateModifier = 0,
    NSAllPredicateModifier,
    NSAnyPredicateModifier
};

typedef NS_ENUM(NSUInteger, NSPredicateOperatorType) {
    NSLessThanPredicateOperatorType = 0,
    NSLessThanOrEqualToPredicateOperatorType,
    NSGreaterThanPredicateOperatorType,
    NSGreaterThanOrEqualToPredicateOperatorType,
    NSEqualToPredicateOperatorType,
    NSNotEqualToPredicateOperatorType,
    NSMatchesPredicateOperatorType,
    NSLikePredicateOperatorType,
    NSBeginsWithPredicateOperatorType,
    NSEndsWithPredicateOperatorType,
    NSInPredicateOperatorType,
    NSCustomSelectorPredicateOperatorType,
    NSContainsPredicateOperatorType = 99,
    NSBetweenPredicateOperatorType
};

@class NSExpression;

@interface NSComparisonPredicate : NSPredicate

+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options;
+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs customSelector:(SEL)selector;
- (id)initWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options;
- (id)initWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs customSelector:(SEL)selector;
- (NSPredicateOperatorType)predicateOperatorType;
- (NSComparisonPredicateModifier)comparisonPredicateModifier;
- (NSExpression *)leftExpression;
- (NSExpression *)rightExpression;
- (SEL)customSelector;
- (NSComparisonPredicateOptions)options;

@end
