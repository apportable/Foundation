#import <Foundation/NSObject.h>

@class NSString, NSDictionary, NSOperationQueue;

@interface NSNotification : NSObject <NSCopying, NSCoding>

- (NSString *)name;
- (id)object;
- (NSDictionary *)userInfo;

@end

@interface NSNotification (NSNotificationCreation)

+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject;
+ (instancetype)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end

@interface NSNotificationCenter : NSObject

+ (id)defaultCenter;
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;
- (void)postNotification:(NSNotification *)notification;
- (void)postNotificationName:(NSString *)aName object:(id)anObject;
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;
- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;
#if NS_BLOCKS_AVAILABLE
- (id)addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block NS_AVAILABLE(10_6, 4_0);
#endif

@end
