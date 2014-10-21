//
//  NSCalendar.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSTimeZone.h>
#import <Foundation/NSLocale.h>
#import "NSCalendarInternal.h"
#import "NSObjectInternal.h"

extern void CFCalendarSetGregorianStartDate(CFCalendarRef calendar, CFDateRef date);
extern CFDateRef CFCalendarCopyGregorianStartDate(CFCalendarRef calendar);
extern Boolean _CFCalendarDecomposeAbsoluteTimeV(CFCalendarRef calendar, CFAbsoluteTime at, const char *componentDesc, int **componentVector, int count);
extern Boolean _CFCalendarGetComponentDifferenceV(CFCalendarRef calendar, CFAbsoluteTime startingAT, CFAbsoluteTime resultAT, CFOptionFlags options, const char *componentDesc, int **vector, int count);

@implementation NSCalendar

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSCalendar class])
    {
        static dispatch_once_t once = 0L;
        static __NSCFCalendar *placeholder = nil;
        dispatch_once(&once, ^{
            placeholder = [__NSCFCalendar allocWithZone:nil];
        });
        return placeholder;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

+ (id)currentCalendar
{
    return [(NSCalendar *)CFCalendarCopyCurrent() autorelease];
}

- (CFTypeID)_cfTypeID
{
    return CFCalendarGetTypeID();
}


- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date
{
    return NO;
}

@end


@implementation __NSCFCalendar

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

#define MAX_COMPS 17

static int makeCFCalendarComponentVector(NSDateComponents *comps, int *componentVector, char *format)
{
    NSInteger era = [comps era];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    NSInteger nanosecond = [comps nanosecond];
    NSInteger weekOfYear = [comps weekOfYear];
    NSInteger weekOfMonth = [comps weekOfMonth];
    NSInteger yearForWeekOfYear = [comps yearForWeekOfYear];
    NSInteger weekday = [comps weekday];
    NSInteger weekdayOrdinal = [comps weekdayOrdinal];

    int count = 0;
    if (era != INT_MAX)
    {
        componentVector[count] = era;
        format[count++] = 'G';
    }
    if (year != INT_MAX)
    {
        componentVector[count] = year;
        format[count++] = 'y';
    }
    if (month != INT_MAX)
    {
        componentVector[count] = month;
        format[count++] = 'M';
    }
    if (day != INT_MAX)
    {
        componentVector[count] = day;
        format[count++] = 'd';
    }
    if (hour != INT_MAX)
    {
        componentVector[count] = hour;
        format[count++] = 'H';
    }
    if (minute != INT_MAX)
    {
        componentVector[count] = minute;
        format[count++] = 'm';
    }
    if (second != INT_MAX)
    {
        componentVector[count] = second;
        format[count++] = 's';
    }
    if (nanosecond != INT_MAX)
    {
        componentVector[count] = nanosecond / NSEC_PER_MSEC;
        format[count++] = 'S';
    }
    if (weekOfYear != INT_MAX)
    {
        componentVector[count] = weekOfYear;
        format[count++] = 'w';
    }
    if (weekOfMonth != INT_MAX)
    {
        componentVector[count] = weekOfMonth;
        format[count++] = 'W';
    }
    if (yearForWeekOfYear != INT_MAX)
    {
        componentVector[count] = yearForWeekOfYear;
        format[count++] = 'Y';
    }
    if (weekday != INT_MAX)
    {
        componentVector[count] = weekday;
        format[count++] = 'E';
    }
    if (weekdayOrdinal != INT_MAX)
    {
        componentVector[count] = weekdayOrdinal;
        format[count++] = 'F';
    }

    format[count] = '\0';

    return count;
}

static int makeCFCalendarComponentsVector(NSUInteger unitFlags, int *componentVector, int **v, char *format)
{
    /*
        TODO: figure out how these are populated
        NSCalendarUnitQuarter

        G UCAL_ERA NSCalendarUnitEra
        y UCAL_YEAR NSCalendarUnitYear
        M UCAL_MONTH NSCalendarUnitMonth
        d UCAL_DAY_OF_MONTH NSCalendarUnitDay
        h UCAL_HOUR 
        H UCAL_HOUR_OF_DAY NSCalendarUnitHour
        m UCAL_MINUTE NSCalendarUnitMinute
        s UCAL_SECOND NSCalendarUnitSecond
        S UCAL_MILLISECOND (NSCalendarUnitNanosecond with conversion)
        w UCAL_WEEK_OF_YEAR NSCalendarUnitWeekOfYear
        W UCAL_WEEK_OF_MONTH NSCalendarUnitWeekOfMonth
        Y UCAL_YEAR_WOY NSCalendarUnitYearForWeekOfYear
        E UCAL_DAY_OF_WEEK NSCalendarUnitWeekday
        D UCAL_DAY_OF_YEAR
        F UCAL_DAY_OF_WEEK_IN_MONTH NSCalendarUnitWeekdayOrdinal
        a UCAL_AM_PM
        g UCAL_JULIAN_DAY
    */

    int count = 0;

    if ((unitFlags & NSCalendarUnitEra) != 0)
    {
        format[count++] = 'G';
    }
    if ((unitFlags & NSCalendarUnitYear) != 0)
    {
        format[count++] = 'y';
    }
    if ((unitFlags & NSCalendarUnitMonth) != 0 ||
        (unitFlags & NSCalendarUnitQuarter) != 0)
    {
        format[count++] = 'M';
    }
    if ((unitFlags & NSCalendarUnitDay) != 0)
    {
        format[count++] = 'd';
    }
    if ((unitFlags & NSCalendarUnitHour) != 0)
    {
        format[count++] = 'H';
    }
    if ((unitFlags & NSCalendarUnitMinute) != 0)
    {
        format[count++] = 'm';
    }
    if ((unitFlags & NSCalendarUnitSecond) != 0)
    {
        format[count++] = 's';
    }
    if ((unitFlags & NSCalendarUnitNanosecond) != 0)
    {
        format[count++] = 'S';
    }
    if ((unitFlags & NSCalendarUnitWeekOfYear) != 0)
    {
        format[count++] = 'w';
    }
    if ((unitFlags & NSCalendarUnitWeekOfMonth) != 0)
    {
        format[count++] = 'W';
    }
    if ((unitFlags & NSCalendarUnitYearForWeekOfYear) != 0)
    {
        format[count++] = 'Y';
    }
    if ((unitFlags & NSCalendarUnitWeekday) != 0)
    {
        format[count++] = 'E';
    }
    if ((unitFlags & NSCalendarUnitWeekdayOrdinal) != 0)
    {
        format[count++] = 'F';
    }

    format[count] = '\0'; // ensure terminator since _CFCalendarDecomposeAbsoluteTimeV iterates on the formatter

    for (NSUInteger idx = 0; idx < MAX_COMPS; idx++)
    {
        v[idx] = &componentVector[idx];
    }

    return count;
}

static NSDateComponents *componentsFromVector(NSCalendar *self, NSUInteger unitFlags, int *componentVector)
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSUInteger count = 0;
    if ((unitFlags & NSCalendarUnitEra) != 0)
    {
        [comps setEra:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitYear) != 0)
    {
        [comps setYear:componentVector[count++]];
    }
    int month = -1;
    if ((unitFlags & NSCalendarUnitMonth) != 0 ||
        (unitFlags & NSCalendarUnitQuarter) != 0)
    {
        month = componentVector[count++];
        if ((unitFlags & NSCalendarUnitMonth) != 0)
        {
            [comps setMonth:month];
        }
    }
    if ((unitFlags & NSCalendarUnitDay) != 0)
    {
        [comps setDay:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitQuarter) != 0)
    {
/*
US Locale Fiscal Quarters:
1st quarter: 1 October 2013 – 31 December 2013
2nd quarter: 1 January 2014 – 31 March 2014
3rd quarter: 1 April 2014 – 30 June 2014
4th quarter: 1 July 2014 – 30 September 2014
*/
        enum {
            january = 1,
            february,
            march,
            april,
            may,
            june,
            july,
            august,
            september,
            october,
            november,
            december,
        };
        int quarter = -1;
        if (october <= month && month <= december)
        {
            quarter = 0;
        }
        else if (january <= month && month <= march)
        {
            quarter = 1;
        }
        else if (april <= month && month <= june)
        {
            quarter = 2;
        }
        else /* if (july <= month && month <= september) */
        {
            quarter = 3;
        }

        if (quarter != -1)
        {
            [comps setQuarter:quarter];
        }
        else
        {
            DEBUG_BREAK();
        }
    }
    if ((unitFlags & NSCalendarUnitHour) != 0)
    {
        [comps setHour:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitMinute) != 0)
    {
        [comps setMinute:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitSecond) != 0)
    {
        [comps setSecond:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitNanosecond) != 0)
    {
        [comps setNanosecond:NSEC_PER_MSEC * componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitWeekOfYear) != 0)
    {
        [comps setWeekOfYear:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitWeekOfMonth) != 0)
    {
        [comps setWeekOfMonth:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitYearForWeekOfYear) != 0)
    {
        [comps setYearForWeekOfYear:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitWeekday) != 0)
    {
        [comps setWeekday:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitWeekdayOrdinal) != 0)
    {
        [comps setWeekdayOrdinal:componentVector[count++]];
    }
    if ((unitFlags & NSCalendarUnitCalendar) != 0)
    {
        [comps setCalendar:self];
    }
    if ((unitFlags & NSCalendarUnitTimeZone) != 0)
    {
        [comps setTimeZone:[self timeZone]];
    }
    return [comps autorelease];
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSUInteger)opts
{
    if (startingDate == nil)
    {
        return nil;
    }

    if (resultDate == nil)
    {
        return nil;
    }


    CFAbsoluteTime startingAT = [startingDate timeIntervalSinceReferenceDate];
    CFAbsoluteTime resultAT = [resultDate timeIntervalSinceReferenceDate];

    char format[MAX_COMPS];
    int componentVector[MAX_COMPS];
    int *v[MAX_COMPS];
    int count = makeCFCalendarComponentsVector(unitFlags, componentVector, v, format);

    if (!_CFCalendarGetComponentDifferenceV((CFCalendarRef)self, startingAT, resultAT, (CFOptionFlags)opts, format, v, count))
    {
        return nil;
    }

    return componentsFromVector(self, unitFlags, componentVector);
}

- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSUInteger)opts
{
    if (comps == nil)
    {
        return nil;
    }
    
    if (date == nil)
    {
        return nil;
    }

    CFAbsoluteTime absTime = [date timeIntervalSinceReferenceDate];
    char format[MAX_COMPS];
    int componentVector[MAX_COMPS];

    int count = makeCFCalendarComponentVector(comps, componentVector, format);

    // TODO handle "yMldHms" for day of week - also era, nanoseconds, etc.
    if (!_CFCalendarAddComponentsV((CFCalendarRef)self, &absTime, opts, format, componentVector, strlen(format)))
    {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSinceReferenceDate:absTime];
}

- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date
{
    if (date == nil)
    {
        return nil;
    }
    
    CFAbsoluteTime at = [date timeIntervalSinceReferenceDate];

    char format[MAX_COMPS];
    int componentVector[MAX_COMPS];
    int *v[MAX_COMPS];
    int count = makeCFCalendarComponentsVector(unitFlags, componentVector, v, format);

    if (!_CFCalendarDecomposeAbsoluteTimeV((CFCalendarRef)self, at, format, v, count))
    {
        return nil;
    }

    return componentsFromVector(self, unitFlags, componentVector);
}



- (NSDate *)dateFromComponents:(NSDateComponents *)comps
{
    if (comps == nil)
    {
        return nil;
    }

    char format[MAX_COMPS];
    int componentVector[MAX_COMPS];

    int count = makeCFCalendarComponentVector(comps, componentVector, format);

    CFAbsoluteTime absTime;

    // TODO handle "yMldHms" for day of week
    if (!_CFCalendarComposeAbsoluteTimeV((CFCalendarRef)self, &absTime, format, componentVector, count))
    {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSinceReferenceDate:absTime];
}

- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date
{
    CFTimeInterval at = [date timeIntervalSinceReferenceDate];
    CFTimeInterval start = at;
    BOOL success = CFCalendarGetTimeRangeOfUnit((CFCalendarRef)self, (CFCalendarUnit)unit, at, &start, (CFTimeInterval *)tip);
    if (datep)
    {
        *datep = [NSDate dateWithTimeIntervalSinceReferenceDate:start];
    }
    return success;
}

- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
    return CFCalendarGetOrdinalityOfUnit((CFCalendarRef)self, (CFCalendarUnit)smaller, (CFCalendarUnit)larger, [date timeIntervalSinceReferenceDate]);
}

- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
    CFRange r = CFCalendarGetRangeOfUnit((CFCalendarRef)self, (CFCalendarUnit)smaller, (CFCalendarUnit)larger, [date timeIntervalSinceReferenceDate]);
    return NSMakeRange(r.location, r.length);
}

- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit
{
    CFRange r = CFCalendarGetMinimumRangeOfUnit((CFCalendarRef)self, (CFCalendarUnit)unit);
    return NSMakeRange(r.location, r.length);
}

- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit
{
    CFRange r = CFCalendarGetMaximumRangeOfUnit((CFCalendarRef)self, (CFCalendarUnit)unit);
    return NSMakeRange(r.location, r.length);
}

