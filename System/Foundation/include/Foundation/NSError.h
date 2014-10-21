#import <Foundation/NSObject.h>

@class NSDictionary, NSArray;

FOUNDATION_EXPORT NSString *const NSCocoaErrorDomain;
FOUNDATION_EXPORT NSString *const NSPOSIXErrorDomain;
FOUNDATION_EXPORT NSString *const NSOSStatusErrorDomain;
FOUNDATION_EXPORT NSString *const NSMachErrorDomain;
FOUNDATION_EXPORT NSString *const NSUnderlyingErrorKey;
FOUNDATION_EXPORT NSString *const NSLocalizedDescriptionKey;
FOUNDATION_EXPORT NSString *const NSLocalizedFailureReasonErrorKey;
FOUNDATION_EXPORT NSString *const NSLocalizedRecoverySuggestionErrorKey;
FOUNDATION_EXPORT NSString *const NSLocalizedRecoveryOptionsErrorKey;
FOUNDATION_EXPORT NSString *const NSRecoveryAttempterErrorKey;
FOUNDATION_EXPORT NSString *const NSHelpAnchorErrorKey;
FOUNDATION_EXPORT NSString *const NSStringEncodingErrorKey;
FOUNDATION_EXPORT NSString *const NSURLErrorKey;
FOUNDATION_EXPORT NSString *const NSFilePathErrorKey;

@interface NSError : NSObject <NSCopying, NSSecureCoding>

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;
- (NSString *)domain;
- (NSInteger)code;
- (NSDictionary *)userInfo;
- (NSString *)localizedDescription;
- (NSString *)localizedFailureReason;
- (NSString *)localizedRecoverySuggestion;
- (NSArray *)localizedRecoveryOptions;
- (id)recoveryAttempter;
- (NSString *)helpAnchor;

@end

@interface NSObject(NSErrorRecoveryAttempting)

- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo;
- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex;

@end
