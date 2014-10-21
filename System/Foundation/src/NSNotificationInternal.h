#import <Foundation/NSNotification.h>

CF_PRIVATE
@interface NSConcreteNotification : NSNotification
+ (id)newTempNotificationWithName:(NSString *)name object:(id)anObject userInfo:(NSDictionary *)aUserInfo;
- (id)initWithName:(NSString *)name object:(id)anObject userInfo:(NSDictionary *)aUserInfo;
- (void)recycle;
@end
