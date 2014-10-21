//
//  NSFunctionExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSOrderedSet.h>

static NSString * const NSArgumentsKey = @"NSArguments";
static NSString * const NSOperandKey = @"NSOperand";
static NSString * const NSSelectorNameKey = @"NSSelectorName";

@implementation NSFunctionExpression
{
    NSExpression *_operand;
    SEL _selector;
    NSArray *_arguments;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithExpressionType:(NSExpressionType)type operand:(id)operand selector:(SEL)selector argumentArray:(NSArray *)arguments
{
    self = [super initWithExpressionType:type];
    if (self != nil)
    {
        _operand = [operand retain];
        _selector = selector;
        _arguments = [arguments retain];
    }
    return self;
}

- (id)initWithTarget:(id)target selectorName:(NSString *)selectorName arguments:(NSArray *)arguments
{
    SEL selector = NSSelectorFromString(selectorName);
    if (selector == NULL)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Bad selector name"];
        return nil;
    }

    self = [super initWithExpressionType:NSFunctionExpressionType];
    if (self != nil)
    {
        _operand = [target retain];
        _selector = selector;
        _arguments = [arguments retain];
    }
    return self;
}

- (id)initWithSelector:(SEL)selector argumentArray:(NSArray *)argumentArray
{
    id operand = [[[NSConstantValueExpression alloc] initWithObject:[_NSPredicateUtilities self]] autorelease];
    return [self initWithExpressionType:NSFunctionExpressionType operand:operand selector:selector argumentArray:argumentArray];
}

