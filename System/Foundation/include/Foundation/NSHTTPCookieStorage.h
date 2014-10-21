#import <Foundation/NSObject.h>

@class NSArray, NSHTTPCookie, NSURL;

typedef NS_ENUM(NSUInteger, NSHTTPCookieAcceptPolicy) {
    NSHTTPCookieAcceptPolicyAlways,
    NSHTTPCookieAcceptPolicyNever,
    NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain
};

FOUNDATION_EXPORT NSString * const NSHTTPCookieManagerAcceptPolicyChangedNotification;
FOUNDATION_EXPORT NSString * const NSHTTPCookieManagerCookiesChangedNotification;

@interface NSHTTPCookieStorage : NSObject

+ (NSHTTPCookieStorage *)sharedHTTPCookieStorage;

- (NSArray *)cookies;
- (void)setCookie:(NSHTTPCookie *)cookie;
- (void)deleteCookie:(NSHTTPCookie *)cookie;
- (NSArray *)cookiesForURL:(NSURL *)URL;
- (void)setCookies:(NSArray *)cookies forURL:(NSURL *)URL mainDocumentURL:(NSURL *)mainDocumentURL;
- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy;
- (void)setCookieAcceptPolicy:(NSHTTPCookieAcceptPolicy)cookieAcceptPolicy;
- (NSArray*)sortedCookiesUsingDescriptors:(NSArray*) sortOrder;

@end
