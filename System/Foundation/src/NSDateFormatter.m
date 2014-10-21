//
//  NSDateFormatter.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSDateFormatter.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSTimeZone.h>
#import <Foundation/NSCalendar.h>
#import <Foundation/NSLocale.h>

@implementation NSDateFormatter
{
    NSMutableDictionary *_attributes;
    struct __CFDateFormatter *_formatter;
}

+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    // TODO: localizedStringFromDate does not localize
    NSString* ret;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    ret = [formatter stringFromDate:date];
    [formatter release];
    return ret;
}

+ (NSString *)dateFormatFromTemplate:(NSString *)tmplate options:(NSUInteger)opts locale:(NSLocale *)locale
{
    return [(NSString *)CFDateFormatterCreateDateFormatFromTemplate(kCFAllocatorDefault, (CFStringRef)tmplate, opts, (CFLocaleRef)locale) autorelease];
}

static NSDateFormatterBehavior defaultBehavior = NSDateFormatterBehaviorDefault;

+ (NSDateFormatterBehavior)defaultFormatterBehavior
{
    return defaultBehavior;
}

+ (void)setDefaultFormatterBehavior:(NSDateFormatterBehavior)behavior
{
    defaultBehavior = behavior;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _attributes = [[NSMutableDictionary alloc] init];
        [self setFormatterBehavior:NSDateFormatterBehavior10_4];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter->_attributes release];
    formatter->_attributes = [_attributes copy];
    return formatter;
}

- (void)dealloc
{
    [self _clearFormatter];
    [_attributes release];
    [super dealloc];
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error
{
    NSError *err = nil;
    NSRange r;
    BOOL success = [self getObjectValue:obj forString:string range:&r error:&err];
    if (error != NULL)
    {
        *error= [err localizedDescription];
    }
    return success;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    [self _regenerateFormatter];
    return [(NSString *)CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, _formatter, (CFDateRef)date) autorelease];
}

- (NSDate *)dateFromString:(NSString *)string
{
    [self _regenerateFormatter];
    return [(NSDate *)CFDateFormatterCreateDateFromString(kCFAllocatorDefault, _formatter, (CFStringRef)string, NULL) autorelease];
}

- (NSDateFormatterStyle)dateStyle
{
    [self _regenerateFormatter];
    return (NSDateFormatterStyle)CFDateFormatterGetDateStyle(_formatter);
}

- (void)setDateStyle:(NSDateFormatterStyle)style
{
    _attributes[@"dateStyle"] = @(style);
    [self _reset];
}

- (NSDateFormatterStyle)timeStyle
{
    [self _regenerateFormatter];
    return (NSDateFormatterStyle)CFDateFormatterGetTimeStyle(_formatter);
}

- (void)setTimeStyle:(NSDateFormatterStyle)style
{
    _attributes[@"timeStyle"] = @(style);
    [self _reset];
}

- (NSString *)dateFormat
{
    return _attributes[@"dateFormat"];
}

- (void)setDateFormat:(NSString *)string
{
    _attributes[@"dateFormat"] = string;
    [self _reset];
}

- (NSLocale *)locale
{
    [self _regenerateFormatter];
    return (NSLocale *)CFDateFormatterGetLocale(_formatter);
}

- (void)setLocale:(NSLocale *)locale
{
    _attributes[@"locale"] = locale;
    [self _reset];
}

- (BOOL)generatesCalendarDates
{
    return [_attributes[@"generatesCalendarDates"] boolValue];
}

- (void)setGeneratesCalendarDates:(BOOL)generate
{
    _attributes[@"generatesCalendarDates"] = @(generate);
}

- (void)_reset
{
    [self _clearFormatter];
    [self _regenerateFormatter];
}

