#import <Foundation/NSObject.h>

@class NSDictionary;

@interface NSProgress : NSObject

+ (NSProgress *)currentProgress;
+ (NSProgress *)progressWithTotalUnitCount:(int64_t)unitCount;
- (instancetype)initWithParent:(NSProgress *)parentProgressOrNil userInfo:(NSDictionary *)userInfoOrNil NS_DESIGNATED_INITIALIZER;
- (void)becomeCurrentWithPendingUnitCount:(int64_t)unitCount;
- (void)resignCurrent;

@property int64_t totalUnitCount;
@property int64_t completedUnitCount;
@property (copy) NSString *localizedDescription;
@property (copy) NSString *localizedAdditionalDescription;
@property (getter=isCancellable) BOOL cancellable;
@property (getter=isPausable) BOOL pausable;
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isPaused) BOOL paused;

#if NS_BLOCKS_AVAILABLE
@property (copy) void (^cancellationHandler)(void);
@property (copy) void (^pausingHandler)(void);
#endif

- (void)setUserInfoObject:(id)objectOrNil forKey:(NSString *)key;

@property (readonly, getter=isIndeterminate) BOOL indeterminate;
@property (readonly) double fractionCompleted;

- (void)cancel;
- (void)pause;

@property (readonly, copy) NSDictionary *userInfo;
@property (copy) NSString *kind;

@end

FOUNDATION_EXPORT NSString *const NSProgressEstimatedTimeRemainingKey NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressThroughputKey NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressKindFile NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileOperationKindKey NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileOperationKindDownloading NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileOperationKindDecompressingAfterDownloading NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileOperationKindReceiving NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileOperationKindCopying NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileURLKey NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileTotalCountKey NS_AVAILABLE(10_9, 7_0);
FOUNDATION_EXPORT NSString *const NSProgressFileCompletedCountKey NS_AVAILABLE(10_9, 7_0);
