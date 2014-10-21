#import <Foundation/NSObject.h>

@class NSString;

FOUNDATION_EXPORT NSString * const NSSystemClockDidChangeNotification;

typedef double NSTimeInterval;

#define NSTimeIntervalSince1970 978307200.0

@interface NSDate : NSObject <NSCopying, NSSecureCoding>

- (NSTimeInterval)timeIntervalSinceReferenceDate;

@end

@interface NSDate (NSExtendedDate)

+ (NSTimeInterval)timeIntervalSinceReferenceDate;
- (NSTimeInterval)timeIntervalSinceDate:(NSDate *)other;
- (NSTimeInterval)timeIntervalSinceNow;
- (NSTimeInterval)timeIntervalSince1970;
- (id)addTimeInterval:(NSTimeInterval)seconds;
- (id)dateByAddingTimeInterval:(NSTimeInterval)ti;
- (NSDate *)earlierDate:(NSDate *)other;
- (NSDate *)laterDate:(NSDate *)other;
- (NSComparisonResult)compare:(NSDate *)other;
- (BOOL)isEqualToDate:(NSDate *)other;
- (NSString *)description;
- (NSString *)descriptionWithLocale:(id)locale;

@end

@interface NSDate (NSDateCreation)

+ (instancetype)date;
+ (instancetype)dateWithTimeIntervalSinceNow:(NSTimeInterval)ti;

+ (instancetype)dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti;
+ (instancetype)dateWithTimeIntervalSince1970:(NSTimeInterval)ti;
+ (instancetype)dateWithTimeInterval:(NSTimeInterval)ti sinceDate:(NSDate *)date;
+ (id)distantFuture;
+ (id)distantPast;
- (instancetype)init;
- (instancetype)initWithTimeIntervalSinceNow:(NSTimeInterval)ti;
- (instancetype)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti;
- (instancetype)initWithTimeIntervalSince1970:(NSTimeInterval)ti;
- (instancetype)initWithTimeInterval:(NSTimeInterval)ti sinceDate:(NSDate *)other;

@end