- (void)dealloc
{
    [_operand release];
    [_arguments release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSFunctionExpression self]])
    {
        return NO;
    }
    if ([self selector] != [other selector])
    {
        return NO;
    }
    if (![[self operand] isEqual:[other operand]])
    {
        return NO;
    }
    if (![[self arguments] isEqual:[other arguments]])
    {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger operandHash = [[self operand] hash];
    NSUInteger functionHash = [[self function] hash];
    NSUInteger argumentsHash = [[self arguments] hash];

    return operandHash ^ functionHash ^ argumentsHash;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithExpressionType:NSFunctionExpressionType operand:[self operand] selector:_selector argumentArray:_arguments];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    self = [super initWithCoder:decoder];
    if (self != nil)
    {
        NSSet *predicateAllowedExpressionClasses = [_NSPredicateUtilities _expressionClassesForSecureCoding];
        NSSet *predicateAllowedExtendedExpressionClasses = [_NSPredicateUtilities _extendedExpressionClassesForSecureCoding];

        NSSet *allowedExpressionClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedExpressionClasses);
        NSSet *allowedExtendedExpressionClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedExtendedExpressionClasses);

        _selector = NSSelectorFromString([decoder decodeObjectOfClass:[NSString self] forKey:NSSelectorNameKey]);
        _operand = [[decoder decodeObjectOfClasses:allowedExpressionClasses forKey:NSOperandKey] retain];
        _arguments = [[decoder decodeObjectOfClasses:allowedExtendedExpressionClasses forKey:NSArgumentsKey] retain];

        if (![_operand isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _operand];
            return nil;
        }

        if (_arguments != nil &&
            ![_arguments isKindOfClass:[NSArray self]] &&
            ![_arguments isKindOfClass:[NSOrderedSet self]] &&
            ![_arguments isKindOfClass:[NSSet self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded argument collection %@", _arguments];
            return nil;
        }

        for (id arg in _arguments)
        {
            if (![arg isKindOfClass:[NSExpression self]])
            {
                [self release];
                [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", arg];
                return nil;
            }
        }

        if (_selector == NULL)
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Could not decode selector"];
            return nil;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];

    [coder encodeObject:NSStringFromSelector([self selector]) forKey:NSSelectorNameKey];
    [coder encodeObject:[self operand] forKey:NSOperandKey];
    [coder encodeObject:[self arguments] forKey:NSArgumentsKey];
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSExpression *newOperand = [[self operand] _expressionWithSubstitutionVariables:variables];

    NSMutableArray *newArguments = [NSMutableArray array];

    for (NSExpression *e in _arguments)
    {
        [newArguments addObject:[e _expressionWithSubstitutionVariables:variables]];
    }

    NSExpressionType type = [self expressionType];
    return [[[[self class] alloc] initWithExpressionType:type operand:newOperand selector:_selector argumentArray:newArguments] autorelease];
}

- (NSExpression *)operand
{
    return _operand;
}

- (NSArray *)arguments
{
    return _arguments;
}

- (NSString *)function
{
    return NSStringFromSelector([self selector]);
}

- (SEL)selector
{
    return _selector;
}

- (NSString *)binaryOperatorForSelector
{
    if (_selector == @selector(onesComplement:))
    {
        return @"~";
    }
    else if (_selector == @selector(rightshift:by:))
    {
        return @">>";
    }
    else if (_selector == @selector(leftshift:by:))
    {
        return @"<<";
    }
    else if (_selector == @selector(bitwiseXor:with:))
    {
        return @"^";
    }
    else if (_selector == @selector(bitwiseOr:with:))
    {
        return @"|";
    }
    else if (_selector == @selector(bitwiseAnd:with:))
    {
        return @"&";
    }
    else if (_selector == @selector(abs:))
    {
        return @"|";
    }
    else if (_selector == @selector(raise:toPower:))
    {
        return @"e";
    }
    else if (_selector == @selector(divide:by:))
    {
        return @"/";
    }
    else if (_selector == @selector(multiply:by:))
    {
        return @"*";
    }
    else if (_selector == @selector(from:subtract:))
    {
        return @"-";
    }
    else if (_selector == @selector(add:to:))
    {
        return @"+";
    }
    else if (_selector == @selector(objectFrom:withIndex:))
    {
        return @"[";
    }

    return nil;
}

- (void)allowEvaluation
{
    [[self operand] allowEvaluation];
    for (id arg in _arguments)
    {
        [arg allowEvaluation];
    }
    [super allowEvaluation];
}

- (NSString *)predicateFormat
{
    NSString *binop = [self binaryOperatorForSelector];
    if (binop != nil)
    {
        NSExpression *left = [[self arguments] objectAtIndex:0];
        NSString *leftOpenParen = @"";
        NSString *leftCloseParen = @"";
        if ([left _shouldUseParensWithDescription])
        {
            leftOpenParen = @"(";
            leftCloseParen = @")";
        }

        NSExpression *right = [[self arguments] objectAtIndex:0];
        NSString *rightOpenParen = @"";
        NSString *rightCloseParen = @"";
        if ([right _shouldUseParensWithDescription])
        {
            rightOpenParen = @"(";
            rightCloseParen = @")";
        }

        unichar firstChar = [binop characterAtIndex:0];
        if (firstChar == '[')
        {
            return [NSString stringWithFormat:@"%@%@%@[%@]", leftOpenParen, left, leftCloseParen, right];
        }

        if (firstChar == 'e')
        {
            binop = @"**";
        }
        return [NSString stringWithFormat:@"%@%@%@ %@ %@%@%@", leftOpenParen, left, leftCloseParen, binop, rightOpenParen, right, rightCloseParen];
    }

    SEL selector = [self selector];

    if (selector == @selector(onesComplement:))
    {
        NSExpression *expression = [[self arguments] objectAtIndex:0];
        NSString *openParen = @"";
        NSString *closeParen = @"";
        if ([expression _shouldUseParensWithDescription])
        {
            openParen = @"(";
            closeParen = @")";
        }
        return [NSString stringWithFormat:@"%@~%@%@", openParen, expression, closeParen];
    }

    NSString *selectorName = NSStringFromSelector(selector);
    if (selector == @selector(castObject:toType:))
    {
        selectorName = @"CAST";
    }
    else if ([_NSPredicateUtilities _isReservedWordInParser:selectorName])
    {
        selectorName = [NSString stringWithFormat:@"#%@", selectorName];
    }

    NSExpression *operand = [self operand];
    NSArray *arguments = [self arguments];

    do {
        if (operand == nil)
        {
            break;
        }
        if ([operand isKindOfClass:[NSConstantValueExpression self]] &&
            [operand constantValue] == [_NSPredicateUtilities self])
        {
            break;
        }
        if ([arguments count] > 0)
        {
            NSString *quotedSelectorName = [NSString stringWithFormat:@"\"%@\" ", selectorName];
            NSMutableArray *fullArguments = [NSMutableArray arrayWithObjects:operand, quotedSelectorName, nil];
            [fullArguments addObjectsFromArray:arguments];
            arguments = fullArguments;
            selectorName = @"FUNCTION";
            break;
        }
        return [NSString stringWithFormat:@"FUNCTION(%@, \"%@\")", operand, selectorName];
    } while (NO);

    NSMutableString *desc = [selectorName mutableCopy];
    [desc appendString:@"("];
    BOOL comma = NO;
    for (NSExpression *exp in arguments)
    {
        if (comma)
        {
            [desc appendString:@", "];
        }
        [desc appendString:[exp predicateFormat]];
        comma = YES;
    }
    [desc appendString:@")"];
    return [desc autorelease];
}

- (BOOL)_shouldUseParensWithDescription
{
    NSString *op = [self binaryOperatorForSelector];
    if (op == nil)
    {
        return NO;
    }
    if ([op isEqualToString:@"["])
    {
        return YES;
    }
    return NO;
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    id retVal = nil;
    NSArray *args = [self arguments];
    SEL cmd = [self selector];
    NSUInteger count = [args count];
    NSExpression *target = [[self operand] expressionValueWithObject:object context:context];

    id *argValues = malloc(sizeof(id) * count);
    if (argValues == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }
    NSUInteger idx = 0;
    for (NSExpression *arg in args)
    {
        argValues[idx] = [arg expressionValueWithObject:object context:context];
        idx++;
    }

    NSMethodSignature *sig = [target methodSignatureForSelector:cmd];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:target];
    [inv setSelector:cmd];

    for (idx = 0; idx < count; idx++)
    {
        [inv setArgument:&argValues[idx] atIndex:idx + 2];
    }

    [inv invoke];
    [inv getReturnValue:&retVal];

    free(argValues);

    return retVal;
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitExpressions) == 0)
    {
        return;
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }

    [[self operand] acceptVisitor:visitor flags:flags];

    for (NSExpression *arg in _arguments)
    {
        [arg acceptVisitor:visitor flags:flags];
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

@end
