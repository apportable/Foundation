/** Implementation of KeyValueCoding for GNUStep
   Copyright (C) 2000,2002 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   <title>NSKeyValueCoding informal protocol reference</title>
   $Date: 2010-09-10 05:47:04 -0700 (Fri, 10 Sep 2010) $ $Revision: 31293 $
 */

#import "common.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSException.h"
#import "Foundation/NSKeyValueCoding.h"
#import "Foundation/NSMethodSignature.h"
#import "Foundation/NSNull.h"
#import "Foundation/NSSet.h"
#import "Foundation/NSValue.h"

/* For the NSKeyValueMutableArray and NSKeyValueMutableSet classes
 */
#include "NSKeyValueMutableArray.m"
#include "NSKeyValueMutableSet.m"

#include <pthread.h>
#include <assert.h>

/* For backward compatibility NSUndefinedKeyException is actually the same
 * as the older NSUnknownKeyException
 */
NSString* const NSUnknownKeyException = @"NSUnknownKeyException";
NSString* const NSUndefinedKeyException = @"NSUnknownKeyException";


/* this should move into autoconf once it's accepted */
#define WANT_DEPRECATED_KVC_COMPAT 1

#ifdef WANT_DEPRECATED_KVC_COMPAT

static IMP takePath = 0;
static IMP takeValue = 0;
static IMP takePathKVO = 0;
static IMP takeValueKVO = 0;

static inline void setupCompat()
{
    if (takePath == 0)
    {
        Class c = NSClassFromString(@"GSKVOBase");

        takePathKVO = [c instanceMethodForSelector:
                       @selector(takeValue:forKeyPath:)];
        takePath = [NSObject instanceMethodForSelector:
                    @selector(takeValue:forKeyPath:)];
        takeValueKVO = [c instanceMethodForSelector:
                        @selector(takeValue:forKey:)];
        takeValue = [NSObject instanceMethodForSelector:
                     @selector(takeValue:forKey:)];
    }
}

#endif

extern char *_objc_copyPropertyAttributeValueStarting(const char *attrs, const char *name);

static inline Method MethodFromFormat(Class cls, char *buffer, size_t capacity, const char *format, const char *name)
{
    snprintf(buffer, capacity, format, name);
    SEL selector = sel_registerName(buffer);
    return class_getInstanceMethod(cls, selector);
}

static inline Method MethodForSetter(Class cls, char *buffer, size_t capacity, const char *name, const char *ucase_name)
{
    Method m = NULL;

    m = MethodFromFormat(cls, buffer, capacity, "set%s:", ucase_name);
    if (m != NULL)
    {
        return m;
    }

    m = MethodFromFormat(cls, buffer, capacity, "_set%s:", ucase_name);
    if (m != NULL)
    {
        return m;
    }

    return m;
}

static inline Method MethodForGetter(Class cls, char *buffer, size_t capacity, const char *name, const char *ucase_name)
{
    Method m = NULL;

    m = MethodFromFormat(cls, buffer, capacity, "get%s", ucase_name);
    if (m != NULL)
    {
        return m;
    }

    m = MethodFromFormat(cls, buffer, capacity, "%s", name);
    if (m != NULL)
    {
        return m;
    }

    m = MethodFromFormat(cls, buffer, capacity, "is%s", ucase_name);
    if (m != NULL)
    {
        return m;
    }

    m = MethodFromFormat(cls, buffer, capacity, "_get%s", ucase_name);
    if (m != NULL)
    {
        return m;
    }

    m = MethodFromFormat(cls, buffer, capacity, "_%s", name);
    if (m != NULL)
    {
        return m;
    }

    return m;
}

static inline Method MethodForPrimitiveSetter(Class cls, char *buffer, size_t capacity, const char *name, const char *ucase_name)
{
    return MethodFromFormat(cls, buffer, capacity, "setPrimitive%s:", ucase_name);
}

static inline Method MethodForPrimitiveGetter(Class cls, char *buffer, size_t capacity, const char *name, const char *ucase_name)
{
    return MethodFromFormat(cls, buffer, capacity, "primitive%s", ucase_name);
}

static inline Ivar IvarFromFormat(Class cls, char *buffer, size_t capacity, const char *format, const char *name)
{
    snprintf(buffer, capacity, format, name);
    return class_getInstanceVariable(cls, buffer);
}

static inline Ivar IvarForProperty(Class cls, char *buffer, size_t capacity, const char *name, const char *ucase_name)
{
    Ivar iv = NULL;

    iv = IvarFromFormat(cls, buffer, capacity, "_%s", name);
    if (iv != NULL)
    {
        return iv;
    }

    iv = IvarFromFormat(cls, buffer, capacity, "_is%s", ucase_name);
    if (iv != NULL)
    {
        return iv;
    }

    iv = IvarFromFormat(cls, buffer, capacity, "%s", name);
    if (iv != NULL)
    {
        return iv;
    }

    iv = IvarFromFormat(cls, buffer, capacity, "is%s", ucase_name);
    if (iv != NULL)
    {
        return iv;
    }

    return iv;
}

@interface _NSKVCContainer : NSObject
@end

