//
//  NSMutableStringProxyForMutableAttributedString.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSMutableStringProxyForMutableAttributedStringInternal.h"

@implementation NSMutableStringProxyForMutableAttributedString
{
    NSMutableAttributedString *_owner;
}

- (id)initWithMutableAttributedString:(NSMutableAttributedString *)owner
{
    self = [super init];

    if (self)
    {
        _owner = [owner retain];
    }

    return self;
}

- (NSUInteger)length
{
    return [_owner length];
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    return [[_owner string] characterAtIndex:index];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange
{
    [[_owner string] getCharacters:buffer range:aRange];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [_owner replaceCharactersInRange:range withString:str];
}

- (void)dealloc
{
    [_owner release];
    [super dealloc];
}

@end
