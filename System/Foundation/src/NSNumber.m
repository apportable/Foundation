//
//  NSNumber.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSDecimalNumber.h>

#import "NSValueInternal.h"
#import "NSCoderInternal.h"
#import "ForFoundationOnly.h"

static NSString *NS_number = @"NS.number";
static NSString *NS_boolval = @"NS.boolval";
static NSString *NS_intval = @"NS.intval";
static NSString *NS_dblval = @"NS.dblval";

static inline id newDecodedNumber(NSCoder *coder)
{
    if ([coder allowsKeyedCoding])
    {
        if ([coder class] == [NSKeyedUnarchiver class] || [coder containsValueForKey:NS_number])
        {
            return [[coder _decodePropertyListForKey:NS_number] retain];
        }
        else if ([coder containsValueForKey:NS_boolval])
        {
            if ([coder decodeBoolForKey:NS_boolval])
            {
                return [@YES retain];
            }
            else
            {
                return [@NO retain];
            }
        }
        else if ([coder containsValueForKey:NS_intval])
        {
            int64_t i = [coder decodeInt64ForKey:NS_intval];
            return [[NSNumber alloc] initWithLongLong:i];
        }
        else if ([coder containsValueForKey:NS_dblval])
        {
            double d = [coder decodeDoubleForKey:NS_dblval];
            return [[NSNumber alloc] initWithDouble:d];
        }
        else
        {
            // we already cleaned up self above here...
            [NSException raise:NSInternalInconsistencyException format:@"unknown number format from coder"];
            return nil;
        }
    }
    else
    {
        // Decode the number type
        char *encodeType = 0;

        [coder decodeValueOfObjCType:@encode(char *) at:&encodeType];

        // Decode the number value
        NSUInteger size = 0;
        NSGetSizeAndAlignment(encodeType, &size, NULL); 
        char buffer[size];

        [coder decodeValueOfObjCType:encodeType at:buffer];

        // Box 
        switch (*encodeType)
        {
            case _C_CHR:
            {
                char val = *(char*)buffer;
                return [[NSNumber alloc] initWithChar:val];
            }
            case _C_UCHR:
            {
                unsigned char val = *(unsigned char*)buffer;
                return [[NSNumber alloc] initWithUnsignedChar:val];
            }
            case _C_SHT:
            {
                short val = *(short*)buffer;
                return [[NSNumber alloc] initWithShort:val];
            }
            case _C_USHT:
            {
                unsigned short val = *(unsigned short*)buffer;
                return [[NSNumber alloc] initWithUnsignedShort:val];
            }
            case _C_INT:
            {
                int val = *(int*)buffer;
                return [[NSNumber alloc] initWithInt:val];
            }
            case _C_UINT:
            {
                unsigned int val = *(unsigned int*)buffer;
                return [[NSNumber alloc] initWithUnsignedInt:val];
            }
            case _C_LNG:
            {
                long val = *(long*)buffer;
                return [[NSNumber alloc] initWithLong:val];
            }
            case _C_ULNG:
            {
                unsigned long val = *(unsigned long*)buffer;
                return [[NSNumber alloc] initWithUnsignedLong:val];
            }
            case _C_LNG_LNG:
            {
                long long val = *(long long*)buffer;
                return [[NSNumber alloc] initWithLongLong:val];
            }
            case _C_ULNG_LNG:
            {
                unsigned long long val = *(unsigned long long*)buffer;
                return [[NSNumber alloc] initWithUnsignedLongLong:val];
            }
            case _C_FLT:
            {
                float val = *(float*)buffer;
                return [[NSNumber alloc] initWithFloat:val];
            }
            case _C_DBL:
            {
                double val = *(double*)buffer;
                return [[NSNumber alloc] initWithDouble:val];
            }
            case _C_BOOL:
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Inconsistent objCType"];
                break;
        }

        return nil;
    }
}

@implementation NSNumber

- (Class)classForCoder
{
    return [NSNumber self];
}

- (NSInteger)integerValue
{
    return (NSInteger)[self longValue];
}

- (NSUInteger)unsignedIntegerValue
{
    return (NSUInteger)[self unsignedLongValue];
}

- (NSDecimal)decimalValue
{
    NSDecimal val;

    if (![[NSScanner scannerWithString:[self stringValue]] scanDecimal:&val])
    {
        return [[NSDecimalNumber notANumber] decimalValue];
    }
    else
    {
        return val;
    }
}

