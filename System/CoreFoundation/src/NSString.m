//
//  NSString.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSData.h>
#import <unicode/uchar.h>
#import <objc/runtime.h>
#import "NSStringInternal.h"
#import "NSObjectInternal.h"
#import "CFPriv.h"
#import "ForFoundationOnly.h"

static inline CFStringRef __CFExceptionProem(id self, SEL _cmd) {
    const char *className = class_getName([self class]);
    if (!className) {
        className = "NULL CLASS";
    }
    const char *selName = sel_getName(_cmd);
    if (!selName) {
        selName = "NULL SEL";
    }

    CFStringRef proem = nil;
    char *allocBuf = NULL;
    asprintf(&allocBuf, "(%s/%s)", className, selName);
    if (allocBuf) {
        proem = CFStringCreateWithCString(NULL, allocBuf, kCFStringEncodingUTF8);
        proem = CFMakeCollectable(proem);
        free(allocBuf);
    }
    return proem;
}

static inline void mutateError(id self, SEL _cmd, int err) {
    switch (err) {
        case _CFStringErrNone:
            break;
        case _CFStringErrNotMutable:
            NSSTRING_INVALIDMUTATIONERROR;
            break;
        case _CFStringErrNilArg:
            NSSTRING_NILSTRINGERROR;
            break;
        case _CFStringErrBounds:
            NSSTRING_BOUNDSERROR;
            break;
        default:
            NSSTRING_ILLEGALREQUESTERROR;
            break;
    }
}

@implementation __NSCFString

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    if (!_CFStringIsMutable((CFStringRef)self))
    {
        NSInvalidMutation();
        return NSNotFound;
    }

    if ((options & NSRegularExpressionSearch) != 0)
    {
        return [super replaceOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    else
    {
        CFStringCompareFlags flags = (CFStringCompareFlags)options;
        if ((options & NSLiteralSearch) == 0)
        {
            flags |= kCFCompareNonliteral;
        }
        return CFStringFindAndReplace((CFMutableStringRef)self, (CFStringRef)target, (CFStringRef)replacement, CFRangeMake(searchRange.location, searchRange.length), flags);
    }
}

- (void)appendCharacters:(unichar *)characters length:(NSUInteger)length
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        CFStringAppendCharacters((CFMutableStringRef)self, characters, length);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)setString:(NSString *)str
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        CFStringReplaceAll((CFMutableStringRef)self, (CFStringRef)str);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)appendFormat:(NSString *)format, ...
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        va_list args;
        va_start(args, format);
        _CFStringAppendFormatAndArgumentsAux((CFMutableStringRef)self, &_NSCFCopyDescription2, NULL, (CFStringRef)format, args);
        va_end(args);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)deleteCharactersInRange:(NSRange)range
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        CFStringDelete((CFMutableStringRef)self, CFRangeMake(range.location, range.length));
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)appendString:(NSString *)str
{
    CFIndex len = _CFStringGetLength2((CFStringRef)self);
    int ret = __CFStringCheckAndReplace((CFMutableStringRef)self, CFRangeMake(len, 0), (CFStringRef)str);
    mutateError(self, _cmd, ret);
}

- (void)insertString:(NSString *)str atIndex:(NSUInteger)index
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        CFStringInsert((CFMutableStringRef)self, index, (CFStringRef)str);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)replacement
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        CFStringReplace((CFMutableStringRef)self, CFRangeMake(range.location, range.length), (CFStringRef)replacement);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (BOOL)_isCString
{
    return __CFStringIsEightBit((CFStringRef)self);
}

- (Class)classForCoder
{
    if (_CFStringIsMutable((CFStringRef)self))
    {
        return objc_lookUpClass("NSMutableString");
    }
    else
    {
        return objc_lookUpClass("NSString");
    }
}

- (NSStringEncoding)smallestEncoding
{
    return CFStringConvertEncodingToNSStringEncoding(CFStringGetSmallestEncoding((CFStringRef)self));
}

- (NSStringEncoding)fastestEncoding
{
    return CFStringConvertEncodingToNSStringEncoding(CFStringGetFastestEncoding((CFStringRef)self));
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return (id)CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)self);
}

