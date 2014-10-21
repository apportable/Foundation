//
//  NSTokenMatchingPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSTokenMatchingPredicateOperator.h"

#import "_NSPredicateOperatorUtilities.h"
#import "_NSPredicateUtilities.h"

@implementation NSTokenMatchingPredicateOperator

- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs
{
    if (lhs == nil || rhs == nil)
    {
        return NO;
    }

    NSComparisonPredicateOptions flags = [self flags];

    if ((flags & NSNormalizedPredicateOption) == NSNormalizedPredicateOption)
    {
        flags = 0;
    }

    CFLocaleRef locale = NULL;
    if ((flags & NSLocaleSensitivePredicateOption) != 0)
    {
        locale = [_NSPredicateOperatorUtilities retainedLocale];
        [(id)locale autorelease];
    }

    NSSet *tokens;
    if ([lhs isNSString__])
    {
        tokens = [_NSPredicateUtilities _processAndTokenize:lhs flags:(CFStringCompareFlags)flags locale:locale];
    }
    else if ([lhs isNSArray__] ||
             [lhs isNSSet__] ||
             [lhs isNSOrderedSet__])
    {
        tokens = [_NSPredicateUtilities _collapseAndTokenize:lhs flags:(CFStringCompareFlags)flags locale:locale];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Could not tokenize object: %@", lhs];
        return NO;
    }

    return [rhs intersectsSet:tokens];
}

- (SEL)selector
{
    return sel_registerName("tokenmatches:");
}

- (NSString *)symbol
{
    return [@"TOKENMATCHES" stringByAppendingString:[self _modifierString]];
}

@end
