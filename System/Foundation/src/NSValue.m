//
//  NSValue.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSValueInternal.h"
#import <Foundation/NSObjCRuntime.h>
#import "NSObjectInternal.h"
#import "NSExternals.h"
#import <Foundation/NSCoder.h>
#import "NSCoderInternal.h"
#import <Foundation/NSRange.h>
#include <libkern/OSAtomic.h>
#include <objc/runtime.h>
#import "ForFoundationOnly.h"

static NSValue *_NSNewValue(void *value, const char *type);

@implementation NSValue

#define MAX_STACK 1024

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSNumber class])
    {
        static NSPlaceholderNumber *placeholder = nil;
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            placeholder = [NSPlaceholderNumber allocWithZone:zone];
        });
        return (NSNumber *)placeholder;
    }
    else if (self == [NSValue class])
    {
        static NSPlaceholderValue *placeholder = nil;
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            placeholder = [NSPlaceholderValue allocWithZone:zone];
        });
        return (NSValue *)placeholder;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (void)getValue:(void *)value
{
    NSRequestConcreteImplementation();
}

- (const char *)objCType
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [self release]; // we are going to create a new value no matter what

    uint8_t stack_val[MAX_STACK];
    uint8_t *val = &stack_val[0];

    char *type = NULL;
    NSUInteger size = 0;
    [aDecoder decodeValueOfObjCType:@encode(char *) at:&type];
    NSGetSizeAndAlignment(type, &size, NULL);
    if (size == 0)
    {
        return nil;
    }

    if (size > MAX_STACK)
    {
        val = malloc(size);
        if (val == NULL)
        {
            return nil;
        }
    }

    [aDecoder decodeValueOfObjCType:type at:val];
    
    NSValue *value = _NSNewValue(val, type);

    if (val != NULL && val != &stack_val[0])
    {
        free(val);
    }

    return value;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    uint8_t stack_val[MAX_STACK];
    uint8_t *val = &stack_val[0];

    const char *type = [self objCType];
    NSUInteger size = 0;
    NSGetSizeAndAlignment(type, &size, NULL);
    if (size > MAX_STACK)
    {
        val = malloc(size);
        if (val == NULL)
        {
            return;
        }
    }
    if (type[0] == '^' && type[1] == 'v')
    {
        [NSException raise:NSInvalidArgumentException format:@"unable to encode void * type value"];
        return;
    }
    [self getValue:val];
    [aCoder encodeValueOfObjCType:@encode(char *) at:&type];
    [aCoder encodeValueOfObjCType:type at:val];
    if (val != NULL && val != &stack_val[0])
    {
        free(val);
    }
}

- (Class)classForCoder
{
    return [NSValue class];
}

- (BOOL)isNSValue__
{
    return YES;
}

@end


static Boolean NSTypeInfoEqual(NSValueTypeInfo *type1, NSValueTypeInfo *type2)
{
    return strcmp(type1->name, type2->name) == 0;
}

static CFHashCode NSTypeInfoHash(NSValueTypeInfo *type)
{
    return CFStringHashISOLatin1CString(type->name, strlen(type->name));
}

@implementation NSPlaceholderValue

- (id)initWithBytes:(const void *)value objCType:(const char *)type
{
    return (id)_NSNewValue((uint8_t *)value, type);
}

static inline NSValue *createValue(void *value, const char *type, NSUInteger size, NSConcreteValueSpecialType flags)
{
    NSConcreteValue *obj = NSAllocateObject([NSConcreteValue class], size, NULL);
    obj->_specialFlags = flags;
    static dispatch_once_t once = 0L;
    static CFMutableSetRef typeInfoCache = NULL;
    static OSSpinLock lock = OS_SPINLOCK_INIT;
    dispatch_once(&once, ^{
            CFSetCallBacks callbacks = {
                0,
                NULL,
                NULL,
                NULL,
                (CFSetEqualCallBack)&NSTypeInfoEqual,
                (CFSetHashCallBack)&NSTypeInfoHash
            };
            typeInfoCache = CFSetCreateMutable(kCFAllocatorDefault, 0, &callbacks);
        });
    NSValueTypeInfo tempInfo = {
        .name = type
    };
    OSSpinLockLock(&lock);
    obj->typeInfo = (NSValueTypeInfo *)CFSetGetValue(typeInfoCache, &tempInfo);
    if (obj->typeInfo == NULL) {
        obj->typeInfo = malloc(sizeof(NSValueTypeInfo) + strlen(type) + 1);
        if (obj->typeInfo == NULL)
        {
            OSSpinLockUnlock(&lock);
            return nil;
        }
        obj->typeInfo->size = size;
        obj->typeInfo->name = &obj->typeInfo->type[0];
        strcpy(&obj->typeInfo->type[0], type);
        CFSetAddValue(typeInfoCache, obj->typeInfo);
    }
    OSSpinLockUnlock(&lock);

    memcpy(object_getIndexedIvars(obj), value, size);

    return obj;
}

