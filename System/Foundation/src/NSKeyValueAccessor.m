//
//  NSKeyValueAccessor.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueAccessor.h"
#import "NSKeyValueCodingInternal.h"
#import "NSKeyValueCollectionProxies.h"
#import "NSKeyValueObservingInternal.h"
#import "NSValueInternal.h"
#import <Foundation/NSRange.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import "NSExternals.h"
#import <CoreFoundation/CFSet.h>

#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <ctype.h>
#import <libkern/OSAtomic.h>

CFMutableSetRef NSKVOSetters = NULL;
CFMutableSetRef NSKVOGetters = NULL;
CFMutableSetRef NSKVOMutableArrayGetters = NULL;
CFMutableSetRef NSKVOMutableOrderedSetGetters = NULL;
CFMutableSetRef NSKVOMutableSetGetters = NULL;

CFSetCallBacks _NSKVOSetterCallbacks = {
    .version = 0,
    .retain = &NSKVOSetterRetain,
    .release = &NSKVOSetterRelease,
    .copyDescription = NULL,
    .equal = &NSKVOSetterEqual,
    .hash = &NSKVOSetterHash
};

@implementation NSKeyValueAccessor

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key implementation:(IMP)implementation selector:(SEL)selector extraArguments:(void *[3])extraArgs count:(NSUInteger)count
{
    self = [super init];
    if (self)
    {
        _containerClassID = cls;
        _key = [key copy];
        _implementation = implementation;
        _selector = selector;
        _extraArgumentCount = count;
        if (count > 0)
        {
            _extraArgument1 = extraArgs[0] == key ? _key : extraArgs[0]; // I believe this horrible hack is correct.
        }
        if (count > 1)
        {
            _extraArgument2 = extraArgs[1] == key ? _key : extraArgs[1];
        }
        if (count > 2)
        {
            _extraArgument3 = extraArgs[2] == key ? _key : extraArgs[2];
        }
    }
    return self;
}

- (void)dealloc
{
    [_key release];
    [super dealloc];
}

- (void *)extraArgument2
{
    return _extraArgument2;
}

- (void *)extraArgument1
{
    return _extraArgument1;
}

- (NSUInteger)extraArgumentCount
{
    return _extraArgumentCount;
}

- (NSString *)key
{
    return _key;
}

- (SEL)selector
{
    return _selector;
}

- (Class)containerClassID
{
    return _containerClassID;
}

@end

@implementation NSKeyValueSetter

@end

#define TYPE_TO_IMP(PREFIX, SUFFIX) \
    /* NOTE: For exmple, imp = &NSKVOObjectSetter , imp = &NSKVOIvarRectGetter , etc... */ \
    switch (*type) \
    { \
        case _C_ID: \
        case _C_CLASS: \
            imp = (IMP)&PREFIX ## Object ## SUFFIX; \
            break; \
        case _C_CHR: \
            imp = (IMP)&PREFIX ## Char ## SUFFIX; \
        case _C_UCHR: \
            imp = (IMP)&PREFIX ## UnsignedChar ## SUFFIX; \
            break; \
        case _C_SHT: \
            imp = (IMP)&PREFIX ## Short ## SUFFIX; \
            break; \
        case _C_USHT: \
            imp = (IMP)&PREFIX ## UnsignedShort ## SUFFIX; \
            break; \
        case _C_INT: \
            imp = (IMP)&PREFIX ## Int ## SUFFIX; \
            break; \
        case _C_UINT: \
            imp = (IMP)&PREFIX ## UnsignedInt ## SUFFIX; \
            break; \
        case _C_LNG: \
            imp = (IMP)&PREFIX ## Long ## SUFFIX; \
            break; \
        case _C_ULNG: \
            imp = (IMP)&PREFIX ## UnsignedLong ## SUFFIX; \
            break; \
        case _C_LNG_LNG: \
            imp = (IMP)&PREFIX ## LongLong ## SUFFIX; \
            break; \
        case _C_ULNG_LNG: \
            imp = (IMP)&PREFIX ## UnsignedLongLong ## SUFFIX; \
            break; \
        case _C_FLT: \
            imp = (IMP)&PREFIX ## Float ## SUFFIX; \
            break; \
        case _C_DBL: \
            imp = (IMP)&PREFIX ## Double ## SUFFIX; \
            break; \
        case _C_BOOL: \
            imp = (IMP)&PREFIX ## Bool ## SUFFIX; \
            break; \
        case _C_STRUCT_B: \
        { \
            if (strcmp(type, @encode(NSRange)) == 0 || strcmp(type, IVAR_NSRANGE) == 0) \
            { \
                imp = (IMP)&PREFIX ## Range ## SUFFIX; \
            } \
            else if (strcmp(type, @encode(CGPoint)) == 0 || strcmp(type, IVAR_CGPOINT) == 0) \
            { \
                imp = (IMP)&PREFIX ## Point ## SUFFIX; \
            } \
            else if (strcmp(type, @encode(CGSize)) == 0 || strcmp(type, IVAR_CGSIZE) == 0) \
            { \
                imp = (IMP)&PREFIX ## Size ## SUFFIX; \
            } \
            else if (strcmp(type, @encode(CGRect)) == 0 || strcmp(type, IVAR_CGRECT) == 0) \
            { \
                imp = (IMP)&PREFIX ## Rect ## SUFFIX; \
            } \
            else \
            { \
                imp = (IMP)&PREFIX ## Struct ## SUFFIX; \
            } \
            break; \
        } \
        default: \
            imp = (IMP)NULL; \
            break; \
    }/* NOT handled for compatibility reasons
        case _C_SEL:
        case _C_PTR:
        case _C_CHARPTR:
        case _C_ARY_B:
        case _C_UNION_B:
        */

#pragma mark -
#pragma mark _NSSetXXXValueForKeyWithMethod static functions

static void _NSSetObjectValueForKeyWithMethod(id obj, SEL cmd, id value, NSString *key, Method method)
{
    // Not used.
    ((void(*)(id, Method, id))method_invoke)(obj, method, value);
}

