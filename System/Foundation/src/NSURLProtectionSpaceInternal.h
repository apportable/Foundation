#import <Foundation/NSURLProtectionSpace.h>
#import <CFNetwork/CFURLProtectionSpace.h>

@interface NSURLProtectionSpace (Internal)
- (id)_initWithCFURLProtectionSpace:(CFURLProtectionSpaceRef)cfspace;
@end
