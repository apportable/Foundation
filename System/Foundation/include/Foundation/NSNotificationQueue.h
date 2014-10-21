#import <Foundation/NSObject.h>

@class NSNotification, NSNotificationCenter, NSArray;

typedef NS_ENUM(NSUInteger, NSPostingStyle) {
    NSPostWhenIdle = 1,
    NSPostASAP = 2,
    NSPostNow = 3
};

typedef NS_ENUM(NSUInteger, NSNotificationCoalescing) {
    NSNotificationNoCoalescing = 0,
    NSNotificationCoalescingOnName = 1,
    NSNotificationCoalescingOnSender = 2
};

@interface NSNotificationQueue : NSObject

+ (id)defaultQueue;
- (id)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter;
- (void)enqueueNotification:(NSNotification *)notification postingStyle:(NSPostingStyle)postingStyle;
- (void)enqueueNotification:(NSNotification *)notification postingStyle:(NSPostingStyle)postingStyle coalesceMask:(NSUInteger)coalesceMask forModes:(NSArray *)modes;
- (void)dequeueNotificationsMatching:(NSNotification *)notification coalesceMask:(NSUInteger)coalesceMask;

@end