- (NSDate *)gregorianStartDate
{
    return [(NSDate *)CFCalendarCopyGregorianStartDate((CFCalendarRef)self) autorelease];
}

- (void)setGregorianStartDate:(NSDate *)date
{
    CFCalendarSetGregorianStartDate((CFCalendarRef)self, (CFDateRef)self);
}

- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw
{
    CFCalendarSetMinimumDaysInFirstWeek((CFCalendarRef)self, mdw);
}

- (NSUInteger)minimumDaysInFirstWeek
{
    return CFCalendarGetMinimumDaysInFirstWeek((CFCalendarRef)self);
}

- (void)setFirstWeekday:(NSUInteger)weekday
{
    CFCalendarSetFirstWeekday((CFCalendarRef)self, weekday);
}

- (NSUInteger)firstWeekday
{
    return CFCalendarGetFirstWeekday((CFCalendarRef)self);
}

- (void)setTimeZone:(NSTimeZone *)tz
{
    CFCalendarSetTimeZone((CFCalendarRef)self, (CFTimeZoneRef)tz);
}

- (NSTimeZone *)timeZone
{
    return [(NSTimeZone *)CFCalendarCopyTimeZone((CFCalendarRef)self) autorelease];
}

- (void)setLocale:(NSLocale *)locale
{
    CFCalendarSetLocale((CFCalendarRef)self, (CFLocaleRef)locale);
}

- (NSLocale *)locale
{
    return [(NSLocale *)CFCalendarCopyLocale((CFCalendarRef)self) autorelease];
}

- (id)initWithCalendarIdentifier:(NSString *)ident
{
    return (id)CFCalendarCreateWithIdentifier(kCFAllocatorDefault, (CFStringRef)ident);
}

- (NSString *)calendarIdentifier
{
    return (NSString *)CFCalendarGetIdentifier((CFCalendarRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    // this seems incomplete
    return (id)CFCalendarCreateWithIdentifier(kCFAllocatorDefault, CFCalendarGetIdentifier((CFCalendarRef)self));
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
    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

@end

