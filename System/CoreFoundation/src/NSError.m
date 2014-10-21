//
//  NSError.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSError.h>

#import <Foundation/NSDictionary.h>
#import "ForFoundationOnly.h"
#import "NSObjectInternal.h"

CF_PRIVATE
@interface __NSCFError : __NSCFType
@end


NSString *const NSCocoaErrorDomain = @"NSCocoaErrorDomain";
NSString *const NSPOSIXErrorDomain = @"NSPOSIXErrorDomain";
NSString *const NSOSStatusErrorDomain = @"NSOSStatusErrorDomain";
NSString *const NSMachErrorDomain = @"NSMachErrorDomain";
NSString *const NSUnderlyingErrorKey = @"NSUnderlyingError";
NSString *const NSLocalizedDescriptionKey = @"NSLocalizedDescription";
NSString *const NSLocalizedFailureReasonErrorKey = @"NSLocalizedFailureReason";
NSString *const NSLocalizedRecoverySuggestionErrorKey = @"NSLocalizedRecoverySuggestion";
NSString *const NSLocalizedRecoveryOptionsErrorKey = @"NSLocalizedRecoveryOptions";
NSString *const NSRecoveryAttempterErrorKey = @"NSRecoveryAttempter";
NSString *const NSHelpAnchorErrorKey = @"NSHelpAnchor";
NSString *const NSStringEncodingErrorKey = @"NSStringEncoding";
NSString *const NSURLErrorKey = @"NSURL";
NSString *const NSFilePathErrorKey = @"NSFilePath";

static NSError *_outOfmemoryError = nil;

@implementation NSError {
// NOTE: This is brittle - the ivar layout MUST be the same as CFErrorRef
    void *_reserved;
    NSUInteger _code;
    NSString *_domain;
    NSDictionary *_userInfo;
}

+ (void)initialize
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        _outOfmemoryError = [[NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Out of memory"}] retain];
    });
}

+ (NSError *)_outOfMemoryError
{
    return _outOfmemoryError;
}

- (CFTypeID)_cfTypeID
{
    return CFErrorGetTypeID();
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    return [[[self alloc] initWithDomain:domain code:code userInfo:dict] autorelease];
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    self = [super init];

    if (self)
    {
        _code = code;
        _domain = [domain copy];
        _userInfo = [dict copy];
    }

    return self;
}

- (NSString *)domain
{
    return _domain;
}

- (NSInteger)code
{
    return _code;
}

- (NSDictionary *)userInfo
{
    return _userInfo;
}

- (NSString *)description
{
    return [(NSString *)_CFErrorCreateDebugDescription((CFErrorRef)self) autorelease];
}

- (NSString *)localizedDescription
{
    NSString *desc = [[self userInfo][NSLocalizedDescriptionKey] copy];

    if (desc == nil)
    {
        desc = (NSString *)_CFErrorCreateLocalizedDescription((CFErrorRef)self);
        if (desc == nil)
        {
            desc = (NSString *)CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Operation could not be completed. %@ %d"), [self domain], [self code]);
        }
    }
    
    return [desc autorelease];
}

- (NSString *)localizedFailureReason
{
    return [self userInfo][NSLocalizedFailureReasonErrorKey];
}

- (NSString *)localizedRecoverySuggestion
{
    return [self userInfo][NSLocalizedRecoverySuggestionErrorKey];
}

- (NSArray *)localizedRecoveryOptions
{
    return [self userInfo][NSLocalizedRecoveryOptionsErrorKey];
}

- (id)recoveryAttempter
{
    return [self userInfo][NSRecoveryAttempterErrorKey];
}

- (NSString *)helpAnchor
{
    return [self userInfo][NSHelpAnchorErrorKey];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSError allocWithZone:zone] initWithDomain:[self domain] code:[self code] userInfo:[self userInfo]];
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
#warning TODO: FIXME
    [self release];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

}

@end

@implementation __NSCFError

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFErrorCreate(kCFAllocatorDefault, (CFStringRef)[self domain], [self code], (CFDictionaryRef)[self userInfo]);
}

- (Class)classForCoder
{
    return [NSError class];
}

- (NSDictionary *)userInfo
{
    return [(NSDictionary *)CFErrorCopyUserInfo((CFErrorRef)self) autorelease];
}

- (NSString *)domain
{
    return (NSString *)CFErrorGetDomain((CFErrorRef)self);
}

- (NSInteger)code
{
    return CFErrorGetCode((CFErrorRef)self);
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

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

@end
