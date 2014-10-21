#import <Foundation/NSPredicate.h>
#import "NSObjectInternal.h"
#import <Foundation/NSCoder.h>

@class NSExpression;
@class NSPredicateOperator;

#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>

typedef NS_OPTIONS(NSUInteger, NSPredicateEvaluationFlags) {
    NSPredicateEvaluationBlocked = 1 << 0,
};

typedef NS_OPTIONS(NSUInteger, NSPredicateVisitorFlags) {
    NSPredicateVisitorVisitExpressions = 1 << 0,
    NSPredicateVisitorVisitOperators = 1 << 1,
    NSPredicateVisitorVisitInternalNodes = 1 << 2,
    NSPredicateVisitorVisitOperatorsBefore = 1 << 3,
};

@interface NSObject (PredicateVisitor)
- (void)visitPredicate:(NSPredicate *)predicate;
@end

@protocol _NSPredicateVisitor
- (void)visitPredicateExpression:(NSExpression *)expression;
- (void)visitPredicateOperator:(NSPredicateOperator *)predicateOperator;
- (void)visitPredicate:(NSPredicate *)predicate;
@end

@interface NSPredicate (Internal)
- (void)allowEvaluation;
- (BOOL)_allowsEvaluation;
- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)variables;
- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags;
@end

@interface NSBlockPredicate : NSPredicate
- (id)initWithBlock:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block;
@end

@interface NSFalsePredicate : NSPredicate
+ (NSFalsePredicate *)defaultInstance;
@end
extern NSFalsePredicate *_NSTheOneFalsePredicate;

@interface NSTruePredicate : NSPredicate
+ (NSTruePredicate *)defaultInstance;
@end
extern NSTruePredicate *_NSTheOneTruePredicate;

CF_PRIVATE NSPredicate *_parsePredicateArray(NSString *format, NSArray *args);
CF_PRIVATE NSPredicate *_parsePredicateVarArgs(NSString *format, va_list args);
CF_PRIVATE void _parsePredicateError(const char *error);

static inline BOOL _NSPredicateKeyedArchiverCheck(NSCoder *coder)
{
    if (![coder allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"Predicates and expressions can only be coded by keyed archivers"];
        return NO;
    }
    return YES;
}

static inline BOOL _NSPredicateEvaluationCheck(NSPredicate *predicate)
{
    if (![predicate _allowsEvaluation])
    {
        [NSException raise:NSInternalInconsistencyException format:@"This object has had evaluation disabled"];
        return NO;
    }
    return YES;
}

static inline BOOL _NSPredicateSubstitutionCheck(NSDictionary *variables)
{
    if (variables == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot substitute nil dictionary"];
        return NO;
    }
    return YES;
}