- (NSString *)stringValue
{
    return [self description];
}

- (id)initWithCoder:(NSCoder *)coder
{
    [self release];

    return newDecodedNumber(coder);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding])
    {
        if ([coder class] == [NSKeyedArchiver class])
        {
            [coder _encodePropertyList:self forKey:NS_number];
        }
        else
        {
            CFTypeID type = CFGetTypeID((CFTypeRef)self);
            if (type == CFBooleanGetTypeID())
            {
                Boolean val = CFBooleanGetValue((CFBooleanRef)self);
                [coder encodeBool:val forKey:NS_boolval];
            }
            else
            {
                const char *objCType = [self objCType];
                switch (*objCType)
                {
                    case _C_CHR:
                    case _C_UCHR:
                    case _C_SHT:
                    case _C_USHT:
                    case _C_INT:
                    case _C_UINT:
                    case _C_LNG:
                    case _C_ULNG:
                    case _C_LNG_LNG:
                    case _C_ULNG_LNG:
                        [coder encodeInt64:[self longLongValue] forKey:NS_intval];
                        break;
                    case _C_FLT:
                    case _C_DBL:
                        [coder encodeDouble:[self doubleValue] forKey:NS_dblval];
                        break;
                    case _C_BOOL:
                        [coder encodeBool:[self boolValue] forKey:NS_boolval];
                        break;
                }
            }
        }
    }
    else
    {
        CFTypeID cfType = CFGetTypeID((CFTypeRef)self);
        if (cfType == CFBooleanGetTypeID())
        {
            Boolean val = CFBooleanGetValue((CFBooleanRef)self);

            // Encode the number type
            const char *encodeType = @encode(char);
            [coder encodeValueOfObjCType:@encode(char*) at:&encodeType];

            // Encode the number value
            [coder encodeValueOfObjCType:@encode(char) at:&val];
        }
        else
        {
            const char *encodeType = NULL;

            const char *objCType = [self objCType];
            switch (*objCType)
            {
                case _C_CHR:
                    encodeType = @encode(char);
                    break;
                case _C_UCHR:
                    encodeType = @encode(unsigned char);
                    break;
                case _C_SHT:
                    encodeType = @encode(short);
                    break;
                case _C_USHT:
                    encodeType = @encode(unsigned short);
                    break;
                case _C_INT:
                    encodeType = @encode(int);
                    break;
                case _C_UINT:
                    encodeType = @encode(unsigned int);
                    break;
                case _C_LNG:
                    encodeType = @encode(long);
                    break;
                case _C_ULNG:
                    encodeType = @encode(unsigned long);
                    break;
                case _C_LNG_LNG:
                    encodeType = @encode(long long);
                    break;
                case _C_ULNG_LNG:
                    encodeType = @encode(unsigned long long);
                    break;
                case _C_FLT:
                    encodeType = @encode(float);
                    break;
                case _C_DBL:
                    encodeType = @encode(double);
                    break;
                case _C_BOOL:
                default:
                    [NSException raise:NSInternalInconsistencyException format:@"Inconsistent objCType"];
                    break;
            }

            // Encode the number type
            [coder encodeValueOfObjCType:@encode(char*) at:&encodeType];

            // Encode the number value
            NSUInteger size = 0;
            NSGetSizeAndAlignment(encodeType, &size, NULL); 
            char buffer[size];
            CFNumberType cfNumberType = CFNumberGetType((CFNumberRef)self);

            CFNumberGetValue((CFNumberRef)self, cfNumberType, &buffer);

            [coder encodeValueOfObjCType:encodeType at:&buffer];
        }
    }
}

- (NSComparisonResult)compare:(NSNumber *)other
{
    if (other == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"cannot compare to nil"];
        return NSOrderedSame;
    }
    
    if (self == other)
    {
        return NSOrderedSame;
    }
    
    const char *type = [self objCType];
    const char *otherType = [other objCType];
    if (*type == _C_DBL || *type == _C_FLT)
    {
        double value1 = [self doubleValue];
        double value2 = [other doubleValue];
        if (value1 < value2)
        {
            return NSOrderedAscending;
        }
        else if (value1 > value2)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }
    else if (*type == _C_ULNG_LNG && *type == *otherType)
    {
        unsigned long long value1 = [self unsignedLongLongValue];
        unsigned long long value2 = [other unsignedLongLongValue];
        if (value1 < value2)
        {
            return NSOrderedAscending;
        }
        else if (value1 > value2)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }
    else
    {
        long long value1 = [self longLongValue];
        long long value2 = [other longLongValue];
        if (value1 < value2)
        {
            return NSOrderedAscending;
        }
        else if (value1 > value2)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }
}

