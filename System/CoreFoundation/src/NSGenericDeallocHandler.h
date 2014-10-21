#import <Foundation/NSObject.h>

void _NSSetDeallocHandler(id object, void (^block)(void));

__attribute__((visibility("hidden"), objc_root_class))
@interface __NSGenericDeallocHandler {
    Class isa;
    void (^_block)(void);
}

+ (void)initialize;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;

@end
