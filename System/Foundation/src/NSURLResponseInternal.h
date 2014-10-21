#import <Foundation/NSURLResponse.h>
#import <CFNetwork/CFURLResponse.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Security/SecTrust.h>

@interface NSURLResponse (Internal)
+ (id)_responseWithCFURLResponse:(CFURLResponseRef)resp;
- (CFURLResponseRef)_CFURLResponse;
@end

CF_PRIVATE
@interface NSURLResponseInternal : NSObject {
@package
    CFURLResponseRef response;
}

- (id)initWithURLResponse:(CFURLResponseRef)resp;
- (void)dealloc;

@end

CF_PRIVATE
@interface NSHTTPURLResponseInternal : NSObject <NSCoding> {
@package
    SecTrustRef peerTrust;
    BOOL isMixedReplace;
}

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;

@end

@interface NSHTTPURLResponse (Internal)

+ (BOOL)isErrorStatusCode:(NSInteger)statusCode;

@end

