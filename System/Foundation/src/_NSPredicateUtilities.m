//
//  _NSPredicateUtilities.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "_NSPredicateUtilities.h"

#import "NSBetweenPredicateOperator.h"
#import "NSComparisonPredicateOperator.h"
#import "NSCompoundPredicateOperator.h"
#import "NSCustomPredicateOperator.h"
#import "NSEqualityPredicateOperator.h"
#import "NSExpressionInternal.h"
#import "NSInPredicateOperator.h"
#import "NSLikePredicateOperator.h"
#import "NSMatchingPredicateOperator.h"
#import "NSObjectInternal.h"
#import "NSStringInternal.h"
#import "NSStringPredicateOperator.h"
#import "NSSubstringPredicateOperator.h"
#import "_NSPredicateOperatorUtilities.h"

#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSComparisonPredicate.h>
#import <Foundation/NSCompoundPredicate.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSException.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSOrderedSet.h>
#import <Foundation/NSSet.h>

#import <CoreFoundation/CFStringTokenizer.h>

#import <dispatch/dispatch.h>
#import <limits.h>
#import <math.h>
#import <stdlib.h>
#import <xlocale.h>

static inline BOOL NSPredicateTestNumber(NSNumber *n1)
{
    if (![n1 isNSNumber__])
    {
        [NSException raise:NSInvalidArgumentException format:@"argument must be numbers"];
        return NO;
    }
    return YES;
}

static inline BOOL NSPredicateTestNumbers(NSNumber *n1, NSNumber *n2)
{
    return NSPredicateTestNumber(n1) && NSPredicateTestNumber(n2);
}

static inline BOOL NSPredicateTestString(NSString *str)
{
    if (![str isNSString__])
    {
        [NSException raise:NSInvalidArgumentException format:@"argument must be string"];
        return NO;
    }
    return YES;
}

@implementation _NSPredicateUtilities

+ (NSSet *)_constantValueClassesForSecureCoding
{
    static NSSet *classes;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        classes = [[NSSet alloc] initWithObjects:
                      [NSArray self],
                      NSClassFromString(@"NSCalendarDate"),
                      [NSData self],
                      [NSDate self],
                      [NSDecimalNumber self],
                      [NSDictionary self],
                      [NSNull self],
                      [NSNumber self],
                      [NSOrderedSet self],
                      [NSSet self],
                      [NSString self],
                      nil];
    });
    return classes;
}

+ (NSSet *)_operatorClassesForSecureCoding
{
    static NSSet *classes;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        classes = [[NSSet alloc] initWithObjects:
                      [NSBetweenPredicateOperator self],
                      [NSComparisonPredicateOperator self],
                      [NSCompoundPredicateOperator self],
                      [NSCustomPredicateOperator self],
                      [NSEqualityPredicateOperator self],
                      [NSInPredicateOperator self],
                      [NSLikePredicateOperator self],
                      [NSMatchingPredicateOperator self],
                      [NSStringPredicateOperator self],
                      [NSSubstringPredicateOperator self],
                      nil];
    });
    return classes;
}

+ (NSSet *)_extendedExpressionClassesForSecureCoding
{
    static NSSet *classes;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        classes = [[NSSet alloc] initWithObjects:
                      [NSArray self],

                      [NSAggregateExpression self],
                      [NSAnyKeyExpression self],
                      [NSConstantValueExpression self],
                      [NSFunctionExpression self],
                      [NSKeyPathExpression self],
                      [NSKeyPathSpecifierExpression self],
                      [NSSelfExpression self],
                      [NSSetExpression self],
                      [NSSubqueryExpression self],
                      [NSSymbolicExpression self],
                      [NSTernaryExpression self],
                      [NSVariableAssignmentExpression self],
                      [NSVariableExpression self],
                      nil];
    });
    return classes;
}

