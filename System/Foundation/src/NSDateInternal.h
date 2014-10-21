#import <Foundation/NSDate.h>
#import "CFInternal.h"

__attribute__((visibility("hidden")))
@interface __NSDate : NSDate

+ (id)allocWithZone:(NSZone *)zone;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(NSTimeInterval)t;
- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)t;
- (void)dealloc;
- (NSTimeInterval)timeIntervalSinceReferenceDate;

@end

__attribute__((visibility("hidden")))
@interface __NSPlaceholderDate : NSDate

+ (id)immutablePlaceholder;
+ (void)initialize;
- (NSTimeInterval)timeIntervalSinceReferenceDate;
- (void)dealloc;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)retain;
- (id)init;
- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)date;

@end

@interface NSCalendarDate : NSDate
@end
