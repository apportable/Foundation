#import <Foundation/NSArray.h>
#import <Foundation/NSLock.h>

__attribute__((visibility("hidden")))
@interface _NSThreadPerformInfo : NSObject {
@public
    id target;
    SEL selector;
    id argument;
    NSMutableArray *modes;
    NSCondition *waiter;
    BOOL *signalled;
    CFRunLoopSourceRef source;
}

- (void)dealloc;

@end