+ (NSSet *)_expressionClassesForSecureCoding
{
    static NSSet *classes;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        classes = [[NSSet alloc] initWithObjects:
                      [NSAggregateExpression self],
                      [NSAnyKeyExpression self],
                      [NSConstantValueExpression self],
                      [NSFunctionExpression self],
                      [NSKeyPathExpression self],
                      [NSKeyPathSpecifierExpression self],
                      [NSSelfExpression self],
                      [NSSetExpression self],
                      [NSSubqueryExpression self],
                      [NSSymbolicExpression self],
                      [NSTernaryExpression self],
                      [NSVariableAssignmentExpression self],
                      [NSVariableExpression self],
                      nil];
    });
    return classes;
}

+ (NSSet *)_compoundPredicateClassesForSecureCoding
{
    static NSSet *classes;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        classes = [[NSSet alloc] initWithObjects:
                      [NSArray self],

                      [NSComparisonPredicate self],
                      [NSCompoundPredicate self],
                      [NSFalsePredicate self],
                      [NSTruePredicate self],
                      nil];
    });
    return classes;
}

+ (NSSet *)_predicateClassesForSecureCoding
{
    static NSSet *classes;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        classes = [[NSSet alloc] initWithObjects:
                      [NSComparisonPredicate self],
                      [NSCompoundPredicate self],
                      [NSFalsePredicate self],
                      [NSTruePredicate self],
                      nil];
    });
    return classes;
}

+ (NSString *)_parserableCollectionDescription:(id)collection
{
    if (collection == nil)
    {
        return @"";
    }

    if ([collection isNSString__])
    {
        return [self _parserableStringDescription:collection];
    }

    id objects;
    BOOL isDict;
    if ([collection isNSDictionary__])
    {
        objects = [collection allKeys];
        isDict = YES;
    }
    else if ([collection isNSArray__] || [collection isNSSet__])
    {
        objects = collection;
        isDict = NO;
    }
    else
    {
        return [collection description];
    }

    NSMutableString *desc = [NSMutableString stringWithString:@"{"];

    BOOL comma = NO;
    for (id obj in objects)
    {
        if (comma)
        {
            [desc appendString:@", "];
        }

        [desc appendString:[_NSPredicateUtilities _parserableCollectionDescription:obj]];

        if (isDict)
        {
            [desc appendString:@"="];
            [desc appendString:[_NSPredicateUtilities _parserableCollectionDescription:[collection objectForKey:obj]]];
        }

        comma = YES;
    }

    [desc appendString:@"}"];

    return desc;
}

+ (NSString *)_parserableDateDescription:(NSDate *)date
{
    return [NSString stringWithFormat:@"CAST(%f, \"NSDate\")", [date timeIntervalSinceReferenceDate]];
}

+ (NSString *)_parserableStringDescription:(NSString *)string
{
    NSMutableString *escapedString = [string mutableCopy];

    [escapedString replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];
    [escapedString replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSLiteralSearch range:NSMakeRange(0, [escapedString length])];

    return [NSString stringWithFormat:@"\"%@\"", escapedString];
}

+ (BOOL)_isReservedWordInParser:(NSString *)word
{
    static NSSet *reservedWords;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        reservedWords = [[NSSet alloc] initWithObjects: @"all", @"and", @"any", @"anykey", @"apply", @"beginswith", @"between",
                               @"cast", @"contains", @"endswith", @"false", @"falsepredicate", @"first", @"function",
                               @"in", @"intersection", @"last", @"like", @"matches", @"minus", @"nil", @"no", @"none",
                               @"not", @"null", @"or", @"self", @"size", @"some", @"subquery", @"tokenmatches", @"true",
                               @"truepredicate", @"union", @"yes", nil];
    });

    return [reservedWords containsObject:[word lowercaseString]];
}

+ (id)inverseOrderKey:(id)arg
{
    [NSException raise:NSInternalInconsistencyException format:@"Internal, why are you calling this?"];
    return nil;
}

+ (id)distinct:(id)arg
{
    [NSException raise:NSInternalInconsistencyException format:@"Reserved for CoreData"];
    return nil;
}

+ (id)noindex:(id)object
{
    return object;
}

+ (NSNumber *)onesComplement:(NSNumber *)n
{
    if (!NSPredicateTestNumber(n))
    {
        return nil;
    }

    return [NSNumber numberWithInteger:~[n integerValue]];
}

+ (NSNumber *)rightshift:(NSNumber *)n1 by:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }

    return [NSNumber numberWithInteger:[n1 integerValue] >> [n2 integerValue]];
}

