#import <Foundation/NSURLAuthenticationChallenge.h>
#import "NSURLConnectionInternal.h"

@interface NSURLAuthenticationChallenge (Internal)
- (id)_initWithCFAuthChallenge:(CFURLAuthChallengeRef)cfchallenge sender:(id<NSURLAuthenticationChallengeSender>)sender;
@end
