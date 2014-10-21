//
//  NSDateFormatterTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSDateFormatter)

test(CFDateFormatterLongStyle)
{
    CFDateRef date = CFDateCreate(NULL, 123456);
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    
    CFDateFormatterRef dateFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterLongStyle, kCFDateFormatterLongStyle);
    
    NSString *formattedString = (NSString *)CFDateFormatterCreateStringWithDate(NULL, dateFormatter, date);
    
    testassert([formattedString isEqualToString:@"January 2, 2001 at 2:17:36 AM PST"]);
    
    // Memory management
    CFRelease(date);
    CFRelease(currentLocale);
    CFRelease(dateFormatter);
    CFRelease(formattedString);
    return YES;
}

test(CFDateFormatterNoStyle)
{
    CFDateRef date = CFDateCreate(NULL, 123456);
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    
    CFDateFormatterRef dateFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterShortStyle, kCFDateFormatterNoStyle);
    
    NSString *formattedString = (NSString *)CFDateFormatterCreateStringWithDate(NULL, dateFormatter, date);
    
    testassert([formattedString isEqualToString:@"1/2/01"]);
    
    // Memory management
    CFRelease(date);
    CFRelease(currentLocale);
    CFRelease(dateFormatter);
    CFRelease(formattedString);
    return YES;
}

test(CFDateFormatterComparing)
{
    CFDateRef date = CFDateCreate(NULL, 123456);
    CFStringRef enUSLocaleIdentifier = CFSTR("en_US");
    CFLocaleRef enUSLocale = CFLocaleCreate(NULL, enUSLocaleIdentifier);
    
    // Create different date formatters
    CFDateFormatterRef shortFormatter = CFDateFormatterCreate
    (NULL, enUSLocale, kCFDateFormatterShortStyle, kCFDateFormatterShortStyle);
    CFDateFormatterRef mediumFormatter = CFDateFormatterCreate
    (NULL, enUSLocale, kCFDateFormatterMediumStyle, kCFDateFormatterMediumStyle);
    CFDateFormatterRef longFormatter = CFDateFormatterCreate
    (NULL, enUSLocale, kCFDateFormatterLongStyle, kCFDateFormatterLongStyle);
    CFDateFormatterRef fullFormatter = CFDateFormatterCreate
    (NULL, enUSLocale, kCFDateFormatterFullStyle, kCFDateFormatterFullStyle);
    
    // Create formatted strings
    CFStringRef shortString = CFDateFormatterCreateStringWithDate
    (NULL, shortFormatter, date);
    CFStringRef mediumString = CFDateFormatterCreateStringWithDate
    (NULL, mediumFormatter, date);
    CFStringRef longString = CFDateFormatterCreateStringWithDate
    (NULL, longFormatter, date);
    CFStringRef fullString = CFDateFormatterCreateStringWithDate
    (NULL, fullFormatter, date);
    
    testassert([(NSString *)shortString isEqualToString:@"1/2/01, 2:17 AM"]);
    testassert([(NSString *)mediumString isEqualToString:@"Jan 2, 2001, 2:17:36 AM"]);
    testassert([(NSString *)longString isEqualToString:@"January 2, 2001 at 2:17:36 AM PST"]);
    testassert([(NSString *)fullString isEqualToString:@"Tuesday, January 2, 2001 at 2:17:36 AM Pacific Standard Time"]);
    
    // Memory management
    CFRelease(date);
    CFRelease(enUSLocale);
    CFRelease(shortFormatter);
    CFRelease(mediumFormatter);
    CFRelease(longFormatter);
    CFRelease(fullFormatter);
    CFRelease(shortString);
    CFRelease(mediumString);
    CFRelease(longString);
    CFRelease(fullString);
    
    return YES;
}

test(CFDateFixedFormats)
{
    CFLocaleRef currentLocale = CFLocaleCopyCurrent();
    CFDateRef date = CFDateCreate(NULL, 123456);
    
    CFDateFormatterRef customDateFormatter = CFDateFormatterCreate
    (NULL, currentLocale, kCFDateFormatterNoStyle, kCFDateFormatterNoStyle);
    CFStringRef customDateFormat = CFSTR("yyyy-MM-dd*HH:mm");
    CFDateFormatterSetFormat(customDateFormatter, customDateFormat);
    
    CFStringRef customFormattedDateString = CFDateFormatterCreateStringWithDate(NULL, customDateFormatter, date);
    testassert([(NSString *)customFormattedDateString isEqualToString:@"2001-01-02*02:17"]);
    
    // Memory management
    CFRelease(currentLocale);
    CFRelease(date);
    CFRelease(customDateFormatter);
    CFRelease(customFormattedDateString);
    return YES;
}

test(NSDateFormatterShortStyle)
{
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormat stringFromDate:today];  // 9/11/13
    testassert([dateString length] >= 6 && [dateString length] <=8);
    return YES;
}


test(NSDateFormatterLongerStyle)
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mma"];
    NSString *dateString = [dateFormat stringFromDate:today];   // 09/11/2013 03:02PM
    testassert([dateString length] == strlen("09/11/2013 03:02PM"));
    [dateFormat release];
    return YES;
}

test(NSDateFormatterLongerStyle2)
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    NSString *dateString = [dateFormat stringFromDate:today];  // Wednesday September 11, 2013
    testassert([dateString characterAtIndex:([dateString length] - 4)] == '2'); // this test will fail in the year 3000
    [dateFormat release];
    return YES;
}

test(NSDateFormatterTime)
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a, zzz"];
    NSString *dateString = [dateFormat stringFromDate:today]; // 3:11 PM, PDT
    testassert([dateString characterAtIndex:([dateString length] - 4)] == ' ');
    [dateFormat release];
    return YES;
}

test(NSDateFormatterConvert)
{
    NSString *dateStr = @"20130912";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    dateStr = [dateFormat stringFromDate:date];
    [dateFormat release];
    testassert([dateStr isEqualToString:@"Thursday September 12, 2013"]);
    return YES;
}


@end