@implementation _NSKVCContainer {
    Method _setterMethod;
    Method _getterMethod;
    Ivar _ivar;
    Class _class;
    NSString *_key;
}

- (Class)classRef
{
    return _class;
}

- (NSString *)key
{
    return _key;
}

- (BOOL)isEqual:(id)other
{
    if (other != self)
    {
        if ([other isKindOfClass:[_NSKVCContainer class]])
        {
            if ([other hash] != [self hash])
            {
                return ([(_NSKVCContainer *)other classRef] == _class &&
                        [[(_NSKVCContainer *)other key] isEqualToString:_key]);
            }
            else
            {
                return YES;
            }
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

- (id)initWithClass:(Class)cls key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        _class = cls;
        _key = [key copy];
        _getterMethod = NULL;
        _setterMethod = NULL;
        _ivar = NULL;
    }
    return self;
}

- (void)dealloc
{
    [_key release];
    [super dealloc];
}

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static NSMutableSet *NSKVCContainers = nil;

+ (_NSKVCContainer *)containerForObject:(NSObject *)object key:(NSString *)key
{
    _NSKVCContainer *found = nil;
    _NSKVCContainer *search = [[_NSKVCContainer alloc] initWithClass:object_getClass(object) key:key];
    pthread_mutex_lock(&lock);
    if (NSKVCContainers == nil)
    {
        NSKVCContainers = [[NSMutableSet alloc] init];
    }
    found = [NSKVCContainers member:search];
    if (found == nil)
    {
        [NSKVCContainers addObject:search];
        found = search;
    }
    pthread_mutex_unlock(&lock);
    [search release];
    return found;
}

#ifndef NDEBUG
// Apple does not throw an exception, and some games depend on this fault
// tolerance.
#define CHECK_VALUE_TYPE(value, type) do { \
        if (![value isKindOfClass:[type class]]) { \
            DEBUG_LOG("============ CHECK_VALUE_TYPE: ASSERTION ============"); \
            DEBUG_LOG("%s:%d - CHECK_VALUE_TYPE Failed: Value '%s' is not of Class '%s'", __FILE__, __LINE__, [[value description] UTF8String], [[type className] UTF8String]); \
        } \
} while(0)
#else
#define CHECK_VALUE_TYPE(value, type) do {} while(0)
#endif

#define ASSIGN_IVAR(ret, addr, value, type, method) do { \
        CHECK_VALUE_TYPE(value, type); \
        *(ret *)addr = (ret)[(type *)value method]; \
} while(0)

#define GET_IVAR(ret, addr, type, method) \
    [type method:*(ret *)addr]

#define CALL_SETTER_METHOD(ret, imp, object, cmd, value, type, method) do { \
        ((void (*)(id, SEL, ret))imp)(object, cmd, (ret)[(type *)value method]); \
} while(0)

#define CALL_GETTER_METHOD(ret, imp, object, cmd, type, method) \
    [type method:((ret (*)(id, SEL))imp)(object, cmd)]

- (void)initializeAccessors
{
    const char *name = [_key UTF8String];
    char *ucase_name = strdup(name);
    ucase_name[0] = toupper(name[0]);

    size_t len = [_key length];
    size_t capacity = 14 + len;  // 14 is the length of setPrimitive:
    char buffer[capacity]; // enough to hold setPrimitive%s:

    if ([_class accessInstanceVariablesDirectly])
    {
        _ivar = IvarForProperty(_class, buffer, capacity, name, ucase_name);
    }
    if (_setterMethod == NULL)
    {
        _setterMethod = MethodForSetter(_class, buffer, capacity, name, ucase_name);
        if (_setterMethod == NULL)
        {
            _setterMethod = MethodForPrimitiveSetter(_class, buffer, capacity, name, ucase_name);
        }
    }
    if (_getterMethod == NULL)
    {
        _getterMethod = MethodForGetter(_class, buffer, capacity, name, ucase_name);
        if (_getterMethod == NULL)
        {
            _getterMethod = MethodForPrimitiveGetter(_class, buffer, capacity, name, ucase_name);
        }
    }
    free(ucase_name);
}

