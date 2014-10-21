#import <Foundation/NSURLCredential.h>

@interface NSURLCredential (Internal)
- (id)_initWithCFURLCredential:(CFURLCredentialRef)cfspace;
@end
