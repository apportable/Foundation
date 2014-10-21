//
//  NSNumber.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSValue.h>
#import <CoreFoundation/CFNumber.h>

#import "NSObjectInternal.h"
#import "CFInternal.h"

CF_EXPORT Boolean _CFNumberGetValue(CFNumberRef number, CFNumberType type, void *valuePtr);
CF_EXPORT CFNumberType _CFNumberGetType(CFNumberRef num);
CF_EXPORT CFNumberType _CFNumberGetType2(CFNumberRef number);
CF_EXPORT CFStringRef __CFNumberCreateFormattingDescription(CFAllocatorRef allocator, CFTypeRef cf, CFDictionaryRef formatOptions);

CF_PRIVATE
@interface __NSCFNumber : __NSCFType
@end

CF_PRIVATE
@interface __NSCFBoolean : __NSCFType
@end

@implementation __NSCFNumber

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (NSComparisonResult)compare:(id)other
{
    if (!other)
    {
        // NOTE : "If the value is nil, the behavior is undefined and may change in future versions of OS X."
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil argument" userInfo:nil];
        return NSOrderedSame;
    }
    return (NSComparisonResult)CFNumberCompare((CFNumberRef)self, (CFNumberRef)other, NULL);
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
    switch (type)
    {
        case kCFNumberSInt8Type:
        case kCFNumberCharType:
            *(char *)value = [self charValue];
            return YES;
        case kCFNumberSInt16Type:
        case kCFNumberShortType:
            *(short *)value = [self shortValue];
            return YES;
        case kCFNumberSInt32Type:
        case kCFNumberIntType:
#if !__LP64__
        case kCFNumberLongType:
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
#endif
            *(int *)value = [self intValue];
            return YES;
        case kCFNumberSInt64Type:
        case kCFNumberLongLongType:
#if __LP64__
        case kCFNumberLongType:
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
#endif
            *(long long *)value = [self longLongValue];
            return YES;
        case kCFNumberFloat32Type:
        case kCFNumberFloatType:
#if !__LP64__
        case kCFNumberCGFloatType:
#endif
            *(float *)value = [self floatValue];
            return YES;
        case kCFNumberDoubleType:
        case kCFNumberFloat64Type:
#if __LP64__
        case kCFNumberCGFloatType:
#endif
            *(double *)value = [self doubleValue];
            return YES;
        default:
            return NO;
    }
}

- (CFNumberType)_cfNumberType
{
    return _CFNumberGetType2((CFNumberRef)self);
}

- (CFTypeID)_cfTypeID
{
    return CFNumberGetTypeID();
}

- (BOOL)boolValue
{
    SInt64 val;

    if (CFNumberIsFloatType((CFNumberRef)self))
    {
        double dval;
        CFNumberGetValue((CFNumberRef)self, kCFNumberDoubleType, &dval);
        val = (SInt64)dval;
    }
    else
    {
        CFNumberGetValue((CFNumberRef)self, kCFNumberSInt64Type, &val);
    }

    return val != 0;
}

- (NSUInteger)unsignedIntegerValue
{
    return [self unsignedLongValue];
}

- (NSInteger)integerValue
{
    return [self longValue];
}

#define GET_VALUE(t,type) ({ \
    t val; \
    CFNumberGetValue((CFNumberRef)self, type, &val); \
    val; \
})

- (double)doubleValue
{
    return GET_VALUE(double, kCFNumberDoubleType);
}

- (float)floatValue
{
    return GET_VALUE(float, kCFNumberFloatType);
}

- (unsigned long long)unsignedLongLongValue
{
    return GET_VALUE(unsigned long long, kCFNumberLongLongType);
}

- (long long)longLongValue
{
    return GET_VALUE(long long, kCFNumberLongLongType);
}

- (unsigned long)unsignedLongValue
{
    return GET_VALUE(unsigned long, kCFNumberLongType);
}

- (long)longValue
{
    return GET_VALUE(long, kCFNumberLongType);
}

- (unsigned int)unsignedIntValue
{
    return GET_VALUE(unsigned int, kCFNumberIntType);
}

- (int)intValue
{
    return GET_VALUE(int, kCFNumberIntType);
}

- (unsigned short)unsignedShortValue
{
    return GET_VALUE(unsigned short, kCFNumberShortType);
}

- (short)shortValue
{
    return GET_VALUE(short, kCFNumberShortType);
}

- (unsigned char)unsignedCharValue
{
    return GET_VALUE(unsigned char, kCFNumberCharType);
}

- (BOOL)charValue
{
    return GET_VALUE(unsigned char, kCFNumberCharType);
}

- (const char *)objCType
{
    CFNumberType t = _CFNumberGetType2((CFNumberRef)self);
    switch (t)
    {
        case kCFNumberSInt8Type:
            return @encode(SInt8);
        case kCFNumberSInt16Type:
            return @encode(SInt16);
        case kCFNumberSInt32Type:
            return @encode(SInt32);
        case kCFNumberSInt64Type:
            return @encode(SInt64);
        case kCFNumberFloat32Type:
            return @encode(Float32);
        case kCFNumberFloat64Type:
            return @encode(Float64);
        case kCFNumberCharType:
            return @encode(char);
        case kCFNumberShortType:
            return @encode(short);
        case kCFNumberIntType:
            return @encode(int);
        case kCFNumberLongType:
            return @encode(long);
        case kCFNumberLongLongType:
            return @encode(long long);
        case kCFNumberFloatType:
            return @encode(float);
        case kCFNumberDoubleType:
            return @encode(double);
        case kCFNumberCFIndexType:
            return @encode(CFIndex);
        case kCFNumberNSIntegerType:
            return @encode(NSInteger);
        case kCFNumberCGFloatType:
            return @encode(float); // really is @encode(CGFloat)
        default:
            return "";
    }
}

