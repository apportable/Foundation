#import <Foundation/NSTimer.h>
#import "CFInternal.h"

@interface NSTimer (CoreFoundation)
- (CFAbsoluteTime)_cffireTime;
@end

__attribute__((visibility("hidden")))
@interface __NSCFTimer : NSTimer

+ (id)allocWithZone:(NSZone *)zone;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (id)init;
- (id)initWithFireDate:(NSDate *)fireDate interval:(NSTimeInterval)ti target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats;
- (void)fire;
- (id)userInfo;
- (void)setFireDate:(NSDate *)date;
- (NSDate *)fireDate;
- (void)invalidate;
- (NSTimeInterval)timeInterval;
- (BOOL)isValid;
- (unsigned int)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

@end
