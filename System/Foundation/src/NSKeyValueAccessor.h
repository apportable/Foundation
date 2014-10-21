#import <Foundation/NSObject.h>

#import <objc/runtime.h>
#import <objc/message.h>

@class NSString;

@interface NSKeyValueAccessor : NSObject {
@public
    Class _containerClassID;
    NSString *_key;
    IMP _implementation;
    SEL _selector;
    NSUInteger _extraArgumentCount;
    void *_extraArgument1;
    void *_extraArgument2;
    void *_extraArgument3;
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key implementation:(IMP)implementation selector:(SEL)selector extraArguments:(void *[3])extraArgs count:(NSUInteger)count;
- (void)dealloc;
- (void *)extraArgument2;
- (void *)extraArgument1;
- (NSUInteger)extraArgumentCount;
- (NSString *)key;
- (SEL)selector;
- (Class)containerClassID;

@end

@interface NSKeyValueSetter : NSKeyValueAccessor
@end

#pragma mark -
#pragma mark NSKeyValueSetter and subclasses

CF_PRIVATE
@interface NSKeyValueMethodSetter : NSKeyValueSetter {
    Method _method;
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key method:(Method)m;
- (Method)method;
- (void)setMethod:(Method)method;

@end

CF_PRIVATE
@interface NSKeyValueIvarSetter : NSKeyValueSetter {
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)container ivar:(Ivar)ivar;
- (Ivar)ivar;
- (void)makeNSKVONotifying;

@end

CF_PRIVATE
@interface NSKeyValueUndefinedSetter : NSKeyValueSetter
{
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)container;

@end

#pragma mark -
#pragma mark NSKeyValueGetter and subclasses

@interface NSKeyValueGetter : NSKeyValueAccessor
@end

CF_PRIVATE
@interface NSKeyValueMethodGetter : NSKeyValueGetter{
    Method _method;
}

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key method:(Method)m;
- (Method)method;

@end

CF_PRIVATE
@interface NSKeyValueIvarGetter : NSKeyValueGetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key ivar:(Ivar)ivar;

@end

CF_PRIVATE
@interface NSKeyValueUndefinedGetter : NSKeyValueGetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)container;

@end
