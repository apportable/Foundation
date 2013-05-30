#import <Block.h>
#include "objc-private.h"
#include "objc-runtime-new.h"

@class NSString;
@class NSMethodSignature;
#ifdef __LP64__
typedef unsigned long NSUInteger;
#else
typedef unsigned int NSUInteger;
#endif
typedef struct _NSZone NSZone;


@protocol NSObject

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (Class)superclass;
- (Class)class;
- (id)self;
- (NSZone *)zone;

- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

- (BOOL)isProxy;

- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;

- (BOOL)respondsToSelector:(SEL)aSelector;

- (id)retain;
- (oneway void)release;
- (id)autorelease;
- (NSUInteger)retainCount;

- (NSString *)description;
- (NSString *)debugDescription;

@end

@interface NSObject <NSObject>
{
    Class isa;
}
@end

@interface NSBlock : NSObject
@end

@implementation NSBlock

extern "C" void *_NSConcreteStackBlock[32];
extern "C" void *_NSConcreteMallocBlock[32];
extern "C" void *_NSConcreteAutoBlock[32];
extern "C" void *_NSConcreteFinalizingBlock[32];
extern "C" void *_NSConcreteGlobalBlock[32];
extern "C" void *_NSConcreteWeakBlockVariable[32];

#define REGISTER_BLOCK_CLASS(cls) do { \
    Class c = objc_allocateClassPair(self, #cls, 0); \
    memcpy(&cls[0], c, sizeof(class_t)); \
    objc_registerClassPair(c); \
} while(0)

+ (void)load
{
    static BOOL created = NO;
    if (!created)
    {
        created = YES;
        REGISTER_BLOCK_CLASS(_NSConcreteStackBlock);
        REGISTER_BLOCK_CLASS(_NSConcreteMallocBlock);
        REGISTER_BLOCK_CLASS(_NSConcreteAutoBlock);
        REGISTER_BLOCK_CLASS(_NSConcreteFinalizingBlock);
        REGISTER_BLOCK_CLASS(_NSConcreteGlobalBlock);
        REGISTER_BLOCK_CLASS(_NSConcreteWeakBlockVariable );
    }
}

- (id)retain
{
    return Block_copy(self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return Block_copy(self);
}

- (oneway void)release
{
    Block_release(self);
}

@end