- (void)setValue:(id)value forObject:(NSObject *)object
{
    if (_setterMethod == NULL && _ivar == NULL)
    {
        [self initializeAccessors];
    }
    if (_setterMethod != NULL)
    {
        IMP imp = method_getImplementation(_setterMethod);
        SEL cmd = method_getName(_setterMethod);
        char *encoding = method_copyArgumentType(_setterMethod, 2);

        switch(*encoding)
        {
        case _C_ID:
            imp(object, cmd, value);
            break;
        case _C_CLASS:
        case _C_SEL:
        case _C_PTR:
        case _C_CHARPTR:
            CALL_SETTER_METHOD(void *, imp, object, cmd, value, NSValue, pointerValue);
            break;
        case _C_CHR:
            CALL_SETTER_METHOD(char, imp, object, cmd, value, NSNumber, charValue);
            break;
        case _C_UCHR:
            CALL_SETTER_METHOD(unsigned char, imp, object, cmd, value, NSNumber, unsignedCharValue);
            break;
        case _C_SHT:
            CALL_SETTER_METHOD(short, imp, object, cmd, value, NSNumber, shortValue);
            break;
        case _C_USHT:
            CALL_SETTER_METHOD(unsigned short, imp, object, cmd, value, NSNumber, unsignedShortValue);
            break;
        case _C_INT:
            CALL_SETTER_METHOD(int, imp, object, cmd, value, NSNumber, intValue);
            break;
        case _C_UINT:
            CALL_SETTER_METHOD(unsigned long, imp, object, cmd, value, NSNumber, unsignedIntValue);
            break;
        case _C_LNG:
            CALL_SETTER_METHOD(long, imp, object, cmd, value, NSNumber, longValue);
            break;
        case _C_ULNG:
            CALL_SETTER_METHOD(unsigned long, imp, object, cmd, value, NSNumber, unsignedLongValue);
            break;
        case _C_LNG_LNG:
            CALL_SETTER_METHOD(long long, imp, object, cmd, value, NSNumber, longLongValue);
            break;
        case _C_ULNG_LNG:
            CALL_SETTER_METHOD(unsigned long long, imp, object, cmd, value, NSNumber, unsignedLongLongValue);
            break;
        case _C_FLT:
            CALL_SETTER_METHOD(float, imp, object, cmd, value, NSNumber, floatValue);
            break;
        case _C_DBL:
            CALL_SETTER_METHOD(double, imp, object, cmd, value, NSNumber, doubleValue);
            break;
        case _C_STRUCT_B: {
            CHECK_VALUE_TYPE(value, NSValue);
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:cmd]];
            [inv setTarget:object];
            [inv setSelector:cmd];
            void *val = malloc(objc_sizeof_type(encoding));
            [(NSValue *)value getValue : val];
            [inv setArgument:val atIndex:2];
            [inv invoke];
            free(val);
            break;
        }
        }

        free(encoding);
    }
    else if (_ivar != NULL)
    {
        char *addr = (char*)object;
        addr += ivar_getOffset(_ivar);
        const char *encoding = ivar_getTypeEncoding(_ivar);
        switch (*encoding)
        {
        case _C_ID:
            // Apple does it like this... I think it is rather dangerous, espc
            // with the way this ignores properties.. but they didnt ask me...
            [*(id < NSObject > *) addr autorelease];
            *(id *)addr = [value retain];
            break;
        case _C_CLASS:
        case _C_SEL:
        case _C_PTR:
        case _C_CHARPTR:
            ASSIGN_IVAR(void*, addr, value, NSValue, pointerValue);
            break;
        case _C_CHR:
            ASSIGN_IVAR(char, addr, value, NSNumber, charValue);
            break;
        case _C_UCHR:
            ASSIGN_IVAR(unsigned char, addr, value, NSNumber, unsignedCharValue);
            break;
        case _C_SHT:
            ASSIGN_IVAR(short, addr, value, NSNumber, shortValue);
            break;
        case _C_USHT:
            ASSIGN_IVAR(unsigned short, addr, value, NSNumber, unsignedShortValue);
            break;
        case _C_INT:
            ASSIGN_IVAR(int, addr, value, NSNumber, intValue);
            break;
        case _C_UINT:
            ASSIGN_IVAR(unsigned int, addr, value, NSNumber, unsignedIntValue);
            break;
        case _C_LNG:
            ASSIGN_IVAR(long, addr, value, NSNumber, longValue);
            break;
        case _C_ULNG:
            ASSIGN_IVAR(unsigned long, addr, value, NSNumber, unsignedLongValue);
            break;
        case _C_LNG_LNG:
            ASSIGN_IVAR(long long, addr, value, NSNumber, longLongValue);
            break;
        case _C_ULNG_LNG:
            ASSIGN_IVAR(unsigned long long, addr, value, NSNumber, unsignedLongLongValue);
            break;
        case _C_FLT:
            ASSIGN_IVAR(float, addr, value, NSNumber, floatValue);
            break;
        case _C_DBL:
            ASSIGN_IVAR(double, addr, value, NSNumber, doubleValue);
            break;
        case _C_STRUCT_B:
            CHECK_VALUE_TYPE(value, NSValue);
            [(NSValue *)value getValue : addr];
            break;
        }
    }
    else
    {
        [object setValue:value forUndefinedKey:_key];
    }
}