- (void)_regenerateFormatter
{
    if (_formatter != NULL)
    {
        return;
    }
    // NOTE: _attributes stores both the creation/parameters AND properties, so a simple iterator wont work
    _formatter = CFDateFormatterCreate(kCFAllocatorDefault, (CFLocaleRef)(_attributes[@"locale"] ?: [NSLocale currentLocale]), [_attributes[@"dateStyle"] intValue], [_attributes[@"timeStyle"] intValue]);

    if (_formatter == nil)
    {
        DEBUG_LOG("Date Formatter creation failed.  Are ICU tables built in?");
        return;
    }

    if (_attributes[@"dateFormat"])
    {
        CFDateFormatterSetFormat(_formatter, (CFStringRef)_attributes[@"dateFormat"]);
    }

    if (_attributes[(id)kCFDateFormatterIsLenient])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterIsLenient, (CFTypeRef)_attributes[(id)kCFDateFormatterIsLenient]);
    }
    if (_attributes[(id)kCFDateFormatterTimeZone])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterTimeZone, (CFTypeRef)_attributes[(id)kCFDateFormatterTimeZone ]);
    }
    if (_attributes[(id)kCFDateFormatterCalendarName])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterCalendarName, (CFTypeRef)_attributes[(id) kCFDateFormatterCalendarName]);
    }
    if (_attributes[(id)kCFDateFormatterDefaultFormat])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterDefaultFormat, (CFTypeRef)_attributes[(id)kCFDateFormatterDefaultFormat]);
    }
    if (_attributes[(id)kCFDateFormatterTwoDigitStartDate])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterTwoDigitStartDate, (CFTypeRef)_attributes[(id)kCFDateFormatterTwoDigitStartDate]);
    }
    if (_attributes[(id)kCFDateFormatterDefaultDate])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterDefaultDate, (CFTypeRef)_attributes[(id)kCFDateFormatterDefaultDate ]);
    }
    if (_attributes[(id)kCFDateFormatterCalendar])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterCalendar, (CFTypeRef)_attributes[(id)kCFDateFormatterCalendar]);
    }
    if (_attributes[(id)kCFDateFormatterEraSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterEraSymbols, (CFTypeRef)_attributes[(id)kCFDateFormatterEraSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterMonthSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterMonthSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterMonthSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterShortMonthSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterShortMonthSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterShortMonthSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterWeekdaySymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterWeekdaySymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterWeekdaySymbols]);
    }
    if (_attributes[(id)kCFDateFormatterShortWeekdaySymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterShortWeekdaySymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterShortWeekdaySymbols]);
    }
    if (_attributes[(id)kCFDateFormatterAMSymbol])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterAMSymbol, (CFTypeRef)_attributes[(id)kCFDateFormatterAMSymbol ]);
    }
    if (_attributes[(id)kCFDateFormatterPMSymbol])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterPMSymbol, (CFTypeRef)_attributes[(id) kCFDateFormatterPMSymbol]);
    }
    if (_attributes[(id)kCFDateFormatterLongEraSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterLongEraSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterLongEraSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterVeryShortMonthSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterVeryShortMonthSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterVeryShortMonthSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterStandaloneMonthSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterStandaloneMonthSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterStandaloneMonthSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterShortStandaloneMonthSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterShortStandaloneMonthSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterShortStandaloneMonthSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterVeryShortStandaloneMonthSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterVeryShortStandaloneMonthSymbols, (CFTypeRef)_attributes[(id)kCFDateFormatterVeryShortStandaloneMonthSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterVeryShortWeekdaySymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterVeryShortStandaloneMonthSymbols, (CFTypeRef)_attributes[(id)kCFDateFormatterVeryShortStandaloneMonthSymbols ]);
    }
    if (_attributes[(id)kCFDateFormatterStandaloneWeekdaySymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterStandaloneWeekdaySymbols, (CFTypeRef)_attributes[(id)kCFDateFormatterStandaloneWeekdaySymbols ]);
    }
    if (_attributes[(id)kCFDateFormatterShortStandaloneWeekdaySymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterShortStandaloneWeekdaySymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterShortStandaloneWeekdaySymbols]);
    }
    if (_attributes[(id)kCFDateFormatterVeryShortStandaloneWeekdaySymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterVeryShortStandaloneWeekdaySymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterVeryShortStandaloneWeekdaySymbols]);
    }
    if (_attributes[(id)kCFDateFormatterQuarterSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterQuarterSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterQuarterSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterShortQuarterSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterShortQuarterSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterShortQuarterSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterStandaloneQuarterSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterStandaloneQuarterSymbols, (CFTypeRef)_attributes[(id) kCFDateFormatterStandaloneQuarterSymbols]);
    }
    if (_attributes[(id)kCFDateFormatterShortStandaloneQuarterSymbols])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterShortStandaloneQuarterSymbols, (CFTypeRef)_attributes[(id)kCFDateFormatterShortStandaloneQuarterSymbols ]);
    }
    if (_attributes[(id)kCFDateFormatterGregorianStartDate])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterGregorianStartDate, (CFTypeRef)_attributes[(id) kCFDateFormatterGregorianStartDate]);
    }
    if (_attributes[(id)kCFDateFormatterDoesRelativeDateFormattingKey])
    {
        CFDateFormatterSetProperty(_formatter, kCFDateFormatterDoesRelativeDateFormattingKey, (CFTypeRef)_attributes[(id) kCFDateFormatterDoesRelativeDateFormattingKey]);
    }
}

