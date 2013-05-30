/** Implementation of NSDateFormatter class
   Copyright (C) 1998 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Created: December 1998

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   <title>NSDateFormatter class reference</title>
   $Date: 2010-11-23 05:20:34 -0800 (Tue, 23 Nov 2010) $ $Revision: 31645 $
 */

#import "common.h"
#define EXPOSE_NSDateFormatter_IVARS    1
#import "Foundation/NSDate.h"
#import "Foundation/NSCalendarDate.h"
#import "Foundation/NSLocale.h"
#import "Foundation/NSTimeZone.h"
#import "Foundation/NSFormatter.h"
#import "Foundation/NSDateFormatter.h"
#import "Foundation/NSCoder.h"
#import "Foundation/NSInvocation.h"

@implementation NSDateFormatter

- (id)init {
    self = [super init];
    if (self) {
        _timezone = nil;
        _locale = nil;
    }
    return self;
}

- (void)setDateStyle:(NSDateFormatterStyle)style
{
    dateStyle_ = style;
}

- (NSDateFormatterStyle)dateStyle
{
    return dateStyle_;
}

- (void)setTimeStyle:(NSDateFormatterStyle)style
{
    timeStyle_ = style;
}

- (NSDateFormatterStyle)timeStyle
{
    return timeStyle_;
}

- (BOOL)allowsNaturalLanguage
{
    return _allowsNaturalLanguage;
}

- (NSAttributedString*)attributedStringForObjectValue:(id)anObject
    withDefaultAttributes:(NSDictionary*)attr
{
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    NSDateFormatter   *other = (id)NSCopyObject(self, 0, zone);

    IF_NO_GC(RETAIN(other->_dateFormat));
    return other;
}

- (NSString*)dateFormat
{
    return _dateFormat;
}

- (void)dealloc
{
    [_timezone release];
    [_locale release];
    [_dateFormat release];
    [super dealloc];
}

- (NSString*)editingStringForObjectValue:(id)anObject
{
    return [self stringForObjectValue:anObject];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeValuesOfObjCTypes:"@C", &_dateFormat, &_allowsNaturalLanguage];
}

- (BOOL)getObjectValue:(id*)anObject
             forString:(NSString*)string
      errorDescription:(NSString**)error
{
    NSCalendarDate    *d;

    if ([string length] == 0)
    {
        d = nil;
    }
    else
    {
        d = [NSCalendarDate dateWithString:string calendarFormat:_dateFormat];
    }
    if (d == nil)
    {
        if (_allowsNaturalLanguage)
        {
            d = [NSCalendarDate dateWithNaturalLanguageString:string];
        }
        if (d == nil)
        {
            if (error)
            {
                *error = @"Couldn't convert to date";
            }
            return NO;
        }
    }
    if (anObject)
    {
        *anObject = d;
    }
    return YES;
}

- (id)initWithCoder:(NSCoder*)aCoder
{
    [aCoder decodeValuesOfObjCTypes:"@C", &_dateFormat, &_allowsNaturalLanguage];
    return self;
}

- (id)initWithDateFormat:(NSString *)format
    allowNaturalLanguage:(BOOL)flag
{
    _dateFormat = [format copy];
    _allowsNaturalLanguage = flag;
    return self;
}

- (BOOL)isPartialStringValid:(NSString*)partialString
    newEditingString:(NSString**)newString
    errorDescription:(NSString**)error
{
    if (newString)
    {
        *newString = nil;
    }
    if (error)
    {
        *error = nil;
    }
    return YES;
}

#include "time.h"

// Convert an NSDate format to a strptime Format.
// Currently only the input characters in yyyy-MM-dd HH:mm:ss are supported as
// format characters
// yyyy-MM-dd HH:mm:ss will be converted to %Y-%m-%d %H:%M:%s