+ (NSNumber *)leftshift:(NSNumber *)n1 by:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }

    return [NSNumber numberWithInteger:[n1 integerValue] << [n2 integerValue]];
}

+ (NSNumber *)bitwiseXor:(NSNumber *)n1 with:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }

    return [NSNumber numberWithInteger:[n1 integerValue] ^ [n2 integerValue]];
}

+ (NSNumber *)bitwiseOr:(NSNumber *)n1 with:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }

    return [NSNumber numberWithInteger:[n1 integerValue] | [n2 integerValue]];
}

+ (NSNumber *)bitwiseAnd:(NSNumber *)n1 with:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }

    return [NSNumber numberWithInteger:[n1 integerValue] & [n2 integerValue]];
}

+ (id)distanceToLocation:(id)loc1 fromLocation:(id)loc2
{
    Class CLLocation = NSClassFromString(@"CLLocation");
    if (CLLocation == nil)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Missing linkage for CoreLocation"];
        return nil;
    }
    double dist = [loc1 distanceFromLocation:loc2];
    return [NSNumber numberWithDouble:dist];
}

+ (NSDate *)now
{
    return [NSDate date];
}

+ (id)objectFrom:(id)container withIndex:(id)index
{
    if ([container isNSArray__] || [container isNSOrderedSet__])
    {
        if ([index isNSNumber__])
        {
            NSUInteger idx = [index integerValue];
            return [container objectAtIndex:idx];
        }
        else
        {
            if (![index isKindOfClass:[NSSymbolicExpression class]])
            {
                [NSException raise:NSInternalInconsistencyException format:@"index is inappropriate for container/orderedset"];
                return nil;
            }
            NSString *indexVal = [(NSSymbolicExpression *)index constantValue];
            if ([NSSymbolicFirstElement caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [container firstObject];
            }
            else if ([NSSymbolicLastElement caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [container lastObject];
            }
            else if ([NSSymbolicSizeAccessor caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [NSNumber numberWithLong:[container count]];
            }
            else
            {
                [NSException raise:NSInternalInconsistencyException format:@"index is inappropriate for container/orderedset"];
                return nil;
            }
        }
    }
    else if ([container isNSSet__])
    {
        if ([index isKindOfClass:[NSSymbolicExpression class]])
        {
            NSString *indexVal = [(NSSymbolicExpression *)index constantValue];
            if ([NSSymbolicFirstElement caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [container anyObject];
            }
            else if ([NSSymbolicLastElement caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [container anyObject];
            }
            else if ([NSSymbolicSizeAccessor caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [NSNumber numberWithLong:[container count]];
            }
            else
            {
                [NSException raise:NSInternalInconsistencyException format:@"index is inappropriate for container/orderedset"];
                return nil;
            }
        }
        else
        {
            return [container member:index];
        }
    }
    else if ([container isNSDictionary__])
    {
        if ([index isKindOfClass:[NSSymbolicExpression class]])
        {
            NSString *indexVal = [(NSSymbolicExpression *)index constantValue];
            NSArray *keys = [container allKeys];
            if ([NSSymbolicFirstElement caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [container objectForKey:[keys firstObject]];
            }
            else if ([NSSymbolicLastElement caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [container objectForKey:[keys lastObject]];
            }
            else if ([NSSymbolicSizeAccessor caseInsensitiveCompare:indexVal] == NSOrderedSame)
            {
                return [NSNumber numberWithLong:[container count]];
            }
            else
            {
                [NSException raise:NSInternalInconsistencyException format:@"index is inappropriate for container/orderedset"];
                return nil;
            }
        }
        else
        {
            return [container objectForKey:index];
        }
    }

    [NSException raise:NSInvalidArgumentException format:@"cant access index %@ on %@", index, container];
    return nil;
}

+ (NSNumber *)randomn:(NSNumber *)n
{
    if (!NSPredicateTestNumber(n))
    {
        return nil;
    }

    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        srandom(time(NULL));
    });
    return [NSNumber numberWithLong:[n longValue] * random()];
}

+ (NSNumber *)random
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        srandom(time(NULL));
    });
    return [NSNumber numberWithDouble:random()];
}

+ (id)castObject:(id)object toType:(NSString *)typeName
{
    if (typeName == nil)
    {
        return object;
    }

    if ([typeName isEqual:@"Class"])
    {
        return NSClassFromString(object);
    }

    Class cls = NSClassFromString(typeName);
    if (cls == Nil)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot cast object %@ to invalid class %@", object, typeName];
        return nil;
    }

    if ([cls isSubclassOfClass:[NSString self]])
    {
        return [object description];
    }
    else if ([cls isSubclassOfClass:[NSDate self]])
    {
        if ([object isNSNumber__])
        {
            return [NSDate dateWithTimeIntervalSinceReferenceDate:[object doubleValue]];
        }
    }
    else if ([cls isSubclassOfClass:[NSDecimalNumber self]])
    {
        NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:[object description]];
        if (decimalNumber != [NSDecimalNumber notANumber])
        {
            return decimalNumber;
        }
    }
    else if ([cls isSubclassOfClass:[NSNumber self]])
    {
        if ([object isNSDate__])
        {
            return [NSNumber numberWithDouble:[object timeIntervalSinceReferenceDate]];
        }
        else if ([object isNSString__])
        {
            return [_NSPredicateUtilities _convertStringToNumber:object];
        }
    }
    else if (class_respondsToSelector(cls, @selector(initWithString:)))
    {
        return [[[cls alloc] initWithString:[object description]] autorelease];
    }

    [NSException raise:NSInternalInconsistencyException format:@"Do not know how to cast object %@ to class %@", object, cls];
    return nil;
}

+ (id)_convertStringToNumber:(NSString *)str
{
    const char *numStr = [str UTF8String];
    if (strchr(numStr, '.') != NULL)
    {
        NSDecimalNumber *dec = [NSDecimalNumber decimalNumberWithString:str];
        if ([dec isEqual:[NSDecimalNumber notANumber]])
        {
            return nil;
        }
        return dec;
    }
    else
    {
        long long ll = strtoll_l(numStr, NULL, 10, NULL);
        return [NSNumber numberWithLongLong:ll];
    }
}

+ (NSString *)lowercase:(NSString *)str
{
    if (!NSPredicateTestString(str))
    {
        return nil;
    }
    return [str lowercaseString];
}

+ (NSString *)uppercase:(NSString *)str
{
    if (!NSPredicateTestString(str))
    {
        return nil;
    }
    return [str uppercaseString];
}

+ (id)tokenize:(id)arg1 using:(id)arg2
{
#warning TODO predicates
    DEBUG_BREAK();
    return nil;
}

+ (NSSet *)_collapseAndTokenize:(id)collection flags:(CFStringCompareFlags)flags locale:(CFLocaleRef)locale
{
    NSMutableSet *tokens = [NSMutableSet set];

    for (id string in collection)
    {
        if (![string isNSString__])
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot tokenize non-string %@", string];
            return nil;
        }
        [tokens unionSet:[_NSPredicateUtilities _processAndTokenize:string flags:flags locale:locale]];
    }

    return tokens;
}

