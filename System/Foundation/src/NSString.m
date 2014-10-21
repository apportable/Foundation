//
//  NSString.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSString.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSCache.h>
#import <Foundation/NSCharacterSet.h>
#import "NSCoderInternal.h"
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSLocale.h>
#import <Foundation/NSRegularExpression.h>
#import "NSStringInternal.h"
#import <Foundation/NSURL.h>
#import "_NSFileIO.h"

#import "CFPriv.h"
#import "CFUnicodeDecomposition.h"
#import "CFString.h"
#import "CFStringTokenizer.h"
#import "NSBOMEncoding.h"
#import "NSRangeCheck.h"
#import "ForFoundationOnly.h"

#import <dispatch/dispatch.h>
#import <unicode/uchar.h>
#import <unicode/ucsdet.h>

static NSUInteger NSStringEncodingConversionFailOnPartial = 4;

@interface __NSStringRegexPatternKey : NSObject {
    NSString *_pattern;
    NSStringCompareOptions _options;
}
@property (nonatomic, readonly) NSString *pattern;
@property (nonatomic, readonly) NSStringCompareOptions options;
@end

@implementation __NSStringRegexPatternKey
- (id)initWithPattern:(NSString *)pattern options:(NSStringCompareOptions)options
{
    self = [super init];
    if (self)
    {
        _pattern = [pattern copy];
        _options = options;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    return [_pattern isEqualToString:[object pattern]] && _options == [(__NSStringRegexPatternKey *)object options];
}

- (NSUInteger)hash
{
    return [_pattern hash] ^ _options;
}

@end

@implementation NSString (NSString)

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithCoder:(NSCoder *)coder
{
    NSUInteger length = 0;
    const void *bytes = NULL;

    if ([coder allowsKeyedCoding])
    {
        if ([coder isKindOfClass:[NSKeyedUnarchiver class]] || [coder containsValueForKey:@"NS.string"])
        {
            id string = [coder _decodePropertyListForKey:@"NS.string"];
            self = [self initWithString:string];
        }
        else
        {
            bytes = [coder decodeBytesForKey:@"NS.bytes" returnedLength:&length];
            self = [self initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        }
    }
    else
    {
        if ([coder versionForClassName:@"NSString"] == 1)
        {
            bytes = [coder decodeBytesWithReturnedLength:&length];
            self = [self initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        }
        else
        {
            [NSException raise:NSGenericException format:@"Bad string version in coder"];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding] && [coder isKindOfClass:[NSKeyedArchiver class]])
    {
        [coder _encodePropertyList:self forKey:@"NS.string"];
        return;
    }

    NSUInteger length = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger usedLength;

    // TODO use c99 dynamic array for small lengths to improve performance
    void *bytes = malloc(length);
    if (bytes == NULL)
    {
        // Sigh.
        return;
    }

    BOOL ret = [self getBytes:bytes maxLength:length usedLength:&usedLength encoding:NSUTF8StringEncoding
                     options:0 range:NSMakeRange(0, length) remainingRange:NULL];
    if (!ret)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to get bytes"];
    }

    if ([coder allowsKeyedCoding])
    {
        [coder encodeBytes:bytes length:usedLength forKey:@"NS.bytes"];
    }
    else
    {
        [coder encodeBytes:bytes length:usedLength];
    }

    free(bytes);

    return;
}
OBJC_PROTOCOL_IMPL_POP

@end

@implementation NSMutableString (NSMutableString)

- (NSUInteger)_replaceOccurrencesOfRegularExpressionPattern:(NSString *)pattern withTemplate:(NSString *)replacementTemplate options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    static dispatch_once_t once = 0L;
    static NSCache *regexCache = nil;
    dispatch_once(&once, ^{
        regexCache = [[NSCache alloc] init];
    });
    __NSStringRegexPatternKey *key = [[__NSStringRegexPatternKey alloc] initWithPattern:pattern options:options];
    NSRegularExpression *regex = [[regexCache objectForKey:key] retain];
    if (regex == nil)
    {
        NSRegularExpressionOptions regexOpts = 0;
        NSError *err = nil;
        if ((options & NSCaseInsensitiveSearch) != 0)
        {
            regexOpts |= NSRegularExpressionCaseInsensitive;
        }
        regex = [[NSRegularExpression alloc] initWithPattern:pattern options:regexOpts error:&err];
        [regexCache setObject:regex forKey:key];
    }
    NSMatchingOptions opts = 0;
    if ((options & NSAnchoredSearch) != 0)
    {
        opts |= NSMatchingAnchored;
    }
    NSUInteger found = [regex replaceMatchesInString:self options:opts range:searchRange withTemplate:replacementTemplate];
    [regex release];
    return found;
}

@end

NSString * const NSParseErrorException = @"NSParseErrorException";

static NSStringEncoding __NSDefaultCStringEncoding()
{
    static NSStringEncoding defaultEncoding = 0;
    if (defaultEncoding == 0)
    {

        CFStringEncoding encoding = CFStringGetSystemEncoding();
        defaultEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
    }
    return defaultEncoding;
}

@implementation NSString

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSString class])
    {
        static NSPlaceholderString *placeholder = nil;
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            placeholder = [NSPlaceholderString allocWithZone:nil];
        });
        return placeholder;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

+ (void)initialize
{
    [self setVersion:1];
}

- (NSUInteger)length
{
    NSRequestConcreteImplementation();
    return 0;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSString allocWithZone:zone] initWithString:self];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[NSMutableString allocWithZone:zone] initWithString:self];
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ([aDecoder allowsKeyedCoding])
    {
        NSString *string;

        if (object_getClass(aDecoder) == objc_getClass("NSKeyedArchiver") && [aDecoder containsValueForKey:@"NS.string"])
        {
            string = [aDecoder _decodePropertyListForKey:@"NS.string"];
        }
        else if ([aDecoder containsValueForKey:@"NS.bytes"])
        {
            string = [aDecoder decodeObjectForKey:@"NS.bytes"];
        }
        else
        {
            [NSException raise:NSInternalInconsistencyException format:@"Unexpected coder"];
            [self release];
            return nil;
        }
        return [self initWithString:string];
    }
    else
    {
        NSUInteger length;
        NSStringEncoding encoding;
        [aDecoder decodeValueOfObjCType:@encode(NSStringEncoding) at:&encoding];
        void *bytes = [aDecoder decodeBytesWithReturnedLength:&length];
        return [self initWithBytes:bytes length:length encoding:encoding];
    }
}

- (Class)classForCoder
{
    return [NSString self];
}

- (CFTypeID)_cfTypeID
{
    return CFStringGetTypeID();
}

- (NSUInteger)hash
{
    return CFStringHashNSString((CFStringRef)self);
}


- (BOOL)isNSString__
{
    return YES;
}

- (CFStringEncoding)_fastestEncodingInCFStringEncoding
{
    return CFStringConvertNSStringEncodingToEncoding([self fastestEncoding]);
}

- (NSString *)_createSubstringWithRange:(NSRange)r
{
    // used in CFStringCreateWithSubstring
    static IMP base = NULL;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        base = class_getMethodImplementation([NSString class], @selector(substringWithRange:));
    });
    
    NSString *substr = nil;
    if (class_getMethodImplementation([self class], @selector(substringWithRange:)) != base)
    {
        substr = [[self substringWithRange:r] retain];
    }
    else
    {
        NSUInteger len = [self length];
        if (NSMaxRange(r) > len)
        {
            [NSException raise:NSRangeException format:@"specified range is out of bounds of string"];
            return nil;
        }
        substr = [self _newSubstringWithRange:r zone:nil];
    }
    
    return substr;
}

