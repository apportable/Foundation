//
//  NSConstantString.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSStringInternal.h"

#import <objc/runtime.h>

@implementation __NSCFConstantString

SINGLETON_RR()

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (BOOL)isKindOfClass:(Class)cls
{
    return cls == objc_lookUpClass("NSString");
}

@end
