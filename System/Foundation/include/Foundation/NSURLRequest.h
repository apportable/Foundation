#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSData, NSDictionary, NSInputStream, NSString, NSURL;

typedef NS_ENUM(NSUInteger, NSURLRequestCachePolicy) {
    NSURLRequestUseProtocolCachePolicy                = 0,
    NSURLRequestReloadIgnoringLocalCacheData          = 1,
    NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4,
    NSURLRequestReloadIgnoringCacheData               = NSURLRequestReloadIgnoringLocalCacheData,
    NSURLRequestReturnCacheDataElseLoad               = 2,
    NSURLRequestReturnCacheDataDontLoad               = 3,
    NSURLRequestReloadRevalidatingCacheData           = 5,
};

typedef NS_ENUM(NSUInteger, NSURLRequestNetworkServiceType) {
    NSURLNetworkServiceTypeDefault    = 0,
    NSURLNetworkServiceTypeVoIP       = 1,
    NSURLNetworkServiceTypeVideo      = 2,
    NSURLNetworkServiceTypeBackground = 3,
    NSURLNetworkServiceTypeVoice      = 4
};

@interface NSURLRequest : NSObject <NSCoding, NSCopying, NSMutableCopying>

+ (id)requestWithURL:(NSURL *)URL;
+ (id)requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;
- (id)initWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;
- (NSURL *)URL;
- (NSURLRequestCachePolicy)cachePolicy;
- (NSTimeInterval)timeoutInterval;
- (NSURL *)mainDocumentURL;
- (NSURLRequestNetworkServiceType)networkServiceType;
- (BOOL)allowsCellularAccess;

@end

@interface NSMutableURLRequest : NSURLRequest

- (void)setURL:(NSURL *)URL;
- (void)setCachePolicy:(NSURLRequestCachePolicy)policy;
- (void)setTimeoutInterval:(NSTimeInterval)seconds;
- (void)setMainDocumentURL:(NSURL *)URL;
- (void)setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType;
- (void)setAllowsCellularAccess:(BOOL)allow;

@end

@interface NSURLRequest (NSHTTPURLRequest)

- (NSString *)HTTPMethod;
- (NSDictionary *)allHTTPHeaderFields;
- (NSString *)valueForHTTPHeaderField:(NSString *)field;
- (NSData *)HTTPBody;
- (NSInputStream *)HTTPBodyStream;
- (BOOL)HTTPShouldHandleCookies;
- (BOOL)HTTPShouldUsePipelining;

@end

@interface NSMutableURLRequest (NSMutableHTTPURLRequest)

- (void)setHTTPMethod:(NSString *)method;
- (void)setAllHTTPHeaderFields:(NSDictionary *)headerFields;
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;
- (void)setHTTPBody:(NSData *)data;
- (void)setHTTPBodyStream:(NSInputStream *)inputStream;
- (void)setHTTPShouldHandleCookies:(BOOL)should;
- (void)setHTTPShouldUsePipelining:(BOOL)shouldUsePipelining;

@end
