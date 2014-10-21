#import <Foundation/NSObject.h>

@class NSData, NSDictionary, NSError, NSStream, NSInputStream, NSOutputStream, NSRunLoop, NSString, NSURL;

FOUNDATION_EXPORT NSString * const NSStreamSocketSecurityLevelKey;
FOUNDATION_EXPORT NSString * const NSStreamSocketSecurityLevelNone;
FOUNDATION_EXPORT NSString * const NSStreamSocketSecurityLevelSSLv2;
FOUNDATION_EXPORT NSString * const NSStreamSocketSecurityLevelSSLv3;
FOUNDATION_EXPORT NSString * const NSStreamSocketSecurityLevelTLSv1;
FOUNDATION_EXPORT NSString * const NSStreamSocketSecurityLevelNegotiatedSSL;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyConfigurationKey;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyHostKey;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyPortKey;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyVersionKey;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyUserKey;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyPasswordKey;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyVersion4;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSProxyVersion5;
FOUNDATION_EXPORT NSString * const NSStreamDataWrittenToMemoryStreamKey;
FOUNDATION_EXPORT NSString * const NSStreamFileCurrentOffsetKey;
FOUNDATION_EXPORT NSString * const NSStreamSocketSSLErrorDomain;
FOUNDATION_EXPORT NSString * const NSStreamSOCKSErrorDomain;
FOUNDATION_EXPORT NSString * const NSStreamNetworkServiceType;
FOUNDATION_EXPORT NSString * const NSStreamNetworkServiceTypeVoIP;
FOUNDATION_EXPORT NSString * const NSStreamNetworkServiceTypeVideo;
FOUNDATION_EXPORT NSString * const NSStreamNetworkServiceTypeBackground;
FOUNDATION_EXPORT NSString * const NSStreamNetworkServiceTypeVoice;

typedef NS_ENUM(NSUInteger, NSStreamStatus) {
    NSStreamStatusNotOpen = 0,
    NSStreamStatusOpening = 1,
    NSStreamStatusOpen    = 2,
    NSStreamStatusReading = 3,
    NSStreamStatusWriting = 4,
    NSStreamStatusAtEnd   = 5,
    NSStreamStatusClosed  = 6,
    NSStreamStatusError   = 7
};

typedef NS_OPTIONS(NSUInteger, NSStreamEvent) {
    NSStreamEventNone              = 0,
    NSStreamEventOpenCompleted     = 1UL << 0,
    NSStreamEventHasBytesAvailable = 1UL << 1,
    NSStreamEventHasSpaceAvailable = 1UL << 2,
    NSStreamEventErrorOccurred     = 1UL << 3,
    NSStreamEventEndEncountered    = 1UL << 4
};

@protocol NSStreamDelegate <NSObject>
@optional
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
@end

@interface NSStream : NSObject

- (void)open;
- (void)close;
- (id <NSStreamDelegate>)delegate;
- (void)setDelegate:(id <NSStreamDelegate>)delegate;
- (id)propertyForKey:(NSString *)key;
- (BOOL)setProperty:(id)property forKey:(NSString *)key;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (NSStreamStatus)streamStatus;
- (NSError *)streamError;

@end

@interface NSInputStream : NSStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len;
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len;
- (BOOL)hasBytesAvailable;

@end

@interface NSOutputStream : NSStream

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len;
- (BOOL)hasSpaceAvailable;

@end

@interface NSInputStream (NSInputStreamExtensions)

+ (id)inputStreamWithData:(NSData *)data;
+ (id)inputStreamWithFileAtPath:(NSString *)path;
+ (id)inputStreamWithURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (id)initWithFileAtPath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

@end

@interface NSOutputStream (NSOutputStreamExtensions)

+ (id)outputStreamToMemory;
+ (id)outputStreamToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity;
+ (id)outputStreamToFileAtPath:(NSString *)path append:(BOOL)shouldAppend;
+ (id)outputStreamWithURL:(NSURL *)url append:(BOOL)shouldAppend;
- (id)initToMemory;
- (id)initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity;
- (id)initToFileAtPath:(NSString *)path append:(BOOL)shouldAppend;
- (id)initWithURL:(NSURL *)url append:(BOOL)shouldAppend;

@end
