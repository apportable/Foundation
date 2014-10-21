#import <Foundation/NSExpression.h>

#import <Foundation/NSException.h>
#import "NSPredicateInternal.h"

#define NSKeyPathSpecifierExpressionType 10
#define NSSymbolicExpressionType 11
#define NSAnyKeyExpressionType 16
#define NSVariableAssignmentExpressionType 16
#define NSTernaryExpressionType 20
#define NSSelfExpressionType 24

#define NSSelfExpressionHash 8421

#define NSSymbolicFirstElement @"FIRST"
#define NSSymbolicLastElement @"LAST"
#define NSSymbolicSizeAccessor @"SIZE"

@interface NSExpression (Internal)
- (void)allowEvaluation;
- (BOOL)_allowsEvaluation;
- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags;
- (NSString *)predicateFormat;
- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context;
- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables;
- (BOOL)_shouldUseParensWithDescription;
+ (NSExpression *)_newKeyPathExpressionForString:(NSString *)string;
@end

CF_PRIVATE
@interface NSAggregateExpression : NSExpression
- (id)initWithCollection:(id)collection;
@end

CF_PRIVATE
@interface NSAnyKeyExpression : NSExpression
@end

@interface NSBlockExpression : NSExpression
- (id)initWithType:(NSExpressionType)type block:(id (^)(id, NSArray *, NSMutableDictionary *))block arguments:(NSArray *)arguments;
@end

@interface NSConstantValueExpression : NSExpression
- (id)initWithObject:(id)object;
@end

@interface NSFunctionExpression : NSExpression
- (id)initWithSelector:(SEL)selector argumentArray:(NSArray *)argumentArray;
- (id)initWithTarget:(id)target selectorName:(NSString *)selectorName arguments:(NSArray *)arguments;
- (id)initWithExpressionType:(NSExpressionType)type operand:(id)operand selector:(SEL)selector argumentArray:(NSArray *)args;
@end

@interface NSKeyPathExpression : NSFunctionExpression
- (id)initWithKeyPath:(NSExpression *)keyPath;
@end

@interface NSKeyPathSpecifierExpression : NSExpression
- (id)initWithObject:(id)object;
@end

@interface NSSelfExpression : NSExpression
+ (id)defaultInstance;
@end

@interface NSSetExpression : NSExpression
- (id)initWithType:(NSExpressionType)type leftExpression:(NSExpression *)left rightExpression:(NSExpression *)right;
@end

@interface NSSubqueryExpression : NSExpression
- (id)initWithExpression:(NSExpression *)expression usingIteratorVariable:(NSString *)variable predicate:(NSPredicate *)predicate;
@end

CF_PRIVATE
@interface NSSymbolicExpression : NSExpression
- (id)initWithString:(NSString *)string;
@end

@interface NSTernaryExpression : NSExpression
- (id)initWithPredicate:(NSPredicate *)predicate trueExpression:(NSExpression *)trueExpression falseExpression:(NSExpression *)falseExpression;
@end

CF_PRIVATE
@interface NSVariableAssignmentExpression : NSExpression
- (id)initWithAssignmentVariable:(NSString *)variableName expression:(NSExpression *)expression;
@end

@interface NSVariableExpression : NSExpression
- (id)initWithObject:(id)object;
@end

static inline BOOL _NSExpressionEvaluationCheck(NSExpression *expression)
{
    if (![expression _allowsEvaluation])
    {
        [NSException raise:NSInternalInconsistencyException format:@"This object has had evaluation disabled"];
        return NO;
    }
    return YES;
}
