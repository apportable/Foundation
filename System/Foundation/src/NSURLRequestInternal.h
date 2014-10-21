#import <Foundation/NSURLRequest.h>
#import <CFNetwork/CFURLRequest.h>

@interface NSURLRequest ()
- (id)_initWithCFURLRequest:(CFURLRequestRef)req;
- (CFURLRequestRef)_CFURLRequest;
@end

CF_PRIVATE
@interface NSURLRequestInternal : NSObject {
@public
    CFURLRequestRef request;
}

- (void)dealloc;

@end
