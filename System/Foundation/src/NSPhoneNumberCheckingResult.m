//
//  NSPhoneNumberCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPhoneNumberCheckingResult.h"
#import <Foundation/NSString.h>

@implementation NSPhoneNumberCheckingResult

- (id)initWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber
{
    return [self initWithRange:range phoneNumber:phoneNumber underlyingResult:nil];
}

- (id)initWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber underlyingResult:(void *)underlyingResult
{
    self = [super init];
    if (self)
    {
        _range = range;
        _phoneNumber = [phoneNumber copy];
        _underlyingResult = underlyingResult;
    }
    return self;
}

- (void)dealloc
{
    [_phoneNumber release];
    [super dealloc];
}

- (NSString *)phoneNumber
{
    return _phoneNumber;
}

- (NSRange)range
{
    return _range;
}

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypePhoneNumber;
}

/*
- (NSString *)description
{

}
*/

@end