- (id)valueForObject:(NSObject *)object
{
    id value = NULL;
    if (_getterMethod == NULL && _ivar == NULL)
    {
        [self initializeAccessors];
    }

    if (_getterMethod)
    {
        IMP imp = method_getImplementation(_getterMethod);
        SEL cmd = method_getName(_getterMethod);
        char *encoding = method_copyReturnType(_getterMethod);
        switch (*encoding)
        {
        case _C_ID:
            value = imp(object, cmd);
            break;
        case _C_CLASS:
        case _C_SEL:
        case _C_PTR:
        case _C_CHARPTR:
            value = CALL_GETTER_METHOD(void*, imp, object, cmd, NSValue, valueWithPointer);
            break;
        case _C_CHR:
            value = CALL_GETTER_METHOD(char, imp, object, cmd, NSNumber, numberWithChar);
            break;
        case _C_UCHR:
            value = CALL_GETTER_METHOD(unsigned char, imp, object, cmd, NSNumber, numberWithUnsignedChar);
            break;
        case _C_SHT:
            value = CALL_GETTER_METHOD(short, imp, object, cmd, NSNumber, numberWithShort);
            break;
        case _C_USHT:
            value = CALL_GETTER_METHOD(unsigned short, imp, object, cmd, NSNumber, numberWithUnsignedShort);
            break;
        case _C_INT:
            value = CALL_GETTER_METHOD(int, imp, object, cmd, NSNumber, numberWithInt);
            break;
        case _C_UINT:
            value = CALL_GETTER_METHOD(unsigned long, imp, object, cmd, NSNumber, numberWithUnsignedInt);
            break;
        case _C_LNG:
            value = CALL_GETTER_METHOD(long, imp, object, cmd, NSNumber, numberWithLong);
            break;
        case _C_ULNG:
            value = CALL_GETTER_METHOD(unsigned long, imp, object, cmd, NSNumber, numberWithUnsignedLong);
            break;
        case _C_LNG_LNG:
            value = CALL_GETTER_METHOD(long long, imp, object, cmd, NSNumber, numberWithLongLong);
            break;
        case _C_ULNG_LNG:
            value = CALL_GETTER_METHOD(unsigned long long, imp, object, cmd, NSNumber, numberWithUnsignedLongLong);
            break;
        case _C_FLT:
            value = CALL_GETTER_METHOD(float, imp, object, cmd, NSNumber, numberWithFloat);
            break;
        case _C_DBL:
            value = CALL_GETTER_METHOD(double, imp, object, cmd, NSNumber, numberWithDouble);
            break;
        case _C_STRUCT_B: {
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[object methodSignatureForSelector:cmd]];
            [inv setTarget:object];
            [inv setSelector:cmd];
            void *val = malloc([[inv methodSignature] methodReturnLength]);
            [inv invoke];
            [inv getReturnValue:val];
            value = [NSValue valueWithBytes:val objCType:encoding];
            free(val);
            break;
        }
        }
        free(encoding);
    }
    else if (_ivar)
    {
        char *addr = (char*)object;
        addr += ivar_getOffset(_ivar);
        const char *encoding = ivar_getTypeEncoding(_ivar);
        switch (*encoding)
        {
        case _C_ID:
            value = *(id *)addr;
            break;
        case _C_CLASS:
        case _C_SEL:
        case _C_PTR:
        case _C_CHARPTR:
            value = GET_IVAR(void*, addr, NSValue, valueWithPointer);
            break;
        case _C_CHR:
            value = GET_IVAR(char, addr, NSNumber, numberWithChar);
            break;
        case _C_UCHR:
            value = GET_IVAR(unsigned char, addr, NSNumber, numberWithUnsignedChar);
            break;
        case _C_SHT:
            value = GET_IVAR(short, addr, NSNumber, numberWithUnsignedShort);
            break;
        case _C_USHT:
            value = GET_IVAR(unsigned short, addr, NSNumber, numberWithUnsignedShort);
            break;
        case _C_INT:
            value = GET_IVAR(int, addr, NSNumber, numberWithInt);
            break;
        case _C_UINT:
            value = GET_IVAR(unsigned int, addr, NSNumber, numberWithUnsignedInt);
            break;
        case _C_LNG:
            value = GET_IVAR(long, addr, NSNumber, numberWithLong);
            break;
        case _C_ULNG:
            value = GET_IVAR(unsigned long, addr, NSNumber, numberWithUnsignedLong);
            break;
        case _C_LNG_LNG:
            value = GET_IVAR(long long, addr, NSNumber, numberWithLongLong);
            break;
        case _C_ULNG_LNG:
            value = GET_IVAR(unsigned long long, addr, NSNumber, numberWithUnsignedLongLong);
            break;
        case _C_FLT:
            value = GET_IVAR(float, addr, NSNumber, numberWithFloat);
            break;
        case _C_DBL:
            value = GET_IVAR(double, addr, NSNumber, numberWithDouble);
            break;
        case _C_STRUCT_B:
            value = [NSValue value:addr withObjCType:encoding];
            break;
        }
    }

    return value;
}

@end

