#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSString, NSArray, NSDictionary, NSDate, NSData, NSLocale;

typedef NS_ENUM(NSInteger, NSTimeZoneNameStyle) {
    NSTimeZoneNameStyleStandard,
    NSTimeZoneNameStyleShortStandard,
    NSTimeZoneNameStyleDaylightSaving,
    NSTimeZoneNameStyleShortDaylightSaving,
    NSTimeZoneNameStyleGeneric,
    NSTimeZoneNameStyleShortGeneric
};

FOUNDATION_EXPORT NSString * const NSSystemTimeZoneDidChangeNotification;

@interface NSTimeZone : NSObject <NSCopying, NSSecureCoding>

- (NSString *)name;
- (NSData *)data;
- (NSInteger)secondsFromGMTForDate:(NSDate *)aDate;
- (NSString *)abbreviationForDate:(NSDate *)aDate;
- (BOOL)isDaylightSavingTimeForDate:(NSDate *)aDate;
- (NSTimeInterval)daylightSavingTimeOffsetForDate:(NSDate *)aDate;
- (NSDate *)nextDaylightSavingTimeTransitionAfterDate:(NSDate *)aDate;

@end

@interface NSTimeZone (NSExtendedTimeZone)

+ (NSTimeZone *)systemTimeZone;
+ (void)resetSystemTimeZone;
+ (NSTimeZone *)defaultTimeZone;
+ (void)setDefaultTimeZone:(NSTimeZone *)aTimeZone;
+ (NSTimeZone *)localTimeZone;
+ (NSArray *)knownTimeZoneNames;
+ (NSDictionary *)abbreviationDictionary;
+ (void)setAbbreviationDictionary:(NSDictionary *)dict;
+ (NSString *)timeZoneDataVersion;
- (NSInteger)secondsFromGMT;
- (NSString *)abbreviation;
- (BOOL)isDaylightSavingTime;
- (NSTimeInterval)daylightSavingTimeOffset;
- (NSDate *)nextDaylightSavingTimeTransition;
- (NSString *)description;
- (BOOL)isEqualToTimeZone:(NSTimeZone *)aTimeZone;
- (NSString *)localizedName:(NSTimeZoneNameStyle)style locale:(NSLocale *)locale;

@end

@interface NSTimeZone (NSTimeZoneCreation)

+ (id)timeZoneWithName:(NSString *)tzName;
+ (id)timeZoneWithName:(NSString *)tzName data:(NSData *)aData;
+ (id)timeZoneForSecondsFromGMT:(NSInteger)seconds;
+ (id)timeZoneWithAbbreviation:(NSString *)abbreviation;
- (id)initWithName:(NSString *)tzName;
- (id)initWithName:(NSString *)tzName data:(NSData *)aData;

@end
