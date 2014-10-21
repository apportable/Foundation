#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

extern id _NSMessageBuilder(id proxy, NSInvocation **inv, SEL _cmd, void *arg);

NS_ROOT_CLASS
@interface __NSMessageBuilder
{
@public
    Class isa;
    id _target;
    id *_addr;
}

+ (void)initialize;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)forwardInvocation:(NSInvocation *)inv;

@end
