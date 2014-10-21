//
//  NSDateComponents.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCalendarInternal.h"
#import <Foundation/NSKeyValueObserving.h>
#import "ForFoundationOnly.h"

typedef struct {
    NSUInteger unitFlags;
    NSInteger era;
    NSInteger year;
    NSInteger month;
    NSInteger dayOfMonth;
    NSInteger hourOfDay;
    NSInteger minute;
    NSInteger second;
    NSInteger nanosecond;
    NSInteger weekOfYear;
    NSInteger weekOfMonth;
    NSInteger yearWeekOfYear;
    NSInteger weekday;
    NSInteger quarter;
    NSInteger weekdayOrdinal;
    NSCalendar *calendar;
    NSTimeZone *timeZone;
} NSDateComponentParts;

@implementation NSDateComponents

+ (id)allocWithZone:(NSZone *)zone
{
    return (id)___CFAllocateObject2(self, sizeof(NSDateComponentParts));
}

- (id)copyWithZone:(NSZone *)zone
{
    NSDateComponents *copy = [[[self class] allocWithZone:zone] init];
    copy.day = self.day;
    copy.month = self.month;
    copy.year = self.year;
    copy.hour = self.hour;
    copy.minute = self.minute;
    copy.second = self.second;
    copy.nanosecond = self.nanosecond;
    copy.weekday = self.weekday;
    copy.week = self.week;
    copy.era = self.era;
    copy.quarter = self.quarter;
    copy.weekOfYear = self.weekOfYear;
    copy.yearForWeekOfYear = self.yearForWeekOfYear;
    copy.weekdayOrdinal = self.weekdayOrdinal;
    copy.calendar = self.calendar;
    copy.timeZone = self.timeZone;
    return copy;
}

- (id)init
{
    self = [super init];

    if (self)
    {
        NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
        parts->era = INT_MAX;
        parts->year = INT_MAX;
        parts->month = INT_MAX;
        parts->dayOfMonth = INT_MAX;
        parts->hourOfDay = INT_MAX;
        parts->minute = INT_MAX;
        parts->second = INT_MAX;
        parts->nanosecond = INT_MAX;
        parts->weekOfYear = INT_MAX;
        parts->weekOfMonth = INT_MAX;
        parts->yearWeekOfYear = INT_MAX;
        parts->weekday = INT_MAX;
        parts->quarter = INT_MAX;
        parts->weekdayOrdinal = INT_MAX;
    }

    return self;
}

- (NSInteger)day
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->dayOfMonth;
}

- (void)setDay:(NSInteger)day
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitDay;
    parts->dayOfMonth = day;
}

- (NSInteger)month
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->month;
}

- (void)setMonth:(NSInteger)month
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitMonth;
    parts->month = month;
}

- (NSInteger)year
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->year;
}

- (void)setYear:(NSInteger)year
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitYear;
    parts->year = year;
}

- (NSInteger)hour
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->hourOfDay;
}

- (void)setHour:(NSInteger)hour
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitHour;
    parts->hourOfDay = hour;
}

- (NSInteger)minute
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->minute;
}

- (void)setMinute:(NSInteger)minute
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitMinute;
    parts->minute = minute;
}

- (NSInteger)second
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->second;
}

- (void)setSecond:(NSInteger)second
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitSecond;
    parts->second = second;
}

- (NSInteger)nanosecond
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->nanosecond;
}

- (void)setNanosecond:(NSInteger)nanosecond
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitNanosecond;
    parts->nanosecond = nanosecond;
}

- (NSInteger)weekday
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->weekday;
}

- (void)setWeekday:(NSInteger)weekday
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitWeekday;
    parts->weekday = weekday;
}

- (NSInteger)week
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->weekOfMonth;
}

- (void)setWeek:(NSInteger)week
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitWeekOfMonth;
    parts->weekOfMonth = week;
}

- (NSInteger)era
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->era;
}

- (void)setEra:(NSInteger)era
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitEra;
    parts->era = era;
}

- (NSInteger)quarter
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->quarter;
}

- (void)setQuarter:(NSInteger)quarter
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitQuarter;
    parts->quarter = quarter;
}

- (NSInteger)weekOfMonth
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->weekOfMonth;
}

- (void)setWeekOfMonth:(NSInteger)weekOfMonth
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitWeekOfMonth;
    parts->weekOfMonth = weekOfMonth;
}

- (NSInteger)weekOfYear
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->weekOfYear;
}

- (void)setWeekOfYear:(NSInteger)weekOfYear
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitWeekOfYear;
    parts->weekOfYear = weekOfYear;
}

- (NSInteger)yearForWeekOfYear
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->yearWeekOfYear;
}

- (void)setYearForWeekOfYear:(NSInteger)yearWeekOfYear
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitYearForWeekOfYear;
    parts->yearWeekOfYear = yearWeekOfYear;
}

- (NSInteger)weekdayOrdinal
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->weekdayOrdinal;
}

- (void)setWeekdayOrdinal:(NSInteger)weekdayOrdinal
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    parts->unitFlags |= NSCalendarUnitWeekdayOrdinal;
    parts->weekdayOrdinal = weekdayOrdinal;
}

- (NSCalendar *)calendar
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->calendar;
}

- (void)setCalendar:(NSCalendar *)calendar
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);

    if (parts->calendar != calendar)
    {
        [parts->calendar release];
        parts->calendar = [calendar retain];
    }
}

- (NSTimeZone *)timeZone
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    return parts->timeZone;
}

- (void)setTimeZone:(NSTimeZone *)timeZone
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    
    if (parts->timeZone != timeZone)
    {
        [parts->timeZone release];
        parts->timeZone = [timeZone retain];
    }
}

-(NSDate *)date
{
    NSDateComponentParts *parts = (NSDateComponentParts *)object_getIndexedIvars(self);
    if (parts->calendar != nil)
    {
        return [parts->calendar dateFromComponents:self];
    }
    return nil;
}

@end