- (void)_clearFormatter
{
    if (_formatter != NULL)
    {
        CFRelease(_formatter);
        _formatter = NULL;
    }
}

#define GET_BOOL(prop) ({ \
    if (_formatter == NULL) { \
        [self _reset]; \
    } \
    [[(NSNumber *)CFDateFormatterCopyProperty(_formatter, prop) autorelease] boolValue]; \
});

#define SET_BOOL(prop, val) \
_attributes[(id)prop] = @(val); \
if (_formatter != NULL) { \
    CFDateFormatterSetProperty(_formatter, prop, (CFTypeRef)@(val)); \
}

#define GET_ID(prop) ({ \
    if (_formatter == NULL) { \
        [self _reset]; \
    } \
    [(id)CFDateFormatterCopyProperty(_formatter, prop) autorelease]; \
})

#define SET_ID(prop, val) \
_attributes[(id)prop] = val; \
if (_formatter != NULL) { \
    CFDateFormatterSetProperty(_formatter, prop, (CFTypeRef)val); \
}

- (NSTimeZone *)timeZone
{
    return GET_ID(kCFDateFormatterTimeZone);
}

- (void)setTimeZone:(NSTimeZone *)tz
{
    SET_ID(kCFDateFormatterTimeZone, tz);
}

- (NSCalendar *)calendar
{
    return GET_ID(kCFDateFormatterCalendar);
}

- (void)setCalendar:(NSCalendar *)calendar
{
    SET_ID(kCFDateFormatterCalendar, calendar);
}

- (BOOL)isLenient
{
    return GET_BOOL(kCFDateFormatterIsLenient);
}

- (void)setLenient:(BOOL)lenient
{
    SET_BOOL(kCFDateFormatterIsLenient, lenient);
}

- (NSDate *)twoDigitStartDate
{
    return GET_ID(kCFDateFormatterTwoDigitStartDate);
}

- (void)setTwoDigitStartDate:(NSDate *)date
{
    SET_ID(kCFDateFormatterTwoDigitStartDate, date);
}

- (NSDate *)defaultDate
{
    return GET_ID(kCFDateFormatterDefaultDate);
}

- (void)setDefaultDate:(NSDate *)date
{
    SET_ID(kCFDateFormatterDefaultDate, date);
}

- (NSArray *)eraSymbols
{
    return GET_ID(kCFDateFormatterEraSymbols);
}

- (void)setEraSymbols:(NSArray *)symbols
{
    SET_ID(kCFDateFormatterEraSymbols, symbols);
}

- (NSArray *)monthSymbols
{
    return GET_ID(kCFDateFormatterMonthSymbols);
}

- (void)setMonthSymbols:(NSArray *)symbols
{
    SET_ID(kCFDateFormatterMonthSymbols, symbols);
}

- (NSArray *)shortMonthSymbols
{
    return GET_ID(kCFDateFormatterShortMonthSymbols);
}

- (void)setShortMonthSymbols:(NSArray *)symbols
{
    SET_ID(kCFDateFormatterShortMonthSymbols, symbols);
}

- (NSArray *)weekdaySymbols
{
    return GET_ID(kCFDateFormatterWeekdaySymbols);
}

- (void)setWeekdaySymbols:(NSArray *)symbols
{
    SET_ID(kCFDateFormatterWeekdaySymbols, symbols);
}

- (NSArray *)shortWeekdaySymbols
{
    return GET_ID(kCFDateFormatterShortWeekdaySymbols);
}

- (void)setShortWeekdaySymbols:(NSArray *)symbols
{
    SET_ID(kCFDateFormatterShortWeekdaySymbols, symbols);
}

- (NSString *)AMSymbol
{
    return GET_ID(kCFDateFormatterAMSymbol);
}

