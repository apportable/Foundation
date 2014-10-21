#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

typedef NS_ENUM(NSInteger, NSNetServicesError) {
    NSNetServicesUnknownError = -72000L,
    NSNetServicesCollisionError = -72001L,
    NSNetServicesNotFoundError  = -72002L,
    NSNetServicesActivityInProgress = -72003L,
    NSNetServicesBadArgumentError = -72004L,
    NSNetServicesCancelledError = -72005L,
    NSNetServicesInvalidError = -72006L,
    NSNetServicesTimeoutError = -72007L,

};

typedef NS_OPTIONS(NSUInteger, NSNetServiceOptions) {
    NSNetServiceNoAutoRename = 1UL << 0
};

@class NSArray, NSData, NSDictionary, NSInputStream, NSOutputStream, NSRunLoop, NSString;
@class NSNetService, NSNetServiceBrowser;

FOUNDATION_EXPORT NSString * const NSNetServicesErrorCode;
FOUNDATION_EXPORT NSString * const NSNetServicesErrorDomain;

@protocol NSNetServiceDelegate <NSObject>
@optional

- (void)netServiceWillPublish:(NSNetService *)sender;
- (void)netServiceDidPublish:(NSNetService *)sender;
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
- (void)netServiceWillResolve:(NSNetService *)sender;
- (void)netServiceDidResolveAddress:(NSNetService *)sender;
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceDidStop:(NSNetService *)sender;
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data;

@end

@protocol NSNetServiceBrowserDelegate <NSObject>
@optional

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser;
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;

@end

@interface NSNetService : NSObject

+ (NSDictionary *)dictionaryFromTXTRecordData:(NSData *)txtData;
+ (NSData *)dataFromTXTRecordDictionary:(NSDictionary *)txtDictionary;
- (id)initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name port:(int)port;
- (id)initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name;
- (id <NSNetServiceDelegate>)delegate;
- (void)setDelegate:(id <NSNetServiceDelegate>)delegate;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (NSString *)domain;
- (NSString *)type;
- (NSString *)name;
- (NSArray *)addresses;
- (NSInteger)port;
- (void)publish;
- (void)publishWithOptions:(NSNetServiceOptions)options;
- (void)resolve;
- (void)stop;
- (NSString *)hostName;
- (void)resolveWithTimeout:(NSTimeInterval)timeout;
- (BOOL)getInputStream:(out __strong NSInputStream **)inputStream outputStream:(out __strong NSOutputStream **)outputStream;
- (BOOL)setTXTRecordData:(NSData *)recordData;
- (NSData *)TXTRecordData;
- (void)startMonitoring;
- (void)stopMonitoring;

@end

@interface NSNetServiceBrowser : NSObject

- (id)init;
- (id <NSNetServiceBrowserDelegate>)delegate;
- (void)setDelegate:(id <NSNetServiceBrowserDelegate>)delegate;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)searchForBrowsableDomains;
- (void)searchForRegistrationDomains;
- (void)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domainString;
- (void)stop;

@end