static id ValueForKey(NSObject *self, const char *key, unsigned size)
{
    SEL sel = 0;
    int off = 0;
    const char    *type = NULL;

    if (size > 0)
    {
        const char    *name;
        char buf[size+5];
        char lo;
        char hi;

        strcpy(buf, "_get");
        strcpy(&buf[4], key);
        lo = buf[4];
        hi = islower(lo) ? toupper(lo) : lo;
        buf[4] = hi;

        name = &buf[1]; // getKey
        sel = sel_getUid(name);
        if (sel == 0 || [self respondsToSelector:sel] == NO)
        {
            buf[4] = lo;
            name = &buf[4]; // key
            sel = sel_getUid(name);
            if (sel == 0 || [self respondsToSelector:sel] == NO)
            {
                buf[4] = hi;
                buf[3] = 's';
                buf[2] = 'i';
                name = &buf[2]; // isKey
                sel = sel_getUid(name);
                if (sel == 0 || [self respondsToSelector:sel] == NO)
                {
                    sel = 0;
                }
            }
        }

        if (sel == 0 && [[self class] accessInstanceVariablesDirectly] == YES)
        {
            buf[4] = hi;
            name = buf; // _getKey
            sel = sel_getUid(name);
            if (sel == 0 || [self respondsToSelector:sel] == NO)
            {
                buf[4] = lo;
                buf[3] = '_';
                name = &buf[3]; // _key
                sel = sel_getUid(name);
                if (sel == 0 || [self respondsToSelector:sel] == NO)
                {
                    sel = 0;
                }
            }
            if (sel == 0)
            {
                buf[4] = lo;
                buf[3] = '_';
                name = &buf[3]; // _key
                if (GSObjCFindVariable(self, name, &type, &size, &off) == NO)
                {
                    buf[4] = hi;
                    buf[3] = 's';
                    buf[2] = 'i';
                    buf[1] = '_';
                    name = &buf[1]; // _isKey
                    if (!GSObjCFindVariable(self, name, &type, &size, &off))
                    {
                        buf[4] = lo;
                        name = &buf[4];     // key
                        if (!GSObjCFindVariable(self, name, &type, &size, &off))
                        {
                            buf[4] = hi;
                            buf[3] = 's';
                            buf[2] = 'i';
                            name = &buf[2]; // isKey
                            GSObjCFindVariable(self, name, &type, &size, &off);
                        }
                    }
                }
            }
        }
    }
    return GSObjCGetVal(self, key, sel, type, size, off);
}


@implementation NSObject (KeyValueCoding)

+ (BOOL)accessInstanceVariablesDirectly
{
    return YES;
}


- (NSDictionary*)dictionaryWithValuesForKeys:(NSArray*)keys
{
    NSMutableDictionary   *dictionary;
    NSEnumerator      *enumerator;
    id key;
#ifdef WANT_DEPRECATED_KVC_COMPAT
    static IMP o = 0;

    /* Backward compatibility hack */
    if (o == 0)
    {
        o = [NSObject instanceMethodForSelector:
             @selector(valuesForKeys:)];
    }
    if ([self methodForSelector:@selector(valuesForKeys:)] != o)
    {
        return [self valuesForKeys:keys];
    }
#endif

    dictionary = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
    enumerator = [keys objectEnumerator];
    while ((key = [enumerator nextObject]) != nil)
    {
        id value = [self valueForKey:key];

        if (value == nil)
        {
            value = [NSNull null];
        }
        [dictionary setObject:value forKey:key];
    }
    return dictionary;
}

- (NSMutableSet*)mutableSetValueForKey:(NSString*)aKey
{
    return [NSKeyValueMutableSet setForKey:aKey ofObject:self];
}

- (NSMutableSet*)mutableSetValueForKeyPath:(NSString*)aKey
{
    NSRange r = [aKey rangeOfString:@"."];

    if (r.length == 0)
    {
        return [self mutableSetValueForKey:aKey];
    }
    else
    {
        NSString  *key = [aKey substringToIndex:r.location];
        NSString  *path = [aKey substringFromIndex:NSMaxRange(r)];

        return [[self valueForKey:key] mutableSetValueForKeyPath:path];
    }
}

- (NSMutableArray*)mutableArrayValueForKey:(NSString*)aKey
{
    return [NSKeyValueMutableArray arrayForKey:aKey ofObject:self];
}

- (NSMutableArray*)mutableArrayValueForKeyPath:(NSString*)aKey
{
    NSRange r = [aKey rangeOfString:@"."];

    if (r.length == 0)
    {
        return [self mutableArrayValueForKey:aKey];
    }
    else
    {
        NSString  *key = [aKey substringToIndex:r.location];
        NSString  *path = [aKey substringFromIndex:NSMaxRange(r)];

        return [[self valueForKey:key] mutableArrayValueForKeyPath:path];
    }
}

- (void)setNilValueForKey:(NSString*)aKey
{
#ifdef WANT_DEPRECATED_KVC_COMPAT
    static IMP o = 0;

    /* Backward compatibility hack */
    if (o == 0)
    {
        o = [NSObject instanceMethodForSelector:
             @selector(unableToSetNilForKey:)];
    }
    if ([self methodForSelector:@selector(unableToSetNilForKey:)] != o)
    {
        [self unableToSetNilForKey:aKey];
        return;
    }
#endif
    [NSException raise:NSInvalidArgumentException
     format:@"%@ -- %@ 0x%x: Given nil value to set for key \"%@\"",
     NSStringFromSelector(_cmd), NSStringFromClass([self class]),
     self, aKey];
}


- (void)setValue:(id)anObject forKey:(NSString*)aKey
{
#ifdef WANT_DEPRECATED_KVC_COMPAT
    IMP o = [self methodForSelector:@selector(takeValue:forKey:)];

    setupCompat();
    if (o != takeValue && o != takeValueKVO)
    {
        (*o)(self, @selector(takeValue:forKey:), anObject, aKey);
        return;
    }
#endif
    [[_NSKVCContainer containerForObject:self key:aKey] setValue:anObject forObject:self];
}


