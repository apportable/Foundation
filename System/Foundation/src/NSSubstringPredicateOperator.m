//
//  NSSubstringPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSSubstringPredicateOperator.h"

#import "_NSPredicateOperatorUtilities.h"

#import <Foundation/NSLocale.h>

@implementation NSSubstringPredicateOperator
{
    NSSubstringPredicateOperatorPosition _position;
}

static NSString * const NSPositionKey = @"NSPosition";

static NSString * const NSSubstringBeginsWithSymbol = @"BEGINSWITH";
static NSString * const NSSubstringEndsWithSymbol = @"ENDSWITH";
static NSString * const NSSubstringContainsSymbol = @"CONTAINS";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSUInteger)variant position:(NSSubstringPredicateOperatorPosition)position
{
    self = [super initWithOperatorType:type modifier:modifier variant:variant];
    if (self != nil)
    {
        _position = position;
    }
    return self;
}

- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs
{
    if (lhs == nil || rhs == nil)
    {
        return NO;
    }

    if (![lhs isNSString__] || ![lhs isNSString__])
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot perform substring check on non-strings %@ and %@", lhs, rhs];
        return NO;
    }

    NSComparisonPredicateOptions flags = [self flags];

    NSLocale *locale = nil;
    NSStringCompareOptions options = 0;
    if (flags == NSNormalizedPredicateOption)
    {
        options = NSLiteralSearch;
    }
    else
    {
        if ((flags & NSCaseInsensitivePredicateOption) != 0)
        {
            options |= NSCaseInsensitiveSearch;
        }
        if ((flags & NSDiacriticInsensitivePredicateOption) != 0)
        {
            options |= NSDiacriticInsensitiveSearch;
        }
        if ((flags & NSLocaleSensitivePredicateOption) != 0)
        {
            locale = [(NSLocale *)[_NSPredicateOperatorUtilities retainedLocale] autorelease];
        }
    }

    NSRange range = NSMakeRange(0, [lhs length]);

    switch (_position)
    {
        case NSSubstringBeginsWith:
            options |= NSAnchoredSearch;
            break;
        case NSSubstringEndsWith:
            options |= NSAnchoredSearch;
            options |= NSBackwardsSearch;
            break;
        case NSSubstringContains:
            break;
    }

    NSRange foundRange = [lhs rangeOfString:rhs options:options range:range locale:locale];
    return foundRange.location != NSNotFound;
}

- (NSString *)symbol
{
    switch (_position)
    {
        case NSSubstringBeginsWith:
            return NSSubstringBeginsWithSymbol;
        case NSSubstringEndsWith:
            return NSSubstringEndsWithSymbol;
        case NSSubstringContains:
            return NSSubstringContainsSymbol;
    }
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSSubstringPredicateOperator self]])
    {
        return NO;
    }
    if ([self operatorType] != [other operatorType])
    {
        return NO;
    }
    if ([self flags] != [other flags])
    {
        return NO;
    }
    if ([self modifier] != [other modifier])
    {
        return NO;
    }
    if ([self position] != [other position])
    {
        return NO;
    }
    return YES;
}

- (NSSubstringPredicateOperatorPosition)position
{
    return _position;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    self = [super initWithCoder:decoder];
    if (self != nil)
    {
        _position = [decoder decodeIntegerForKey:NSPositionKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];

    [coder encodeInteger:_position forKey:NSPositionKey];
}

- (SEL)selector
{
    return @selector(rangeOfString:options:);
}

@end