+ (NSSet *)_processAndTokenize:(NSString *)string flags:(CFStringCompareFlags)flags locale:(CFLocaleRef)locale
{
    if (flags != 0)
    {
        string = [[_NSPredicateOperatorUtilities newStringFrom:string usingUnicodeTransforms:flags] autorelease];
    }

    return [_NSPredicateUtilities _doTokenization:string locale:locale];
}

+ (NSSet *)_doTokenization:(NSString *)string locale:(CFLocaleRef)locale
{
    CFOptionFlags options = locale == NULL ? kCFStringTokenizerTokenHasDerivedSubTokensMask : kCFStringTokenizerTokenNone;
    CFRange range = CFRangeMake(0, [string length]);
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef)string, range, options, locale);

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSMutableSet *tokens = [NSMutableSet set];

    CFStringTokenizerAdvanceToNextToken(tokenizer);
    while (YES)
    {
        CFRange cfTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        if (cfTokenRange.location == kCFNotFound)
        {
            break;
        }
        NSRange tokenRange = NSMakeRange(cfTokenRange.location, cfTokenRange.length);
        NSString *token = [string substringWithRange:tokenRange];
        if (![whitespace characterIsMember:[token characterAtIndex:0]])
        {
            [tokens addObject:token];
        }
        CFStringTokenizerAdvanceToNextToken(tokenizer);
    }

    CFRelease(tokenizer);

    return tokens;
}

