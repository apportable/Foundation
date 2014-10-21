//
//  NSTimeZoneTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <Foundation/NSDate.h>

@testcase(NSTimeZone)

// Change this if device has another default
#define MY_TIMEZONE @"America/Los_Angeles"

test(CFTimeZoneCopySystem)
{
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCopySystem();
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

test(CFTimeZoneGetName)
{
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    CFStringRef n = CFTimeZoneGetName(tz);
    testassert([(NSString *)n isEqualToString:MY_TIMEZONE]);
    return YES;
}

test(CFTimeZoneCopyDefault)
{
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCopyDefault();
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

test(CFTimeZoneCreateWithName)
{
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCreateWithName(NULL, CFSTR("Europe/Monaco"), false);
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:@"Europe/Monaco"]);
    return YES;
}

test(CFTimeZoneSetDefault)
{
    CFTimeZoneRef cftz = CFTimeZoneCreateWithName(NULL, CFSTR("Europe/Monaco"), false);
    CFTimeZoneSetDefault(cftz);
    
    NSTimeZone *d = (NSTimeZone *)CFTimeZoneCopyDefault();
    testassert([[d name] isEqualToString:@"Europe/Monaco"]);
    
    d = (NSTimeZone *)CFTimeZoneCopySystem();
    testassert([[d name] isEqualToString:MY_TIMEZONE]);
    
    CFTimeZoneSetDefault(CFTimeZoneCopySystem());
    
    d = (NSTimeZone *)CFTimeZoneCopyDefault();
    testassert([[d name] isEqualToString:MY_TIMEZONE]);
    return YES;
}

static CFAbsoluteTime makeCFAbsoluteTime(int year, int month, int day)
{
    CFGregorianDate     gregDate;
    
    // Construct a Gregorian date.
    gregDate.year = year;
    gregDate.month = month;
    gregDate.day = day;
    gregDate.hour = 0;
    gregDate.minute = 0;
    gregDate.second = 0;
    
    // Convert the Gregorian date to absolute time.
    return CFGregorianDateGetAbsoluteTime(gregDate, NULL);
}

test(CFTimeZoneGetDaylightSavingTimeOffset)
{
    CFTimeZoneRef tz = CFTimeZoneCreateWithName(NULL, CFSTR("America/Los_Angeles"), false);
    CFAbsoluteTime t = makeCFAbsoluteTime(2013, 10, 18);
    
    CFTimeInterval ti = CFTimeZoneGetDaylightSavingTimeOffset(tz, t);
    testassert(ti == 3600);
    return YES;
}

test(CFTimeZoneGetNextDaylightSavingTimeTransition)
{
    CFTimeZoneRef tz = CFTimeZoneCreateWithName(NULL, CFSTR("America/Los_Angeles"), false);
    CFAbsoluteTime t = makeCFAbsoluteTime(2013, 10, 18);
    
    CFAbsoluteTime t2 = CFTimeZoneGetNextDaylightSavingTimeTransition(tz, t);
    testassert((double)t2 == 405162000);   // 2013-11-03 01:00:00 PST
   
    tz = CFTimeZoneCreateWithName(NULL, CFSTR("US/Arizona"), false);
    t = makeCFAbsoluteTime(2013, 10, 18);
    t2 = CFTimeZoneGetNextDaylightSavingTimeTransition(tz, t);
    testassert((double)t2 == 0);   // never
    
    return YES;
}

test(CFTimeZoneGetSecondsFromGMT)
{
    CFTimeZoneRef tz = CFTimeZoneCreateWithName(NULL, CFSTR("America/Los_Angeles"), false);
    CFAbsoluteTime t = makeCFAbsoluteTime(2013, 10, 18);
    
    CFTimeInterval ti = CFTimeZoneGetSecondsFromGMT(tz, t);
    
    testassert(ti == -25200);
    return YES;
}

test(CFTimeZoneIsDaylightSavingTime)
{
    CFTimeZoneRef tz = CFTimeZoneCreateWithName(NULL, CFSTR("America/Los_Angeles"), false);
    CFAbsoluteTime t = makeCFAbsoluteTime(2013, 10, 18);
    Boolean b = CFTimeZoneIsDaylightSavingTime(tz, t);
    testassert(b);
    
    t = makeCFAbsoluteTime(2013, 12, 18);
    b = CFTimeZoneIsDaylightSavingTime(tz, t);
    testassert(!b);
    
    tz = CFTimeZoneCreateWithName(NULL, CFSTR("US/Arizona"), false);
    t = makeCFAbsoluteTime(2013, 10, 18);
    b = CFTimeZoneIsDaylightSavingTime(tz, t);
    testassert(!b);
    
    return YES;
}

test(DefaultTimeZone)
{
    NSTimeZone *d = [NSTimeZone defaultTimeZone];
    const char *cName = object_getClassName(d);
    testassert(strcmp(cName, "__NSTimeZone") == 0);
    return YES;
}

