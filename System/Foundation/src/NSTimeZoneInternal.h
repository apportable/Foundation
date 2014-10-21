#import <Foundation/NSTimeZone.h>
#import "CFInternal.h"

CF_PRIVATE
@interface __NSPlaceholderTimeZone : NSTimeZone

+ (id)immutablePlaceholder;
+ (void)initialize;
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate;
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate;
- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate;
- (NSString *)abbreviationForDate:(NSDate *)aDate;
- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate;
- (NSData *)data;
- (NSString *)name;
- (void)dealloc;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)retain;
- (id)init;
- (id)initWithName:(NSString *)name;
- (id)__initWithName:(NSString *)name cache:(BOOL)shouldCache;
- (id)initWithName:(NSString *)name data:(NSData *)data;
- (id)__initWithName:(NSString *)name data:(NSData *)data cache:(BOOL)shouldCache;

@end

CF_PRIVATE
@interface __NSTimeZone : NSTimeZone

+ (id)allocWithZone:(NSZone *)zone;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(CFStringRef)name cache:(BOOL)shouldCache;
+ (id)__new:(CFStringRef)name data:(CFDataRef)data;
- (void)dealloc;
- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale;
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate;
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate;
- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate;
- (NSString *)abbreviationForDate:(NSDate *)aDate;
- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate;
- (NSData *)data;
- (NSString *)name;

@end
