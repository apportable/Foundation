#import <Foundation/NSObject.h>

@class NSDictionary, NSString, NSURLCredential, NSURLProtectionSpace;

FOUNDATION_EXPORT NSString *const NSURLCredentialStorageChangedNotification;

@interface NSURLCredentialStorage : NSObject

+ (NSURLCredentialStorage *)sharedCredentialStorage;
- (NSDictionary *)credentialsForProtectionSpace:(NSURLProtectionSpace *)space;
- (NSDictionary *)allCredentials;
- (void)setCredential:(NSURLCredential *)credential forProtectionSpace:(NSURLProtectionSpace *)space;
- (void)removeCredential:(NSURLCredential *)credential forProtectionSpace:(NSURLProtectionSpace *)space;
- (NSURLCredential *)defaultCredentialForProtectionSpace:(NSURLProtectionSpace *)space;
- (void)setDefaultCredential:(NSURLCredential *)credential forProtectionSpace:(NSURLProtectionSpace *)space;

@end