- (NSString *)_newSubstringWithRange:(NSRange)range zone:(NSZone *)zone
{
    NSUInteger length = [self length];
    if (length == 0)
    {
        return @"";
    }
    else
    {
        const char *contents = [self _fastCStringContents:NO];
        if (contents != NULL)
        {
            CFStringEncoding encoding;
            if (__CFDefaultEightBitStringEncoding == kCFStringEncodingInvalidId)
            {
                __CFStringComputeEightBitStringEncoding();
            }
            encoding = __CFDefaultEightBitStringEncoding;
            return (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)(contents + range.location), range.length, encoding, false);
        }
        else
        {
            unichar *buffer = calloc(range.length, sizeof(unichar));
            [self getCharacters:buffer range:range];
            return [[NSString alloc] initWithCharactersNoCopy:buffer length:range.length freeWhenDone:YES];
        }
    }
}

@end

@implementation NSMutableString

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSMutableString class])
    {
        static NSPlaceholderMutableString *placeholder = nil;
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            placeholder = [NSPlaceholderMutableString allocWithZone:nil];
        });
        return placeholder;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    NSRequestConcreteImplementation();
}

- (Class)classForCoder
{
    return [NSMutableString self];
}

@end

@implementation NSPlaceholderString

- (NSUInteger)length
{
    NSRequestConcreteImplementation();
    return 0;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)init
{
    return (NSPlaceholderString *)@"";
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding
{
    return (id)CFStringCreateWithBytes(kCFAllocatorDefault, bytes, len, CFStringConvertNSStringEncodingToEncoding(encoding), true);
}

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [self initWithBytes:[data bytes] length:[data length] encoding:encoding];
}

- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList
{
    return (id)_CFStringCreateWithFormatAndArgumentsAux(kCFAllocatorDefault, &_NSCFCopyDescription2, NULL, (CFStringRef)format, argList);
}

- (id)initWithString:(NSString *)str
{
    if (str == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"***" userInfo:nil];
    }
    // Note: we cant use isKindOfClass here since NSString lies about it's parentage in some cases
    if (object_getClass(str) == objc_getClass("__NSCFString"))
    {
        return (id)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)str);
    }
    else
    {
        NSUInteger length = [str length];
        if (length > (NSUIntegerMax / sizeof(unichar)))
        {
            return nil;
        }
        unichar *buffer = CFAllocatorAllocate(kCFAllocatorMalloc, MAX(length, 1) * sizeof(unichar), 0);
        [str getCharacters:buffer];

        return (id)CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, buffer, length, kCFAllocatorMalloc);
    }
}

- (id)initWithCString:(const char *)str
{
    return (id)CFStringCreateWithCString(kCFAllocatorDefault, str, CFStringGetSystemEncoding());
}

- (id)initWithCString:(const char *)str length:(NSUInteger)length
{
    return (id)CFStringCreateWithBytes(kCFAllocatorDefault, str, length, CFStringGetSystemEncoding(), false);
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer
{
    return (id)CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, bytes, len, CFStringConvertNSStringEncodingToEncoding(encoding), true, freeBuffer ? kCFAllocatorMalloc : kCFAllocatorNull);
}

- (id)initWithCStringNoCopy:(char *)str length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{
    return (id)CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, str, length, CFStringGetSystemEncoding(), false, freeBuffer ? kCFAllocatorMalloc : kCFAllocatorNull);
}

- (id)initWithCString:(const char *)str encoding:(NSStringEncoding)encoding
{
    return (id)CFStringCreateWithCString(kCFAllocatorDefault, str, CFStringConvertNSStringEncodingToEncoding(encoding));
}
- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
    return (id)CFStringCreateWithCharacters(kCFAllocatorDefault, characters, length);
}

- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{
    return (id)CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, characters, length, freeBuffer ? kCFAllocatorMalloc : kCFAllocatorNull);
}

SINGLETON_RR()

@end

@implementation NSPlaceholderMutableString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)replacement
{
    NSRequestConcreteImplementation();
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSUInteger)length
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    _CFStringAppendFormatAndArgumentsAux(str, &_NSCFCopyDescription2, NULL, (CFStringRef)format, argList);
    return (id)str;
}

- (id)initWithCStringNoCopy:(char *)str length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{
    CFStringRef string = CFStringCreateWithBytes(kCFAllocatorDefault, str, length, CFStringGetSystemEncoding(), false);
    if (freeBuffer)
    {
        free(str);
    }
    CFMutableStringRef mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    CFRelease(string);
    return (id)mutableString;
}

- (id)initWithCString:(const char *)str encoding:(NSStringEncoding)encoding
{
    CFMutableStringRef string = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppendCString(string, str, CFStringConvertNSStringEncodingToEncoding(encoding));
    return (id)string;
}

- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{
    CFMutableStringRef string = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppendCharacters(string, characters, length);
    if (freeBuffer)
    {
        free(characters);
    }
    return (id)string;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer
{
    CFStringRef string = CFStringCreateWithBytes(kCFAllocatorDefault, bytes, len, CFStringConvertNSStringEncodingToEncoding(encoding), true);
    if (freeBuffer)
    {
        free(bytes);
    }
    CFMutableStringRef mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    CFRelease(string);
    return (id)mutableString;
}

- (id)initWithUTF8String:(const char *)str
{
    CFStringRef string = CFStringCreateWithBytes(kCFAllocatorDefault, str, strlen(str), kCFStringEncodingUTF8, false);
    CFMutableStringRef mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    CFRelease(string);
    return (id)mutableString;
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding
{
    CFStringRef string = CFStringCreateWithBytes(kCFAllocatorDefault, bytes, len, CFStringConvertNSStringEncodingToEncoding(encoding), true);
    CFMutableStringRef mutableString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
    CFRelease(string);
    return (id)mutableString;
}

- (id)initWithString:(NSString *)string
{
    if ([string class] == objc_getClass("__NSCFString"))
    {
        return (id)CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef)string);
    }
    else
    {
        CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
        CFStringAppend(str, (CFStringRef)string);
        return (id)str;
    }
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    return (id)CFStringCreateMutable(kCFAllocatorDefault, capacity);
}

- (id)init
{
    return (id)CFStringCreateMutable(kCFAllocatorDefault, 0);
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    // placeholders are singletons and cannot be relased.
}

- (void)dealloc
{
    [NSException raise:NSInternalInconsistencyException format:@"placeholder object cannot be released"];
    [super dealloc];
}

- (id)retain
{
    return self;
}

@end

@implementation NSString (NSStringExtensionMethods)

+ (NSStringEncoding)defaultCStringEncoding
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=269
    return NSUTF8StringEncoding;
}

+ (const NSStringEncoding *)availableStringEncodings
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=269
    return nil;
}

+ (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=269
    return nil;
}

+ (id)string
{
    return [[[self alloc] init] autorelease];
}

+ (id)stringWithString:(NSString *)string
{
    return [[[self alloc] initWithString:string] autorelease];
}

+ (id)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
    return [[[self alloc] initWithCharacters:characters length:length] autorelease];
}

+ (id)stringWithUTF8String:(const char *)nullTerminatedCString
{
    return [[[self alloc] initWithUTF8String:nullTerminatedCString] autorelease];
}

+ (id)stringWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *str = [[self alloc] initWithFormat:format locale:nil arguments:args];
    va_end(args);
    return [str autorelease];
}

+ (id)localizedStringWithFormat:(NSString *)format, ...
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=269
    return nil;
}

+ (id)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc
{
    return [[[self alloc] initWithCString:cString encoding:enc] autorelease];
}

+ (id)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    return [[[self alloc] initWithContentsOfURL:url encoding:enc error:error] autorelease];
}

+ (id)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
    return [[[self alloc] initWithContentsOfFile:path encoding:enc error:error] autorelease];
}

+ (id)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    return [[[self alloc] initWithContentsOfURL:url usedEncoding:enc error:error] autorelease];
}

+ (id)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    return [[[self alloc] initWithContentsOfFile:path usedEncoding:enc error:error] autorelease];
}

- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
    return [self initWithCharactersNoCopy:(unichar *)characters length:length freeWhenDone:NO];
}