- (BOOL)isEqualToNumber:(NSNumber *)number
{
    if (self == number)
    {
        return YES;
    }
    
    return [self compare:number] == NSOrderedSame;
}

@end


@implementation NSNumber (NSNumberCreation)

+ (NSNumber *)numberWithChar:(char)value
{
    return [[[self alloc] initWithChar:value] autorelease];
}

+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value
{
    return [[[self alloc] initWithUnsignedChar:value] autorelease];
}

+ (NSNumber *)numberWithShort:(short)value
{
    return [[[self alloc] initWithShort:value] autorelease];
}

+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value
{
    return [[[self alloc] initWithUnsignedShort:value] autorelease];
}

+ (NSNumber *)numberWithInt:(int)value
{
    return [[[self alloc] initWithInt:value] autorelease];
}

+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value
{
    return [[[self alloc] initWithUnsignedInt:value] autorelease];
}

+ (NSNumber *)numberWithLong:(long)value
{
    return [[[self alloc] initWithLong:value] autorelease];
}

+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value
{
    return [[[self alloc] initWithUnsignedLong:value] autorelease];
}

+ (NSNumber *)numberWithLongLong:(long long)value
{
    return [[[self alloc] initWithLongLong:value] autorelease];
}

+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value
{
    return [[[self alloc] initWithUnsignedLongLong:value] autorelease];
}

+ (NSNumber *)numberWithFloat:(float)value
{
    return [[[self alloc] initWithFloat:value] autorelease];
}

+ (NSNumber *)numberWithDouble:(double)value
{
    return [[[self alloc] initWithDouble:value] autorelease];
}

+ (NSNumber *)numberWithBool:(BOOL)value
{
    return [[[self alloc] initWithBool:value] autorelease];
}

+ (NSNumber *)numberWithInteger:(NSInteger)value
{
    return [[[self alloc] initWithInteger:value] autorelease];
}

+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value
{
    return [[[self alloc] initWithUnsignedInteger:value] autorelease];
}

- (id)initWithChar:(char)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUnsignedChar:(unsigned char)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithShort:(short)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUnsignedShort:(unsigned short)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithInt:(int)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUnsignedInt:(unsigned int)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithLong:(long)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUnsignedLong:(unsigned long)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithLongLong:(long long)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUnsignedLongLong:(unsigned long long)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithFloat:(float)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithDouble:(double)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithBool:(BOOL)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithInteger:(NSInteger)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithUnsignedInteger:(NSUInteger)value
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (NSUInteger)hash
{
    const char *type = [self objCType];
    switch (type[0])
    {
        case _C_BOOL:
        case _C_CHR:
        case _C_UCHR:
        case _C_SHT:
        case _C_USHT:
        case _C_INT:
        case _C_LNG:
        {
            long longValue = [self longValue];
            return _CFHashInt(longValue);
        }

        case _C_UINT:
        case _C_ULNG:
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        case _C_FLT:
        case _C_DBL:
        default:
        {
            double doubleValue = [self doubleValue];
            return _CFHashDouble(doubleValue);
        }
    }
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    
    if (![other isNSNumber__])
    {
        return NO;
    }
    
    return [self isEqualToNumber:other];
}

- (BOOL)isEqualToNumber:(id)other
{
    if (other == self)
    {
        return YES;
    }
    
    return [self compare:other] == NSOrderedSame;
}

- (BOOL)isNSNumber__
{
    return YES;
}

- (NSComparisonResult)_reverseCompare:(id)other
{
    CFComparisonResult result = CFNumberCompare((CFNumberRef)self, (CFNumberRef)other, NULL);
    switch (result) {
        case kCFCompareLessThan:
            return NSOrderedDescending;
        case kCFCompareGreaterThan:
            return NSOrderedAscending;
        case kCFCompareEqualTo:
            return NSOrderedDescending;
    }
}

