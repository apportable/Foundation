#import <Foundation/NSObject.h>

NS_AUTOMATED_REFCOUNT_UNAVAILABLE
@interface NSAutoreleasePool : NSObject

+ (void)addObject:(id)anObject;
- (void)addObject:(id)anObject;
- (void)drain;

@end