- (id)initWithUTF8String:(const char *)nullTerminatedCString
{
    if (nullTerminatedCString == NULL)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"null terminated c strings should not be NULL"];
        return nil;
    }
    return [self initWithBytes:nullTerminatedCString length:strlen(nullTerminatedCString) encoding:NSUTF8StringEncoding];
}

- (id)initWithString:(NSString *)str
{
    NSUInteger length = [str length];
    unichar *buffer = malloc(sizeof(unichar) * length);
    [str getCharacters:buffer];
    return [self initWithCharactersNoCopy:buffer length:length freeWhenDone:YES];
}

- (id)initWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *string = [self initWithFormat:format locale:nil arguments:args];
    va_end(args);
    return string;
}

- (id)initWithFormat:(NSString *)format arguments:(va_list)argList
{
    return [self initWithFormat:format locale:nil arguments:argList];
}

- (id)initWithFormat:(NSString *)format locale:(id)locale, ...
{
    va_list args;
    va_start(args, locale);
    NSString *string = [self initWithFormat:format locale:locale arguments:args];
    va_end(args);
    return string;
}

- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [self initWithBytes:[data bytes] length:[data length] encoding:encoding];
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding
{
    return [self initWithBytes:nullTerminatedCString length:strlen(nullTerminatedCString) encoding:encoding];
}

- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error
{
    if ([url isFileURL])
    {
        return [self initWithContentsOfFile:[url path] encoding:enc error:error];
    }
    else
    {
        NSData *data = [[[NSData alloc] initWithContentsOfURL:url options:0 error:error] autorelease];
        if (data == nil)
        {
            [self release];
            return nil;
        }
        return [self initWithData:data encoding:enc];
    }
}

- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error
{
    NSUInteger length = 0;
    void *bytes = _NSReadBytesFromFile(path, 0, &length, NULL, error);
    if (bytes == NULL)
    {
        [self release];
        return nil;
    }
    return [self initWithBytesNoCopy:bytes length:length encoding:enc freeWhenDone:YES];
}

- (id)_initWithBytesOfUnknownEncoding:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy usedEncoding:(NSStringEncoding *)usedEncoding
{
    NSStringEncoding encoding = 0;
    uint32_t BOM;
    if (length > 4)
    {
        memcpy(&BOM, bytes, 4);
        _NSDetectEncodingFromBOM(BOM, &encoding, NULL);
    }

    if (encoding == 0)
    {
        UCharsetDetector *csd;
        const UCharsetMatch *ucm;
        UErrorCode status = U_ZERO_ERROR;
        const char *matchName = NULL;
        do {
            csd = ucsdet_open(&status);
            if (csd == NULL || status != U_ZERO_ERROR)
            {
                break;
            }

            ucsdet_setText(csd, bytes, length, &status);
            if (status != U_ZERO_ERROR) {
                break;
            }

            ucsdet_enableInputFilter(csd, TRUE);

            ucm = ucsdet_detect(csd, &status);
            if (ucm == NULL || status != U_ZERO_ERROR)
            {
                break;
            }

            matchName = ucsdet_getName(ucm, &status);
            if (matchName == NULL || status != U_ZERO_ERROR)
            {
                break;
            }

            if (strcmp(matchName, "UTF-8") == 0)
            {
                encoding = NSUTF8StringEncoding;
            }
            else if (strcmp(matchName, "UTF-16BE") == 0)
            {
                encoding = NSUTF16BigEndianStringEncoding;
            }
            else if (strcmp(matchName, "UTF-16LE") == 0)
            {
                encoding = NSUTF16BigEndianStringEncoding;
            }
            else if (strcmp(matchName, "UTF-32BE") == 0)
            {
                encoding = NSUTF32BigEndianStringEncoding;
            }
            else if (strcmp(matchName, "UTF-32LE") == 0)
            {
                encoding = NSUTF32LittleEndianStringEncoding;
            }
            else if (strcmp(matchName, "Shift_JIS") == 0)
            {
                encoding = NSShiftJISStringEncoding;
            }
            else if (strcmp(matchName, "ISO-2022-JP") == 0)
            {
                encoding = NSISO2022JPStringEncoding;
            }
            else if (strcmp(matchName, "ISO-8859-1") == 0)
            {
                encoding = NSISOLatin1StringEncoding;
            }
            else if (strcmp(matchName, "ISO-8859-2") == 0)
            {
                encoding = NSISOLatin2StringEncoding;
            }
            else if (strcmp(matchName, "windows-1250") == 0)
            {
                encoding = NSWindowsCP1250StringEncoding;
            }
            else if (strcmp(matchName, "windows-1251") == 0)
            {
                encoding = NSWindowsCP1251StringEncoding;
            }
            else if (strcmp(matchName, "windows-1252") == 0)
            {
                encoding = NSWindowsCP1252StringEncoding;
            }
            else if (strcmp(matchName, "windows-1253") == 0)
            {
                encoding = NSWindowsCP1253StringEncoding;
            }
            else if (strcmp(matchName, "windows-1254") == 0)
            {
                encoding = NSWindowsCP1254StringEncoding;
            }
            /*
            The following encodings need homes?
            ISO-2022-CN
            ISO-2022-KR
            GB18030
            Big5
            EUC-JP
            EUC-KR
            ISO-8859-5
            ISO-8859-6
            ISO-8859-7
            ISO-8859-8
            ISO-8859-9
            windows-1255
            windows-1256
            KOI8-R
            IBM420
            IBM424
            */
        } while (0);
        if (csd != NULL)
        {
            ucsdet_close(csd);
        }
    }

    if (encoding == 0)
    {
        encoding = NSNonLossyASCIIStringEncoding; // well I guess it might work?
        // perhaps this is an error and forces a nil return, worth further testing
    }

    if (usedEncoding != NULL)
    {
        *usedEncoding = encoding;
    }
    if (shouldCopy)
    {
        id string = [self initWithBytes:bytes length:length encoding:encoding];
        free(bytes);
        return string;
    }
    else
    {
        return [self initWithBytesNoCopy:bytes length:length encoding:encoding freeWhenDone:YES];
    }
}

- (id)_initWithDataOfUnknownEncoding:(NSData *)data
{
    NSStringEncoding usedEncoding;
    return [self _initWithBytesOfUnknownEncoding:(void *)[data bytes] length:[data length] copy:YES usedEncoding:&usedEncoding];
}

- (id)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    if ([url isFileURL])
    {
        NSUInteger length = 0;
        void *bytes = _NSReadBytesFromFile([url path], 0, &length, NULL, error);
        if (bytes == NULL)
        {
            [self release];
            return nil;
        }
        return [self _initWithBytesOfUnknownEncoding:bytes length:length copy:NO usedEncoding:enc];
    }
    else
    {
        NSData *data = [[[NSData alloc] initWithContentsOfURL:url options:0 error:error] autorelease];
        if (data == nil)
        {
            [self release];
            return nil;
        }
        return [self _initWithBytesOfUnknownEncoding:(void *)[data bytes] length:[data length] copy:YES usedEncoding:enc];
    }
}