+ (NSNumber *)abs:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double absValue = fabs(doubleValue);
    return [NSNumber numberWithDouble:absValue];
}

+ (id)ceiling:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double ceilValue = ceil(doubleValue);
    return [NSNumber numberWithDouble:ceilValue];
}

+ (id)trunc:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double truncValue = trunc(doubleValue);
    return [NSNumber numberWithDouble:truncValue];
}

+ (NSNumber *)floor:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double floorValue = floor(doubleValue);
    return [NSNumber numberWithDouble:floorValue];
}


+ (NSNumber *)exp:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double expValue = exp(doubleValue);
    return [NSNumber numberWithDouble:expValue];
}

+ (NSNumber *)raise:(NSNumber *)base toPower:(NSNumber *)power
{
    if (!NSPredicateTestNumbers(base, power))
    {
        return nil;
    }

    double baseValue = [base doubleValue];
    double powerValue = [power doubleValue];
    double resultValue = pow(baseValue, powerValue);
    return [NSNumber numberWithDouble:resultValue];
}

+ (NSNumber *)ln:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double lnValue = log(doubleValue);
    return [NSNumber numberWithDouble:lnValue];
}

+ (NSNumber *)log:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double logValue = log10(doubleValue);
    return [NSNumber numberWithDouble:logValue];
}

+ (NSNumber *)sqrt:(NSNumber *)number
{
    if (!NSPredicateTestNumber(number))
    {
        return nil;
    }

    double doubleValue = [number doubleValue];
    double sqrtValue = sqrt(doubleValue);
    return [NSNumber numberWithDouble:sqrtValue];
}

+ (NSNumber *)modulus:(NSNumber *)n1 by:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }
    return [NSNumber numberWithInteger:[n1 integerValue] % [n2 integerValue]];
}

+ (NSNumber *)divide:(NSNumber *)n1 by:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }
    NSPredicateMathType type = MIN([self _getITypeFor:[n1 objCType]], [self _getITypeFor:[n2 objCType]]);
    // verify that this isnt just always double (or a compare is made to force to double based math)
    switch (type)
    {
        case NSPredicateIntegerMathType:
            return [NSNumber numberWithInteger:[n1 integerValue] / [n2 integerValue]];
        case NSPredicateLongLongMathType:
            return [NSNumber numberWithLongLong:[n1 longLongValue] / [n2 longLongValue]];
        case NSPredicateDoubleMathType:
            return [NSNumber numberWithDouble:[n1 doubleValue] / [n2 doubleValue]];
        default:
            return nil; // technically unreachable
    }

}

+ (NSNumber *)multiply:(NSNumber *)n1 by:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }
    NSPredicateMathType type = MIN([self _getITypeFor:[n1 objCType]], [self _getITypeFor:[n2 objCType]]);
    switch (type)
    {
        case NSPredicateIntegerMathType:
            return [NSNumber numberWithInteger:[n1 integerValue] * [n2 integerValue]];
        case NSPredicateLongLongMathType:
            return [NSNumber numberWithLongLong:[n1 longLongValue] * [n2 longLongValue]];
        case NSPredicateDoubleMathType:
            return [NSNumber numberWithDouble:[n1 doubleValue] * [n2 doubleValue]];
        default:
            return nil; // technically unreachable
    }
}

+ (NSNumber *)from:(NSNumber *)n1 subtract:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }
    NSPredicateMathType type = MIN([self _getITypeFor:[n1 objCType]], [self _getITypeFor:[n2 objCType]]);
    switch (type)
    {
        case NSPredicateIntegerMathType:
            return [NSNumber numberWithInteger:[n1 integerValue] - [n2 integerValue]];
        case NSPredicateLongLongMathType:
            return [NSNumber numberWithLongLong:[n1 longLongValue] - [n2 longLongValue]];
        case NSPredicateDoubleMathType:
            return [NSNumber numberWithDouble:[n1 doubleValue] - [n2 doubleValue]];
        default:
            return nil; // technically unreachable
    }
}

