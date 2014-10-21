#import <Foundation/NSFormatter.h>
#import <CoreFoundation/CFDateFormatter.h>

typedef NS_ENUM(NSUInteger, NSDateFormatterStyle) {
    NSDateFormatterNoStyle     = kCFDateFormatterNoStyle,
    NSDateFormatterShortStyle  = kCFDateFormatterShortStyle,
    NSDateFormatterMediumStyle = kCFDateFormatterMediumStyle,
    NSDateFormatterLongStyle   = kCFDateFormatterLongStyle,
    NSDateFormatterFullStyle   = kCFDateFormatterFullStyle
};

typedef NS_ENUM(NSUInteger, NSDateFormatterBehavior) {
    NSDateFormatterBehaviorDefault = 0,
    NSDateFormatterBehavior10_4    = 1040,
};

@class NSLocale, NSDate, NSCalendar, NSTimeZone, NSError, NSArray, NSMutableDictionary;

@interface NSDateFormatter : NSFormatter

+ (NSString *)localizedStringFromDate:(NSDate *)date dateStyle:(NSDateFormatterStyle)dstyle timeStyle:(NSDateFormatterStyle)tstyle;
+ (NSString *)dateFormatFromTemplate:(NSString *)tmplate options:(NSUInteger)opts locale:(NSLocale *)locale;
+ (NSDateFormatterBehavior)defaultFormatterBehavior;
+ (void)setDefaultFormatterBehavior:(NSDateFormatterBehavior)behavior;

- (id)init;
- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string range:(inout NSRange *)rangep error:(out NSError **)error;
- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)string;
- (NSDateFormatterStyle)dateStyle;
- (void)setDateStyle:(NSDateFormatterStyle)style;
- (NSDateFormatterStyle)timeStyle;
- (void)setTimeStyle:(NSDateFormatterStyle)style;
- (NSLocale *)locale;
- (void)setLocale:(NSLocale *)locale;
- (BOOL)generatesCalendarDates;
- (void)setGeneratesCalendarDates:(BOOL)generate;
- (NSDateFormatterBehavior)formatterBehavior;
- (void)setFormatterBehavior:(NSDateFormatterBehavior)behavior;

// Set and get all CFDate formatter property keys except kCFDateFormatterCalendarName
- (NSString *)dateFormat;
- (void)setDateFormat:(NSString *)string;
- (NSTimeZone *)timeZone;
- (void)setTimeZone:(NSTimeZone *)tz;
- (NSCalendar *)calendar;
- (void)setCalendar:(NSCalendar *)calendar;
- (BOOL)isLenient;
- (void)setLenient:(BOOL)lenient;
- (NSDate *)twoDigitStartDate;
- (void)setTwoDigitStartDate:(NSDate *)date;
- (NSDate *)defaultDate;
- (void)setDefaultDate:(NSDate *)date;
- (NSArray *)eraSymbols;
- (void)setEraSymbols:(NSArray *)symbols;
- (NSArray *)monthSymbols;
- (void)setMonthSymbols:(NSArray *)symbols;
- (NSArray *)shortMonthSymbols;
- (void)setShortMonthSymbols:(NSArray *)symbols;
- (NSArray *)weekdaySymbols;
- (void)setWeekdaySymbols:(NSArray *)symbols;
- (NSArray *)shortWeekdaySymbols;
- (void)setShortWeekdaySymbols:(NSArray *)symbols;
- (NSString *)AMSymbol;
- (void)setAMSymbol:(NSString *)string;
- (NSString *)PMSymbol;
- (void)setPMSymbol:(NSString *)string;
- (NSArray *)longEraSymbols;
- (void)setLongEraSymbols:(NSArray *)array;
- (NSArray *)veryShortMonthSymbols;
- (void)setVeryShortMonthSymbols:(NSArray *)array;
- (NSArray *)standaloneMonthSymbols;
- (void)setStandaloneMonthSymbols:(NSArray *)array;
- (NSArray *)shortStandaloneMonthSymbols;
- (void)setShortStandaloneMonthSymbols:(NSArray *)array;
- (NSArray *)veryShortStandaloneMonthSymbols;
- (void)setVeryShortStandaloneMonthSymbols:(NSArray *)array;
- (NSArray *)veryShortWeekdaySymbols;
- (void)setVeryShortWeekdaySymbols:(NSArray *)array;
- (NSArray *)standaloneWeekdaySymbols;
- (void)setStandaloneWeekdaySymbols:(NSArray *)array;
- (NSArray *)shortStandaloneWeekdaySymbols;
- (void)setShortStandaloneWeekdaySymbols:(NSArray *)array;
- (NSArray *)veryShortStandaloneWeekdaySymbols;
- (void)setVeryShortStandaloneWeekdaySymbols:(NSArray *)array;
- (NSArray *)quarterSymbols;
- (void)setQuarterSymbols:(NSArray *)array;
- (NSArray *)shortQuarterSymbols;
- (void)setShortQuarterSymbols:(NSArray *)array;
- (NSArray *)standaloneQuarterSymbols;
- (void)setStandaloneQuarterSymbols:(NSArray *)array;
- (NSArray *)shortStandaloneQuarterSymbols;
- (void)setShortStandaloneQuarterSymbols:(NSArray *)array;
- (NSDate *)gregorianStartDate;
- (void)setGregorianStartDate:(NSDate *)date;
- (BOOL)doesRelativeDateFormatting;
- (void)setDoesRelativeDateFormatting:(BOOL)b;

@end