static void _NSSetStructValueForKeyWithMethod(id obj, SEL cmd, id value, NSString *key, Method method)
{
    if (value == nil)
    {
        [obj setNilValueForKey:key];
    }
    else
    {
        char *type = method_copyArgumentType(method, 2);
        NSUInteger size;
        NSUInteger align;
        if (NSGetSizeAndAlignment(type, &size, &align))
        {
            void *buffer = (void *)malloc(size);
            if (buffer == NULL)
            {
                // fault?
            }
            [value getValue:buffer];
            NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
            
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:obj];
            [inv setSelector:cmd];
            [inv setArgument:buffer atIndex:2];
            [inv invoke];
            free(buffer);
        }
        else
        {
            // fault?
        }
        free(type);
    }
}

#define DEFINE_SET_WITH_METHOD(INFIX, TYPE, GETTER) \
static void _NSSet ## INFIX ##ValueForKeyWithMethod(id obj, SEL cmd, id value, NSString *key, Method method) \
{ \
    if (value) \
    { \
        ((void(*)(id, Method, TYPE))method_invoke)(obj, method, [value GETTER]); \
    } \
    else \
    { \
        [obj setNilValueForKey:key]; \
    } \
}

DEFINE_SET_WITH_METHOD(Char, char, charValue)
DEFINE_SET_WITH_METHOD(UnsignedChar, unsigned char, unsignedCharValue)
DEFINE_SET_WITH_METHOD(Short, short, shortValue)
DEFINE_SET_WITH_METHOD(UnsignedShort, unsigned short, unsignedShortValue)
DEFINE_SET_WITH_METHOD(Int, int, intValue)
DEFINE_SET_WITH_METHOD(UnsignedInt, unsigned int, unsignedIntValue)
DEFINE_SET_WITH_METHOD(Long, long, longValue)
DEFINE_SET_WITH_METHOD(UnsignedLong, unsigned long, unsignedLongValue)
DEFINE_SET_WITH_METHOD(LongLong, long long, longLongValue)
DEFINE_SET_WITH_METHOD(UnsignedLongLong, unsigned long long, unsignedLongLongValue)
DEFINE_SET_WITH_METHOD(Float, float, floatValue)
DEFINE_SET_WITH_METHOD(Double, double, doubleValue)
DEFINE_SET_WITH_METHOD(Bool, BOOL, boolValue)
DEFINE_SET_WITH_METHOD(Range, NSRange, rangeValue)
DEFINE_SET_WITH_METHOD(Point, CGPoint, pointValue)
DEFINE_SET_WITH_METHOD(Size, CGSize, sizeValue)
DEFINE_SET_WITH_METHOD(Rect, CGRect, rectValue)

#undef DEFINE_SET_WITH_METHOD

#pragma mark -

@implementation NSKeyValueMethodSetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key method:(Method)m
{
    unsigned int argc = method_getNumberOfArguments(m);

    if (argc != 3)
    {
        [self release];
        return nil;
    }
    
    char *type = method_copyArgumentType(m, 2);
    IMP imp = NULL;
    if (*type == _C_ID || *type == _C_CLASS)
    {
        // Special case to call implementation directly
        imp = method_getImplementation(m);
        free(type);
        void *extras[1] = {
            key
        };
        self = [super initWithContainerClassID:cls key:key implementation:imp selector:method_getName(m) extraArguments:extras count:1];
    }
    else
    {
        TYPE_TO_IMP(_NSSet, ValueForKeyWithMethod);
        free(type);
        if (imp == NULL)
        {
            [self release];
            return nil;
        }
        void *extras[2] = {
            key,
            m
        };
        self = [super initWithContainerClassID:cls key:key implementation:imp selector:method_getName(m) extraArguments:extras count:2];
    }
    
    if (self)
    {
        _method = m;
    }
    return self;
}

- (Method)method
{
    return _method;
}

- (void)setMethod:(Method)method {
    _method = method;
    if (_extraArgument2)
    {
        _extraArgument2 = method;
    }
}

@end

#pragma mark -
#pragma mark _NSSetXXXValueForKeyInIvar static functions

static void _NSSetObjectValueForKeyInIvar(id obj, SEL cmd, id value, NSString *key, Ivar ivar)
{
    //object_setIvar(obj, ivar, value);
    // Seems unsafe
    id* addr = (id*)((char*)obj + ivar_getOffset(ivar));
    id oldVal = *addr;
    *addr = [value retain];
    [oldVal autorelease];
}

static void _NSSetStructValueForKeyInIvar(id obj, SEL cmd, id value, NSString *key, Ivar ivar)
{
    NSUInteger size = 0;
    NSUInteger align = 0;
    if (NSGetSizeAndAlignment([value objCType], &size, &align))
    {
        [value getValue:(void *)((char *)obj + ivar_getOffset(ivar))];
    }
    else
    {
        // fault?
        DEBUG_BREAK();
    }
}

#define DEFINE_SET_IN_IVAR(INFIX, TYPE, GETTER) \
static void _NSSet ## INFIX ##ValueForKeyInIvar(id obj, SEL cmd, id value, NSString *key, Ivar ivar) \
{ \
    if (value) \
    { \
        *(TYPE*)((char*)obj + ivar_getOffset(ivar)) = [value GETTER]; \
    } \
    else \
    { \
        [obj setNilValueForKey:key]; \
    } \
}