- (void)setValue:(id)anObject forKeyPath:(NSString*)aKey
{
    NSRange r = [aKey rangeOfString:@"."];
#ifdef WANT_DEPRECATED_KVC_COMPAT
    IMP o = [self methodForSelector:@selector(takeValue:forKeyPath:)];

    setupCompat();
    if (o != takePath && o != takePathKVO)
    {
        (*o)(self, @selector(takeValue:forKeyPath:), anObject, aKey);
        return;
    }
#endif

    if (r.length == 0)
    {
        [self setValue:anObject forKey:aKey];
    }
    else
    {
        NSString  *key = [aKey substringToIndex:r.location];
        NSString  *path = [aKey substringFromIndex:NSMaxRange(r)];

        [[self valueForKey:key] setValue:anObject forKeyPath:path];
    }
}


- (void)setValue:(id)anObject forUndefinedKey:(NSString*)aKey
{
    NSDictionary  *dict;
    NSException   *exp;
#ifdef WANT_DEPRECATED_KVC_COMPAT
    static IMP o = 0;

    /* Backward compatibility hack */
    if (o == 0)
    {
        o = [NSObject instanceMethodForSelector:
             @selector(handleTakeValue:forUnboundKey:)];
    }
    if ([self methodForSelector:@selector(handleTakeValue:forUnboundKey:)] != o)
    {
        [self handleTakeValue:anObject forUnboundKey:aKey];
        return;
    }
#endif

    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            (anObject ? (id)anObject : (id)@"(nil)"), @"NSTargetObjectUserInfoKey",
            (aKey ? (id)aKey : (id)@"(nil)"), @"NSUnknownUserInfoKey",
            nil];
    exp = [NSException exceptionWithName:NSUndefinedKeyException
           reason:@"Unable to set nil value for key"
           userInfo:dict];
    [exp raise];
}


- (void)setValuesForKeysWithDictionary:(NSDictionary*)aDictionary
{
    NSEnumerator  *enumerator;
    NSString  *key;
#ifdef WANT_DEPRECATED_KVC_COMPAT
    static IMP o = 0;

    /* Backward compatibility hack */
    if (o == 0)
    {
        o = [NSObject instanceMethodForSelector:
             @selector(takeValuesFromDictionary:)];
    }
    if ([self methodForSelector:@selector(takeValuesFromDictionary:)] != o)
    {
        [self takeValuesFromDictionary:aDictionary];
        return;
    }
#endif

    enumerator = [aDictionary keyEnumerator];
    while ((key = [enumerator nextObject]) != nil)
    {
        [self setValue:[aDictionary objectForKey:key] forKey:key];
    }
}


- (BOOL)validateValue:(id*)aValue
    forKey:(NSString*)aKey
    error:(NSError**)anError
{
    unsigned size;

    if (aValue == 0 || (size = [aKey length] * 8) == 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil argument"];
    }
    else
    {
        char name[size+16];
        SEL sel;
        BOOL (*imp)(id,SEL,id*,id*);

        strcpy(name, "validate");
        [aKey getCString:&name[8]
         maxLength:size+1
         encoding:NSUTF8StringEncoding];
        size = strlen(&name[8]);
        strcpy(&name[size+8], ":error:");
        if (islower(name[8]))
        {
            name[8] = toupper(name[8]);
        }
        sel = sel_getUid(name);
        if (sel != 0 && [self respondsToSelector:sel] == YES)
        {
            imp = (BOOL (*)(id,SEL,id*,id*))[self methodForSelector : sel];
            return (*imp)(self, sel, aValue, anError);
        }
    }
    return YES;
}

- (BOOL)validateValue:(id*)aValue
    forKeyPath:(NSString*)aKey
    error:(NSError**)anError
{
    NSRange r = [aKey rangeOfString:@"."];

    if (r.length == 0)
    {
        return [self validateValue:aValue forKey:aKey error:anError];
    }
    else
    {
        NSString  *key = [aKey substringToIndex:r.location];
        NSString  *path = [aKey substringFromIndex:NSMaxRange(r)];

        return [[self valueForKey:key] validateValue:aValue
                forKeyPath:path
                error:anError];
    }
}


- (id)valueForKey:(NSString*)aKey
{
    return [[_NSKVCContainer containerForObject:self key:aKey] valueForObject:self];
}


- (id)valueForKeyPath:(NSString*)aKey
{
    NSRange r = [aKey rangeOfString:@"."];

    if (r.length == 0)
    {
        return [self valueForKey:aKey];
    }
    else
    {
        NSString  *key = [aKey substringToIndex:r.location];
        NSString  *path = [aKey substringFromIndex:NSMaxRange(r)];

        return [[self valueForKey:key] valueForKeyPath:path];
    }
}


