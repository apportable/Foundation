#import <Foundation/NSObject.h>

@class NSArray, NSDate, NSDictionary, NSString, NSURL;

FOUNDATION_EXPORT NSString * const NSHTTPCookieName;
FOUNDATION_EXPORT NSString * const NSHTTPCookieValue;
FOUNDATION_EXPORT NSString * const NSHTTPCookieOriginURL;
FOUNDATION_EXPORT NSString * const NSHTTPCookieVersion;
FOUNDATION_EXPORT NSString * const NSHTTPCookieDomain;
FOUNDATION_EXPORT NSString * const NSHTTPCookiePath;
FOUNDATION_EXPORT NSString * const NSHTTPCookieSecure;
FOUNDATION_EXPORT NSString * const NSHTTPCookieExpires;
FOUNDATION_EXPORT NSString * const NSHTTPCookieComment;
FOUNDATION_EXPORT NSString * const NSHTTPCookieCommentURL;
FOUNDATION_EXPORT NSString * const NSHTTPCookieDiscard;
FOUNDATION_EXPORT NSString * const NSHTTPCookieMaximumAge;
FOUNDATION_EXPORT NSString * const NSHTTPCookiePort;

@interface NSHTTPCookie : NSObject

+ (id)cookieWithProperties:(NSDictionary *)properties;
+ (NSDictionary *)requestHeaderFieldsWithCookies:(NSArray *)cookies;
+ (NSArray *)cookiesWithResponseHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)URL;
- (id)initWithProperties:(NSDictionary *)properties;
- (NSDictionary *)properties;
- (NSUInteger)version;
- (NSString *)name;
- (NSString *)value;
- (NSDate *)expiresDate;
- (BOOL)isSessionOnly;
- (NSString *)domain;
- (NSString *)path;
- (BOOL)isSecure;
- (BOOL)isHTTPOnly;
- (NSString *)comment;
- (NSURL *)commentURL;
- (NSArray *)portList;

@end