static NSValue *_NSNewValue(void *value, const char *type)
{
    NSUInteger size = 0;
    NSGetSizeAndAlignment(type, &size, NULL);
    NSConcreteValueSpecialType flags = NSNotSpecialType;
    if (strcmp(type, NSRANGE_32) == 0)
    {
#if !__LP64__
        flags = NSRangeType;
#endif
    }
    else if (strcmp(type, NSRANGE_64) == 0)
    {
#if __LP64__
        flags = NSRangeType;
#endif
    }
    else if (strcmp(type, CGPOINT_32) == 0)
    {
#if !__LP64__
        flags = NSPointType;
#endif
    }
    else if (strcmp(type, CGPOINT_64) == 0)
    {
#if __LP64__
        flags = NSPointType;
#endif
    }
    else if (strcmp(type, CGSIZE_32) == 0)
    {
#if !__LP64__
        flags = NSSizeType;
#endif
    }
    else if (strcmp(type, CGSIZE_64) == 0)
    {
#if __LP64__
        flags = NSSizeType;
#endif
    }
    else if (strcmp(type, CGRECT_32) == 0)
    {
#if !__LP64__
        flags = NSRectType;
#endif
    }
    else if (strcmp(type, CGRECT_64) == 0)
    {
#if __LP64__
        flags = NSRectType;
#endif
    }
    else if (strcmp(type, CGAFFINETRANSFORM_32) == 0)
    {
#if !__LP64__
        flags = NSAffineTransformType;
#endif
    }
    else if (strcmp(type, CGAFFINETRANSFORM_64) == 0)
    {
#if __LP64__
        flags = NSAffineTransformType;
#endif
    }
    else if (strcmp(type, UIEDGEINSETS_32) == 0)
    {
#if !__LP64__
        flags = NSEdgeInsetsType;
#endif
    }
    else if (strcmp(type, UIEDGEINSETS_64) == 0)
    {
#if __LP64__
        flags = NSEdgeInsetsType;
#endif
    }
    else if (strcmp(type, NSEDGEINSETS_64) == 0)
    {
#if __LP64__
        flags = NSEdgeInsetsType;
#endif
    }
    else if (strcmp(type, NSEDGEINSETS_32) == 0)
    {
#if !__LP64__
        flags = NSEdgeInsetsType;
#endif
    }
    else if (strcmp(type, UIOFFSET_32) == 0)
    {
#if !__LP64__
        flags = NSOffsetType;
#endif
    }
    else if (strcmp(type, UIOFFSET_64) == 0)
    {
#if __LP64__
        flags = NSOffsetType;
#endif
    }
    return createValue(value, type, size, flags);
}