DEFINE_SET_IN_IVAR(Char, char, charValue)
DEFINE_SET_IN_IVAR(UnsignedChar, unsigned char, unsignedCharValue)
DEFINE_SET_IN_IVAR(Short, short, shortValue)
DEFINE_SET_IN_IVAR(UnsignedShort, unsigned short, unsignedShortValue)
DEFINE_SET_IN_IVAR(Int, int, intValue)
DEFINE_SET_IN_IVAR(UnsignedInt, unsigned int, unsignedIntValue)
DEFINE_SET_IN_IVAR(Long, long, longValue)
DEFINE_SET_IN_IVAR(UnsignedLong, unsigned long, unsignedLongValue)
DEFINE_SET_IN_IVAR(LongLong, long long, longLongValue)
DEFINE_SET_IN_IVAR(UnsignedLongLong, unsigned long long, unsignedLongLongValue)
DEFINE_SET_IN_IVAR(Float, float, floatValue)
DEFINE_SET_IN_IVAR(Double, double, doubleValue)
DEFINE_SET_IN_IVAR(Bool, BOOL, boolValue)
DEFINE_SET_IN_IVAR(Range, NSRange, rangeValue)
DEFINE_SET_IN_IVAR(Point, CGPoint, pointValue)
DEFINE_SET_IN_IVAR(Size, CGSize, sizeValue)
DEFINE_SET_IN_IVAR(Rect, CGRect, rectValue)

#undef DEFINE_SET_IN_IVAR

static void _NSSetValueAndNotifyForKeyInIvar(id obj, SEL cmd, id value, NSString *key, Ivar ivar)
{
    const char *type = ivar_getTypeEncoding(ivar);
    IMP imp = NULL;
    TYPE_TO_IMP(_NSSet, ValueForKeyInIvar);
    [obj willChangeValueForKey:key];
    ((void (*)(id, SEL, id, void*, void*))imp)(obj, cmd, value, key, ivar);
    [obj didChangeValueForKey:key];
}

#pragma mark -

@implementation NSKeyValueIvarSetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)container ivar:(Ivar)ivar
{
    void *extras[2] = {
        key,
        ivar
    };
    const char *type = ivar_getTypeEncoding(ivar);
    IMP imp = NULL;
    TYPE_TO_IMP(_NSSet, ValueForKeyInIvar);
    if (imp == NULL)
    {
        [self release];
        return nil;
    }
    return [super initWithContainerClassID:cls key:key implementation:imp selector:NULL extraArguments:extras count:2];
}

- (Ivar)ivar
{
    return [super extraArgument2];
}

- (void)makeNSKVONotifying {
    _implementation = (IMP)&_NSSetValueAndNotifyForKeyInIvar;
}

@end

static void _NSSetValueAndNotifyForUndefinedKey(id obj, SEL cmd, id value, NSString *key, IMP imp)
{
    [obj willChangeValueForKey:key];
    ((void(*)(id, SEL, id, NSString*))imp)(obj, cmd, value, key);
    [obj didChangeValueForKey:key];
}

@implementation NSKeyValueUndefinedSetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)container
{
    SEL sel = @selector(setValue:forUndefinedKey:);
    IMP imp = method_getImplementation(class_getInstanceMethod(cls, sel));
    
    if (_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(cls, key))
    {
        void *extras[1] = {
            key
        };
        return [super initWithContainerClassID:cls key:key implementation:imp selector:sel extraArguments:extras count:1];
    }
    else
    {
        void *extras[2] = {
            key,
            imp
        };
        return [super initWithContainerClassID:cls key:key implementation:(IMP)&_NSSetValueAndNotifyForUndefinedKey selector:sel extraArguments:extras count:2];
    }
}

@end


@implementation NSKeyValueGetter

@end

#pragma mark -
#pragma mark _NSGetXXXValueWithMethod static functions

static id _NSGetObjectValueWithMethod(id obj, SEL cmd, Method method)
{
    // Not used.
    return ((id(*)(id, Method))method_invoke)(obj, method);
}

static id _NSGetStructValueWithMethod(id obj, SEL cmd, Method method)
{
    id val = nil;
    char *type = method_copyReturnType(method);
    NSUInteger size;
    NSUInteger align;
    if (NSGetSizeAndAlignment(type, &size, &align))
    {
        void *buffer = (void *)malloc(size);
        if (buffer == NULL)
        {
            // fault?
        }
        
        NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
        
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
        [inv setTarget:obj];
        [inv setSelector:cmd];
        [inv invoke];
        [inv getReturnValue:buffer];
        val = [NSValue value:buffer withObjCType:type];
        free(buffer);
    }
    else
    {
        // fault?
    }
    free(type);
    
    return val;
}