- (void)setAMSymbol:(NSString *)string
{
    SET_ID(kCFDateFormatterAMSymbol, string);
}

- (NSString *)PMSymbol
{
    return GET_ID(kCFDateFormatterPMSymbol);
}

- (void)setPMSymbol:(NSString *)string
{
    SET_ID(kCFDateFormatterPMSymbol, string);
}

- (NSArray *)longEraSymbols
{
    return GET_ID(kCFDateFormatterLongEraSymbols);
}

- (void)setLongEraSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterLongEraSymbols, array);
}

- (NSArray *)veryShortMonthSymbols
{
    return GET_ID(kCFDateFormatterVeryShortMonthSymbols);
}

- (void)setVeryShortMonthSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterVeryShortMonthSymbols, array);
}

- (NSArray *)standaloneMonthSymbols
{
    return GET_ID(kCFDateFormatterStandaloneMonthSymbols);
}

- (void)setStandaloneMonthSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterStandaloneMonthSymbols, array);
}

- (NSArray *)shortStandaloneMonthSymbols
{
    return GET_ID(kCFDateFormatterShortStandaloneMonthSymbols);
}

- (void)setShortStandaloneMonthSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterShortStandaloneMonthSymbols, array);
}

- (NSArray *)veryShortStandaloneMonthSymbols
{
    return GET_ID(kCFDateFormatterVeryShortStandaloneMonthSymbols);
}

- (void)setVeryShortStandaloneMonthSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterVeryShortStandaloneMonthSymbols, array);
}

- (NSArray *)veryShortWeekdaySymbols
{
    return GET_ID(kCFDateFormatterVeryShortWeekdaySymbols);
}

- (void)setVeryShortWeekdaySymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterVeryShortWeekdaySymbols, array);
}

- (NSArray *)standaloneWeekdaySymbols
{
    return GET_ID(kCFDateFormatterStandaloneWeekdaySymbols);
}

- (void)setStandaloneWeekdaySymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterStandaloneWeekdaySymbols, array);
}

- (NSArray *)shortStandaloneWeekdaySymbols
{
    return GET_ID(kCFDateFormatterShortStandaloneWeekdaySymbols);
}

- (void)setShortStandaloneWeekdaySymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterShortStandaloneWeekdaySymbols, array);
}

- (NSArray *)veryShortStandaloneWeekdaySymbols
{
    return GET_ID(kCFDateFormatterVeryShortStandaloneWeekdaySymbols);
}

- (void)setVeryShortStandaloneWeekdaySymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterVeryShortStandaloneWeekdaySymbols, array);
}

- (NSArray *)quarterSymbols
{
    return GET_ID(kCFDateFormatterQuarterSymbols);
}

- (void)setQuarterSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterQuarterSymbols, array);
}

- (NSArray *)shortQuarterSymbols
{
    return GET_ID(kCFDateFormatterShortQuarterSymbols);
}

- (void)setShortQuarterSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterShortQuarterSymbols, array);
}

- (NSArray *)standaloneQuarterSymbols
{
    return GET_ID(kCFDateFormatterStandaloneQuarterSymbols);
}

- (void)setStandaloneQuarterSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterStandaloneQuarterSymbols, array);
}

- (NSArray *)shortStandaloneQuarterSymbols
{
    return GET_ID(kCFDateFormatterShortStandaloneQuarterSymbols);
}

- (void)setShortStandaloneQuarterSymbols:(NSArray *)array
{
    SET_ID(kCFDateFormatterShortStandaloneQuarterSymbols, array);
}

- (NSDate *)gregorianStartDate
{
    return GET_ID(kCFDateFormatterGregorianStartDate);
}

- (void)setGregorianStartDate:(NSDate *)date
{
    SET_ID(kCFDateFormatterGregorianStartDate, date);
}

- (BOOL)doesRelativeDateFormatting
{
    return GET_BOOL(kCFDateFormatterDoesRelativeDateFormattingKey);
}

- (void)setDoesRelativeDateFormatting:(BOOL)b
{
    SET_BOOL(kCFDateFormatterDoesRelativeDateFormattingKey, b);
}

- (NSDateFormatterBehavior)formatterBehavior
{
    return [_attributes[@"formatterBehavior"] intValue];
}

- (void)setFormatterBehavior:(NSDateFormatterBehavior)behavior
{
    _attributes[@"formatterBehavior"] = @(behavior);
}

@end
