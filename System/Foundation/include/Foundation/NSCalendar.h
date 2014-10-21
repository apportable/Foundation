#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSDate.h>
#import <CoreFoundation/CFCalendar.h>

@class NSDateComponents, NSLocale, NSTimeZone, NSString;

typedef NS_OPTIONS(NSUInteger, NSCalendarUnit) {
    NSCalendarUnitEra               = kCFCalendarUnitEra,
    NSCalendarUnitYear              = kCFCalendarUnitYear,
    NSCalendarUnitMonth             = kCFCalendarUnitMonth,
    NSCalendarUnitDay               = kCFCalendarUnitDay,
    NSCalendarUnitHour              = kCFCalendarUnitHour,
    NSCalendarUnitMinute            = kCFCalendarUnitMinute,
    NSCalendarUnitSecond            = kCFCalendarUnitSecond,
    NSCalendarUnitWeekday           = kCFCalendarUnitWeekday,
    NSCalendarUnitWeekdayOrdinal    = kCFCalendarUnitWeekdayOrdinal,
    NSCalendarUnitQuarter           = kCFCalendarUnitQuarter,
    NSCalendarUnitWeekOfMonth       = kCFCalendarUnitWeekOfMonth,
    NSCalendarUnitWeekOfYear        = kCFCalendarUnitWeekOfYear,
    NSCalendarUnitYearForWeekOfYear = kCFCalendarUnitYearForWeekOfYear,
    NSCalendarUnitNanosecond        = (1 << 15),
    NSCalendarUnitCalendar          = (1 << 20),
    NSCalendarUnitTimeZone          = (1 << 21),

    NSEraCalendarUnit               = NSCalendarUnitEra,
    NSYearCalendarUnit              = NSCalendarUnitYear,
    NSMonthCalendarUnit             = NSCalendarUnitMonth,
    NSDayCalendarUnit               = NSCalendarUnitDay,
    NSHourCalendarUnit              = NSCalendarUnitHour,
    NSMinuteCalendarUnit            = NSCalendarUnitMinute,
    NSSecondCalendarUnit            = NSCalendarUnitSecond,
    NSWeekCalendarUnit              = kCFCalendarUnitWeek,
    NSWeekdayCalendarUnit           = NSCalendarUnitWeekday,
    NSWeekdayOrdinalCalendarUnit    = NSCalendarUnitWeekdayOrdinal,
    NSQuarterCalendarUnit           = NSCalendarUnitQuarter,
    NSWeekOfMonthCalendarUnit       = NSCalendarUnitWeekOfMonth,
    NSWeekOfYearCalendarUnit        = NSCalendarUnitWeekOfYear,
    NSYearForWeekOfYearCalendarUnit = NSCalendarUnitYearForWeekOfYear,
    NSCalendarCalendarUnit          = NSCalendarUnitCalendar,
    NSTimeZoneCalendarUnit          = NSCalendarUnitTimeZone,
};

enum {
    NSWrapCalendarComponents = kCFCalendarComponentsWrap,
};

enum {
    NSUndefinedDateComponent = NSIntegerMax
};

@interface NSCalendar : NSObject <NSCopying, NSSecureCoding>

+ (id)currentCalendar;
+ (id)autoupdatingCurrentCalendar;

- (id)initWithCalendarIdentifier:(NSString *)ident;
- (NSString *)calendarIdentifier;
- (void)setLocale:(NSLocale *)locale;
- (NSLocale *)locale;
- (void)setTimeZone:(NSTimeZone *)tz;
- (NSTimeZone *)timeZone;
- (void)setFirstWeekday:(NSUInteger)weekday;
- (NSUInteger)firstWeekday;
- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw;
- (NSUInteger)minimumDaysInFirstWeek;
- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit;
- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit;
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date;
- (NSDate *)dateFromComponents:(NSDateComponents *)comps;
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date;
- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSUInteger)opts;
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSUInteger)opts;

@end

@interface NSDateComponents : NSObject <NSCopying, NSSecureCoding>

- (NSCalendar *)calendar;
- (NSTimeZone *)timeZone;
- (NSInteger)era;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (NSInteger)week;
- (NSInteger)weekday;
- (NSInteger)weekdayOrdinal;
- (NSInteger)quarter;
- (NSInteger)weekOfMonth;
- (NSInteger)weekOfYear;
- (NSInteger)yearForWeekOfYear;
- (BOOL)isLeapMonth;
- (void)setCalendar:(NSCalendar *)cal;
- (void)setTimeZone:(NSTimeZone *)tz;
- (void)setEra:(NSInteger)era;
- (void)setYear:(NSInteger)year;
- (void)setMonth:(NSInteger)month;
- (void)setDay:(NSInteger)day;
- (void)setHour:(NSInteger)hour;
- (void)setMinute:(NSInteger)min;
- (void)setSecond:(NSInteger)sec;
- (void)setWeek:(NSInteger)week;
- (void)setWeekday:(NSInteger)weekday;
- (void)setWeekdayOrdinal:(NSInteger)ordinal;
- (void)setQuarter:(NSInteger)quarter;
- (void)setWeekOfMonth:(NSInteger)week;
- (void)setWeekOfYear:(NSInteger)week;
- (void)setYearForWeekOfYear:(NSInteger)year;
- (void)setLeapMonth:(BOOL)leapMonth;
- (NSDate *)date;

@end