- (id)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error
{
    NSUInteger length = 0;
    void *bytes = _NSReadBytesFromFile(path, 0, &length, NULL, error);
    if (bytes == NULL)
    {
        [self release];
        return nil;
    }
    return [self _initWithBytesOfUnknownEncoding:bytes length:length copy:NO usedEncoding:enc];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange
{
    NSUInteger idx = 0;
    for (NSUInteger location = aRange.location; location < NSMaxRange(aRange); location++)
    {
        buffer[idx] = [self characterAtIndex:location];
        idx++;
    }
}

- (NSString *)substringFromIndex:(NSUInteger)from
{
    return [self substringWithRange:NSMakeRange(from, [self length] - from)];
}

- (NSString *)substringToIndex:(NSUInteger)to
{
    return [self substringWithRange:NSMakeRange(0, to)];
}

- (NSString *)substringWithRange:(NSRange)range
{
    unichar *buffer = malloc(sizeof(unichar) * range.length);
    [self getCharacters:buffer range:range];
    return [[[NSString alloc] initWithCharactersNoCopy:buffer length:range.length freeWhenDone:YES] autorelease];
}

- (NSComparisonResult)compare:(NSString *)string
{
    return [self compare:string options:0 range:NSMakeRange(0, [self length]) locale:nil];
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask
{
    return [self compare:string options:mask range:NSMakeRange(0, [self length]) locale:nil];
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange
{
    return [self compare:string options:mask range:compareRange locale:nil];
}

- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange locale:(id)locale
{
    if (!string)
    {
        // NOTE : "If the value is nil, the behavior is undefined and may change in future versions of OS X."
        return NSOrderedDescending;
    }
    return (NSComparisonResult)CFStringCompareWithOptionsAndLocale((CFStringRef)self, (CFStringRef)string, CFRangeMake(compareRange.location, compareRange.length), (CFStringCompareFlags)mask, (CFLocaleRef)locale);
}

- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string
{
    return [self compare:string options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length]) locale:nil];
}

- (NSComparisonResult)localizedCompare:(NSString *)string
{
    return [self compare:string options:0 range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string
{
    return [self compare:string options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

- (NSComparisonResult)localizedStandardCompare:(NSString *)string
{
    return [self compare:string options:NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]];
}

- (BOOL)isEqual:(id)other
{
    if ([other isNSString__])
    {
        return [self isEqualToString:other];
    }
    else
    {
        return NO;
    }
}

- (BOOL)isEqualToString:(NSString *)str
{
    if (self == str)
    {
        return YES;
    }
    NSUInteger len1 = [self length];
    NSUInteger len2 = [str length];
    if (len1 != len2)
    {
        return NO;
    }
    return [self compare:str options:NSLiteralSearch range:NSMakeRange(0, len1) locale:nil] == kCFCompareEqualTo;
}

- (BOOL)hasPrefix:(NSString *)str
{
    if ([str length] > [self length])
    {
        return NO;
    }

    return [self rangeOfString:str options:NSLiteralSearch range:NSMakeRange(0, [str length])].location != NSNotFound;
}

- (BOOL)hasSuffix:(NSString *)str
{
    NSUInteger len1 = [self length];
    NSUInteger len2 = [str length];
    if (len1 < len2)
    {
        return NO;
    }
    return [self rangeOfString:str options:NSLiteralSearch range:NSMakeRange(len1 - len2, len2)].location != NSNotFound;
}

- (NSRange)rangeOfString:(NSString *)str
{
    return [self rangeOfString:str options:0 range:NSMakeRange(0, [self length]) locale:nil];
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask
{
    return [self rangeOfString:str options:mask range:NSMakeRange(0, [self length]) locale:nil];
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange
{
    return [self rangeOfString:str options:mask range:searchRange locale:nil];
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale
{
    if (!NSRangeCheckException(searchRange, [self length]))
    {
        return NSMakeRange(NSNotFound, 0);
    }

    if (mask & NSRegularExpressionSearch)
    {
        NSError  *error  = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:str options:0 error:&error];
        if (error)
        {
            return NSMakeRange(NSNotFound, 0);
        }
        return [regex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    }

    CFRange found;
    if (CFStringFindWithOptionsAndLocale((CFStringRef)self, (CFStringRef)str, CFRangeMake(searchRange.location, searchRange.length), (CFStringCompareFlags)mask, (CFLocaleRef)locale, &found))
    {
        return NSMakeRange(found.location, found.length);
    }
    else
    {
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet
{
    return [self rangeOfCharacterFromSet:aSet options:0 range:NSMakeRange(0, [self length])];
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask
{
    return [self rangeOfCharacterFromSet:aSet options:mask range:NSMakeRange(0, [self length])];
}

- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask range:(NSRange)searchRange
{
    CFRange found;
    if (CFStringFindCharacterFromSet((CFStringRef)self, (CFCharacterSetRef)aSet, CFRangeMake(searchRange.location, searchRange.length), (CFStringCompareFlags)mask, &found))
    {
        return NSMakeRange(found.location, found.length);
    }
    else
    {
        return NSMakeRange(NSNotFound, 0);
    }
}

- (NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index
{
    CFRange r = CFStringGetRangeOfCharacterClusterAtIndex((CFStringRef)self, index, kCFStringComposedCharacterCluster);
    return NSMakeRange(r.location, r.length);
}

- (NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range
{
    NSRange composed = NSMakeRange(NSNotFound, 0);
    NSRange minRange = [self rangeOfComposedCharacterSequenceAtIndex:range.location];
    if (minRange.location == NSNotFound)
    {
        return composed;
    }
    composed.location = minRange.location;

    NSRange maxRange = [self rangeOfComposedCharacterSequenceAtIndex:NSMaxRange(range)];
    composed.length = NSMaxRange(maxRange) - minRange.location;

    return composed;
}

- (NSString *)description
{
    return self;
}

- (NSString *)stringByAppendingString:(NSString *)str
{
    NSUInteger len1 = [self length];
    NSUInteger len2 = [str length];
    NSUInteger length = len1 + len2;
    if (length == 0)
    {
        return @"";
    }

    unichar *buffer = malloc(length * sizeof(unichar));
    [self getCharacters:buffer range:NSMakeRange(0, len1)];
    [str getCharacters:buffer + len1 range:NSMakeRange(0, len2)];
    return [[[NSString alloc] initWithCharactersNoCopy:buffer length:length freeWhenDone:YES] autorelease];
}

- (NSString *)stringByAppendingFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSString *ret = [self stringByAppendingString:str];
    [str release];
    return ret;
}

- (NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc
{
    return CFStringGetMaximumSizeForEncoding([self length], CFStringConvertNSStringEncodingToEncoding(enc));
}

/*!
 @note     Returns mutable
 */
- (NSArray *)componentsSeparatedByString:(NSString *)separator
{
    if (separator == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passed a nil separator to componentsSeparatedByString" userInfo:nil];
        return nil;
    }
    NSRange search = NSMakeRange(0, [self length]);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while (YES)
    {
        NSRange found = [self rangeOfString:separator options:0 range:search];
        if (found.location == NSNotFound)
        {
            if ([array count] == 0)
            {
                NSString *copyHolder = [self copy];
                [array addObject:copyHolder];
                [copyHolder release];
            }
            else
            {
                [array addObject:[self substringWithRange:search]];
            }
            break;
        }
        NSRange subRange = NSMakeRange(search.location, found.location - search.location);
        [array addObject:[self substringWithRange:subRange]];
        search = NSMakeRange(NSMaxRange(found), NSMaxRange(search) - NSMaxRange(found));
    }
    return [array autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator
{
    if (separator == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passed a nil separator to componentsSeparatedByCharactersInSet" userInfo:nil];
        return nil;
    }
    NSRange search = NSMakeRange(0, [self length]);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while (YES)
    {
        NSRange found = [self rangeOfCharacterFromSet:separator options:0 range:search];
        if (found.location == NSNotFound)
        {
            if ([array count] == 0)
            {
                NSString *copyHolder = [self copy];
                [array addObject:copyHolder];
                [copyHolder release];
            }
            else
            {
                [array addObject:[self substringWithRange:search]];
            }
            break;
        }
        NSRange subRange = NSMakeRange(search.location, found.location - search.location);
        if (subRange.length > 0)
        {
            [array addObject:[self substringWithRange:subRange]];
        }
        else
        {
            [array addObject:@""];
        }
        search = NSMakeRange(NSMaxRange(found), NSMaxRange(search) - NSMaxRange(found));
    }
    return [array autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)uppercaseStringWithLocale:(NSLocale *)locale
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringUppercase(str, (CFLocaleRef)locale);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)uppercaseString
{
    return [self uppercaseStringWithLocale:nil];
}

/*!
 @note     Returns mutable
 */
- (NSString *)lowercaseStringWithLocale:(NSLocale *)locale
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringLowercase(str, (CFLocaleRef)locale);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)lowercaseString
{
    return [self lowercaseStringWithLocale:nil];
}

/*!
 @note     Returns mutable
 */
- (NSString *)capitalizedStringWithLocale:(NSLocale *)locale
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringCapitalize(str, (CFLocaleRef)locale);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)capitalizedString
{
    return [self capitalizedStringWithLocale:nil];
}

- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set
{
    if (set == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil set"];
        return nil;
    }
    NSUInteger len = [self length];
    NSUInteger i;
    NSUInteger j;
    for (i = 0; i < len; i++)
    {
        if (![set characterIsMember:[self characterAtIndex:i]]) {
            break;
        }
    }
    if (i == len)
    {
        return @"";
    }
    for (j = len - 1; j > i; j--)
    {
        if (![set characterIsMember:[self characterAtIndex:j]]) {
            break;
        }
    }
    return [self substringWithRange:NSMakeRange(i, j - i + 1)];
}

- (NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex
{
    NSUInteger length = [self length];
    NSUInteger padLength = [padString length];
    if (padLength == 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil or empty pad string"];
        return nil;
    }

    if (padIndex > padLength - 1)
    {
        [NSException raise:NSInvalidArgumentException format:@"out of range padIndex"];
        return nil;
    }

    if (newLength == length)
    {
        return self;
    }

    CFMutableStringRef str = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, (CFStringRef)self);
    CFStringPad(str, (CFStringRef)padString, newLength, padIndex);
    return (NSString *)str;
}

#define CarriageReturn '\r'    /* 0x0d */
#define NewLine '\n'        /* 0x0a */
#define NextLine 0x0085
#define LineSeparator 0x2028
#define ParaSeparator 0x2029

CF_INLINE Boolean isALineSeparatorTypeCharacter(UniChar ch, Boolean includeLineEndings) {
    if (ch > CarriageReturn && ch < NextLine) return false;
    return (ch == NewLine || ch == CarriageReturn || ch == ParaSeparator || (includeLineEndings && (ch == NextLine || ch == LineSeparator))) ? true : false;
}

- (void)_getBlockStart:(NSUInteger *)startPtr end:(NSUInteger *)blockEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range stopAtLineSeparators:(BOOL)stopOnLines
{
    NSUInteger len = [self length];
    unichar ch;

    if (range.location > len || NSMaxRange(range) > len)
    {
        [NSException raise:NSRangeException format:@"specified range is out of bounds of string"];
        return;
    }


    if (startPtr)
    {
        NSUInteger start;
        if (range.location == 0)
        {
            start = 0;
        }
        else
        {
            NSInteger idx = range.location;
            ch = [self characterAtIndex:idx];
            idx--;
            if (ch == NewLine && [self characterAtIndex:idx] == CarriageReturn)
            {
                idx--;
            }
            while (true)
            {
                if (idx < 0)
                {
                    start = 0;
                    break;
                }
                else if (isALineSeparatorTypeCharacter([self characterAtIndex:idx] , stopOnLines))
                {
                    start = idx + 1;
                    break;
                }
                else
                {
                    idx--;
                }
            }
        }
        *startPtr = start;
    }

    if (blockEndPtr || contentsEndPtr)
    {
        NSUInteger endOfContents, lineSeparatorLength = 1;    /* 1 by default */

        NSInteger idx = range.location + range.length - (range.length ? 1 : 0);

        ch = [self characterAtIndex:idx];
        if (ch == NewLine)
        {
            endOfContents = idx;
            idx--;
            if ([self characterAtIndex:idx] == CarriageReturn)
            {
                lineSeparatorLength = 2;
                endOfContents--;
            }
        }
        else
        {
            while (true)
            {
                if (isALineSeparatorTypeCharacter(ch, stopOnLines))
                {
                    endOfContents = idx;
                    idx++;
                    if ((ch == CarriageReturn) && ([self characterAtIndex:idx] == NewLine))
                    {
                        lineSeparatorLength = 2;
                    }
                    break;
                }
                else if (idx >= len)
                {
                    endOfContents = len;
                    lineSeparatorLength = 0;
                    break;
                }
                else
                {
                    idx++;
                    ch = [self characterAtIndex:idx];
                }
            }
        }
        if (contentsEndPtr) *contentsEndPtr = endOfContents;
        if (blockEndPtr) *blockEndPtr = endOfContents + lineSeparatorLength;
    }
}

- (void)getLineStart:(NSUInteger *)startPtr end:(NSUInteger *)lineEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range
{
    [self _getBlockStart:startPtr end:lineEndPtr contentsEnd:contentsEndPtr forRange:range stopAtLineSeparators:YES];
}

- (NSRange)lineRangeForRange:(NSRange)range
{
    NSRange found = NSMakeRange(NSNotFound, 0);
    NSUInteger start = NSNotFound;
    NSUInteger end = NSNotFound;
    [self getLineStart:&start end:&end contentsEnd:NULL forRange:range];
    if (start != NSNotFound && end != NSNotFound)
    {
        found = NSMakeRange(start, end - start);
    }
    return found;
}

- (void)getParagraphStart:(NSUInteger *)startPtr end:(NSUInteger *)parEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range
{
    [self _getBlockStart:startPtr end:parEndPtr contentsEnd:contentsEndPtr forRange:range stopAtLineSeparators:NO];
}

- (NSRange)paragraphRangeForRange:(NSRange)range
{
    NSRange found = NSMakeRange(NSNotFound, 0);
    NSUInteger start = NSNotFound;
    NSUInteger end = NSNotFound;
    [self getParagraphStart:&start end:&end contentsEnd:NULL forRange:range];
    if (start != NSNotFound && end != NSNotFound)
    {
        found = NSMakeRange(start, end - start);
    }
    return found;
}

- (NSStringEncoding)fastestEncoding
{
    return NSUnicodeStringEncoding;
}

- (NSStringEncoding)smallestEncoding
{
    if (![self canBeConvertedToEncoding:NSASCIIStringEncoding])
    {
        return __NSDefaultCStringEncoding();
    }
    else
    {
        return NSASCIIStringEncoding;
    }
}

- (BOOL)_encodingCantBeStoredInEightBitCFString
{
    return NO;
}

/*!
 @note     Returns mutable
 */
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy
{
    NSUInteger length = [self length];
    CFStringEncoding enc = CFStringConvertNSStringEncodingToEncoding(encoding);
    CFIndex byteLength = 0;
    CFIndex converted = __CFStringEncodeByteStream((CFStringRef)self, 0, length, false, enc, lossy ? '?' : 0, NULL, 0, &byteLength);
    if (converted != length)
    {
        return nil;
    }

    NSMutableData *data = [[NSMutableData alloc] initWithLength:byteLength];
    converted = __CFStringEncodeByteStream((CFStringRef)self, 0, length, false, enc, lossy ? '?' : 0, [data mutableBytes], byteLength, NULL);
    if (converted != length)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Unable to convert all of the characters expected"];
        return nil;
    }

    return [data autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding
{
    return [self dataUsingEncoding:encoding allowLossyConversion:NO];
}

- (NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)encoding
{
    CFIndex len = [self length];
    CFIndex usedLen = 0;
    if (__CFStringEncodeByteStream((CFStringRef)self, 0, len, false, CFStringConvertNSStringEncodingToEncoding(encoding), 0, NULL, 0, &usedLen) == len)
    {
        return (NSUInteger)usedLen;
    }
    else
    {
        return 0;
    }
}

static const char* bytesInEncoding(NSString *string, BOOL externalRep, NSStringEncoding encoding, BOOL lossy, BOOL raiseOnError)
{
    NSUInteger byteLength = 0;
    NSStringEncodingConversionOptions options = NSStringEncodingConversionFailOnPartial;
    if (lossy)
    {
        options |= NSStringEncodingConversionAllowLossy;
    }
    if (externalRep)
    {
        options |= NSStringEncodingConversionExternalRepresentation;
    }
    NSUInteger stringLength = [string length];
    NSRange range = NSMakeRange(0, stringLength);
    
    const int stackBufferSize = 1000;
    // 6 corresponds to the largest multiplier in CFStringGetMaximumSizeForEncoding
    if (stringLength < stackBufferSize / 6)
    {
        char buffer[stackBufferSize];
        
        if ([string getBytes:buffer maxLength:sizeof(buffer) usedLength:&byteLength encoding:encoding options:options range:range remainingRange:NULL])
        {
            buffer[byteLength] = '\0';
            
            CFDataRef data = CFDataCreate(NULL, buffer, byteLength+1);
            const char *bytes = CFDataGetBytePtr(data);
            CFBridgingRelease(data);
            
            if (bytes)
            {
                return bytes;
            }
        }
    }
    
    if (![string getBytes:NULL maxLength:0 usedLength:&byteLength encoding:encoding options:options range:range remainingRange:NULL])
    {
        if (raiseOnError)
        {
            [NSException raise:NSCharacterConversionException format:@"Conversion to encoding %ld failed for string \"%@\"",
             (long)encoding, string];
        }
        return NULL;
    }
    
    NSUInteger usedLength = 0;
    NSMutableData *data = [NSMutableData dataWithLength:byteLength + 1];
    char *bytes = (char*)[data mutableBytes];
    [string getBytes:bytes maxLength:byteLength usedLength:&usedLength encoding:encoding options:options range:range remainingRange:NULL];
    if (usedLength != byteLength)
    {
        // Should never happen
        [NSException raise:NSInternalInconsistencyException format:@"Unable to convert all of the characters expected"];
        return NULL;
    }
    
    bytes[byteLength] = '\0';
    return [data bytes];
}

- (__strong const char *)cStringUsingEncoding:(NSStringEncoding)encoding NS_RETURNS_INNER_POINTER
{
    return bytesInEncoding(self, NO, encoding, NO, NO);
}

/*!
 @note     Returns mutable
 */
- (NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringFold(str, (CFStringCompareFlags)options, (CFLocaleRef)locale);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)decomposedStringWithCanonicalMapping
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringNormalize(str, kCFStringNormalizationFormD);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)precomposedStringWithCanonicalMapping
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringNormalize(str, kCFStringNormalizationFormKD);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)decomposedStringWithCompatibilityMapping
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringNormalize(str, kCFStringNormalizationFormC);
    return [(NSString *)str autorelease];
}

/*!
 @note     Returns mutable
 */
- (NSString *)precomposedStringWithCompatibilityMapping
{
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)self);
    CFStringNormalize(str, kCFStringNormalizationFormKC);
    return [(NSString *)str autorelease];
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    if (target == nil || replacement == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"replacement cannot be nil"];
        return nil;
    }

    NSMutableString *str = [self mutableCopy];
    [str replaceOccurrencesOfString:target withString:replacement options:options range:searchRange];

    return [str autorelease];
}

- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
{
    return [self stringByReplacingOccurrencesOfString:target withString:replacement options:0 range:NSMakeRange(0, [self length])];
}

- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement
{
    if (replacement == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"replacement cannot be nil"];
        return nil;
    }

    NSMutableString *str = [self mutableCopy];
    [str replaceCharactersInRange:range withString:replacement];

    return [str autorelease];
}

- (__strong const char *)UTF8String
{
    return bytesInEncoding(self, NO, NSUTF8StringEncoding, NO, YES);
}

- (const unichar*)_fastCharacterContents
{
    return NULL;
}

- (const char *)_fastCStringContents:(BOOL)unused
{
    return NULL;
}

- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding
{
    CFIndex len = [self length];
    return __CFStringEncodeByteStream((CFStringRef)self, 0, len, false, CFStringConvertNSStringEncodingToEncoding(encoding), 0, NULL, 0, NULL) == len;
}

- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding
{
    if (maxBufferCount > 0)
    {
        NSUInteger usedLength = 0;
        BOOL result = [self getBytes:buffer maxLength:maxBufferCount-1 usedLength:&usedLength encoding:encoding options:NSStringEncodingConversionFailOnPartial range:NSMakeRange(0, [self length]) remainingRange:NULL];
        buffer[usedLength] = '\0';
        return result;
    }
    else
    {
        return NO;
    }
}

- (BOOL)_getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(CFStringEncoding)encoding
{
    return [self getCString:buffer maxLength:maxBufferCount + 1 encoding:CFStringConvertEncodingToNSStringEncoding(encoding)];
}

- (NSString *)commonPrefixWithString:(NSString *)str options:(NSStringCompareOptions)mask
{
    // Documentation claims that this only supports NSLiteralSearch and NSCaseInsensitiveSearch however
    // experementation shows that this does support NSDiacriticInsensitiveSearch, other options seem
    // to be either nonsenical or no-op'd into NSLiteral searches
    NSUInteger len1 = [self length];
    NSUInteger len2 = [str length];
    if (len1 == 0 || len2 == 0)
    {
        return @"";
    }
    NSUInteger haystack = MIN(len1, len2);
    NSUInteger needle = 0;
    NSUInteger sz = 1024;
    unichar buffer1[sz];
    unichar buffer2[sz];
    BOOL searching = NO;
    NSUInteger found = 0;
    while (needle < haystack && searching)
    {
        NSRange search = NSMakeRange(needle, MIN(MIN(len1 - needle, sz), MIN(len2 - needle, sz)));
        [self getCharacters:buffer1 range:search];
        [str getCharacters:buffer2 range:search];
        for (NSUInteger idx = 0; idx < search.length; idx++)
        {
            if ((mask & NSCaseInsensitiveSearch) != 0)
            {
                if ((mask & NSDiacriticInsensitiveSearch) != 0)
                {
                    UTF32Char c1[8] = {0};
                    UTF32Char c2[8] = {0};
                    CFUniCharDecomposeCharacter(buffer1[0], &c1[0], 8);
                    CFUniCharDecomposeCharacter(buffer2[0], &c2[0], 8);
                    if (u_tolower(c1[0]) != u_tolower(c2[0]))
                    {
                        searching = NO;
                        break;
                    }
                }
                else if (u_tolower(buffer1[0]) != u_tolower(buffer2[0]))
                {
                    searching = NO;
                    break;
                }
            }
            else
            {
                if (buffer1[idx] != buffer2[idx])
                {
                    searching = NO;
                    break;
                }
            }
            found = needle + idx;
        }
        needle += sz;
    }
    if (found == 0)
    {
        return @"";
    }
    else
    {
        return [self substringWithRange:NSMakeRange(0, found)];
    }
}


- (void)enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop))block
{
    if (block == nil)
    {
        return;
    }

    CFOptionFlags options = 0;
    if ((opts & NSStringEnumerationByLines) != 0)
    {
        options |= kCFStringTokenizerUnitLineBreak;
    }
    if ((opts & NSStringEnumerationByParagraphs) != 0)
    {
        options |= kCFStringTokenizerUnitParagraph;
    }
    if ((opts & NSStringEnumerationByWords) != 0)
    {
        options |= kCFStringTokenizerUnitWord;
    }
    if ((opts & NSStringEnumerationBySentences) != 0)
    {
        options |= kCFStringTokenizerUnitSentence;
    }
#warning TODO https://code.google.com/p/apportable/issues/detail?id=272

    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (CFStringRef)self, CFRangeMake(range.location, range.length), options, locale);

    CFStringTokenizerTokenType type = kCFStringTokenizerTokenNone;
    BOOL stop = NO;
    while (kCFStringTokenizerTokenNone != (type = CFStringTokenizerAdvanceToNextToken(tokenizer)) && !stop)
    {
        CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        NSRange substringRange = NSMakeRange(tokenRange.location, tokenRange.length);
        NSString *substring = [self substringWithRange:substringRange];
        block(substring, substringRange, substringRange /* this is incorrect and should be fixed */, &stop);
    }

    CFRelease(tokenizer);
    CFRelease(locale);
}

- (void)enumerateLinesUsingBlock:(void (^)(NSString *line, BOOL *stop))block
{
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        block(substring, stop);
    }];
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
    if (![url isFileURL])
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"does this even make sense? what would it even do? POST?"
            }];
        }
        return NO;
    }
    NSData *data = [self dataUsingEncoding:enc];
    return [data writeToURL:url options:useAuxiliaryFile ? NSDataWritingAtomic : 0 error:error];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error
{
    return [self writeToURL:[NSURL fileURLWithPath:path] atomically:useAuxiliaryFile encoding:enc error:error];
}