- (void)getLineStart:(NSUInteger *)startPtr end:(NSUInteger *)lineEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range
{
    CFStringGetLineBounds((CFStringRef)self, CFRangeMake(range.location, range.length), (CFIndex *)startPtr, (CFIndex *)lineEndPtr, (CFIndex *)contentsEndPtr);
}

- (BOOL)hasSuffix:(NSString *)prefix
{
    return CFStringHasSuffix((CFStringRef)self, (CFStringRef)prefix);
}

- (BOOL)hasPrefix:(NSString *)suffix
{
    return CFStringHasPrefix((CFStringRef)self, (CFStringRef)suffix);
}

- (BOOL)isEqualToString:(NSString *)other
{
    if (other == nil)
    {
        return NO;
    }

    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }

    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

- (id)substringWithRange:(NSRange)range
{
    return [(__NSCFString *)CFStringCreateWithSubstring(kCFAllocatorDefault, (CFStringRef)self, CFRangeMake(range.location, range.length)) autorelease];
}

- (BOOL)getCString:(char *)bytes maxLength:(NSUInteger)maxLength encoding:(NSStringEncoding)encoding
{
    return CFStringGetCString((CFStringRef)self, bytes, maxLength, CFStringConvertNSStringEncodingToEncoding(encoding));
}

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding
{
    CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding);

    if (cfEncoding == kCFStringEncodingInvalidId)
    {
        return NULL;
    }
    const char *str = CFStringGetCStringPtr((CFStringRef)self, cfEncoding);

    if (str != NULL)
    {
        return str;
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
        return [super cStringUsingEncoding:encoding];
#pragma clang diagnostic pop
    }
}

- (NSUInteger)cStringLength
{
    return [(NSString *)self lengthOfBytesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(CFStringGetSystemEncoding())];
}

static inline const char *cStringForEncoding(__NSCFString *self, CFStringEncoding encoding, BOOL allowLossyConversion)
{
    const char *str = CFStringGetCStringPtr((CFStringRef)self, encoding);

    if (str == NULL)
    {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(encoding);
        NSUInteger length = [(NSString *)self lengthOfBytesUsingEncoding:enc];
        NSMutableData *data = [[NSMutableData alloc] initWithCapacity:length + 1];
        [data setLength:length + 1];
        NSStringEncodingConversionOptions opts = 0;
        if (allowLossyConversion)
        {
            opts = NSStringEncodingConversionAllowLossy|NSStringEncodingConversionExternalRepresentation;
        }
        [self getBytes:[data mutableBytes] maxLength:length usedLength:NULL encoding:enc options:opts range:NSMakeRange(0, [self length]) remainingRange:NULL];
        str = [data bytes];
        [data autorelease];
    }
    
    return str;
}

- (const char *)UTF8String
{
    return cStringForEncoding(self, kCFStringEncodingUTF8, NO);
}

- (const char *)cString
{
    return cStringForEncoding(self, CFStringGetSystemEncoding(), NO);
}

- (const char *)lossyCString
{
    return cStringForEncoding(self, CFStringGetSystemEncoding(), YES);
}

- (const char *)_fastCStringContents:(BOOL)unused
{
    CFStringEncoding encoding = CFStringGetSystemEncoding();
    return CFStringGetCStringPtr((CFStringRef)self, encoding);
}

- (const unichar*)_fastCharacterContents
{
    return CFStringGetCharactersPtr((CFStringRef)self);
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)range
{
    CFStringGetCharacters((CFStringRef)self, CFRangeMake(range.location, range.length), buffer);
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    return CFStringGetCharacterAtIndex((CFStringRef)self, index);
}

- (NSUInteger)length
{
    return _CFStringGetLength2((CFStringRef)self);
}

- (NSUInteger)hash
{
    return __CFStringHash((CFTypeRef)self);
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

- (BOOL)isNSString__
{
    return YES;
}

- (CFTypeID)_cfTypeID
{
    return CFStringGetTypeID();
}

@end
