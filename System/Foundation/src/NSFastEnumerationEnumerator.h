#import <Foundation/NSEnumerator.h>
#import "ForFoundationOnly.h"

@interface __NSFastEnumerationEnumerator : NSEnumerator  {
@package
    id <NSFastEnumeration> _obj;
    id _origObj;
    NSUInteger _count;
    NSUInteger _mut;
}

- (id)initWithObject:(id<NSFastEnumeration>)object;
@end