// This is partially cribbed from CoreFoundation/CFStringScanner.c
static const unsigned char __NSNumberSet[16] = {
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  nul soh stx etx eot enq ack bel
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  bs  ht  nl  vt  np  cr  so  si
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  dle dc1 dc2 dc3 dc4 nak syn etb
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  can em  sub esc fs  gs  rs  us
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  sp   !   "   #   $   %   &   '
    0X68, // 0, 0, 0, 1, 0, 1, 1, 0, //  (   )   *   +   ,   -   .   /
    0xFF, // 1, 1, 1, 1, 1, 1, 1, 1, //  0   1   2   3   4   5   6   7
    0X03, // 1, 1, 0, 0, 0, 0, 0, 0, //  8   9   :   ;   <   =   >   ?
    0X20, // 0, 0, 0, 0, 0, 1, 0, 0, //  @   A   B   C   D   E   F   G
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  H   I   J   K   L   M   N   O
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  P   Q   R   S   T   U   V   W
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  X   Y   Z   [   \   ]   ^   _
    0X20, // 0, 0, 0, 0, 0, 1, 0, 0, //  `   a   b   c   d   e   f   g
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  h   i   j   k   l   m   n   o
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0, //  p   q   r   s   t   u   v   w
    0X00, // 0, 0, 0, 0, 0, 0, 0, 0  //  x   y   z   {   |   }   ~  del
};

