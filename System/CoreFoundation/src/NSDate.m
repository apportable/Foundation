//
//  NSDate.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//


#import <Foundation/NSDate.h>
#import "NSObjectInternal.h"
#import "ForFoundationOnly.h"
#import <sys/time.h>

CF_PRIVATE
@interface __NSPlaceholderDate : NSDate
+ (id)immutablePlaceholder;
@end

CF_PRIVATE
@interface __NSDate : NSDate
@end

#define NSTimeInterval1970 978307200.0
#define NSTimeIntervalDistantFuture 63113904000.0
#define NSTimeIntervalDistantPast (-63114076800.0)


@implementation NSDate

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSDate class])
    {
        return [__NSPlaceholderDate immutablePlaceholder];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    NSRequestConcreteImplementation();
    return 0.0;
}

- (CFTypeID)_cfTypeID
{
    return CFDateGetTypeID();
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (BOOL)isNSDate__
{
    return YES;
}

@end

@implementation NSDate (NSExtendedDate)

+ (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return CFAbsoluteTimeGetCurrent();
}

- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)other
{
    return [self timeIntervalSinceReferenceDate] - [other timeIntervalSinceReferenceDate];
}

- (NSTimeInterval)timeIntervalSinceNow
{
    return [self timeIntervalSinceReferenceDate] - CFAbsoluteTimeGetCurrent();
}

- (NSTimeInterval)timeIntervalSince1970
{
    return [self timeIntervalSinceReferenceDate] + NSTimeInterval1970;
}

- (id)addTimeInterval:(NSTimeInterval)seconds
{
    return [self dateByAddingTimeInterval:seconds];
}

- (id)dateByAddingTimeInterval:(NSTimeInterval)ti
{
    return [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate] + ti] autorelease];
}

- (NSDate *)earlierDate:(NSDate *)other
{
    if (other == nil)
    {
        return self;
    }
    
    if ([other timeIntervalSinceReferenceDate] < [self timeIntervalSinceReferenceDate])
    {
        return other;
    }
    else
    {
        return self;
    }
}

- (NSDate *)laterDate:(NSDate *)other
{
    if (other == nil)
    {
        return self;
    }
    
    if ([other timeIntervalSinceReferenceDate] > [self timeIntervalSinceReferenceDate])
    {
        return other;
    }
    else
    {
        return self;
    }
}

- (NSComparisonResult)compare:(NSDate *)other
{
    NSTimeInterval t1 = [self timeIntervalSinceReferenceDate];
    NSTimeInterval t2 = [other timeIntervalSinceReferenceDate];
    if (t1 < t2)
    {
        return NSOrderedAscending;
    }
    else if (t1 > t2)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedSame;
    }
}

- (NSUInteger)hash
{
    return (NSUInteger)[self timeIntervalSinceReferenceDate];
}

- (BOOL)isEqual:(id)other
{
    if (![other isNSDate__])
    {
        return NO;
    }
    return [self isEqualToDate:other];
}

- (BOOL)isEqualToDate:(NSDate *)other
{
    return [other timeIntervalSinceReferenceDate] == [self timeIntervalSinceReferenceDate];
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    static CFLocaleRef loc = NULL;
    static CFDateFormatterRef formatter = NULL;
    static dispatch_once_t once = 0L;
    CFDateFormatterRef effectiveFormatter = NULL;
    CFLocaleRef effectiveLocale = (CFLocaleRef)locale;

    if (effectiveLocale == NULL)
    {
        effectiveLocale = CFLocaleCopyCurrent();
    }

    if (loc == NULL)
    {
        // Cache the primary locale based formatter
        loc = (CFLocaleRef)CFRetain(effectiveLocale);
        dispatch_once(&once, ^{
            formatter = CFDateFormatterCreate(kCFAllocatorDefault, loc, kCFDateFormatterFullStyle, kCFDateFormatterFullStyle);
            CFTimeZoneRef tz = CFTimeZoneCreateWithTimeIntervalFromGMT(kCFAllocatorDefault, 0.0); // All date descriptions seem to be based off of GMT
            CFDateFormatterSetProperty(formatter, kCFDateFormatterTimeZone, tz);
            CFRelease(tz);
            CFDateFormatterSetFormat(formatter, CFSTR("yyyy-MM-dd HH:mm:ss '+0000'"));
        });
    }

    if (loc == effectiveLocale)
    {
        effectiveFormatter = formatter;
    }
    else
    {
        // cache miss; the locale specified is not the primary locale formatter
        effectiveFormatter = CFDateFormatterCreate(kCFAllocatorDefault, effectiveLocale, kCFDateFormatterFullStyle, kCFDateFormatterFullStyle);
        CFTimeZoneRef tz = CFTimeZoneCreateWithTimeIntervalFromGMT(kCFAllocatorDefault, 0.0); // All date descriptions seem to be based off of GMT
        CFDateFormatterSetProperty(effectiveFormatter, kCFDateFormatterTimeZone, tz);
        CFRelease(tz);
        CFDateFormatterSetFormat(effectiveFormatter, CFSTR("yyyy-MM-dd HH:mm:ss '+0000'"));
    }

    CFStringRef desc = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, effectiveFormatter, (CFDateRef)self);

    if (effectiveLocale != locale)
    {
        CFRelease(effectiveLocale);
    }

    if (effectiveFormatter != formatter)
    {
        CFRelease(effectiveFormatter);
    }

    return [(NSString *)desc autorelease];
}