- (id)valueForUndefinedKey:(NSString*)aKey
{
    NSDictionary  *dict;
    NSException   *exp;
    NSString      *reason;
#ifdef WANT_DEPRECATED_KVC_COMPAT
    static IMP o = 0;

    /* Backward compatibility hack */
    if (o == 0)
    {
        o = [NSObject instanceMethodForSelector:
             @selector(handleQueryWithUnboundKey:)];
    }
    if ([self methodForSelector:@selector(handleQueryWithUnboundKey:)] != o)
    {
        return [self handleQueryWithUnboundKey:aKey];
    }
#endif
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            self, @"NSTargetObjectUserInfoKey",
            (aKey ? (id)aKey : (id)@"(nil)"), @"NSUnknownUserInfoKey",
            nil];
    reason = [NSString stringWithFormat:
              @"Unable to find value for key \"%@\" of object %@ (%@)",
              aKey, self, [self class]];
    exp = [NSException exceptionWithName:NSUndefinedKeyException
           reason:reason
           userInfo:dict];

    [exp raise];
    return nil;
}


#ifdef WANT_DEPRECATED_KVC_COMPAT

+ (BOOL)useStoredAccessor
{
    return YES;
}

- (id)storedValueForKey:(NSString*)aKey
{
    unsigned size;

    if ([[self class] useStoredAccessor] == NO)
    {
        return [self valueForKey:aKey];
    }

    size = [aKey length] * 8;
    if (size > 0)
    {
        SEL sel = 0;
        const char    *type = NULL;
        int off = 0;
        const char    *name;
        char key[size+1];
        char buf[size+5];
        char lo;
        char hi;

        strcpy(buf, "_get");
        [aKey getCString:key
         maxLength:size+1
         encoding:NSUTF8StringEncoding];
        size = strlen(key);
        strcpy(&buf[4], key);
        lo = buf[4];
        hi = islower(lo) ? toupper(lo) : lo;
        buf[4] = hi;

        name = buf; // _getKey
        sel = sel_getUid(name);
        if (sel == 0 || [self respondsToSelector:sel] == NO)
        {
            buf[3] = '_';
            buf[4] = lo;
            name = &buf[3]; // _key
            sel = sel_getUid(name);
            if (sel == 0 || [self respondsToSelector:sel] == NO)
            {
                sel = 0;
            }
        }
        if (sel == 0)
        {
            if ([[self class] accessInstanceVariablesDirectly] == YES)
            {
                // _key
                if (GSObjCFindVariable(self, name, &type, &size, &off) == NO)
                {
                    name = &buf[4]; // key
                    GSObjCFindVariable(self, name, &type, &size, &off);
                }
            }
            if (type == NULL)
            {
                buf[3] = 't';
                buf[4] = hi;
                name = &buf[1]; // getKey
                sel = sel_getUid(name);
                if (sel == 0 || [self respondsToSelector:sel] == NO)
                {
                    buf[4] = lo;
                    name = &buf[4]; // key
                    sel = sel_getUid(name);
                    if (sel == 0 || [self respondsToSelector:sel] == NO)
                    {
                        sel = 0;
                    }
                }
            }
        }
        if (sel != 0 || type != NULL)
        {
            return GSObjCGetVal(self, key, sel, type, size, off);
        }
    }
    [self handleTakeValue:nil forUnboundKey:aKey];
    return nil;
}


- (void)takeStoredValue:(id)anObject forKey:(NSString*)aKey
{
    unsigned size;

    if ([[self class] useStoredAccessor] == NO)
    {
        [self takeValue:anObject forKey:aKey];
        return;
    }

    size = [aKey length] * 8;
    if (size > 0)
    {
        SEL sel;
        const char    *type;
        int off = 0;
        const char    *name;
        char key[size+1];
        char buf[size+6];
        char lo;
        char hi;

        strcpy(buf, "_set");
        [aKey getCString:key
         maxLength:size+1
         encoding:NSUTF8StringEncoding];
        size = strlen(key);
        strcpy(&buf[4], key);
        lo = buf[4];
        hi = islower(lo) ? toupper(lo) : lo;
        buf[4] = hi;
        buf[size+4] = ':';
        buf[size+5] = '\0';

        name = buf; // _setKey:
        type = NULL;
        sel = sel_getUid(name);
        if (sel == 0 || [self respondsToSelector:sel] == NO)
        {
            sel = 0;
            if ([[self class] accessInstanceVariablesDirectly] == YES)
            {
                buf[size+4] = '\0';
                buf[4] = lo;
                buf[3] = '_';
                name = &buf[3]; // _key
                if (GSObjCFindVariable(self, name, &type, &size, &off) == NO)
                {
                    name = &buf[4]; // key
                    GSObjCFindVariable(self, name, &type, &size, &off);
                }
            }
            if (type == NULL)
            {
                buf[size+4] = ':';
                buf[4] = hi;
                buf[3] = 't';
                name = &buf[1]; // setKey:
                sel = sel_getUid(name);
                if (sel == 0 || [self respondsToSelector:sel] == NO)
                {
                    sel = 0;
                }
            }
        }
        if (sel != 0 || type != NULL)
        {
            GSObjCSetVal(self, key, anObject, sel, type, size, off);
            return;
        }
    }
    [self handleTakeValue:anObject forUnboundKey:aKey];
}


- (void)takeStoredValuesFromDictionary:(NSDictionary*)aDictionary
{
    NSEnumerator  *enumerator = [aDictionary keyEnumerator];
    NSNull    *null = [NSNull null];
    NSString  *key;

    while ((key = [enumerator nextObject]) != nil)
    {
        id obj = [aDictionary objectForKey:key];

        if (obj == null)
        {
            obj = nil;
        }
        [self takeStoredValue:obj forKey:key];
    }
}