static NSCharacterSet *invertedWhitespaceSet = nil;
#define STACK_BUFFER_SIZE 256
#define ALLOC_CHUNK_SIZE 256
typedef enum {
    NSNumericBOOLValue,
    NSNumericLongValue,
    NSNumericLongLongValue,
    NSNumericFloatValue,
    NSNumericDoubleValue
} NSNumericValueType;

typedef union {
    BOOL b;
    long l;
    long long ll;
    float f;
    double d;
} NSNumericValue;

static BOOL _NSScanStringValue(NSString *self, NSNumericValueType type, NSNumericValue *resultValue)
{
    char localCharBuffer[STACK_BUFFER_SIZE];
    char *charPtr = localCharBuffer;
    char *endCharPtr = NULL;
    SInt32 numChars = 0;
    SInt32 capacity = STACK_BUFFER_SIZE;
    unichar ch;
    if (invertedWhitespaceSet == nil)
    {
        invertedWhitespaceSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];
    }

    NSRange found = [self rangeOfCharacterFromSet:invertedWhitespaceSet];
    if (found.location == NSNotFound)
    {
        // is this the correct fault case?
        return NO;
    }
    NSUInteger index = found.location;

    ch = [self characterAtIndex:index];
    while ((ch < 127 && __NSNumberSet[ch >> 3] & (1 << (ch & 7))))
    {
        if (numChars >= capacity - 1)
        {
            capacity += ALLOC_CHUNK_SIZE;
            if (charPtr == localCharBuffer)
            {
                charPtr = (char *)malloc(capacity * sizeof(char));
                memmove(charPtr, localCharBuffer, numChars * sizeof(char));
            }
            else
            {
                charPtr = (char *)realloc(charPtr, capacity * sizeof(char));
            }
        }
        charPtr[numChars++] = (char)ch;
        index++;
        ch = [self characterAtIndex:index];
    }
    charPtr[numChars++] = 0;
    if (type == NSNumericBOOLValue)
    {
        long l = strtol(charPtr, &endCharPtr, 10);
        if (l == 0)
        {
            NSString *substr = [self substringFromIndex:found.location];
            if ([substr compare:@"YES" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 3)] == NSOrderedSame)
            {
                resultValue->b = YES;
            }
            else if ([substr compare:@"TRUE" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 4)] == NSOrderedSame)
            {
                resultValue->b = YES;
            }
            else
            {
                resultValue->b = NO;
            }
        }
        else
        {
            resultValue->b = YES;
        }
    }
    else if (type == NSNumericLongValue)
    {
        resultValue->l = strtol(charPtr, &endCharPtr, 10);
    }
    else if (type == NSNumericLongLongValue)
    {
        resultValue->ll = strtoll(charPtr, &endCharPtr, 10);
    }
    else if (type == NSNumericFloatValue)
    {
        resultValue->f = strtof(charPtr, &endCharPtr);
    }
    else if (type == NSNumericDoubleValue)
    {
        resultValue->d = strtod(charPtr, &endCharPtr);
    }
    if (charPtr != localCharBuffer)
    {
        free(charPtr);
    }
    return YES;
}

