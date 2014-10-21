#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSZone.h>

@class NSInvocation, NSMethodSignature, NSCoder, NSString, NSEnumerator;
@class Protocol;

@protocol NSObject

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (Class)superclass;
- (Class)class;
- (id)self;
- (NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (id)performSelector:(SEL)sel;
- (id)performSelector:(SEL)sel withObject:(id)object;
- (id)performSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2;
- (BOOL)isProxy;
- (BOOL)isKindOfClass:(Class)aClass;
- (BOOL)isMemberOfClass:(Class)aClass;
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;
- (BOOL)respondsToSelector:(SEL)sel;
- (id)retain NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (oneway void)release NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (id)autorelease NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (NSUInteger)retainCount NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (NSString *)description;

@optional

- (NSString *)debugDescription;

@end

@protocol NSCopying

- (id)copyWithZone:(NSZone *)zone;

@end

@protocol NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone;

@end

@protocol NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

@protocol NSSecureCoding <NSCoding>
@required

+ (BOOL)supportsSecureCoding;

@end

NS_ROOT_CLASS
@interface NSObject <NSObject> {
    Class isa;
}

+ (void)load;
+ (void)initialize;
+ (id)new;
+ (id)allocWithZone:(NSZone *)zone;
+ (id)alloc;
+ (id)copyWithZone:(NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
+ (id)mutableCopyWithZone:(NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
+ (Class)superclass;
+ (Class)class;
+ (BOOL)instancesRespondToSelector:(SEL)sel;
+ (BOOL)conformsToProtocol:(Protocol *)protocol;
+ (IMP)instanceMethodForSelector:(SEL)sel;
+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)sel;
+ (NSString *)description;
+ (BOOL)isSubclassOfClass:(Class)aClass;
+ (BOOL)resolveClassMethod:(SEL)sel;
+ (BOOL)resolveInstanceMethod:(SEL)sel;
- (id)init;
- (void)dealloc;
- (void)finalize;
- (id)copy;
- (id)mutableCopy;
- (IMP)methodForSelector:(SEL)sel;
- (void)doesNotRecognizeSelector:(SEL)sel;
- (id)forwardingTargetForSelector:(SEL)sel;
- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (BOOL)allowsWeakReference NS_UNAVAILABLE;
- (BOOL)retainWeakReference NS_UNAVAILABLE;

@end

@interface NSObject (NSCoderMethods)

+ (NSInteger)version;
+ (void)setVersion:(NSInteger)aVersion;
- (Class)classForCoder;
- (id)replacementObjectForCoder:(NSCoder *)aCoder;
- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder NS_REPLACES_RECEIVER;

@end

@protocol NSDiscardableContent
@required

- (BOOL)beginContentAccess;
- (void)endContentAccess;
- (void)discardContentIfPossible;
- (BOOL)isContentDiscarded;

@end

@interface NSObject (NSDiscardableContentProxy)
- (id)autoContentAccessingProxy;
@end

FOUNDATION_EXPORT id NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
FOUNDATION_EXPORT void NSDeallocateObject(id object) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
FOUNDATION_EXPORT id NSCopyObject(id object, NSUInteger extraBytes, NSZone *zone) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
FOUNDATION_EXPORT BOOL NSShouldRetainWithZone(id anObject, NSZone *requestedZone) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
FOUNDATION_EXPORT void NSIncrementExtraRefCount(id object) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
FOUNDATION_EXPORT BOOL NSDecrementExtraRefCountWasZero(id object) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
FOUNDATION_EXPORT NSUInteger NSExtraRefCount(id object) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

#if __has_feature(objc_arc)

NS_INLINE CF_RETURNS_RETAINED CFTypeRef CFBridgingRetain(id X) {
    return (__bridge_retained CFTypeRef)X;
}

NS_INLINE id CFBridgingRelease(CFTypeRef CF_CONSUMED X) {
    return (__bridge_transfer id)X;
}

#else

NS_INLINE CF_RETURNS_RETAINED CFTypeRef CFBridgingRetain(id X) {
    return X ? CFRetain((CFTypeRef)X) : NULL;
}

NS_INLINE id CFBridgingRelease(CFTypeRef CF_CONSUMED X) {
    return [(id)CFMakeCollectable(X) autorelease];
}

#endif
