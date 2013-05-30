#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSDate.h>
#import <CoreFoundation/CoreFoundation.h>

enum {
  NSUndefinedDateComponent = NSIntegerMax
};

enum {
    NSEraCalendarUnit = kCFCalendarUnitEra,
    NSYearCalendarUnit = kCFCalendarUnitYear,
    NSMonthCalendarUnit = kCFCalendarUnitMonth,
    NSDayCalendarUnit = kCFCalendarUnitDay,
    NSHourCalendarUnit = kCFCalendarUnitHour,
    NSMinuteCalendarUnit = kCFCalendarUnitMinute,
    NSSecondCalendarUnit = kCFCalendarUnitSecond,
    NSWeekCalendarUnit = kCFCalendarUnitWeek,
    NSWeekdayCalendarUnit = kCFCalendarUnitWeekday,
    NSWeekdayOrdinalCalendarUnit = kCFCalendarUnitWeekdayOrdinal,
    NSQuarterCalendarUnit = kCFCalendarUnitQuarter,
    NSWeekOfMonthCalendarUnit = kCFCalendarUnitWeekOfMonth,
    NSWeekOfYearCalendarUnit = kCFCalendarUnitWeekOfYear,
    NSYearForWeekOfYearCalendarUnit = kCFCalendarUnitYearForWeekOfYear,
    NSCalendarCalendarUnit = (1 << 20),
    NSTimeZoneCalendarUnit = (1 << 21),
};
typedef NSUInteger NSCalendarUnit;

enum {
    NSWrapCalendarComponents = (1UL << 0), // option for adding
};

@interface NSDateComponents : NSObject

@property (assign,nonatomic) NSInteger era;
@property (assign,nonatomic) NSInteger year;
@property (assign,nonatomic) NSInteger month;
@property (assign,nonatomic) NSInteger day;
@property (assign,nonatomic) NSInteger hour;
@property (assign,nonatomic) NSInteger minute;
@property (assign,nonatomic) NSInteger second;
@property (assign,nonatomic) NSInteger weekday;
@property (assign,nonatomic) NSInteger weekdayOrdinal;
@property (assign,nonatomic) NSInteger week;

@end

@class NSLocale;

@interface NSCalendar : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) NSString *calendarIdentifier;
@property (nonatomic, retain) NSLocale *locale;
@property (nonatomic, retain) NSTimeZone *timeZone;
@property (nonatomic, assign) NSUInteger firstWeekday;
@property (nonatomic, assign) NSUInteger minimumDaysInFirstWeek;

+ (id)currentCalendar;
+ (id)autoupdatingCurrentCalendar;
- (id)initWithCalendarIdentifier:(NSString *)ident;
- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit NS_UNIMPLEMENTED;
- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit NS_UNIMPLEMENTED;
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date NS_UNIMPLEMENTED;
- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date NS_UNIMPLEMENTED;
- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date NS_UNIMPLEMENTED;
- (NSDate *)dateFromComponents:(NSDateComponents *)comps;
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date;
- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSUInteger)opts;
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSUInteger)opts;

@end