test(DefaultTimeZoneName)
{
    NSTimeZone *d = [NSTimeZone defaultTimeZone];
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

test(LocalTimeZoneName)
{
    NSTimeZone *d = [NSTimeZone localTimeZone];
    NSString *name = [d name];
    testassert([name length] > 0);
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

test(TimeZoneForSecondsFromGMT)
{
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:-300];
    NSString *name = [tz name];
    testassert([name isEqualToString:@"GMT-0005"]);
    return YES;
}

test(DaylightSavingTimeOffset)
{
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:60];
    NSTimeInterval ti = [tz daylightSavingTimeOffset];
    testassert(ti == 0);
    
    tz = [[NSTimeZone alloc] initWithName:@"America/Los_Angeles"];
    ti = [tz daylightSavingTimeOffset];
    testassert(ti == ([tz isDaylightSavingTime] ? 3600 : 0));
    
    return YES;
}

static NSDate *makeNSDate(int year, int month, int day)
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
//    [comps setHour:0];   // Unitialized should be treated as zero
//    [comps setMinute:0];
//    [comps setSecond:0];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [cal dateFromComponents:comps];
    [comps release];
    return date;
}

test(DaylightSavingTimeOffsetForDate)
{
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:-300];
    NSDate *date = makeNSDate(2013, 10, 19);
    NSTimeInterval ti = [tz daylightSavingTimeOffsetForDate:date];
    testassert(ti == 0);
    
    tz = [[NSTimeZone alloc] initWithName:@"America/Los_Angeles"];
    ti = [tz daylightSavingTimeOffsetForDate:date];
    testassert(ti == 3600);
    
    date = makeNSDate(2013, 12, 19);
    ti = [tz daylightSavingTimeOffsetForDate:date];
    testassert(ti == 0);
    
    tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];
    date = makeNSDate(2013, 10, 19);
    ti = [tz daylightSavingTimeOffsetForDate:date];
    testassert(ti == 0);
    
    return YES;
}


test(IsDaylightSavingTime)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];  // no DST in Hawaii
    BOOL b = [tz isDaylightSavingTime];
    testassert(!b);
    return YES;
}

test(IsDaylightSavingTimeForDate)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:@"America/Los_Angeles"];
    NSDate *date = makeNSDate(2013, 10, 19);
    BOOL b = [tz isDaylightSavingTimeForDate:date];
    testassert(b);
    
    date = makeNSDate(2013, 12, 19);
    b = [tz isDaylightSavingTimeForDate:date];
    testassert(!b);
    
    tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];
    date = makeNSDate(2013, 10, 19);
    b = [tz isDaylightSavingTimeForDate:date];
    testassert(!b);
    
    return YES;
}

test(IsEqualToTimeZone)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:MY_TIMEZONE];
    testassert([tz isEqualToTimeZone:[NSTimeZone localTimeZone]]);
    return YES;
}

test(Name)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:MY_TIMEZONE];
    NSString *name = [tz name];
    testassert([name isEqualToString:MY_TIMEZONE]);
    return YES;
}

test(NextDaylightSavingTimeTransition)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];  // no DST in Hawaii
    NSDate *d = [tz nextDaylightSavingTimeTransition];
    testassert(d == nil);
    return YES;
}

test(NextDaylightSavingTimeTransitionAfterDate)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:@"America/Los_Angeles"];
    NSDate *date = makeNSDate(2013, 10, 19);
    NSDate *next = [tz nextDaylightSavingTimeTransitionAfterDate:date];
    testassert([next timeIntervalSince1970] == 1383469200.0);  // 2013-11-03 01:00:00 PST
    
    date = makeNSDate(2013, 12, 19);
    next = [tz nextDaylightSavingTimeTransitionAfterDate:date];
    testassert([next timeIntervalSince1970] == 1394359200.0);  // 2014-03-09 03:00:00 PDT
    
    tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];
    date = makeNSDate(2013, 10, 19);
    next = [tz nextDaylightSavingTimeTransitionAfterDate:date];
    testassert(next == nil);
    
    return YES;
}

test(SecondsFromGMT)
{
    NSTimeZone *tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];  // never in Hawaii
    NSInteger sec = [tz secondsFromGMT];
    testassert(sec == -36000);
    return YES;
}

test(SecondsFromGMTForDate)
{
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:60];
    NSDate *date = makeNSDate(2013, 10, 19);
    NSInteger sec = [tz secondsFromGMTForDate:date];
    testassert(sec == 60);
    
    date = makeNSDate(2013, 12, 19);
    sec = [tz secondsFromGMTForDate:date];
    testassert(sec == 60);

    tz = [[NSTimeZone alloc] initWithName:@"America/Los_Angeles"];
    date = makeNSDate(2013, 10, 19);
    sec = [tz secondsFromGMTForDate:date];
    testassert(sec == -25200);
    
    date = makeNSDate(2013, 12, 19);
    sec = [tz secondsFromGMTForDate:date];
    testassert(sec == -28800);
    
    tz = [[NSTimeZone alloc] initWithName:@"US/Hawaii"];
    date = makeNSDate(2013, 10, 19);
    sec = [tz secondsFromGMTForDate:date];
    testassert(sec == -36000);
    
    return YES;
}

#if 0
//WARNING: mileage will vary depending on where you run this test...change check to your current time zone if it fails
test(GetLocalTimeZoneAbbreviation)
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSString *abbreviation = tz.abbreviation;
    testassert([abbreviation isEqualToString:@"PST"]);
    return YES;
}
#endif

@end
