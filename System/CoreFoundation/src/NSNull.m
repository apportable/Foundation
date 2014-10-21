//
//  NSNull.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSNull.h>
#import "NSCFType.h"
#import "NSObjectInternal.h"

@implementation NSNull

+ (BOOL)supportsSecureCoding
{
    return NO;
}

+ (id)null
{
    return (id)kCFNull;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return (id)kCFNull;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    
}

- (id)initWithCoder:(NSCoder *)coder
{
    return (id)kCFNull;
}

- (id)description
{
    return @"<null>";
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)kCFNull;
}

SINGLETON_RR()

- (CFTypeID)_cfTypeID
{
    return CFNullGetTypeID();
}

@end
