//
//  NSCoder.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCoderInternal.h"
#import <Foundation/NSSet.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import "NSExternals.h"
#import "NSObjectInternal.h"

@implementation NSCoder

- (void)_validateAllowedClass:(Class)cls forKey:(NSString *)key allowingInvocations:(BOOL)allowInv
{
#warning TODO: Fixme
}

- (void)validateAllowedClass:(Class)cls forKey:(NSString *)key
{
    [self _validateAllowedClass:cls forKey:key allowingInvocations:NO];
}

- (void)setAllowedClasses:(NSSet *)classes
{

}

- (long)decodeLongForKey:(NSString *)key
{
    return [self decodeInt32ForKey:key];
}

- (void)encodeLong:(long)value forKey:(NSString *)key
{
    [self encodeInt32:value forKey:key];
}

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr
{
    NSRequestConcreteImplementation();
}

- (void)encodeDataObject:(NSData *)data
{
    NSRequestConcreteImplementation();
}

- (void)decodeValueOfObjCType:(const char *)type at:(void *)data
{
    NSRequestConcreteImplementation();
}

- (NSData *)decodeDataObject
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSInteger)versionForClassName:(NSString *)className
{
    NSRequestConcreteImplementation();
    return 0;
}

- (void)encodeObject:(id)obj
{
    [self encodeValueOfObjCType:@encode(id) at:&obj];
}

- (void)encodeRootObject:(id)root
{
    [self encodeObject:root];
}

- (void)encodeBycopyObject:(id)obj
{
    [self encodeObject:obj];
}

- (void)encodeByrefObject:(id)obj
{
    [self encodeObject:obj];
}

- (void)encodeConditionalObject:(id)obj
{
    [self encodeObject:obj];
}

static inline const char *nextType(const char *type)
{
    if (*type == _C_CONST)
    {
        type++;
    }
    switch (*type)
    {
        case _C_ID:
            type++;
            if (*type != '"')
            {
                return type;
            }
            else
            {
                type++;
                while (*type != '"' && *type != '\0')
                {
                    type++;
                }
                return ++type;
            }
        case _C_CLASS:
        case _C_SEL:
        case _C_CHR:
        case _C_UCHR:
        case _C_CHARPTR:
        case _C_ATOM:
        case _C_SHT:
        case _C_USHT:
        case _C_INT:
        case _C_UINT:
        case _C_LNG:
        case _C_ULNG:
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        case _C_FLT:
        case _C_DBL:
        case _C_VOID:
        case _C_UNDEF:
            return ++type;
        case _C_PTR:
            return nextType(++type);
        case _C_ARY_B:
            type++;
            while (isdigit(*type))
            {
                type++;
            }
            if (*type == _C_ARY_E)
            {
                return ++type;
            }
            else
            {
                return NULL;
            }
        case _C_STRUCT_B:
            while (*type != _C_STRUCT_E)
            {
                type++;
                if (*type == '=')
                {
                    type++;
                    type = nextType(type);
                    if (type == NULL)
                    {
                        return NULL;
                    }
                }
            }
            return ++type;
        case _C_UNION_B:
            while (*type != _C_UNION_E)
            {
                type++;
                if (*type == '=')
                {
                    type++;
                    type = nextType(type);
                    if (type == NULL)
                    {
                        return NULL;
                    }
                }
            }
            return ++type;
        default:
            return NULL;
    }
}

- (void)encodeValuesOfObjCTypes:(const char *)types, ...
{
    va_list ap;
    va_start(ap, types);
    while (types != NULL && *types)
    {
        [self encodeValueOfObjCType:types at:va_arg(ap, void *)];
        types = nextType(types);
    }
    va_end(ap);
}

- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array
{
    size_t typelen = strlen(type);
    size_t len = typelen + 14; // enough space for the type and NSUIntegerMax and the braces
    char buffer[len];
    snprintf(buffer, len, "[%d%s]", count, type);
    [self encodeValueOfObjCType:buffer at:array];
    
}

- (void)encodeBytes:(const void *)addr length:(NSUInteger)len
{
    [self encodeValueOfObjCType:@encode(NSUInteger) at:&len];
    [self encodeArrayOfObjCType:@encode(char) count:len at:addr];
}

- (id)decodeObject
{
    id obj = nil;
    [self decodeValueOfObjCType:@encode(id) at:&obj];
    return [obj autorelease];
}

- (void)decodeValuesOfObjCTypes:(const char *)types, ...
{
    va_list ap;
    va_start(ap, types);
    while (types != NULL && *types)
    {
        [self decodeValueOfObjCType:types at:va_arg(ap, void *)];
        types = nextType(types);
    }
    va_end(ap);
}

- (void)decodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(void *)array
{
    size_t typelen = strlen(type);
    size_t len = typelen + 14; // enough space for the type and NSUIntegerMax and the braces
    char buffer[len];
    snprintf(buffer, len, "[%d%s]", count, type);
    [self decodeValueOfObjCType:buffer at:array];
}

