#import <Foundation/NSObject.h>

@class NSMethodSignature, NSInvocation;

NS_ROOT_CLASS
@interface NSProxy <NSObject> {
    Class isa;
}

+ (id)alloc;
+ (id)allocWithZone:(NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
+ (Class)class;
+ (BOOL)respondsToSelector:(SEL)aSelector;
- (void)forwardInvocation:(NSInvocation *)invocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)dealloc;
- (void)finalize;
- (NSString *)description;
- (NSString *)debugDescription;
- (BOOL)allowsWeakReference NS_UNAVAILABLE;
- (BOOL)retainWeakReference NS_UNAVAILABLE;

@end