static id newDecodedValue(NSCoder *aCoder)
{
    NSConcreteValueSpecialType flags = NSNotSpecialType;
    if ([aCoder allowsKeyedCoding] && [aCoder containsValueForKey:NS_special])
    {
        flags = [aCoder decodeIntegerForKey:NS_special];
    }
    if (flags != NSNotSpecialType)
    {
        switch (flags)
        {
            case NSPointType: {
                CGPoint pt = [aCoder decodePointForKey:NS_pointval];
                return createValue((uint8_t *)&pt, @encode(CGPoint), sizeof(CGPoint), flags);
            }
            case NSSizeType: {
                CGSize sz = [aCoder decodeSizeForKey:NS_sizeval];
                return createValue((uint8_t *)&sz, @encode(CGSize), sizeof(CGSize), flags);
            }
            case NSCGRectType:
            case NSRectType: {
                CGRect rect = [aCoder decodeRectForKey:NS_rectval];
                return createValue((uint8_t *)&rect, @encode(CGRect), sizeof(CGRect), flags);
            }
            case NSRangeType: {
                NSRange r;
                r.location = [aCoder decodeIntegerForKey:NS_rangeval_location];
                r.length = [aCoder decodeIntegerForKey:NS_rangeval_length];
                return createValue((uint8_t *)&r, @encode(NSRange), sizeof(NSRange), flags);
            }
            case NSAffineTransformType: {
                CGAffineTransform transform;
#if __LP64__
                transform.a = [aCoder decodeDoubleForKey:NS_atval_a];
                transform.b = [aCoder decodeDoubleForKey:NS_atval_b];
                transform.c = [aCoder decodeDoubleForKey:NS_atval_c];
                transform.d = [aCoder decodeDoubleForKey:NS_atval_d];
                transform.tx = [aCoder decodeDoubleForKey:NS_atval_tx];
                transform.ty = [aCoder decodeDoubleForKey:NS_atval_ty];
#else
                transform.a = [aCoder decodeFloatForKey:NS_atval_a];
                transform.b = [aCoder decodeFloatForKey:NS_atval_b];
                transform.c = [aCoder decodeFloatForKey:NS_atval_c];
                transform.d = [aCoder decodeFloatForKey:NS_atval_d];
                transform.tx = [aCoder decodeFloatForKey:NS_atval_tx];
                transform.ty = [aCoder decodeFloatForKey:NS_atval_ty];
#endif
                return createValue((uint8_t *)&transform, @encode(CGAffineTransform), sizeof(CGAffineTransform), flags);
            }
            case NSEdgeInsetsType:
            case NSEdgeType: { // probably good enough
                UIEdgeInsets insets;
#if __LP64__
                insets.top = [aCoder decodeDoubleForKey:NS_edgeval_top];
                insets.left = [aCoder decodeDoubleForKey:NS_edgeval_left];
                insets.bottom = [aCoder decodeDoubleForKey:NS_edgeval_bottom];
                insets.right = [aCoder decodeDoubleForKey:NS_edgeval_right];
#else
                insets.top = [aCoder decodeFloatForKey:NS_edgeval_top];
                insets.left = [aCoder decodeFloatForKey:NS_edgeval_left];
                insets.bottom = [aCoder decodeFloatForKey:NS_edgeval_bottom];
                insets.right = [aCoder decodeFloatForKey:NS_edgeval_right];
#endif
                return createValue((uint8_t *)&insets, @encode(UIEdgeInsets), sizeof(UIEdgeInsets), flags);
            }
            case NSOffsetType: {
                UIOffset offset;
#if __LP64__
                offset.horizontal = [aCoder decodeDoubleForKey:NS_offset_h];
                offset.vertical = [aCoder decodeDoubleForKey:NS_offset_v];
#else
                offset.horizontal = [aCoder decodeFloatForKey:NS_offset_h];
                offset.vertical = [aCoder decodeFloatForKey:NS_offset_v];
#endif
                return createValue((uint8_t *)&offset, @encode(UIOffset), sizeof(UIOffset), flags);
            }
            default: {
                [NSException raise:NSInternalInconsistencyException format:@"Incorrect special type encoding for value"];
                return nil;
            }
        }
    }
    else
    {
        char *type;
        uint8_t stack_val[MAX_STACK];
        uint8_t *val = &stack_val[0];
        [aCoder decodeValueOfObjCType:@encode(char *) at:&type];

        NSUInteger size;
        NSGetSizeAndAlignment(type, &size, NULL);
        if (size > MAX_STACK)
        {
            val = (uint8_t *)malloc(size);
            if (val == NULL)
            {
                return nil;
            }
        }
        [aCoder decodeValueOfObjCType:type at:val];
        id value = _NSNewValue(val, type);
        if (val != NULL && val != &stack_val[0])
        {
            free(val);
        }
        return value;
    }
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    return newDecodedValue(aCoder);
}

@end

@implementation NSValue (NSValueCreation)

- (id)initWithBytes:(const void *)value objCType:(const char *)type
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

+ (NSValue *)valueWithBytes:(const void *)value objCType:(const char *)type
{
    return [[[NSValue alloc] initWithBytes:value objCType:type] autorelease];
}

+ (NSValue *)value:(const void *)value withObjCType:(const char *)type
{
    return [self valueWithBytes:value objCType:type];
}

@end

@implementation NSValue (NSValueExtensionMethods)

+ (NSValue *)valueWithNonretainedObject:(id)anObject
{
    return [NSValue valueWithBytes:&anObject objCType:@encode(void *)];
}

