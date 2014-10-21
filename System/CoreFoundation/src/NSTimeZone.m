//
//  NSTimeZone.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSTimeZoneInternal.h"
#import "NSObjectInternal.h"
#import <Foundation/NSCache.h>
#import "CFInternal.h"

@implementation NSTimeZone

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSTimeZone class])
    {
        return [__NSPlaceholderTimeZone immutablePlaceholder];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (NSString *)name
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSData *)data
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSString *)abbreviationForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return NO;
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return 0.0;
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSRequestConcreteImplementation();
    return nil;
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (CFTypeID)_cfTypeID
{
    return CFTimeZoneGetTypeID();
}

- (BOOL)isNSTimeZone__
{
    return YES;
}

@end

@implementation NSTimeZone (NSExtendedTimeZone)

+ (NSTimeZone *)systemTimeZone
{
    return [(NSTimeZone *)CFTimeZoneCopySystem() autorelease];
}

+ (void)resetSystemTimeZone
{
    CFTimeZoneResetSystem();
}

+ (NSTimeZone *)defaultTimeZone
{
    return [(NSTimeZone *)CFTimeZoneCopyDefault() autorelease];
}

+ (void)setDefaultTimeZone:(NSTimeZone *)aTimeZone
{
    CFTimeZoneSetDefault((CFTimeZoneRef)aTimeZone);
}

+ (NSTimeZone *)localTimeZone
{
    static NSTimeZone *localTZ = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        CFStringRef zoneName = CFStringCreateWithCString(kCFAllocatorDefault, getenv("TZ"), kCFStringEncodingUTF8);
        localTZ = (NSTimeZone *)CFTimeZoneCreateWithName(NULL, zoneName, false);
        [localTZ retain];
        CFRelease(zoneName);
    });
    return localTZ;
}

+ (NSArray *)knownTimeZoneNames
{
    return [(NSArray *)CFTimeZoneCopyKnownNames() autorelease];
}

+ (NSDictionary *)abbreviationDictionary
{
    return [(NSDictionary *)CFTimeZoneCopyAbbreviationDictionary() autorelease];
}

+ (void)setAbbreviationDictionary:(NSDictionary *)dict
{
    CFTimeZoneSetAbbreviationDictionary((CFDictionaryRef)dict);
}

- (NSInteger)secondsFromGMT
{
    return [self secondsFromGMTForDate:[NSDate date]];
}

- (NSString *)abbreviation
{
    NSRequestConcreteImplementation();
    return nil;
}

- (BOOL)isDaylightSavingTime
{
    return [self isDaylightSavingTimeForDate:[NSDate date]];
}

- (NSTimeInterval)daylightSavingTimeOffset
{
    return [self daylightSavingTimeOffsetForDate:[NSDate date]];
}

- (NSDate *)nextDaylightSavingTimeTransition
{
    return [self nextDaylightSavingTimeTransitionAfterDate:[NSDate date]];
}

- (BOOL)isEqualToTimeZone:(NSTimeZone *)aTimeZone
{
    return [[self name] isEqualToString:[aTimeZone name]] && [[self data] isEqualToData:[aTimeZone data]];
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale
{
    NSRequestConcreteImplementation();
    return nil;
}


@end

@implementation NSTimeZone (NSTimeZoneCreation)

+ (id)timeZoneWithName:(NSString *)tzName
{
    return [[[NSTimeZone alloc] initWithName:tzName] autorelease];
}

+ (id)timeZoneWithName:(NSString *)tzName data:(NSData *)aData
{
    return [[[self alloc] initWithName:tzName data:aData] autorelease];
}

+ (id)timeZoneForSecondsFromGMT:(NSInteger)seconds
{
    return [(NSTimeZone *)CFTimeZoneCreateWithTimeIntervalFromGMT(kCFAllocatorDefault, seconds) autorelease];
}

+ (id)timeZoneWithAbbreviation:(NSString *)abbreviation
{
    CFStringRef name = CFDictionaryGetValue((CFDictionaryRef)[NSTimeZone abbreviationDictionary], abbreviation);
    if (name != nil)
    {
        return [[[self alloc] initWithName:(NSString *)name] autorelease];
    }
    return nil;
}


- (id)initWithName:(NSString *)tzName
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithName:(NSString *)tzName data:(NSData *)aData
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

@end

@implementation __NSPlaceholderTimeZone

static NSCache *tzCache = nil;

+ (id)immutablePlaceholder
{
    static dispatch_once_t once = 0L;
    static __NSPlaceholderTimeZone *placeholder = nil;
    dispatch_once(&once, ^{
        placeholder = [__NSPlaceholderTimeZone alloc];
    });
    return placeholder;
}

+ (void)initialize
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        tzCache = [[NSCache alloc] init];
    });
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return 0.0;
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return NO;
}

