#import <Foundation/NSObject.h>

@interface NSMethodSignature : NSObject

+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types;
- (NSUInteger)numberOfArguments;
- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx NS_RETURNS_INNER_POINTER;
- (NSUInteger)frameLength;
- (BOOL)isOneway;
- (const char *)methodReturnType NS_RETURNS_INNER_POINTER;
- (NSUInteger)methodReturnLength;

@end