#define DEFINE_GET_NUMBER_WITH_METHOD(INFIX, TYPE) \
static id _NSGet ## INFIX ##ValueWithMethod(id obj, SEL cmd, Method method) \
{ \
    return [NSNumber numberWith##INFIX:((TYPE(*)(id, Method))method_invoke)(obj, method)]; \
}

#define DEFINE_GET_VALUE_WITH_METHOD(INFIX, TYPE) \
static id _NSGet ## INFIX ##ValueWithMethod(id obj, SEL cmd, Method method) \
{ \
    return [NSValue valueWith##INFIX:((TYPE(*)(id, Method))method_invoke_stret)(obj, method)]; \
}

DEFINE_GET_NUMBER_WITH_METHOD(Char, char)
DEFINE_GET_NUMBER_WITH_METHOD(UnsignedChar, unsigned char)
DEFINE_GET_NUMBER_WITH_METHOD(Short, short)
DEFINE_GET_NUMBER_WITH_METHOD(UnsignedShort, unsigned short)
DEFINE_GET_NUMBER_WITH_METHOD(Int, int)
DEFINE_GET_NUMBER_WITH_METHOD(UnsignedInt, unsigned int)
DEFINE_GET_NUMBER_WITH_METHOD(Long, long)
DEFINE_GET_NUMBER_WITH_METHOD(UnsignedLong, unsigned long)
DEFINE_GET_NUMBER_WITH_METHOD(LongLong, long long)
DEFINE_GET_NUMBER_WITH_METHOD(UnsignedLongLong, unsigned long long)
DEFINE_GET_NUMBER_WITH_METHOD(Float, float)
DEFINE_GET_NUMBER_WITH_METHOD(Double, double)
DEFINE_GET_NUMBER_WITH_METHOD(Bool, BOOL)
DEFINE_GET_VALUE_WITH_METHOD(Range, NSRange)
DEFINE_GET_VALUE_WITH_METHOD(Point, CGPoint)
DEFINE_GET_VALUE_WITH_METHOD(Size, CGSize)
DEFINE_GET_VALUE_WITH_METHOD(Rect, CGRect)

#undef DEFINE_GET_NUMBER_WITH_METHOD
#undef DEFINE_GET_VALUE_WITH_METHOD

#pragma mark -

@implementation NSKeyValueMethodGetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key method:(Method)m
{
    unsigned int argc = method_getNumberOfArguments(m) - 2;
    if (argc > 0)
    {
        [self release];
        return nil;
    }

    char *type = method_copyReturnType(m);
    IMP imp = NULL;
    if (*type == _C_ID || *type == _C_CLASS)
    {
        // Special case to call implementation directly
        imp = method_getImplementation(m);
        free(type);
        self = [super initWithContainerClassID:cls key:key implementation:imp selector:method_getName(m) extraArguments:NULL count:0];
    }
    else
    {
        TYPE_TO_IMP(_NSGet, ValueWithMethod);
        free(type);
        if (imp == NULL)
        {
            [self release];
            return nil;
        }
        void *extras[1] = {
            m
        };
        self = [super initWithContainerClassID:cls key:key implementation:imp selector:method_getName(m) extraArguments:extras count:1];
    }
    if (self != nil)
    {
        _method = m;
    }
    return self;
}

@end

#pragma mark -
#pragma mark _NSGetXXXValueInIvar static functions

static id _NSGetObjectValueInIvar(id obj, SEL cmd, Ivar ivar)
{
    return object_getIvar(obj, ivar);
}

static id _NSGetStructValueInIvar(id obj, SEL cmd, Ivar ivar)
{
    id val = nil;
    const char *type = ivar_getTypeEncoding(ivar);
    NSUInteger size;
    NSUInteger align;
    if (NSGetSizeAndAlignment(type, &size, &align))
    {
        void *buffer = (void *)malloc(size);
        if (buffer == NULL)
        {
            // fault?
        }
        
        object_getInstanceVariable(obj, ivar_getName(ivar), (void **)buffer);
        
        val = [NSValue value:buffer withObjCType:type];
        free(buffer);
    }
    else
    {
        // fault?
    }
    return val;
}

#define DEFINE_GET_NUMBER_IN_IVAR(INFIX, TYPE) \
static id _NSGet ## INFIX ##ValueInIvar(id obj, SEL cmd, Ivar ivar) \
{ \
    TYPE val; \
    object_getInstanceVariable(obj, ivar_getName(ivar), (void **)&val); \
    return [NSNumber numberWith##INFIX:val]; \
}

#define DEFINE_GET_VALUE_IN_IVAR(INFIX, TYPE) \
static id _NSGet ## INFIX ##ValueInIvar(id obj, SEL cmd, Ivar ivar) \
{ \
    TYPE val; \
    object_getInstanceVariable(obj, ivar_getName(ivar), (void**)&val); \
    return [NSValue valueWith##INFIX:val]; \
}

DEFINE_GET_NUMBER_IN_IVAR(Char, char)
DEFINE_GET_NUMBER_IN_IVAR(UnsignedChar, unsigned char)
DEFINE_GET_NUMBER_IN_IVAR(Short, short)
DEFINE_GET_NUMBER_IN_IVAR(UnsignedShort, unsigned short)
DEFINE_GET_NUMBER_IN_IVAR(Int, int)
DEFINE_GET_NUMBER_IN_IVAR(UnsignedInt, unsigned int)
DEFINE_GET_NUMBER_IN_IVAR(Long, long)
DEFINE_GET_NUMBER_IN_IVAR(UnsignedLong, unsigned long)
DEFINE_GET_NUMBER_IN_IVAR(LongLong, long long)
DEFINE_GET_NUMBER_IN_IVAR(UnsignedLongLong, unsigned long long)
DEFINE_GET_NUMBER_IN_IVAR(Float, float)
DEFINE_GET_NUMBER_IN_IVAR(Double, double)
DEFINE_GET_NUMBER_IN_IVAR(Bool, BOOL)
DEFINE_GET_VALUE_IN_IVAR(Range, NSRange)
DEFINE_GET_VALUE_IN_IVAR(Point, CGPoint)
DEFINE_GET_VALUE_IN_IVAR(Size, CGSize)
DEFINE_GET_VALUE_IN_IVAR(Rect, CGRect)

#undef DEFINE_GET_NUMBER_IN_IVAR
#undef DEFINE_GET_VALUE_IN_IVAR

#pragma mark -

@implementation NSKeyValueIvarGetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key ivar:(Ivar)ivar
{
    void *extras[1] = {
        ivar
    };
    const char *type = ivar_getTypeEncoding(ivar);
    IMP imp = NULL;
    TYPE_TO_IMP(_NSGet, ValueInIvar);
    if (imp == NULL)
    {
        [self release];
        return nil;
    }
    return [super initWithContainerClassID:cls key:key implementation:imp selector:NULL extraArguments:extras count:1];
}

@end

@implementation NSKeyValueUndefinedGetter

- (id)initWithContainerClassID:(Class)cls key:(NSString *)key containerIsa:(Class)container
{
    void *extras[1] = {
        key
    };
    SEL sel = @selector(valueForUndefinedKey:);
    IMP imp = method_getImplementation(class_getInstanceMethod(cls, sel));
    return [super initWithContainerClassID:cls key:key implementation:imp selector:sel extraArguments:extras count:1];
}

@end

@implementation NSObject (NSKeyValueCodingPrivate)

static NSUInteger __NSSetupKeyBuffer(const char *prefix, NSString *key, const char *suffix, char **keyStrRet)
{
    NSUInteger prefixLen = strlen(prefix);
    NSUInteger suffixLen = strlen(suffix);
    NSUInteger keyLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    char keyStr[prefixLen + keyLen + suffixLen + 1];
    memcpy(&keyStr[0], prefix, prefixLen);
    [key getCString:keyStr + prefixLen maxLength:keyLen + 1 encoding:NSUTF8StringEncoding];
    if (suffixLen)
    {
        memcpy(&keyStr[prefixLen + keyLen], suffix, suffixLen);
    }
    keyStr[prefixLen + keyLen + suffixLen] = '\0';
    *keyStrRet = strdup(keyStr);//ALLOC
    return prefixLen;
}

+ (NSKeyValueSetter*)_createValueSetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    NSKeyValueSetter *setter = nil;
    NSKVOSetterStruct kvoKey = {
        .evil = NULL,
        .cls = cls,
        .key = key,
        .implementation = NULL,
        .selector = NULL
    };
    if (NSKVOSetters == NULL)
    {
        NSKVOSetters = CFSetCreateMutable(kCFAllocatorDefault, 0, &_NSKVOSetterCallbacks);
    }
    setter = (NSKeyValueSetter *)CFSetGetValue(NSKVOSetters, &kvoKey);
    if (setter != NULL)
    {
        return setter;
    }
    char *keyStr = NULL;
    NSUInteger keyLen = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger prefixLen = __NSSetupKeyBuffer("_set", key, ":", &keyStr); // "_setFoo:"
    do {
        // setKey:
        keyStr[prefixLen] = toupper(keyStr[prefixLen]);
        Method m = class_getInstanceMethod(cls, sel_getUid(&keyStr[1]));
        if (m != NULL)
        {
            setter = [[NSKeyValueMethodSetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        // _setKey:
        m = class_getInstanceMethod(cls, sel_getUid(&keyStr[0]));
        if (m != NULL)
        {
            setter = [[NSKeyValueMethodSetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        if ([cls accessInstanceVariablesDirectly])
        {
            Ivar iv = NULL;
            keyStr[3] = '_';
            keyStr[4 + keyLen] = '\0';
            keyStr[4] = tolower(keyStr[4]);

            // _key
            iv = class_getInstanceVariable(cls, &keyStr[3]);
            if (iv != NULL)
            {
                setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:iv];
                break;
            }

            // key
            iv = class_getInstanceVariable(cls, &keyStr[4]);
            if (iv != NULL)
            {
                setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:iv];
                break;
            }

            keyStr[1] = '_';
            keyStr[2] = 'i';
            keyStr[3] = 's';
            keyStr[4] = toupper(keyStr[4]);

            // _isKey
            iv = class_getInstanceVariable(cls, &keyStr[1]);
            if (iv != NULL)
            {
                setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:iv];
                break;
            }

            keyStr[2] = 'i';
            keyStr[3] = 's';
            keyStr[4] = toupper(keyStr[4]);

            // isKey
            iv = class_getInstanceVariable(cls, &keyStr[2]);
            if (iv != NULL)
            {
                setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:iv];
                break;
            }
        }

        setter = [NSObject _createValuePrimitiveSetterWithContainerClassID:cls key:key];

    } while (0);

    if (setter == nil)
    {
        setter = [[NSKeyValueUndefinedSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls];
    }

    CFSetAddValue(NSKVOSetters, setter);
    [setter release];
    free(keyStr);
    return setter;
}

+ (NSKeyValueSetter*)_createValuePrimitiveSetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    NSKeyValueSetter *setter = nil;
    char *keyStr = NULL;
    NSUInteger prefixLen = __NSSetupKeyBuffer("_setPrimitive", key, ":", &keyStr);
    do {
        // setPrimitiveFoo:
        keyStr[prefixLen] = toupper(keyStr[prefixLen]);
        Method m = class_getInstanceMethod(cls, sel_getUid(&keyStr[1]));
        if (m != NULL)
        {
            setter = [[NSKeyValueMethodSetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        if ([cls accessInstanceVariablesDirectly])
        {
            Ivar iv = __NSKeyValueIvarForPattern(cls, key, keyStr, prefixLen);
            if (iv != NULL)
            {
                setter = [[NSKeyValueIvarSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:iv];
                break;
            }
        }
    } while (0);

    if (!setter)
    {
        setter = [cls _createOtherValueSetterWithContainerClassID:cls key:key];
    }

    free(keyStr);
    return setter;
}

+ (id)_createOtherValueSetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    return [[NSKeyValueUndefinedSetter alloc] initWithContainerClassID:cls key:key containerIsa:cls];
}

static Ivar __NSKeyValueIvarForPattern(Class cls, NSString *key, char *keyStr, NSUInteger prefixLen)
{
    Ivar iv = NULL;

    keyStr[prefixLen-1] = '_';
    keyStr[prefixLen] = tolower(keyStr[prefixLen]);
    iv = class_getInstanceVariable(cls, &keyStr[prefixLen-1]); // "_foo"
    if (iv != NULL)
    {
        return iv;
    }

    keyStr[prefixLen-3] = '_';
    keyStr[prefixLen-2] = 'i';
    keyStr[prefixLen-1] = 's';
    keyStr[prefixLen] = toupper(keyStr[prefixLen]);
    iv = class_getInstanceVariable(cls, &keyStr[prefixLen-3]); // "_isFoo"
    if (iv != NULL)
    {
        return iv;
    }

    keyStr[prefixLen] = tolower(keyStr[prefixLen]);
    iv = class_getInstanceVariable(cls, &keyStr[prefixLen]); // "foo"
    if (iv != NULL)
    {
        return iv;
    }

    keyStr[prefixLen] = toupper(keyStr[prefixLen]);
    iv = class_getInstanceVariable(cls, &keyStr[prefixLen-2]); // "isFoo"

    return iv;
}

+ (NSKeyValueGetter*)_createOtherValueGetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    return [[NSKeyValueUndefinedGetter alloc] initWithContainerClassID:cls key:key containerIsa:cls];
}

+ (NSKeyValueGetter*)_createValuePrimitiveGetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    NSKeyValueGetter *getter = nil;
    char *keyStr = NULL;
    NSUInteger prefixLen = __NSSetupKeyBuffer("_getPrimitive", key, "", &keyStr); // "_getPrimitive"

    do {
        keyStr[prefixLen] = toupper(keyStr[prefixLen]);
        SEL selector = sel_registerName(&keyStr[1]); // "getPrimitiveFoo"
        Method m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        keyStr[4] = tolower(keyStr[4]);
        selector = sel_registerName(&keyStr[4]); // "primitiveFoo"
        m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        if ([cls accessInstanceVariablesDirectly])
        {
            Ivar iv = __NSKeyValueIvarForPattern(cls, key, keyStr, prefixLen);
            if (iv != NULL)
            {
                getter = [[NSKeyValueIvarGetter alloc] initWithContainerClassID:cls key:key ivar:iv];
                break;
            }
        }
    } while (0);

    if (!getter)
    {
        getter = [NSObject _createOtherValueGetterWithContainerClassID:cls key:key];
    }

    free(keyStr);
    return getter;
}

+ (NSKeyValueGetter*)_createValueGetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    NSKeyValueGetter *getter = nil;
    NSKVOGetterStruct kvoKey = {
        .evil = NULL,
        .cls = cls,
        .key = key,
        .implementation = NULL,
        .selector = NULL
    };
    if (NSKVOGetters == NULL)
    {
        NSKVOGetters = CFSetCreateMutable(kCFAllocatorDefault, 0, &_NSKVOSetterCallbacks);
    }
    getter = (NSKeyValueGetter *)CFSetGetValue(NSKVOGetters, &kvoKey);
    if (getter != NULL)
    {
        return getter;
    }
    char *keyStr = NULL;
    NSUInteger prefixLen = __NSSetupKeyBuffer("_get", key, "", &keyStr); // "_get"
    char firstCharOriginal = keyStr[4];

    do {
        keyStr[4] = toupper(keyStr[4]);
        SEL selector = sel_registerName(&keyStr[1]); // _"getFoo"
        Method m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        keyStr[4] = firstCharOriginal;
        selector = sel_registerName(&keyStr[4]); // _get"foo"
        m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        keyStr[2] = 'i';
        keyStr[3] = 's';
        keyStr[4] = toupper(keyStr[4]);
        selector = sel_registerName(&keyStr[2]); // _g"isFoo"
        m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        keyStr[2] = 'e';
        keyStr[3] = 't';
        selector = sel_registerName(&keyStr[0]); // "_getFoo"
        m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        keyStr[3] = '_';
        keyStr[4] = firstCharOriginal;
        selector = sel_registerName(&keyStr[3]); // _ge"_foo"
        m = class_getInstanceMethod(cls, selector);
        if (m != NULL)
        {
            getter = [[NSKeyValueMethodGetter alloc] initWithContainerClassID:cls key:key method:m];
            break;
        }

        if ([cls accessInstanceVariablesDirectly])
        {
            Ivar iv = __NSKeyValueIvarForPattern(cls, key, keyStr, prefixLen);
            if (iv != NULL)
            {
                getter = [[NSKeyValueIvarGetter alloc] initWithContainerClassID:cls key:key ivar:iv];
                break;
            }
        }
    } while (0);

    if (!getter)
    {
        getter = [NSObject _createValuePrimitiveGetterWithContainerClassID:cls key:key];
    }

    CFSetAddValue(NSKVOGetters, getter);
    [getter release];
    free(keyStr);

    return getter;
}

static Method NSKeyValueMethodForPattern(Class cls, const char* pattern, const char* key)
{
    int patternLength = strlen(pattern);
    int keyLength = 2 * strlen(key);

    char methodName[patternLength+keyLength+1];
    snprintf(methodName, sizeof(methodName), pattern, key, key);

    SEL selector = sel_registerName(methodName);
    return class_getInstanceMethod(cls, selector);
}

+ (NSKeyValueProxyGetter*)_createMutableArrayValueGetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    if (_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(cls, key))
    {
        Class originalClass = _NSKVONotifyingOriginalClassForIsa(cls);
        NSKVOGetterStruct kvoKey = {
            .evil = NULL,
            .cls = originalClass,
            .key = key,
            .implementation = NULL,
            .selector = NULL
        };
        
        if (NSKVOMutableArrayGetters == NULL)
        {
            NSKVOMutableArrayGetters = CFSetCreateMutable(kCFAllocatorDefault, 0, &_NSKVOSetterCallbacks);
        }
        NSKeyValueProxyGetter *arrayGetter = (NSKeyValueProxyGetter *)CFSetGetValue(NSKVOMutableArrayGetters, &kvoKey);
        if (arrayGetter == nil)
        {
            arrayGetter = [NSObject _createMutableArrayValueGetterWithContainerClassID:originalClass key:key];
            CFSetAddValue(NSKVOMutableArrayGetters, arrayGetter);
            [arrayGetter release];
        }
        
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:cls key:key mutableCollectionGetter:arrayGetter proxyClass:[NSKeyValueNotifyingMutableArray class]];
    }
    else
    {
        int keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char keyBuffer[keyLength+1];
        [key getCString:keyBuffer maxLength:keyLength+1 encoding:NSUTF8StringEncoding];

        if ([key length] != 0)
        {
            keyBuffer[0] = toupper(keyBuffer[0]);
        }

        // We already hold NSKVOLock
        // Must always have getter to be able to obtain original array
        // TODO Create macro for this code?
        NSKeyValueGetter *getter = [NSObject _createValueGetterWithContainerClassID:cls key:key];
        // Which "setters" have we got?
        Method insertObjectAtIndex = NSKeyValueMethodForPattern(cls, "insertObject:in%sAtIndex:", keyBuffer);
        Method insertObjectsAtIndexes = NSKeyValueMethodForPattern(cls, "insert%s:atIndexes:", keyBuffer);
        Method removeObjectAtIndex = NSKeyValueMethodForPattern(cls, "removeObjectFrom%sAtIndex:", keyBuffer);
        Method removeObjectsAtIndexes = NSKeyValueMethodForPattern(cls, "remove%sAtIndexes:", keyBuffer);

        BOOL hasInsertionAndRemovalMethods = (insertObjectAtIndex || insertObjectsAtIndexes) &&
                                             (removeObjectAtIndex || removeObjectsAtIndexes);
        if (!hasInsertionAndRemovalMethods)
        {
            NSKeyValueSetter *setter = [NSObject _createValueSetterWithContainerClassID:cls key:key];
            
            if ([setter isKindOfClass:[NSKeyValueIvarSetter class]])
            {
                NSKeyValueIvarSetter *ivarSetter = (NSKeyValueIvarSetter*)setter;
                (void)ivarSetter;
                
                return [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:[ivarSetter ivar] proxyClass:[NSKeyValueIvarMutableArray class]];
            }
            else
            {
                return [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:cls key:key baseGetter:getter baseSetter:setter containerIsa:cls proxyClass:[NSKeyValueSlowMutableArray class]];
            }
        }
        else
        {
            NSKeyValueMutatingArrayMethodSet* mutatingMethods = [[NSKeyValueMutatingArrayMethodSet alloc] init];
            mutatingMethods->insertObjectAtIndex = insertObjectAtIndex;
            mutatingMethods->insertObjectsAtIndexes = insertObjectsAtIndexes;
            mutatingMethods->removeObjectAtIndex = removeObjectAtIndex;
            mutatingMethods->removeObjectsAtIndexes = removeObjectsAtIndexes;

            // We'll use replacement functions if we've got them.
            mutatingMethods->replaceObjectAtIndex = NSKeyValueMethodForPattern(cls, "replaceObjectIn%sAtIndex:withObject:", keyBuffer);
            mutatingMethods->replaceObjectsAtIndexes = NSKeyValueMethodForPattern(cls, "replace%sAtIndexes:with%s:", keyBuffer);

            NSKeyValueProxyGetter* proxy;
            if ([getter isKindOfClass:[NSKeyValueCollectionGetter class]])
            {
                NSKeyValueCollectionGetter* collectionGetter = (NSKeyValueCollectionGetter*)getter;
                proxy = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:cls key:key nonmutatingMethods:[collectionGetter methods] mutatingMethods:mutatingMethods proxyClass:[NSKeyValueFastMutableArray1 class]];
            }
            else
            {
                proxy = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:cls key:key baseGetter:getter mutatingMethods:mutatingMethods proxyClass:[NSKeyValueFastMutableArray2 class]];
            }
            
            [mutatingMethods release];
            return proxy;
        }
    }
}

+ (NSKeyValueProxyGetter*)_createMutableOrderedSetValueGetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    if (_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(cls, key))
    {
        Class originalClass = _NSKVONotifyingOriginalClassForIsa(cls);
        NSKVOGetterStruct kvoKey = {
            .evil = NULL,
            .cls = originalClass,
            .key = key,
            .implementation = NULL,
            .selector = NULL
        };
        
        if (NSKVOMutableOrderedSetGetters == NULL)
        {
            NSKVOMutableOrderedSetGetters = CFSetCreateMutable(kCFAllocatorDefault, 0, &_NSKVOSetterCallbacks);
        }
        NSKeyValueProxyGetter *orderedSetGetter = (NSKeyValueProxyGetter *)CFSetGetValue(NSKVOMutableOrderedSetGetters, &kvoKey);
        if (orderedSetGetter == nil)
        {
            orderedSetGetter = [NSObject _createMutableOrderedSetValueGetterWithContainerClassID:originalClass key:key];
            CFSetAddValue(NSKVOMutableOrderedSetGetters, orderedSetGetter);
            [orderedSetGetter release];
        }
        
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:cls key:key mutableCollectionGetter:orderedSetGetter proxyClass:[NSKeyValueNotifyingMutableOrderedSet class]];
    }
    else
    {
        int keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char keyBuffer[keyLength+1];
        [key getCString:keyBuffer maxLength:keyLength+1 encoding:NSUTF8StringEncoding];
        
        if ([key length] != 0)
        {
            keyBuffer[0] = toupper(keyBuffer[0]);
        }
        
        NSKeyValueGetter *getter = [NSObject _createValueGetterWithContainerClassID:cls key:key];
        
        Method insertObjectAtIndex = NSKeyValueMethodForPattern(cls, "insertObject:in%sAtIndex:", keyBuffer);
        Method insertObjectsAtIndexes = NSKeyValueMethodForPattern(cls, "insert%s:atIndexes:", keyBuffer);
        Method removeObjectAtIndex = NSKeyValueMethodForPattern(cls, "removeObjectFrom%sAtIndex:", keyBuffer);
        Method removeObjectsAtIndexes = NSKeyValueMethodForPattern(cls, "remove%sAtIndexes:", keyBuffer);
        
        BOOL hasInsertionAndRemovalMethods = (insertObjectAtIndex || insertObjectsAtIndexes) &&
                                             (removeObjectAtIndex || removeObjectsAtIndexes);
        if (!hasInsertionAndRemovalMethods)
        {
            NSKeyValueSetter *setter = [NSObject _createValueSetterWithContainerClassID:cls key:key];
            if ([setter isKindOfClass:[NSKeyValueIvarSetter class]])
            {
                NSKeyValueIvarSetter *ivarSetter = (NSKeyValueIvarSetter*)setter;
                (void)ivarSetter;
                
                return [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:[ivarSetter ivar] proxyClass:[NSKeyValueIvarMutableOrderedSet class]];
            }
            else
            {
                return [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:cls key:key baseGetter:getter baseSetter:setter containerIsa:cls proxyClass:[NSKeyValueSlowMutableOrderedSet class]];
            }
        }
        else
        {
            NSKeyValueMutatingOrderedSetMethodSet* mutatingMethods = [[NSKeyValueMutatingOrderedSetMethodSet alloc] init];
            mutatingMethods->insertObjectAtIndex = insertObjectAtIndex;
            mutatingMethods->insertObjectsAtIndexes = insertObjectsAtIndexes;
            mutatingMethods->removeObjectAtIndex = removeObjectAtIndex;
            mutatingMethods->removeObjectsAtIndexes = removeObjectsAtIndexes;
            mutatingMethods->replaceObjectAtIndex = NSKeyValueMethodForPattern(cls, "replaceObjectIn%sAtIndex:withObject:", keyBuffer);
            mutatingMethods->replaceObjectsAtIndexes = NSKeyValueMethodForPattern(cls, "replace%sAtIndexes:with%s:", keyBuffer);
            
            NSKeyValueProxyGetter* proxy;
            if ([getter isKindOfClass:[NSKeyValueCollectionGetter class]])
            {
                NSKeyValueCollectionGetter* collectionGetter = (NSKeyValueCollectionGetter*)getter;
                proxy = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:cls key:key nonmutatingMethods:[collectionGetter methods] mutatingMethods:mutatingMethods proxyClass:[NSKeyValueFastMutableOrderedSet1 class]];
            }
            else
            {
                proxy = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:cls key:key baseGetter:getter mutatingMethods:mutatingMethods proxyClass:[NSKeyValueFastMutableOrderedSet2 class]];
            }
            
            [mutatingMethods release];
            return proxy;
        }
    }
}

