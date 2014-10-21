//
//  NSFormatter.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSFormatter.h>
#import <Foundation/NSException.h>
#import "NSObjectInternal.h"

@implementation NSFormatter

- (NSString *)stringForObjectValue:(id)obj
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs
{
    return nil;
}

- (NSString *)editingStringForObjectValue:(id)obj
{
    return [self stringForObjectValue:obj];
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error
{
    NSRequestConcreteImplementation();
    return NO;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString
            errorDescription:(NSString **)error
{
    return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error
{
    NSString *editingString = nil;
    BOOL success = [self isPartialStringValid:*partialStringPtr newEditingString:&editingString errorDescription:error];
    if (success)
    {
        return YES;
    }

    if (editingString != nil && proposedSelRangePtr != NULL)
    {
        proposedSelRangePtr->location = [editingString length];
        proposedSelRangePtr->length = 0;
    }

    return success;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    return;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

@end