- (Boolean)_getValue:(void *)value forType:(CFNumberType)type
{
    switch(type)
    {
        case kCFNumberSInt8Type: *(int8_t *)value = [self charValue]; return YES;
        case kCFNumberSInt16Type: *(int16_t *)value = [self shortValue]; return YES;
        case kCFNumberSInt32Type: *(int32_t *)value = [self intValue]; return YES;
        case kCFNumberSInt64Type: *(int64_t *)value = [self longLongValue]; return YES;
        case kCFNumberFloat32Type: *(float *)value = [self floatValue]; return YES;
        case kCFNumberFloat64Type: *(double *)value = [self doubleValue]; return YES;
        case kCFNumberCharType: *(unsigned char *)value = [self unsignedCharValue]; return YES;
        case kCFNumberShortType: *(unsigned short *)value = [self unsignedShortValue]; return YES;
        case kCFNumberIntType: *(unsigned int *)value = [self unsignedIntValue]; return YES;
        case kCFNumberLongType : *(unsigned long *)value = [self unsignedLongValue]; return YES;
        case kCFNumberLongLongType : *(unsigned long long *)value = [self unsignedLongLongValue]; return YES;
        case kCFNumberFloatType : *(float *)value = [self floatValue]; return YES;
        case kCFNumberDoubleType : *(double *)value = [self doubleValue]; return YES;
        case kCFNumberCFIndexType : *(CFIndex *)value = [self integerValue]; return YES;
        case kCFNumberNSIntegerType: *(NSInteger *)value = [self integerValue]; return YES;
#ifdef __LP64__
        case kCFNumberCGFloatType  : *(double *)value = [self doubleValue]; return YES;
#else
        case kCFNumberCGFloatType  : *(float *)value = [self floatValue]; return YES;
#endif
    }
    DEBUG_BREAK(); // Should never get here
    return NO;
}

- (CFNumberType)_cfNumberType
{
    // For NSNumber subclasses
    const char *type = [self objCType];
    switch (type[0])
    {
        case _C_CHR      : return kCFNumberCharType;
        case _C_UCHR     : return kCFNumberCharType;
        case _C_SHT      : return kCFNumberShortType;
        case _C_USHT     : return kCFNumberShortType;
        case _C_INT      : return kCFNumberIntType;
        case _C_UINT     : return kCFNumberIntType;
        case _C_LNG      : return kCFNumberLongType;
        case _C_ULNG     : return kCFNumberLongType;
        case _C_LNG_LNG  : return kCFNumberLongLongType;
        case _C_ULNG_LNG : return kCFNumberLongLongType;
        case _C_FLT      : return kCFNumberFloatType;
        case _C_DBL      : return kCFNumberDoubleType;
        case _C_BOOL     : return kCFNumberCharType;
    }
    DEBUG_BREAK(); // Should never get here
    return 0;
}

- (CFTypeID)_cfTypeID
{
    return CFNumberGetTypeID();
}

@end


@implementation NSPlaceholderNumber

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (id)initWithCoder:(NSCoder *)coder
{
    return newDecodedNumber(coder);
}

- (id)initWithBool:(BOOL)val
{
    return (id)(val ? kCFBooleanTrue : kCFBooleanFalse);
}

- (id)initWithDouble:(double)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &val);
}

- (id)initWithFloat:(float)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &val);
}

- (id)initWithUnsignedLongLong:(unsigned long long)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &val);
}

- (id)initWithLongLong:(long long)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &val);
}

- (id)initWithUnsignedLong:(unsigned long)val
{
    SInt64 v = val;
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &v);
}

- (id)initWithLong:(long)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &val);
}

- (id)initWithUnsignedInteger:(NSUInteger)val
{
    SInt64 v = val; // this is valid only on iOS. On MacOS where NSUInteger is 64 bits, this will produce incorrect behavior.
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &v);
}

- (id)initWithInteger:(NSInteger)val
{
#if __LP64__
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &val);
#else
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &val);
#endif
}

- (id)initWithUnsignedInt:(unsigned int)val
{
    SInt64 v = val;
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &v);
}

- (id)initWithInt:(int)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &val);
}

- (id)initWithUnsignedShort:(unsigned short)val
{
    SInt32 v = val;
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &v);
}

- (id)initWithShort:(short)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt16Type, &val);
}

- (id)initWithUnsignedChar:(unsigned char)val
{
    SInt16 v = val;
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt16Type, &v);
}

- (id)initWithChar:(char)val
{
    return (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &val);
}

- (id)init
{
    return nil;
}

@end