static char *convertFormat(const char *input)
{
    char *returnValue = malloc(strlen(input) * 2); // conservative - the new
                                                   // string should always be
                                                   // smaller than the input
    const char *c = input;
    char *r = returnValue;
    while (*c) {
        switch (*c) {
        case 'Y':
            *r++ = '%';
            *r++ = 'Y';
            while (*++c == 'Y') ;
            break;
        case 'y':
            *r++ = '%';
            *r++ = 'Y';
            while (*++c == 'y') ;
            break;
        case 'M':
            *r++ = '%';
            *r++ = 'm';
            while (*++c == 'M') ;
            break;
        case 'd':
            *r++ = '%';
            *r++ = 'd';
            while (*++c == 'd') ;
            break;
        case 'H':
            *r++ = '%';
            *r++ = 'H';
            while (*++c == 'H') ;
            break;
        case 'h':
            *r++ = '%';
            *r++ = 'I';
            while (*++c == 'h') ;
            break;
        case 'a':
            *r++ = '%';
            *r++ = 'p';
            while (*++c == 'a') ;
            break;
        case 'm':
            *r++ = '%';
            *r++ = 'M';
            while (*++c == 'm') ;
            break;
        case 's':
            *r++ = '%';
            *r++ = 'S';
            while (*++c == 's') ;
            break;
        case '\'':
            // Single-quote escape sequence
            while (*++c != '\'' && *c)
            {
                *r++ = *c;
            }
            if (*c) { c++; }
            break;
        case '+':
            // +0000 ==> %z
            *r++ = '%';
            *r++ = 'z';
            while (*++c == '0') ;
            break;
        default:
            *r++ = *c++;
        }
        *r = '\0';
    }
    return returnValue;
}

- (char *)getFormat
{
    char *fmt = "";
    if (_dateFormat != nil)
    {
        fmt = convertFormat([_dateFormat UTF8String]);
    }
    else
    {
        char *dateFmt = "";
        char *timeFmt = "";
        switch (dateStyle_) {
        case NSDateFormatterNoStyle: dateFmt = ""; break;
        case NSDateFormatterShortStyle: dateFmt = "M/d/yy"; break;
        case NSDateFormatterMediumStyle:
        case NSDateFormatterLongStyle:
        case NSDateFormatterFullStyle:
        default:
            DEBUG_LOG("Date style %d not implemented", dateStyle_);
        }
        switch (timeStyle_) {
        case NSDateFormatterNoStyle: timeFmt = ""; break;
        case NSDateFormatterShortStyle: timeFmt = " h:mm a"; break;
        case NSDateFormatterMediumStyle:
        case NSDateFormatterLongStyle:
        case NSDateFormatterFullStyle:
        default:
            DEBUG_LOG("Time style %d not implemented", timeStyle_);
        }
        char *dateTimeFmt = malloc(strlen(dateFmt) + strlen(timeFmt) + 1);
        strcpy(dateTimeFmt, dateFmt);
        strcat(dateTimeFmt, timeFmt);
        fmt = convertFormat(dateTimeFmt);
        free(dateTimeFmt);
    }
    return fmt;
}

+ (NSString *)dateFormatFromTemplate:(NSString *)template options:(NSUInteger)opts locale:(NSLocale *)locale
{
    DEBUG_LOG("locale formaters not supported");
    return template;
}

- (NSString*)stringForObjectValue:(id)anObject
{
    if ([anObject isKindOfClass:[NSDate class]] == NO)
    {
        return nil;
    }
    char *fmt = [self getFormat];

    NSString *gsFmt = [NSString stringWithUTF8String:fmt];
    NSString *result = [anObject descriptionWithCalendarFormat:gsFmt timeZone:[NSTimeZone defaultTimeZone] locale:nil];
    free(fmt);
    return result;
}


- (NSString *)stringFromDate:(NSDate *)date
{
    return [self stringForObjectValue:date];
}

- (void)setDateFormat:(NSString *)string
{
    _dateFormat = string;
}

- (NSLocale *)locale {
    return _locale;
}

- (void)setLocale:(NSLocale *)locale {
    if (_locale != locale) {
        [_locale autorelease];
        _locale = [locale retain];
    }
    DEBUG_LOG("locales are not supported yet on NSDateFormatter");
}


- (NSTimeZone *)timeZone {
    return _timezone;
}

- (void)setTimeZone:(NSTimeZone *)tz {
    if (_timezone != tz) {
        [_timezone autorelease];
        _timezone = [tz retain];
    }
    DEBUG_LOG("timezone not supported yet on NSDateFormatter");
}


// Convert a string date to epoch seconds - Number of seconds since 1970
// This function will not work on 32bit processors after 2038.
// date should be something like  "2012-06-20 12:05:00"
// The supported format examples is "yyyy-MM-dd HH:mm:ss"
// The return type is time_t which is long on Android

static time_t convertDate(const char *date, char *strptimeFormat)
{
    struct tm stm = {0};
    strptime(date, strptimeFormat, &stm);
    free(strptimeFormat);
    return mktime(&stm);
}

- (NSDate *)dateFromString:(NSString *)date
{
    if (date == NULL)
    {
        return NULL;
    }
    time_t longSecondsSince1970 = convertDate([date UTF8String], [self getFormat]);
    return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)longSecondsSince1970];
}

@end