- (void *)decodeBytesWithReturnedLength:(NSUInteger *)len
{
    NSUInteger length = 0;
    [self decodeValueOfObjCType:@encode(NSUInteger) at:&length];
    NSMutableData *data = [NSMutableData dataWithLength:length];
    void *bytes = [data mutableBytes];
    [self decodeArrayOfObjCType:@encode(char) count:length at:bytes];
    if (len != NULL)
    {
        *len = length;
    }
    return bytes;
}

- (void)setObjectZone:(NSZone *)zone
{

}

- (NSZone *)objectZone
{
    return NSDefaultMallocZone();
}

- (unsigned)systemVersion
{
    return NSCoderSystemVersion;
}

- (BOOL)allowsKeyedCoding
{
    return NO;
}

- (void)encodeObject:(id)obj forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeConditionalObject:(id)obj forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeBool:(BOOL)value forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeInt:(int)value forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeInt32:(int32_t)value forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeInt64:(int64_t)value forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeFloat:(float)value forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeDouble:(double)value forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (void)encodeBytes:(const uint8_t *)buffer length:(NSUInteger)len forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
}

- (BOOL)containsValueForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return NO;
}

- (id)decodeObjectForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return nil;
}

- (BOOL)decodeBoolForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return NO;
}

- (int)decodeIntForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return 0;
}

- (int32_t)decodeInt32ForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return 0;
}

- (int64_t)decodeInt64ForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return 0;
}

- (float)decodeFloatForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return 0.0f;
}

- (double)decodeDoubleForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return 0.0;
}

- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)len
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)encodeInteger:(NSInteger)value forKey:(NSString *)key
{
    [self encodeInt32:value forKey:key];
}

- (NSInteger)decodeIntegerForKey:(NSString *)key
{
    return [self decodeInt32ForKey:key];
}

- (BOOL)requiresSecureCoding
{
    return NO;
}

- (id)decodeObjectOfClass:(Class)aClass forKey:(NSString *)key
{
    return [self decodeObjectOfClasses:[NSSet setWithObject:aClass] forKey:key];
}

- (id)decodeObjectOfClasses:(NSSet *)classes forKey:(NSString *)key
{
    if (![self allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"requires keyed coding"];
        return nil;
    }

    if ([self requiresSecureCoding])
    {
        NSRequestConcreteImplementation();
        return nil;
    }
    else
    {
        return [self decodeObjectForKey:key];
    }
}

- (id)decodePropertyListForKey:(NSString *)key
{
    if (![self allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"requires keyed coding"];
        return nil;
    }
    static NSSet *plistClasses = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        plistClasses = [[NSSet alloc] initWithObjects:[NSData class], [NSString class], [NSArray class], [NSDictionary class], [NSDate class], [NSNumber class], nil];
    });
    return [self decodeObjectOfClasses:plistClasses forKey:key];
}

- (NSSet *)allowedClasses
{
    return nil;
}

@end

@implementation NSCoder (NSGeometryCoding)

- (CGRect)decodeRect
{
    CGRect r;
    [self decodeValuesOfObjCTypes:@encode(CGRect), &r];
    return r;
}

- (void)encodeRect:(CGRect)r
{
    [self encodeValuesOfObjCTypes:@encode(CGRect), &r];
}

- (CGSize)decodeSize
{
    CGSize sz;
    [self decodeValuesOfObjCTypes:@encode(CGSize), &sz];
    return sz;
}

- (void)encodeSize:(CGSize)sz
{
    [self encodeValuesOfObjCTypes:@encode(CGSize), &sz];
}

- (CGPoint)decodePoint
{
    CGPoint pt;
    [self decodeValuesOfObjCTypes:@encode(CGPoint), &pt];
    return pt;
}

- (void)encodePoint:(CGPoint)pt
{
    [self encodeValuesOfObjCTypes:@encode(CGPoint), &pt];
}

@end

@implementation NSCoder (NSKeyedGeometryCoding)

- (CGRect)decodeRectForKey:(NSString *)key
{
    return NSRectFromString([self decodeObjectForKey:key]);
}

- (CGSize)decodeSizeForKey:(NSString *)key
{
    return NSSizeFromString([self decodeObjectForKey:key]);
}

- (CGPoint)decodePointForKey:(NSString *)key
{
    return NSPointFromString([self decodeObjectForKey:key]);
}

- (void)encodeRect:(CGRect)r forKey:(NSString *)key
{
    [self encodeObject:NSStringFromRect(r) forKey:key];
}

- (void)encodeSize:(CGSize)sz forKey:(NSString *)key
{
    [self encodeObject:NSStringFromSize(sz) forKey:key];
}

- (void)encodePoint:(CGPoint)pt forKey:(NSString *)key
{
    [self encodeObject:NSStringFromPoint(pt) forKey:key];
}

@end

