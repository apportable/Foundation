#import <Foundation/NSCalendar.h>
#import "ForFoundationOnly.h"

CF_PRIVATE
@interface __NSCFCalendar : NSCalendar

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)startingDate toDate:(NSDate *)resultDate options:(NSUInteger)opts;
- (NSDate *)dateByAddingComponents:(NSDateComponents *)comps toDate:(NSDate *)date options:(NSUInteger)opts;
- (NSDateComponents *)components:(NSUInteger)unitFlags fromDate:(NSDate *)date;
- (NSDate *)dateFromComponents:(NSDateComponents *)comps;
- (BOOL)rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)datep interval:(NSTimeInterval *)tip forDate:(NSDate *)date;
- (NSUInteger)ordinalityOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date;
- (NSRange)minimumRangeOfUnit:(NSCalendarUnit)unit;
- (NSRange)maximumRangeOfUnit:(NSCalendarUnit)unit;
- (NSDate *)gregorianStartDate;
- (void)setGregorianStartDate:(NSDate *)date;
- (void)setMinimumDaysInFirstWeek:(NSUInteger)mdw;
- (NSUInteger)minimumDaysInFirstWeek;
- (void)setFirstWeekday:(NSUInteger)weekday;
- (NSUInteger)firstWeekday;
- (void)setTimeZone:(NSTimeZone *)tz;
- (NSTimeZone *)timeZone;
- (void)setLocale:(NSLocale *)locale;
- (NSLocale *)locale;
- (id)initWithCalendarIdentifier:(NSString *)ident;
- (NSString *)calendarIdentifier;
- (id)copyWithZone:(NSZone *)zone;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

@end

@class NSNotification;

CF_PRIVATE
@interface NSAutoCalendar : NSCalendar

- (id)init;
- (id)initWithCalendarIdentifier:(NSString *)ident;
- (void)dealloc;
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
- (void)_update:(NSNotification *)notif;

@end

@interface NSDateComponents (Internal)

- (NSInteger)nanosecond;
- (void)setNanosecond:(NSInteger)nsec;

@end

Boolean _CFCalendarComposeAbsoluteTimeV(CFCalendarRef calendar, /* out */ CFAbsoluteTime *atp, const char *componentDesc, int *vector, int count);
Boolean _CFCalendarAddComponentsV(CFCalendarRef calendar, /* inout */ CFAbsoluteTime *atp, CFOptionFlags options, const char *componentDesc, int *vector, int count);