+ (NSKeyValueProxyGetter*)_createMutableSetValueGetterWithContainerClassID:(Class)cls key:(NSString *)key
{
    if (_NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(cls, key))
    {
        Class originalClass = _NSKVONotifyingOriginalClassForIsa(cls);
        NSKVOGetterStruct kvoKey = {
            .evil = NULL,
            .cls = originalClass,
            .key = key,
            .implementation = NULL,
            .selector = NULL
        };
        
        if (NSKVOMutableSetGetters == NULL)
        {
            NSKVOMutableSetGetters = CFSetCreateMutable(kCFAllocatorDefault, 0, &_NSKVOSetterCallbacks);
        }
        NSKeyValueProxyGetter *setGetter = (NSKeyValueProxyGetter *)CFSetGetValue(NSKVOMutableSetGetters, &kvoKey);
        if (setGetter == nil)
        {
            setGetter = [NSObject _createMutableSetValueGetterWithContainerClassID:originalClass key:key];
            CFSetAddValue(NSKVOMutableSetGetters, setGetter);
            [setGetter release];
        }
        
        return [[NSKeyValueNotifyingMutableCollectionGetter alloc] initWithContainerClassID:cls key:key mutableCollectionGetter:setGetter proxyClass:[NSKeyValueNotifyingMutableSet class]];
    }
    else
    {
        int keyLength = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        char keyBuffer[keyLength+1];
        [key getCString:keyBuffer maxLength:keyLength+1 encoding:NSUTF8StringEncoding];
        
        if ([key length] != 0)
        {
            keyBuffer[0] = toupper(keyBuffer[0]);
        }
        
        NSKeyValueGetter *getter = [NSObject _createValueGetterWithContainerClassID:cls key:key];
        
        Method addObject = NSKeyValueMethodForPattern(cls, "add%sObject:", keyBuffer);
        Method unionSet = NSKeyValueMethodForPattern(cls, "add%s:", keyBuffer);
        Method removeObject = NSKeyValueMethodForPattern(cls, "remove%sObject:", keyBuffer);
        Method minusSet = NSKeyValueMethodForPattern(cls, "remove%s:", keyBuffer);
        
        BOOL hasAdditionAndRemovalMethods = (addObject || unionSet) &&
                                            (removeObject || minusSet);
        if (!hasAdditionAndRemovalMethods)
        {
            NSKeyValueSetter *setter = [NSObject _createValueSetterWithContainerClassID:cls key:key];
            if ([setter isKindOfClass:[NSKeyValueIvarSetter class]])
            {
                NSKeyValueIvarSetter *ivarSetter = (NSKeyValueIvarSetter*)setter;
                (void)ivarSetter;
                
                return [[NSKeyValueIvarMutableCollectionGetter alloc] initWithContainerClassID:cls key:key containerIsa:cls ivar:[ivarSetter ivar] proxyClass:[NSKeyValueIvarMutableSet class]];
            }
            else
            {
                return [[NSKeyValueSlowMutableCollectionGetter alloc] initWithContainerClassID:cls key:key baseGetter:getter baseSetter:setter containerIsa:cls proxyClass:[NSKeyValueSlowMutableSet class]];
            }
        }
        else
        {
            NSKeyValueMutatingSetMethodSet* mutatingMethods = [[NSKeyValueMutatingSetMethodSet alloc] init];
            mutatingMethods->addObject = addObject;
            mutatingMethods->unionSet = unionSet;
            mutatingMethods->removeObject = removeObject;
            mutatingMethods->minusSet = minusSet;
            mutatingMethods->intersectSet = NSKeyValueMethodForPattern(cls, "intersect%s:", keyBuffer);
            mutatingMethods->setSet = NSKeyValueMethodForPattern(cls, "set%s:", keyBuffer);
            
            NSKeyValueProxyGetter* proxy;
            if ([getter isKindOfClass:[NSKeyValueCollectionGetter class]])
            {
                NSKeyValueCollectionGetter* collectionGetter = (NSKeyValueCollectionGetter*)getter;
                proxy = [[NSKeyValueFastMutableCollection1Getter alloc] initWithContainerClassID:cls key:key nonmutatingMethods:[collectionGetter methods] mutatingMethods:mutatingMethods proxyClass:[NSKeyValueFastMutableSet1 class]];
            }
            else
            {
                proxy = [[NSKeyValueFastMutableCollection2Getter alloc] initWithContainerClassID:cls key:key baseGetter:getter mutatingMethods:mutatingMethods proxyClass:[NSKeyValueFastMutableSet2 class]];
            }
            
            [mutatingMethods release];
            return proxy;
        }
    }
}

@end