+ (NSValue *)valueWithPointer:(const void *)pointer
{
    return [NSValue valueWithBytes:&pointer objCType:@encode(void *)];
}

+ (NSValue *)valueWithPoint:(CGPoint)point
{
    return [NSValue valueWithBytes:&point objCType:@encode(CGPoint)];
}

+ (NSValue *)valueWithRect:(CGRect)rect
{
    return [NSValue valueWithBytes:&rect objCType:@encode(CGRect)];
}

+ (NSValue *)valueWithSize:(CGSize)size
{
    return [NSValue valueWithBytes:&size objCType:@encode(CGSize)];
}

- (id)nonretainedObjectValue
{
    id obj = nil;
    [self getValue:&obj];
    return obj;
}

- (NSRange)rangeValue
{
    NSRange r = {0, 0};
    [self getValue:&r];
    return r;
}

- (CGRect)rectValue
{
    CGRect r = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    [self getValue:&r];
    return r;
}

- (CGSize)sizeValue
{
    CGSize sz = {0.0f, 0.0f};
    [self getValue:&sz];
    return sz;
}

- (CGPoint)pointValue
{
    CGPoint pt = {0.0f, 0.0f};
    [self getValue:&pt];
    return pt;
}

- (void *)pointerValue
{
    void *ptr = NULL;
    [self getValue:&ptr];
    return ptr;
}

- (BOOL)isEqual:(id)value
{
    if (self == value)
    {
        return YES;
    }
    else if (![value isKindOfClass:[NSValue class]])
    {
        return NO;
    }
    else if (strcmp([self objCType], [value objCType]) != 0)
    {
        return NO;
    }
    return [self isEqualToValue:value];
}

- (BOOL)isEqualToValue:(NSValue *)value
{
    BOOL equal = YES;
    if (self != value)
    {
        const char *type = [self objCType];
        NSUInteger sz = 0;
        NSGetSizeAndAlignment(type, &sz, NULL);
        void *v1 = malloc(sz);
        void *v2 = malloc(sz);
        [self getValue:v1];
        [self getValue:v2];
        equal = memcmp(v1, v2, sz) == 0;
        free(v1);
        free(v2);
    }
    return equal;
}

+ (NSValue *)valueWithCGPoint:(CGPoint)point
{
    return [NSValue value:&point withObjCType:@encode(CGPoint)];
}

+ (NSValue *)valueWithCGRect:(CGRect)rect
{
    return [NSValue value:&rect withObjCType:@encode(CGRect)];
}

+ (NSValue *)valueWithCGSize:(CGSize)size
{
    return [NSValue value:&size withObjCType:@encode(CGSize)];
}

+ (NSValue *)valueWithCGAffineTransform:(CGAffineTransform)transform
{
    return [NSValue value:&transform withObjCType:@encode(CGAffineTransform)];
}

- (CGPoint)CGPointValue
{
	CGPoint pt = {0,0};
    [self getValue:&pt];
    return pt;
}

- (CGRect)CGRectValue
{
    CGRect r = {{0,0},{0,0}};
    [self getValue:&r];
    return r;
}

- (CGSize)CGSizeValue
{
	CGSize sz = {0,0};
    [self getValue:&sz];
    return sz;
}

- (CGAffineTransform)CGAffineTransformValue
{
    CGAffineTransform transform = {1,0,0,1,0,0};
    [self getValue:&transform];
    return transform;
}

@end

