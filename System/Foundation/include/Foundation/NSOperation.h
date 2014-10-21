#import <Foundation/NSObject.h>

@class NSArray, NSSet;

typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};

enum {
    NSOperationQueueDefaultMaxConcurrentOperationCount = -1
};

FOUNDATION_EXPORT NSString * const NSInvocationOperationVoidResultException;
FOUNDATION_EXPORT NSString * const NSInvocationOperationCancelledException;

@interface NSOperation : NSObject

- (id)init;
- (void)start;
- (void)main;
- (BOOL)isCancelled;
- (void)cancel;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (BOOL)isConcurrent;
- (BOOL)isReady;
- (void)addDependency:(NSOperation *)op;
- (void)removeDependency:(NSOperation *)op;
- (NSArray *)dependencies;
- (NSOperationQueuePriority)queuePriority;
- (void)setQueuePriority:(NSOperationQueuePriority)p;
#if NS_BLOCKS_AVAILABLE
- (void (^)(void))completionBlock;
- (void)setCompletionBlock:(void (^)(void))block;
#endif
- (void)waitUntilFinished;
- (double)threadPriority;
- (void)setThreadPriority:(double)p;

@end

@interface NSBlockOperation : NSOperation

#if NS_BLOCKS_AVAILABLE
+ (id)blockOperationWithBlock:(void (^)(void))block;
- (void)addExecutionBlock:(void (^)(void))block;
- (NSArray *)executionBlocks;
#endif

@end

@interface NSInvocationOperation : NSOperation

- (id)initWithTarget:(id)target selector:(SEL)sel object:(id)arg;
- (id)initWithInvocation:(NSInvocation *)inv;
- (NSInvocation *)invocation;
- (id)result;

@end

@interface NSOperationQueue : NSObject

+ (id)currentQueue;
+ (id)mainQueue;
- (void)addOperation:(NSOperation *)op;
- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait;
#if NS_BLOCKS_AVAILABLE
- (void)addOperationWithBlock:(void (^)(void))block;
#endif
- (NSArray *)operations;
- (NSUInteger)operationCount;
- (NSInteger)maxConcurrentOperationCount;
- (void)setMaxConcurrentOperationCount:(NSInteger)cnt;
- (void)setSuspended:(BOOL)b;
- (BOOL)isSuspended;
- (void)setName:(NSString *)n;
- (NSString *)name;
- (void)cancelAllOperations;
- (void)waitUntilAllOperationsAreFinished;

@end
