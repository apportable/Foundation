//
//  NSCFType.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCFType.h"
#import "CFRuntime.h"
#import "ForFoundationOnly.h"

@implementation NSObject (NSCFType)

- (NSString *)_copyDescription
{
    return [(id)[self description] copy];
}

- (CFTypeID)_cfTypeID
{
    return CFTypeGetTypeID();
}

@end

@implementation __NSCFType

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (id)retain
{
    return (id)CFRetain((CFTypeRef)self);
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (NSString *)description
{
    return [(id)CFCopyDescription((CFTypeRef)self) autorelease];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [self description];
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

@end