- (id)handleQueryWithUnboundKey:(NSString*)aKey
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self, @"NSTargetObjectUserInfoKey",
                          (aKey ? (id)aKey : (id)@"(nil)"), @"NSUnknownUserInfoKey",
                          nil];
    NSException *exp = [NSException exceptionWithName:NSUndefinedKeyException
                        reason:@"Unable to find value for key"
                        userInfo:dict];

    GSOnceMLog(@"This method is deprecated, use -valueForUndefinedKey:");
    [exp raise];
    return nil;
}


- (void)handleTakeValue:(id)anObject forUnboundKey:(NSString*)aKey
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          (anObject ? (id)anObject : (id)@"(nil)"), @"NSTargetObjectUserInfoKey",
                          (aKey ? (id)aKey : (id)@"(nil)"), @"NSUnknownUserInfoKey",
                          nil];
    NSException *exp = [NSException exceptionWithName:NSUndefinedKeyException
                        reason:@"Unable to set value for key"
                        userInfo:dict];
    GSOnceMLog(@"This method is deprecated, use -setValue:forUndefinedKey:");
    [exp raise];
}


- (void)takeValue:(id)anObject forKey:(NSString*)aKey
{
    SEL sel = 0;
    const char    *type = 0;
    int off = 0;
    unsigned size = [aKey length] * 8;
    char key[size+1];

    GSOnceMLog(@"This method is deprecated, use -setValue:forKey:");
    [aKey getCString:key
     maxLength:size+1
     encoding:NSUTF8StringEncoding];
    size = strlen(key);
    if (size > 0)
    {
        const char    *name;
        char buf[size+6];
        char lo;
        char hi;

        strcpy(buf, "_set");
        strcpy(&buf[4], key);
        lo = buf[4];
        hi = islower(lo) ? toupper(lo) : lo;
        buf[4] = hi;
        buf[size+4] = ':';
        buf[size+5] = '\0';

        name = &buf[1]; // setKey:
        type = NULL;
        sel = sel_getUid(name);
        if (sel == 0 || [self respondsToSelector:sel] == NO)
        {
            name = buf; // _setKey:
            sel = sel_getUid(name);
            if (sel == 0 || [self respondsToSelector:sel] == NO)
            {
                sel = 0;
                if ([[self class] accessInstanceVariablesDirectly] == YES)
                {
                    buf[size+4] = '\0';
                    buf[3] = '_';
                    buf[4] = lo;
                    name = &buf[4]; // key
                    if (GSObjCFindVariable(self, name, &type, &size, &off) == NO)
                    {
                        name = &buf[3]; // _key
                        GSObjCFindVariable(self, name, &type, &size, &off);
                    }
                }
            }
        }
    }
    GSObjCSetVal(self, key, anObject, sel, type, size, off);
}


- (void)takeValue:(id)anObject forKeyPath:(NSString*)aKey
{
    NSRange r = [aKey rangeOfString:@"."];

    GSOnceMLog(@"This method is deprecated, use -setValue:forKeyPath:");
    if (r.length == 0)
    {
        [self takeValue:anObject forKey:aKey];
    }
    else
    {
        NSString  *key = [aKey substringToIndex:r.location];
        NSString  *path = [aKey substringFromIndex:NSMaxRange(r)];

        [[self valueForKey:key] takeValue:anObject forKeyPath:path];
    }
}


- (void)takeValuesFromDictionary:(NSDictionary*)aDictionary
{
    NSEnumerator  *enumerator = [aDictionary keyEnumerator];
    NSNull    *null = [NSNull null];
    NSString  *key;

    GSOnceMLog(@"This method is deprecated, use -setValuesForKeysWithDictionary:");
    while ((key = [enumerator nextObject]) != nil)
    {
        id obj = [aDictionary objectForKey:key];

        if (obj == null)
        {
            obj = nil;
        }
        [self takeValue:obj forKey:key];
    }
}


- (void)unableToSetNilForKey:(NSString*)aKey
{
    GSOnceMLog(@"This method is deprecated, use -setNilValueForKey:");
    [NSException raise:NSInvalidArgumentException
     format:@"%@ -- %@ 0x%x: Given nil value to set for key \"%@\"",
     NSStringFromSelector(_cmd), NSStringFromClass([self class]), self, aKey];
}


- (NSDictionary*)valuesForKeys:(NSArray*)keys
{
    NSMutableDictionary   *dict;
    NSNull        *null = [NSNull null];
    unsigned count = [keys count];
    unsigned pos;

    GSOnceMLog(@"This method is deprecated, use -dictionaryWithValuesForKeys:");
    dict = [NSMutableDictionary dictionaryWithCapacity:count];
    for (pos = 0; pos < count; pos++)
    {
        NSString  *key = [keys objectAtIndex:pos];
        id val = [self valueForKey:key];

        if (val == nil)
        {
            val = null;
        }
        [dict setObject:val forKey:key];
    }
    return AUTORELEASE([dict copy]);
}

#endif

@end

