#import <Foundation/NSObject.h>

typedef int NSSocketNativeHandle;

enum {
    NSMachPortDeallocateNone = 0,
    NSMachPortDeallocateSendRight = (1UL << 0),
    NSMachPortDeallocateReceiveRight = (1UL << 1)
};

@class NSRunLoop, NSMutableArray, NSDate, NSConnection, NSPortMessage, NSData;

@protocol NSMachPortDelegate;

@protocol NSPortDelegate <NSObject>
@optional

- (void)handlePortMessage:(NSPortMessage *)message;

@end

@protocol NSMachPortDelegate <NSPortDelegate>
@optional

- (void)handleMachMessage:(void *)msg;

@end

FOUNDATION_EXPORT NSString * const NSPortDidBecomeInvalidNotification;

@interface NSPort : NSObject <NSCopying, NSCoding>

+ (NSPort *)port;
- (void)invalidate;
- (BOOL)isValid;
- (void)setDelegate:(id <NSPortDelegate>)anObject;
- (id <NSPortDelegate>)delegate;
- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (NSUInteger)reservedSpaceLength;
- (BOOL)sendBeforeDate:(NSDate *)limitDate components:(NSMutableArray *)components from:(NSPort *) receivePort reserved:(NSUInteger)headerSpaceReserved;
- (BOOL)sendBeforeDate:(NSDate *)limitDate msgid:(NSUInteger)msgID components:(NSMutableArray *)components from:(NSPort *)receivePort reserved:(NSUInteger)headerSpaceReserved;

@end

NS_AUTOMATED_REFCOUNT_WEAK_UNAVAILABLE

@interface NSMachPort : NSPort

+ (NSPort *)portWithMachPort:(uint32_t)machPort;
+ (NSPort *)portWithMachPort:(uint32_t)machPort options:(NSUInteger)f;
- (id)initWithMachPort:(uint32_t)machPort;  // designated initializer
- (void)setDelegate:(id <NSMachPortDelegate>)anObject;
- (id <NSMachPortDelegate>)delegate;
- (id)initWithMachPort:(uint32_t)machPort options:(NSUInteger)f;
- (uint32_t)machPort;
- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode;

@end

NS_AUTOMATED_REFCOUNT_WEAK_UNAVAILABLE

@interface NSMessagePort : NSPort
@end