- (void)getValue:(void *)buffer
{
    CFNumberType t = _CFNumberGetType2((CFNumberRef)self);
    CFNumberGetValue((CFNumberRef)self, t, buffer);
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (id)stringValue
{
    return [(NSString *)__CFNumberCreateFormattingDescription(kCFAllocatorDefault, (CFTypeRef)self, NULL) autorelease];
}

- (id)description
{
    return [self descriptionWithLocale:nil];
}

- (id)descriptionWithLocale:(id)locale
{
    return [(NSString *)__CFNumberCreateFormattingDescription(kCFAllocatorDefault, (CFTypeRef)self, (CFDictionaryRef)locale) autorelease];
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating((CFTypeRef)self);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain((CFTypeRef)self) != NULL;
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)retain
{
    return (id)CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)other
{
    if (other == NULL)
    {
        return NO;
    }

    if (![other isNSNumber__])
    {
        return NO;
    }

    return [self isEqualToNumber:other];
}

- (BOOL)isEqualToNumber:(id)other
{
    return [self compare:other] == NSOrderedSame;
}

- (BOOL)isNSNumber__
{
    return YES;
}

@end

@implementation __NSCFBoolean

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (NSComparisonResult)compare:(id)other
{
    if (self == other)
    {
        return NSOrderedSame;
    }
    else if (self == (__NSCFBoolean *)kCFBooleanFalse && other == (id)kCFBooleanTrue)
    {
        return NSOrderedAscending;
    }
    else if (self == (__NSCFBoolean *)kCFBooleanTrue && other == (id)kCFBooleanFalse)
    {
        return NSOrderedDescending;
    }
    else
    {
        double d = [other doubleValue];
        double s = self == (id)kCFBooleanTrue ? 1.0 : 0.0;

        if (s < d)
        {
            return NSOrderedAscending;
        }
        else if (s > d)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }
}

- (NSComparisonResult)_reverseCompare:(id)other
{
    if (self == other)
    {
        return NSOrderedSame;
    }
    else if (self == (__NSCFBoolean *)kCFBooleanFalse && other == (id)kCFBooleanTrue)
    {
        return NSOrderedDescending;
    }
    else if (self == (__NSCFBoolean *)kCFBooleanTrue && other == (id)kCFBooleanFalse)
    {
        return NSOrderedAscending;
    }
    else
    {
        CFComparisonResult result = CFNumberCompare((CFNumberRef)self, (CFNumberRef)other, NULL);

        switch (result) {
            case kCFCompareLessThan:
                return NSOrderedDescending;
            case kCFCompareGreaterThan:
                return NSOrderedAscending;
            case kCFCompareEqualTo:
                return NSOrderedSame;
        }
    }
}

- (BOOL)_getValue:(void *)val forType:(CFNumberType)type
{
    switch (type) {
        case kCFNumberSInt8Type:
        case kCFNumberCharType:
            *(char *)val = [self charValue];
            return YES;
        case kCFNumberSInt16Type:
        case kCFNumberShortType:
            *(short *)val = [self shortValue];
            return YES;
        case kCFNumberSInt32Type:
        case kCFNumberIntType:
        case kCFNumberLongType:
#if !(__LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64)
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
#endif
            *(int *)val = [self intValue];
            return YES;
        case kCFNumberSInt64Type:
        case kCFNumberLongLongType:
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
        case kCFNumberCFIndexType:
        case kCFNumberNSIntegerType:
#endif
            *(long long *)val = [self longLongValue];
            return YES;
        case kCFNumberFloat32Type:
        case kCFNumberFloat64Type:
        case kCFNumberFloatType:
        case kCFNumberCGFloatType:
        case kCFNumberDoubleType:
            *(double *)val = [self doubleValue];
            return YES;
        default:
            return NO;
    }
}

- (CFNumberType)_cfNumberType
{
    return kCFNumberCharType;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
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
    if (self == other)
    {
        return YES;
    }

    return [self compare:other] == NSOrderedSame;
}

SINGLETON_RR()

- (const char *)objCType
{
    return "c";
}

- (void)getValue:(void *)val
{
    *(Boolean *)val = CFBooleanGetValue((CFBooleanRef)self);
}

- (CFTypeID)_cfTypeID
{
    return CFBooleanGetTypeID();
}

- (BOOL)boolValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (unsigned int)unsignedIntegerValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (int)integerValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (double)doubleValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (float)floatValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (unsigned long long)unsignedLongLongValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (long long)longLongValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (unsigned long)unsignedLongValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (long)longValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (unsigned int)unsignedIntValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (int)intValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (unsigned short)unsignedShortValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (short)shortValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (unsigned char)unsignedCharValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (BOOL)charValue
{
    return (CFBooleanRef)self == kCFBooleanTrue;
}

- (id)description
{
    return [self descriptionWithLocale:nil];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale
{
    return [self boolValue] ? @"1" :@ "0";
}

- (NSString *)stringValue
{
    return [self descriptionWithLocale:nil];
}

@end