@implementation NSConcreteValue

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (void)initialize
{
    // Runtime check whether certain hardwired string encodings
    // for CGRect, CGPoint, and CGSize are correct would be necessary if we didn't use
    // @encode consistently
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (_specialFlags == 0)
    {
        [super encodeWithCoder:aCoder];
        return;
    }
    if ([aCoder allowsKeyedCoding])
    {
        [aCoder encodeInteger:_specialFlags forKey:NS_special];  // _specialFlags is 2 for CGSize
        switch (_specialFlags)
        {
            case NSNotSpecialType:
                [super encodeWithCoder:aCoder];
                break;
            case NSPointType:
                [aCoder encodePoint:[self pointValue] forKey:NS_pointval];
                break;
            case NSSizeType:
                [aCoder encodeSize:[self sizeValue] forKey:NS_sizeval];
                break;
            case NSCGRectType:
            case NSRectType:
                [aCoder encodeRect:[self rectValue] forKey:NS_rectval];
                break;
            case NSRangeType: {
                NSRange r = [self rangeValue];
                [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:r.location] forKey:NS_rangeval_location];
                [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:r.length] forKey:NS_rangeval_length];
                break;
            }
            
            case NSAffineTransformType: {
                CGAffineTransform transform;
                [self getValue:&transform];
#if __LP64__
                [aCoder encodeDouble:transform.a forKey:NS_atval_a];
                [aCoder encodeDouble:transform.b forKey:NS_atval_b];
                [aCoder encodeDouble:transform.c forKey:NS_atval_c];
                [aCoder encodeDouble:transform.d forKey:NS_atval_d];
                [aCoder encodeDouble:transform.tx forKey:NS_atval_tx];
                [aCoder encodeDouble:transform.ty forKey:NS_atval_ty];
#else
                [aCoder encodeFloat:transform.a forKey:NS_atval_a];
                [aCoder encodeFloat:transform.b forKey:NS_atval_b];
                [aCoder encodeFloat:transform.c forKey:NS_atval_c];
                [aCoder encodeFloat:transform.d forKey:NS_atval_d];
                [aCoder encodeFloat:transform.tx forKey:NS_atval_tx];
                [aCoder encodeFloat:transform.ty forKey:NS_atval_ty];
#endif
                break;
            }
            case NSEdgeInsetsType:
            case NSEdgeType: {
                UIEdgeInsets insets;
                [self getValue:&insets];
#if __LP64__
                [aCoder encodeDouble:insets.top forKey:NS_edgeval_top];
                [aCoder encodeDouble:insets.left forKey:NS_edgeval_left];
                [aCoder encodeDouble:insets.bottom forKey:NS_edgeval_bottom];
                [aCoder encodeDouble:insets.right forKey:NS_edgeval_right];
#else
                [aCoder encodeFloat:insets.top forKey:NS_edgeval_top];
                [aCoder encodeFloat:insets.left forKey:NS_edgeval_left];
                [aCoder encodeFloat:insets.bottom forKey:NS_edgeval_bottom];
                [aCoder encodeFloat:insets.right forKey:NS_edgeval_right];
#endif
                break;
            }
            case NSOffsetType: {
                UIOffset offset;
                [self getValue:&offset];
#if __LP64__
                [aCoder encodeDouble:offset.horizontal forKey:NS_offset_h];
                [aCoder encodeDouble:offset.vertical forKey:NS_offset_v];
#else
                [aCoder encodeFloat:offset.horizontal forKey:NS_offset_h];
                [aCoder encodeFloat:offset.vertical forKey:NS_offset_v];
#endif
                break;
            }
        }
    }
}

static uint8_t charHalfToAscii(uint8_t in)
{
    return (in >= 10) ? (in + 'a' - 10) : (in + '0');
}

- (NSString *)description
{
    NSInteger size = typeInfo->size;
    char buf[size * 3];
    char *bufPtr = buf;
    const uint8_t *data = (const uint8_t *)[self _value];
    for (unsigned i = 0; i < size; i++)
    {
        if (i > 0 && (i % 4) == 0)
        {
            *bufPtr++ = ' ';
        }
        *bufPtr++ = charHalfToAscii(data[i] / 0x10);
        *bufPtr++ = charHalfToAscii(data[i] & 0xf);
    }
    *bufPtr = '\0';
    return [NSString stringWithFormat:@"<%s>", buf];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSUInteger)hash
{
    const char *valPtr = [self _value];
    int size = typeInfo->size;
    NSUInteger ret = 0;
    for (int i = 0; i < size; i++)
    {
        ret = (ret << 8) + valPtr[i] + ret;
    }
    return ret;
}

- (BOOL)isEqualToValue:(NSValue *)other
{
    if (strcmp([self objCType], [other objCType]) != 0)
    {
        return NO;
    }
    int size = typeInfo->size;
    char otherVal[size];
    [other getValue:&otherVal];
    return memcmp([self _value], &otherVal, typeInfo->size) == 0;
}

- (const void *)_value
{
    return object_getIndexedIvars(self);
}

- (const char *)objCType NS_RETURNS_INNER_POINTER
{
    return typeInfo->name;
}

- (void)getValue:(void *)value
{
    memcpy(value, [self _value], typeInfo->size);
}

@end