- (NSString *)abbreviationForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSData *)data
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)name
{
    NSRequestConcreteImplementation();
    return nil;
}

SINGLETON_RR()

- (id)init
{
    return nil;
}

static NSTimeZone *NSTimeZoneCacheFind(NSString *name)
{
    return [tzCache objectForKey:name];
}

static void NSTimeZoneCacheAdd(NSString *name, NSTimeZone *tz)
{
    [tzCache setObject:tz forKey:name cost:[[tz data] length]];
}

- (id)initWithName:(NSString *)name
{
    return (id)CFTimeZoneCreateWithName(kCFAllocatorDefault, (CFStringRef)name, YES);
}

- (id)initWithName:(NSString *)name data:(NSData *)data
{
    return [self __initWithName:name data:data cache:NO];
}

- (id)__initWithName:(NSString *)name data:(NSData *)data cache:(BOOL)shouldCache
{
    NSTimeZone *tz = (NSTimeZone *)CFTimeZoneCreate(kCFAllocatorDefault, (CFStringRef)name, (CFDataRef)data);
    
    if (tz != NULL && shouldCache)
    {
        NSTimeZoneCacheAdd(name, tz);
    }

    return (id)tz;
}

@end

@implementation __NSTimeZone {
    CFStringRef _name;
    CFDataRef _data;
    void **_ucal;
    int _lock;
}

- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale
{
    return [(NSString *)CFTimeZoneCopyLocalizedName((CFTimeZoneRef)self, (CFTimeZoneNameStyle)style, (CFLocaleRef)locale) autorelease];
}

- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate
{
    CFAbsoluteTime time = CFTimeZoneGetNextDaylightSavingTimeTransition((CFTimeZoneRef)self, [aDate timeIntervalSinceReferenceDate]);
    return (time == 0) ? nil : [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate
{
    return CFTimeZoneGetDaylightSavingTimeOffset((CFTimeZoneRef)self, [aDate timeIntervalSinceReferenceDate]);
}

- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate
{
    return CFTimeZoneIsDaylightSavingTime((CFTimeZoneRef)self, [aDate timeIntervalSinceReferenceDate]);
}

- (NSString *)abbreviationForDate:(NSDate *)aDate
{
    //This implementation is more correct than calling CFTimeZoneCopyAbbreviation from this point.
    //TODO - account for daylight savings by using ICU
    const void *keys[48];
    const void *values[48];
    CFDictionaryGetKeysAndValues((CFDictionaryRef)[NSTimeZone abbreviationDictionary], keys, values);
    
    for (int i = 0; i < 48; i++)
    {
        if ([((NSString*)values[i]) isEqualToString:[self name]])
        {
            return keys[i];
        }
    }
    
    return nil;

    //This date is not the date that is sourced for the timezone, but used for determining the current daylight savings status
    //return [(NSString *)CFTimeZoneCopyAbbreviation((CFTimeZoneRef)self, [aDate timeIntervalSinceReferenceDate]) autorelease];
}

- (NSString *)description
{
    CFStringRef description = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@ (%@) %d"), [self name], [self abbreviation], [self secondsFromGMT]);
    return [(NSString *)description autorelease];
}

- (NSString *)abbreviation
{
    return [self abbreviationForDate:[NSDate date]];
}

- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate
{
    return CFTimeZoneGetSecondsFromGMT((CFTimeZoneRef)self, [aDate timeIntervalSinceReferenceDate]);
}

- (NSData *)data
{
    return (NSData *)CFTimeZoneGetData((CFTimeZoneRef)self);
}

- (NSString *)name
{
    return (NSString *)CFTimeZoneGetName((CFTimeZoneRef)self);
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

- (BOOL)isEqual:(id)obj
{
    if (obj == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)obj);
}

@end