@end

@implementation NSDate (NSDateCreation)

+ (id)date
{
    return [[[self alloc] initWithTimeIntervalSinceReferenceDate:CFAbsoluteTimeGetCurrent()] autorelease];
}

+ (id)dateWithTimeIntervalSinceNow:(NSTimeInterval)ti
{
    return [[[self alloc] initWithTimeIntervalSinceReferenceDate:CFAbsoluteTimeGetCurrent() + ti] autorelease];
}

+ (id)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{
    return [[[self alloc] initWithTimeIntervalSinceReferenceDate:ti] autorelease];
}

+ (id)dateWithTimeIntervalSince1970:(NSTimeInterval)ti
{
    return [[[self alloc] initWithTimeIntervalSinceReferenceDate:ti - NSTimeIntervalSince1970] autorelease];
}

+ (id)dateWithTimeInterval:(NSTimeInterval)ti sinceDate:(NSDate *)date
{
    return [[[self alloc] initWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate] + ti] autorelease];
}

+ (id)distantFuture
{
    static NSDate *distantFuture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        distantFuture = [[self alloc] initWithTimeIntervalSinceReferenceDate:NSTimeIntervalDistantFuture];
    });
    return distantFuture;
}

+ (id)distantPast
{
    static NSDate *distantPast = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, 
    ^{
        distantPast = [[self alloc] initWithTimeIntervalSinceReferenceDate:NSTimeIntervalDistantPast];
    });
    return distantPast;
}

- (id)init
{
    return [self initWithTimeIntervalSinceReferenceDate:CFAbsoluteTimeGetCurrent()];
}

- (id)initWithTimeIntervalSinceNow:(NSTimeInterval)ti
{
    return [self initWithTimeIntervalSinceReferenceDate:CFAbsoluteTimeGetCurrent() + ti];
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithTimeIntervalSince1970:(NSTimeInterval)ti
{
    return [self initWithTimeIntervalSinceReferenceDate:ti - NSTimeIntervalSince1970];
}

- (id)initWithTimeInterval:(NSTimeInterval)ti sinceDate:(NSDate *)other
{
    return [self initWithTimeIntervalSinceReferenceDate:ti + [other timeIntervalSinceReferenceDate]];
}

@end

@implementation __NSDate {
    NSTimeInterval _time;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [__NSPlaceholderDate immutablePlaceholder];
}

+ (id)__new:(NSTimeInterval)t
{
    __NSDate *date = ___CFAllocateObject(self);
    date->_time = t;
    return date;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)t
{
    return (id)[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:t];
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return _time;
}

- (void)dealloc
{
    // this seems strange to implement but it seems to be implemented
    [super dealloc];
}

@end

@implementation __NSPlaceholderDate

+ (id)immutablePlaceholder
{
    static dispatch_once_t once = 0L;
    static __NSPlaceholderDate *immutablePlaceholder = nil;
    dispatch_once(&once, ^{
        immutablePlaceholder = [__NSPlaceholderDate alloc];
    });
    return immutablePlaceholder;
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return 0.0;
}

SINGLETON_RR()

- (id)init
{
    return [self initWithTimeIntervalSinceReferenceDate:CFAbsoluteTimeGetCurrent()];
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)t
{
    return (id)[__NSDate __new:t];
}

@end