+ (NSNumber *)add:(NSNumber *)n1 to:(NSNumber *)n2
{
    if (!NSPredicateTestNumbers(n1, n2))
    {
        return nil;
    }
    NSPredicateMathType type = MIN([self _getITypeFor:[n1 objCType]], [self _getITypeFor:[n2 objCType]]);
    switch (type)
    {
        case NSPredicateIntegerMathType:
            return [NSNumber numberWithInteger:[n1 integerValue] + [n2 integerValue]];
        case NSPredicateLongLongMathType:
            return [NSNumber numberWithLongLong:[n1 longLongValue] + [n2 longLongValue]];
        case NSPredicateDoubleMathType:
            return [NSNumber numberWithDouble:[n1 doubleValue] + [n2 doubleValue]];
        default:
            return nil; // technically unreachable
    }
}

+ (id)stddev:(NSArray *)values
{
    double avg = [[self average:values] doubleValue];
    double sum = 0.0;
    for (NSNumber *value in values)
    {
        double variance = [value doubleValue] - avg;
        sum += (variance * variance);
    }
    return [NSNumber numberWithDouble:sqrt(sum / [values count])];
}

+ (id)mode:(id)values
{
    __block NSNumber *mode = nil;
    __block NSUInteger max = 0;
    CFDictionaryValueCallBacks valueCallBacks = {
        .version = 0,
    };
    NSUInteger total = [values count];
    CFMutableDictionaryRef mapping = CFDictionaryCreateMutable(kCFAllocatorDefault, total, &kCFTypeDictionaryKeyCallBacks, &valueCallBacks);
    [values enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL *stop) {
        NSUInteger count = (NSUInteger)CFDictionaryGetValue(mapping, n);
        count++;
        CFDictionarySetValue(mapping, n, (const void *)count);
        if (count > max)
        {
            mode = n;
            max = count;
        }

        if (count > total - (idx + 1)) // no other value can surpass this one
        {
            *stop = YES;
        }
    }];
    CFRelease(mapping);

    return [NSArray arrayWithObject:mode];
}

+ (id)median:(id)values
{
    NSPredicateMathType type = [self _getCommonTypeFor:values];
    NSArray *sorted = [values sortedArrayUsingComparator:^(NSNumber *n1, NSNumber *n2){
        switch (type)
        {
            case NSPredicateIntegerMathType: {
                NSInteger i1 = [n1 integerValue];
                NSInteger i2 = [n2 integerValue];
                if (i1 > i2)
                {
                    return NSOrderedDescending;
                }
                else if (i1 < i2)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedSame;
                }
            }
            case NSPredicateLongLongMathType: {
                NSInteger ll1 = [n1 longLongValue];
                NSInteger ll2 = [n2 longLongValue];
                if (ll1 > ll2)
                {
                    return NSOrderedDescending;
                }
                else if (ll1 < ll2)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedSame;
                }
            }
            case NSPredicateDoubleMathType: {
                NSInteger d1 = [n1 doubleValue];
                NSInteger d2 = [n2 doubleValue];
                if (d1 > d2)
                {
                    return NSOrderedDescending;
                }
                else if (d1 < d2)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedSame;
                }
            }
            default: {
                return NSOrderedSame; // unreachable
            }
        }
    }];
    NSUInteger count = [sorted count];
    if (count % 2 == 0)
    {
        NSUInteger idx1 = (count / 2);
        NSUInteger idx2 = (count / 2) + 1;
        NSNumber *n1 = [sorted objectAtIndex:idx1];
        NSNumber *n2 = [sorted objectAtIndex:idx2];
        return [NSNumber numberWithDouble:([n1 doubleValue] + [n2 doubleValue]) / 2.0];
    }
    else
    {
        return [sorted objectAtIndex:count / 2];
    }
}

+ (id)average:(NSArray *)values
{
    double sum = [[self sum:values] doubleValue];
    return [NSNumber numberWithDouble:sum / [values count]];
}

