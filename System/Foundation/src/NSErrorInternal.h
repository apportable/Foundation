#import <Foundation/NSError.h>

@interface NSError (Internal)
+ (NSError *)_outOfMemoryError;
@end
