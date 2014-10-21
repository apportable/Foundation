#import <Foundation/NSObject.h>

@class NSString, NSArray, NSMutableDictionary, NSPredicate;

typedef NS_ENUM(NSUInteger, NSExpressionType) {
    NSConstantValueExpressionType = 0,
    NSEvaluatedObjectExpressionType,
    NSVariableExpressionType,
    NSKeyPathExpressionType,
    NSFunctionExpressionType,
    NSUnionSetExpressionType,
    NSIntersectSetExpressionType,
    NSMinusSetExpressionType,
    NSSubqueryExpressionType = 13,
    NSAggregateExpressionType
#if NS_BLOCKS_AVAILABLE
    ,
    NSBlockExpressionType = 19
#endif
};

@interface NSExpression : NSObject <NSCoding, NSCopying>
{
@package
    NSUInteger _expressionFlags;
    NSUInteger reserved;
    NSExpressionType _expressionType;
}

+ (NSExpression *)expressionWithFormat:(NSString *)format argumentArray:(NSArray *)arguments;
+ (NSExpression *)expressionWithFormat:(NSString *)format, ...;
+ (NSExpression *)expressionWithFormat:(NSString *)format arguments:(va_list)args;
+ (NSExpression *)expressionForConstantValue:(id)obj;
+ (NSExpression *)expressionForEvaluatedObject;
+ (NSExpression *)expressionForVariable:(NSString *)string;
+ (NSExpression *)expressionForKeyPath:(NSString *)keyPath;
+ (NSExpression *)expressionForFunction:(NSString *)name arguments:(NSArray *)parameters;
+ (NSExpression *)expressionForAggregate:(NSArray *)subexpressions;
+ (NSExpression *)expressionForUnionSet:(NSExpression *)left with:(NSExpression *)right;
+ (NSExpression *)expressionForIntersectSet:(NSExpression *)left with:(NSExpression *)right;
+ (NSExpression *)expressionForMinusSet:(NSExpression *)left with:(NSExpression *)right;
+ (NSExpression *)expressionForSubquery:(NSExpression *)expression usingIteratorVariable:(NSString *)variable predicate:(id)predicate;
+ (NSExpression *)expressionForFunction:(NSExpression *)target selectorName:(NSString *)name arguments:(NSArray *)parameters;
#if NS_BLOCKS_AVAILABLE
+ (NSExpression *)expressionForBlock:(id (^)(id evaluatedObject, NSArray *expressions, NSMutableDictionary *context))block arguments:(NSArray *)arguments;
#endif
- (id)initWithExpressionType:(NSExpressionType)type;
- (NSExpressionType)expressionType;
- (id)constantValue;
- (NSString *)keyPath;
- (NSString *)function;
- (NSString *)variable;
- (NSExpression *)operand;
- (NSArray *)arguments;
- (id)collection;
- (NSPredicate *)predicate;
- (NSExpression *)leftExpression;
- (NSExpression *)rightExpression;
#if NS_BLOCKS_AVAILABLE
- (id (^)(id, NSArray *, NSMutableDictionary *))expressionBlock;
#endif
- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context;

@end
