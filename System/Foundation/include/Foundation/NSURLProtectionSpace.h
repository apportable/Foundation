#import <Foundation/NSObject.h>
#import <Security/Security.h>

@class NSString, NSArray;

FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceHTTP;
FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceHTTPS;
FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceFTP;
FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceHTTPProxy;
FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceHTTPSProxy;
FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceFTPProxy;
FOUNDATION_EXPORT NSString * const NSURLProtectionSpaceSOCKSProxy;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodDefault;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodHTTPBasic;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodHTTPDigest;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodHTMLForm;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodNTLM;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodNegotiate;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodClientCertificate;
FOUNDATION_EXPORT NSString * const NSURLAuthenticationMethodServerTrust;

@interface NSURLProtectionSpace : NSObject <NSCoding, NSCopying>
- (id)initWithHost:(NSString *)host port:(NSInteger)port protocol:(NSString *)protocol realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod;
- (id)initWithProxyHost:(NSString *)host port:(NSInteger)port type:(NSString *)type realm:(NSString *)realm  authenticationMethod:(NSString *)authenticationMethod;
- (NSString *)realm;
- (BOOL)receivesCredentialSecurely;
- (BOOL)isProxy;
- (NSString *)host;
- (NSInteger)port;
- (NSString *)proxyType;
- (NSString *)protocol;
- (NSString *)authenticationMethod;

@end

@interface NSURLProtectionSpace (NSClientCertificateSpace)

- (NSArray *)distinguishedNames;

@end

@interface NSURLProtectionSpace(NSServerTrustValidationSpace)

- (SecTrustRef)serverTrust;

@end