+ (id)max:(id)values
{
    NSUInteger count = [values count];
    if (count == 0)
    {
        // why is this the case? very strange behavior to replicate (returning nil should be reasonable imho...)
        [NSException raise:NSInvalidArgumentException format:@"min on zero elements is prohibited"];
        return nil;
    }
    NSPredicateMathType type = [self _getCommonTypeFor:values];
    NSNumber *max = nil;

    for (NSNumber *item in values)
    {
        if (max == nil)
        {
            max = item;
        }
        else
        {
            switch (type)
            {
                case NSPredicateIntegerMathType:
                    if ([max integerValue] < [item integerValue])
                    {
                        max = item;
                    }
                    break;
                case NSPredicateLongLongMathType:
                    if ([max longLongValue] < [item longLongValue])
                    {
                        max = item;
                    }
                    break;
                case NSPredicateDoubleMathType:
                    if ([max doubleValue] < [item doubleValue])
                    {
                        max = item;
                    }
                    break;
                default:
                    return nil; // not reachable
            }

        }
    }
    return max;
}

+ (id)min:(id)values
{
    NSUInteger count = [values count];
    if (count == 0)
    {
        // why is this the case? very strange behavior to replicate (returning nil should be reasonable imho...)
        [NSException raise:NSInvalidArgumentException format:@"min on zero elements is prohibited"];
        return nil;
    }
    NSPredicateMathType type = [self _getCommonTypeFor:values];
    NSNumber *min = nil;

    for (NSNumber *item in values)
    {
        if (min == nil)
        {
            min = item;
        }
        else
        {
            switch (type)
            {
                case NSPredicateIntegerMathType:
                    if ([min integerValue] > [item integerValue])
                    {
                        min = item;
                    }
                    break;
                case NSPredicateLongLongMathType:
                    if ([min longLongValue] > [item longLongValue])
                    {
                        min = item;
                    }
                    break;
                case NSPredicateDoubleMathType:
                    if ([min doubleValue] > [item doubleValue])
                    {
                        min = item;
                    }
                    break;
                default:
                    return nil; // not reachable
            }

        }
    }
    return min;
}

+ (id)count:(NSArray *)values
{
    return [NSNumber numberWithInteger:[values count]];
}

+ (id)sum:(NSArray *)values
{
    double sum = 0.0;
    for (NSNumber *value in values)
    {
        sum += [value doubleValue];
    }
    return [NSNumber numberWithDouble:sum];
}

+ (NSPredicateMathType)_getCommonTypeFor:(id)arg
{
    NSPredicateMathType commonType = NSPredicateIntegerMathType;
    if ([arg isNSArray__] ||
        [arg isNSSet__] ||
        [arg isNSOrderedSet__])
    {
        for (NSNumber *item in arg)
        {
            if ([item isNSNumber__])
            {
                NSPredicateMathType type = [self _getITypeFor:[item objCType]];
                if (type < commonType)
                {
                    commonType = type;
                }
            }
            else
            {
                return NSPredicateInvalidMathType;
            }
        }
    }
    return commonType;
}

+ (NSPredicateMathType)_getITypeFor:(const char *)type
{
    if (strcmp(type, @encode(short)) == 0||
        strcmp(type, @encode(unsigned short)) == 0 ||
        strcmp(type, @encode(int)) == 0 ||
        strcmp(type, @encode(unsigned int)) == 0 ||
        strcmp(type, @encode(long)) == 0 ||
        strcmp(type, @encode(unsigned long)) == 0)
    {
        return NSPredicateIntegerMathType;
    }
    else if (strcmp(type, @encode(long long)) == 0 ||
             strcmp(type, @encode(unsigned long long)) == 0)
    {
        return NSPredicateLongLongMathType;
    }
    else if (strcmp(type, @encode(double)) == 0 ||
             strcmp(type, @encode(float)) == 0)
    {
        return NSPredicateDoubleMathType;
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid type for math functions"];
        return NSPredicateInvalidMathType;
    }
}

@end

@implementation _NSPredicateUtilities (Compiler)

- (double)distanceFromLocation:(id)arg1
{
    return 0.0;
}

@end
