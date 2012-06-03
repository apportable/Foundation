
#import <CoreFoundation/CoreFoundation.h>

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

@interface NSDateComponents : NSObject {
  NSInteger year;
  NSInteger month;
  NSInteger day;
  NSInteger hour;
  NSInteger minute;
  NSInteger second;
}

@property(assign,nonatomic) NSInteger year;
@property(assign,nonatomic) NSInteger month;
@property(assign,nonatomic) NSInteger day;
@property(assign,nonatomic) NSInteger hour;
@property(assign,nonatomic) NSInteger minute;
@property(assign,nonatomic) NSInteger second;

@end

@interface NSCalendar : NSObject
+(id) currentCalendar;
-(NSDateComponents *) components:(NSUInteger)unitFlags fromDate:(NSDate *)date;
@end

