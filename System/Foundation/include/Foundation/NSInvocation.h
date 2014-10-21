#import <Foundation/NSObject.h>
#import <stdbool.h>

@class NSMethodSignature;

@interface NSInvocation : NSObject

+ (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig;
- (NSMethodSignature *)methodSignature;
- (void)retainArguments;
- (BOOL)argumentsRetained;
- (id)target;
- (void)setTarget:(id)target;
- (SEL)selector;
- (void)setSelector:(SEL)selector;
- (void)getReturnValue:(void *)retLoc;
- (void)setReturnValue:(void *)retLoc;
- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx;
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx;
- (void)invoke;
- (void)invokeWithTarget:(id)target;

@end
