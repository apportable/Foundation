//
//  NSUUID.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSUUID.h>

#import <Foundation/NSCoder.h>
#import <dispatch/dispatch.h>
#import "NSObjectInternal.h"

static NSString * const NSUUIDBytesKey = @"NS.uuidbytes";

CF_PRIVATE
@interface __NSConcreteUUID : NSUUID
@end

@implementation NSUUID

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSUUID class])
    {
        static dispatch_once_t once = 0L;
        static __NSConcreteUUID *placeholder = nil;
        dispatch_once(&once, ^{
            placeholder = [__NSConcreteUUID allocWithZone:zone];
        });
        return placeholder;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

+ (id)UUID
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    return [super init];
}

- (id)initWithUUIDString:(NSString *)string
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUUIDBytes:(const uuid_t)bytes
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (void)getUUIDBytes:(uuid_t)uuid
{
    bzero(uuid, sizeof(uuid_t));
}

- (NSString *)UUIDString
{
    return @"";
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    uuid_t uuid;
    [self getUUIDBytes:uuid];
    return [[NSUUID alloc] initWithUUIDBytes:uuid];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (![aDecoder allowsKeyedCoding])
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"UUIDs can only be decoded by keyed coders"];
        return nil;
    }

    NSUInteger decodedLength;
    const char *uuidBytes = [aDecoder decodeBytesForKey:NSUUIDBytesKey returnedLength:&decodedLength];
    if (decodedLength == sizeof(uuid_t))
    {
        return [self initWithUUIDBytes:uuidBytes];
    }
    else
    {
        return [self init];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (![aCoder allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"UUIDs can only be encoded by keyed coders"];
        return;
    }

    uuid_t uuid;
    [self getUUIDBytes:uuid];
    [aCoder encodeBytes:uuid length:sizeof(uuid) forKey:NSUUIDBytesKey];
}

- (CFStringRef)_cfUUIDString
{
    return (CFStringRef)[[self UUIDString] retain];
}

- (CFTypeID)_cfTypeID
{
    return CFUUIDGetTypeID();
}

@end

@implementation __NSConcreteUUID

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (Class)classForCoder
{
    return [NSUUID class];
}

- (id)description
{
    return [NSString stringWithFormat:@"<%s %p> %@", object_getClassName(self), self, [self UUIDString]];
}

- (CFUUIDBytes)_cfUUIDBytes
{
    return CFUUIDGetUUIDBytes((CFUUIDRef)self);
}

- (void)getUUIDBytes:(uuid_t)bytes
{
    CFUUIDBytes uuid = [self _cfUUIDBytes];
    memcpy(bytes, &uuid, sizeof(uuid_t));
}

- (NSString *)UUIDString
{
    CFStringRef uuidString = CFUUIDCreateString(NULL, (CFUUIDRef)self);
    return [(NSString *)uuidString autorelease];
}

- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:objc_lookUpClass("NSUUID")])
    {
        return NO;
    }
    uuid_t u1;
    uuid_t u2;
    [self getUUIDBytes:u1];
    [other getUUIDBytes:u2];
    return uuid_compare(u1, u2) == 0;
}

- (id)initWithUUIDBytes:(const uuid_t)bytes
{
    return (id)CFUUIDCreateWithBytes(kCFAllocatorDefault,
                                      bytes[0],  bytes[1],  bytes[2],  bytes[3],
                                      bytes[4],  bytes[5],  bytes[6],  bytes[7],
                                      bytes[8],  bytes[9], bytes[10], bytes[11],
                                     bytes[12], bytes[13], bytes[14], bytes[15]);
}

- (id)initWithUUIDString:(NSString *)string
{
    return (id)CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)string);
}

- (id)init
{
    return (id)CFUUIDCreate(kCFAllocatorDefault);
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating((CFTypeRef)self);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain((CFTypeRef)self) != NULL;
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)retain
{
    return (id)CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

@end
