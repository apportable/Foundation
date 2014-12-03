#import <Foundation/NSObject.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import "CFInternal.h"
#import "NSCFType.h"
#import <objc/runtime.h>

#define LIKELY(x)       __builtin_expect((x),1)
#define UNLIKELY(x)     __builtin_expect((x),0)

#define INDENT "    "

#define NSRequestConcreteImplementation() do { \
    _NSRequestConcreteImplementation([self class], _cmd); \
} while (0);

static inline void _NSRequestConcreteImplementation(Class cls, SEL cmd)
{
    [NSException raise:NSInvalidArgumentException format:@"%s %s requires a subclass implementation", class_getName(cls), sel_getName(cmd)];
}

#define NSInvalidMutation() \
    [NSException raise:NSInternalInconsistencyException format:@"attempting to mutate an immutable object"]

#define NSCapacityCheck(c, lim, fmt, ...) if (c >= lim) { \
    [self release]; \
    [NSException raise:NSInvalidArgumentException format:fmt, ##__VA_ARGS__]; \
    return nil; \
}

extern Class NSClassFromObject(id object);
extern NSString *_NSMethodExceptionProem(id object, SEL selector);
extern NSString *_NSFullMethodName(id object, SEL selector);

@interface NSObject (__NSIsKinds)

- (BOOL)isNSValue__;
- (BOOL)isNSTimeZone__;
- (BOOL)isNSString__;
- (BOOL)isNSSet__;
- (BOOL)isNSOrderedSet__;
- (BOOL)isNSNumber__;
- (BOOL)isNSDictionary__;
- (BOOL)isNSDate__;
- (BOOL)isNSData__;
- (BOOL)isNSArray__;

@end

static inline BOOL NSIsPlistType(NSObject *object)
{
    if ([object isNSString__] ||
        [object isNSNumber__] ||
        [object isNSDate__] ||
        [object isNSData__])
    {
        return YES;
    }
    else if ([object isNSArray__])
    {
        for (id item in (NSArray *)object)
        {
            if (!NSIsPlistType(item))
            {
                return NO;
            }
        }
        return YES;
    }
    else if ([object isNSDictionary__])
    {
        for (id key in (NSDictionary *)object)
        {
            if (!NSIsPlistType(key))
            {
                return NO;
            }
            if (!NSIsPlistType([(NSDictionary *)object objectForKey:key]))
            {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#define SINGLETON_RR() \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wobjc-missing-super-calls\"") \
- (void)dealloc { \
} \
_Pragma("clang diagnostic pop") \
- (NSUInteger)retainCount{ \
    return NSUIntegerMax; \
} \
- (oneway void)release{ \
} \
- (id)retain { \
    return self; \
} \
- (id)autorelease { \
    return self; \
}

#define OBJC_PROTOCOL_IMPL_PUSH \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wobjc-protocol-method-implementation\"")

#define OBJC_PROTOCOL_IMPL_POP \
_Pragma("clang diagnostic pop")

__attribute__((visibility("hidden")))
@interface _NSWeakRef: NSObject

@property (nonatomic, retain) id object;

- (id)init;
- (id)initWithObject:(id)object;

@end
