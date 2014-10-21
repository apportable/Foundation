//
//  NSMatchingPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSMatchingPredicateOperator.h"

#import "_NSPredicateOperatorUtilities.h"

#import <libkern/OSAtomic.h>
#import <stdlib.h>

@implementation NSMatchingPredicateOperator
{
    OSSpinLock _contextLock;
    struct regexContext *_regexContext;
}

- (void)dealloc
{
    if (_regexContext != NULL)
    {
        [self _clearContext];
        free(_regexContext);
    }
    [super dealloc];
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSUInteger)variant
{
    self = [super initWithOperatorType:type modifier:modifier variant:variant];
    if (self != nil)
    {
        _regexContext = NULL;
    }
    return self;
}

- (BOOL)performPrimitiveOperationUsingObject:(id)string andObject:(id)pattern
{
    if (string == nil || pattern == nil)
    {
        return NO;
    }

    if (![string isNSString__])
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot match with non-string %@", string];
        return NO;
    }

    if (![pattern isNSString__])
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot match with non-string %@", pattern];
        return NO;
    }

    if ([pattern isEqual:@""])
    {
        return NO;
    }

    BOOL result = NO;

    @try {
        OSSpinLockLock(&_contextLock);

        if (_regexContext == NULL)
        {
            _regexContext = calloc(sizeof(*_regexContext), 1);
        }
        else if (_regexContext->_field1 != nil && ![_regexContext->_field1 isEqualToString:pattern])
        {
            [self _clearContext];
        }

        NSComparisonPredicateOptions flags = [self flags];
        BOOL escapeForLike = [self _shouldEscapeForLike];

        result = [_NSPredicateOperatorUtilities doRegexForString:string pattern:pattern likeProtect:escapeForLike flags:flags context:_regexContext];
    }
    @catch (id e) {
        [self _clearContext];
        @throw;
    }
    @finally {
        OSSpinLockUnlock(&_contextLock);
        return result;
    }
}

- (BOOL)_shouldEscapeForLike
{
    return NO;
}

- (SEL)selector
{
    return sel_registerName("matches:");
}

- (NSString *)symbol
{
    return [@"MATCHES" stringByAppendingString:[self _modifierString]];
}

- (void)_clearContext
{
    if (_regexContext->_field2 != NULL)
    {
        uregex_close(_regexContext->_field2);
        _regexContext->_field2 = NULL;
    }
    if (_regexContext->_field1 != nil)
    {
        CFRelease(_regexContext->_field1);
        _regexContext->_field1 = nil;
    }
}

@end
