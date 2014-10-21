#import <Foundation/NSObject.h>

@class NSDate;

@protocol NSLocking

- (void)lock;
- (void)unlock;

@end

@interface NSLock : NSObject <NSLocking>

- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate *)limit;
- (void)setName:(NSString *)n;
- (NSString *)name;

@end

@interface NSConditionLock : NSObject <NSLocking>

- (id)initWithCondition:(NSInteger)condition;
- (NSInteger)condition;
- (void)lockWhenCondition:(NSInteger)condition;
- (BOOL)tryLock;
- (BOOL)tryLockWhenCondition:(NSInteger)condition;
- (void)unlockWithCondition:(NSInteger)condition;
- (BOOL)lockBeforeDate:(NSDate *)limit;
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;
- (void)setName:(NSString *)n;
- (NSString *)name;

@end

@interface NSRecursiveLock : NSObject <NSLocking>

- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate *)limit;
- (void)setName:(NSString *)n;
- (NSString *)name;

@end

@interface NSCondition : NSObject <NSLocking>

- (void)wait;
- (BOOL)waitUntilDate:(NSDate *)limit;
- (void)signal;
- (void)broadcast;
- (void)setName:(NSString *)n;
- (NSString *)name;

@end