- (double)doubleValue
{
    NSNumericValue val;
    if (_NSScanStringValue(self, NSNumericDoubleValue, &val))
    {
        return val.d;
    }
    return 0.0;
}

- (float)floatValue
{
    NSNumericValue val;
    if (_NSScanStringValue(self, NSNumericFloatValue, &val))
    {
        return val.f;
    }
    return 0.0f;
}

- (int)intValue
{
    NSNumericValue val;
    if (_NSScanStringValue(self, NSNumericLongValue, &val))
    {
        return val.l;
    }
    return 0;
}

- (NSInteger)integerValue
{
    NSNumericValue val;
    if (_NSScanStringValue(self, NSNumericLongValue, &val))
    {
        return val.l;
    }
    return 0;
}

- (long long)longLongValue
{
    NSNumericValue val;
    if (_NSScanStringValue(self, NSNumericLongLongValue, &val))
    {
        return val.ll;
    }
    return 0LL;
}

// Undocumented method used by KVC when setting an NSUInteger property/ivar using an NSString.
- (unsigned int)unsignedIntValue
{
    // This seems unnecessary but is here for compatibility
    NSMutableString *trimmed = [self mutableCopy];
    CFStringTrimWhitespace ((CFMutableStringRef)trimmed);
    [trimmed autorelease];
    
    // intValue caps value on underflow & overflow whereas this function just truncates.
    return [trimmed longLongValue];
}

/*!
 @note Apple truncates the numeric value to SInt32 it seems... (which means that LLONG_MIN returns NO)
*/
- (BOOL)boolValue
{
    NSNumericValue val;
    if (_NSScanStringValue(self, NSNumericBOOLValue, &val))
    {
        return val.b;
    }
    return NO;
}


@end

@implementation NSMutableString (NSMutableStringExtensionMethods)

+ (id)stringWithCapacity:(NSUInteger)capacity
{
    return [[[self alloc] initWithCapacity:capacity] autorelease];
}

- (void)insertString:(NSString *)str atIndex:(NSUInteger)loc
{
    [self replaceCharactersInRange:NSMakeRange(loc, 0) withString:str];
}

- (void)deleteCharactersInRange:(NSRange)range
{
    [self replaceCharactersInRange:range withString:@""];
}

- (void)appendString:(NSString *)str
{
    [self replaceCharactersInRange:NSMakeRange([self length], 0) withString:str];
}

- (void)appendFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format locale:nil arguments:args];
    va_end(args);
    [self replaceCharactersInRange:NSMakeRange([self length], 0) withString:str];
    [str release];
}

