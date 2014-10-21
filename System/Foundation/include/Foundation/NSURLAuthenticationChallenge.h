#import <Foundation/NSObject.h>

@class NSURLAuthenticationChallenge, NSURLCredential, NSURLProtectionSpace, NSURLResponse, NSError;

@protocol NSURLAuthenticationChallengeSender <NSObject>
@required

- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)cancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@optional

- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)rejectProtectionSpaceAndContinueWithChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

@interface NSURLAuthenticationChallenge : NSObject <NSCoding>

- (id)initWithProtectionSpace:(NSURLProtectionSpace *)space proposedCredential:(NSURLCredential *)credential previousFailureCount:(NSInteger)previousFailureCount failureResponse:(NSURLResponse *)response error:(NSError *)error sender:(id<NSURLAuthenticationChallengeSender>)sender;
- (id)initWithAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge sender:(id<NSURLAuthenticationChallengeSender>)sender;
- (NSURLProtectionSpace *)protectionSpace;
- (NSURLCredential *)proposedCredential;
- (NSInteger)previousFailureCount;
- (NSURLResponse *)failureResponse;
- (NSError *)error;
- (id<NSURLAuthenticationChallengeSender>)sender;

@end
