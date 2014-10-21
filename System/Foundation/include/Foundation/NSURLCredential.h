#import <Foundation/NSObject.h>
#import <Security/Security.h>

@class NSString, NSArray;

typedef NS_ENUM(NSUInteger, NSURLCredentialPersistence) {
    NSURLCredentialPersistenceNone,
    NSURLCredentialPersistenceForSession,
    NSURLCredentialPersistencePermanent
};

@interface NSURLCredential : NSObject <NSCoding, NSCopying>

- (NSURLCredentialPersistence)persistence;

@end

@interface NSURLCredential (NSInternetPassword)

+ (NSURLCredential *)credentialWithUser:(NSString *)user password:(NSString *)password persistence:(NSURLCredentialPersistence)persistence;
- (id)initWithUser:(NSString *)user password:(NSString *)password persistence:(NSURLCredentialPersistence)persistence;
- (NSString *)user;
- (NSString *)password;
- (BOOL)hasPassword;

@end

@interface NSURLCredential (NSClientCertificate)

+ (NSURLCredential *)credentialWithIdentity:(SecIdentityRef)identity certificates:(NSArray *)certArray persistence:(NSURLCredentialPersistence)persistence NS_AVAILABLE(10_6, 3_0);
- (id)initWithIdentity:(SecIdentityRef)identity certificates:(NSArray *)certArray persistence:(NSURLCredentialPersistence) persistence NS_AVAILABLE(10_6, 3_0);
- (SecIdentityRef)identity;
- (NSArray *)certificates;

@end

@interface NSURLCredential(NSServerTrust)

+ (NSURLCredential *)credentialForTrust:(SecTrustRef)trust;
- (id)initWithTrust:(SecTrustRef)trust;

@end