- (void)setString:(NSString *)str
{
    [self replaceCharactersInRange:NSMakeRange(0, [self length]) withString:str];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange
{
    NSUInteger length = [self length];
    if (target == nil || replacement == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil target or replacement"];
        return 0;
    }
    if (searchRange.location > length || NSMaxRange(searchRange) > length)
    {
        [NSException raise:NSRangeException format:@"specified range is out of bounds of string"];
    }

    if ((options & NSRegularExpressionSearch) != 0)
    {
        return [self _replaceOccurrencesOfRegularExpressionPattern:target withTemplate:replacement options:options range:searchRange];
    }
    else
    {
        CFArrayRef found = CFStringCreateArrayWithFindResults(kCFAllocatorDefault, (CFStringRef)self, (CFStringRef)target, CFRangeMake(searchRange.location, searchRange.length), (CFStringCompareFlags)options);
        NSUInteger diff = [target length] - [replacement length];
        NSUInteger offset = 0;
        NSUInteger count = CFArrayGetCount(found);
        for (CFIndex idx = 0; idx < count; idx++)
        {
            CFRange *range = (CFRange *)CFArrayGetValueAtIndex(found, idx);
            [self replaceCharactersInRange:NSMakeRange(range->location + offset, range->length) withString:replacement];
            offset += diff;
        }
        return count;
    }
}

@end

@implementation NSString (NSExtendedStringPropertyListParsing)

- (id)propertyList
{
    CFStringRef err = NULL;
    CFTypeRef plist = _CFPropertyListCreateFromXMLString(kCFAllocatorDefault, (CFStringRef)self, 0, &err, true, NULL);
    if (plist == NULL)
    {
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        if (data != NULL)
        {
            plist = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)data, 0, &err);
        }

        if (plist == NULL)
        {
            [NSException raise:NSParseErrorException format:@"unable to parse string into plist"];
            return nil;
        }
    }

    return [(id)plist autorelease];
}

- (NSDictionary *)propertyListFromStringsFileFormat
{
    id plist = [self propertyList];
    if (![plist isNSDictionary__])
    {
        return nil;
    }
    return plist;
}

@end

@implementation NSString (NSStringDeprecated)

+ (id)stringWithContentsOfFile:(NSString *)path
{
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+ (id)stringWithContentsOfURL:(NSURL *)url
{
    return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

+ (id)stringWithCString:(const char *)bytes length:(NSUInteger)length
{
    return [[[self alloc] initWithCString:bytes length:length] autorelease];
}

+ (id)stringWithCString:(const char *)bytes
{
    return [[[self alloc] initWithCString:bytes] autorelease];
}

- (void)getCString:(char *)bytes
{
    NSUInteger len = [self length];
    NSUInteger maxLength = (NSUInteger)bytes ^ -1;
    if (maxLength > NSMaximumStringLength)
    {
        maxLength = NSMaximumStringLength;
    }
    [self getCString:bytes maxLength:maxLength range:NSMakeRange(0, len) remainingRange:NULL];
}

- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength
{
    NSUInteger len = [self length];
    [self getCString:bytes maxLength:maxLength range:NSMakeRange(0, len) remainingRange:NULL];
}

- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength range:(NSRange)aRange remainingRange:(NSRangePointer)leftoverRange
{
    NSUInteger filledLength = 0;
    if (![self getBytes:bytes maxLength:maxLength filledLength:&filledLength encoding:__NSDefaultCStringEncoding() allowLossyConversion:NO range:aRange remainingRange:leftoverRange])
    {
        [NSException raise:NSCharacterConversionException format:@"Could not covert \"%@\" to default C-string encoding", self];
        return;
    }
    
    // bytes buffer is expected to be at least maxLength + 1 bytes long.
    bytes[filledLength] = '\0';
}

- (void)getCharacters:(unichar *)buffer
{
    [self getCharacters:buffer range:NSMakeRange(0, [self length])];
}

- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount filledLength:(NSUInteger *)filledLength encoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy range:(NSRange)range remainingRange:(NSRangePointer)leftover
{
    NSStringEncodingConversionOptions options = NSStringEncodingConversionExternalRepresentation | NSStringEncodingConversionFailOnPartial;
    if (lossy)
    {
        options |= NSStringEncodingConversionAllowLossy;
    }
    return [self getBytes:buffer maxLength:maxBufferCount usedLength:filledLength encoding:encoding options:options range:range remainingRange:leftover];
}

- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount usedLength:(NSUInteger *)usedBufferCount encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options range:(NSRange)range remainingRange:(NSRangePointer)leftover
{
    if ([self length] == 0)
    {
        // Special case for empty string. Always succeeeds but won't read null,
        // but for non-empty strings will read past end of string!
        if (usedBufferCount)
        {
            *usedBufferCount = 0;
        }
        
        if (leftover)
        {
            *leftover = range;
        }
        
        return YES;
    }
    
    CFIndex used;
    uint8_t lossByte = (options & NSStringEncodingConversionAllowLossy) ? '?' : 0;
    Boolean externalRep = (options & NSStringEncodingConversionExternalRepresentation) != 0;
    CFIndex numCharsProcessed = __CFStringEncodeByteStream((CFStringRef)self, range.location, range.length, externalRep, CFStringConvertNSStringEncodingToEncoding(encoding), lossByte, buffer, maxBufferCount, &used);
    
    if (usedBufferCount != NULL)
    {
        *usedBufferCount = used;
    }

    if (leftover != NULL)
    {
        leftover->location = range.location + numCharsProcessed;
        leftover->length = range.length - numCharsProcessed;
    }
    
    if (options & NSStringEncodingConversionFailOnPartial)
    {
        return numCharsProcessed == range.length;
    }
    else
    {
        return numCharsProcessed > 0;
    }
}

- (const char *)cString
{
    return bytesInEncoding(self, YES, __NSDefaultCStringEncoding(), NO, YES);
}

- (const char *)lossyCString
{
    return bytesInEncoding(self, NO, __NSDefaultCStringEncoding(), YES, YES);
}

- (NSUInteger)cStringLength
{
    return [self lengthOfBytesUsingEncoding:__NSDefaultCStringEncoding()];
}

- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc
{
    CFStringEncoding cfEnc = CFStringConvertNSStringEncodingToEncoding(enc);
    NSString *escapedStr = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, cfEnc);
    return [escapedStr autorelease];
}

- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc
{
    CFStringEncoding cfEnc = CFStringConvertNSStringEncodingToEncoding(enc);
    NSString *escapedStr = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, (CFStringRef)@"", cfEnc);
    return [escapedStr autorelease];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically
{
    return [self writeToFile:path atomically:atomically encoding:__NSDefaultCStringEncoding() error:NULL];
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
    return [self writeToURL:url atomically:atomically encoding:__NSDefaultCStringEncoding() error:NULL];
}


- (id)initWithContentsOfFile:(NSString *)path
{
    NSData *data = [[NSData alloc] initWithContentsOfMappedFile:path];
    self = [self _initWithDataOfUnknownEncoding:data];
    [data release];
    return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    self = [self _initWithDataOfUnknownEncoding:data];
    [data release];
    return self;
}

@end

@implementation NSSimpleCString

+ (id)allocWithZone:(NSZone *)zone
{
    return NSAllocateObject(self, 0, NSDefaultMallocZone());
}

- (id)initWithCStringNoCopy:(char *)cString length:(NSUInteger)length
{
    // super skipped purposefully
    bytes = cString;
    numBytes = length;
    return self;
}

- (void)dealloc
{
    if (bytes != NULL)
    {
        free(bytes);
    }
    [super dealloc];
}

- (NSUInteger)length
{
    return numBytes;
}

- (const char *)UTF8String
{
    return bytes;
}

- (const char *)_fastCStringContents:(BOOL)getContents
{
    if (getContents)
    {
        return NULL;
    }
    else
    {
        return bytes;
    }
}

- (unichar)characterAtIndex:(unsigned int)index
{
    return bytes[index];
}
@end

@implementation NSConstantString

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)copy
{
    return self;
}

- (id)retain
{
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"

- (void)dealloc
{

}

#pragma clang diagnostic pop

- (id)autorelease
{
    return self;
}

- (BOOL)_isDeallocating
{
    return NO;
}

- (BOOL)_tryRetain
{
    return YES;
}

@end
