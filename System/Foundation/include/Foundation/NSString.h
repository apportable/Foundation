typedef unsigned short unichar;

#import <limits.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <stdarg.h>

@class NSData, NSArray, NSDictionary, NSCharacterSet, NSURL, NSError, NSLocale;

FOUNDATION_EXPORT NSString * const NSParseErrorException;

#define NSMaximumStringLength    (INT_MAX-1)

typedef NS_OPTIONS(NSUInteger, NSStringCompareOptions) {
    NSCaseInsensitiveSearch      = 1,
    NSLiteralSearch              = 2,
    NSBackwardsSearch            = 4,
    NSAnchoredSearch             = 8,
    NSNumericSearch              = 64,
    NSDiacriticInsensitiveSearch = 128,
    NSWidthInsensitiveSearch     = 256,
    NSForcedOrderingSearch       = 512,
    NSRegularExpressionSearch    = 1024
};

enum {
    NSASCIIStringEncoding             = 1,
    NSNEXTSTEPStringEncoding          = 2,
    NSJapaneseEUCStringEncoding       = 3,
    NSUTF8StringEncoding              = 4,
    NSISOLatin1StringEncoding         = 5,
    NSSymbolStringEncoding            = 6,
    NSNonLossyASCIIStringEncoding     = 7,
    NSShiftJISStringEncoding          = 8,
    NSISOLatin2StringEncoding         = 9,
    NSUnicodeStringEncoding           = 10,
    NSWindowsCP1251StringEncoding     = 11,
    NSWindowsCP1252StringEncoding     = 12,
    NSWindowsCP1253StringEncoding     = 13,
    NSWindowsCP1254StringEncoding     = 14,
    NSWindowsCP1250StringEncoding     = 15,
    NSISO2022JPStringEncoding         = 21,
    NSMacOSRomanStringEncoding        = 30,
    NSUTF16StringEncoding             = NSUnicodeStringEncoding,
    NSUTF16BigEndianStringEncoding    = 0x90000100,
    NSUTF16LittleEndianStringEncoding = 0x94000100,
    NSUTF32StringEncoding             = 0x8c000100,
    NSUTF32BigEndianStringEncoding    = 0x98000100,
    NSUTF32LittleEndianStringEncoding = 0x9c000100
};
typedef NSUInteger NSStringEncoding; 

typedef NS_OPTIONS(NSUInteger, NSStringEncodingConversionOptions) {
    NSStringEncodingConversionAllowLossy             = 1,
    NSStringEncodingConversionExternalRepresentation = 2
};

#if NS_BLOCKS_AVAILABLE
typedef NS_OPTIONS(NSUInteger, NSStringEnumerationOptions) {
    NSStringEnumerationByLines = 0,
    NSStringEnumerationByParagraphs = 1,
    NSStringEnumerationByComposedCharacterSequences = 2,
    NSStringEnumerationByWords = 3,
    NSStringEnumerationBySentences = 4,
    NSStringEnumerationReverse = 1UL << 8,
    NSStringEnumerationSubstringNotRequired = 1UL << 9,
    NSStringEnumerationLocalized = 1UL << 10
};
#endif

enum {
    NSProprietaryStringEncoding = 65536
};

FOUNDATION_EXPORT NSString * const NSCharacterConversionException;

@interface NSString : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

- (NSUInteger)length;

- (unichar)characterAtIndex:(NSUInteger)index;

@end

@interface NSString (NSStringExtensionMethods)

+ (NSStringEncoding)defaultCStringEncoding;
+ (const NSStringEncoding *)availableStringEncodings;
+ (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding;
+ (instancetype)string;
+ (instancetype)stringWithString:(NSString *)string;
+ (instancetype)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length;
+ (instancetype)stringWithUTF8String:(const char *)nullTerminatedCString;
+ (instancetype)stringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (instancetype)localizedStringWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (instancetype)stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc;
+ (instancetype)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
+ (instancetype)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
+ (instancetype)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
+ (instancetype)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
- (instancetype)init;
- (instancetype)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;
- (instancetype)initWithCharacters:(const unichar *)characters length:(NSUInteger)length;
- (instancetype)initWithUTF8String:(const char *)nullTerminatedCString;
- (instancetype)initWithString:(NSString *)str;
- (instancetype)initWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (instancetype)initWithFormat:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (instancetype)initWithFormat:(NSString *)format locale:(id)locale, ... NS_FORMAT_FUNCTION(1,3);
- (instancetype)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
- (instancetype)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;
- (instancetype)initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding;
- (instancetype)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError **)error;
- (instancetype)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
- (instancetype)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
- (instancetype)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange;
- (NSString *)substringFromIndex:(NSUInteger)from;
- (NSString *)substringToIndex:(NSUInteger)to;
- (NSString *)substringWithRange:(NSRange)range;
- (NSComparisonResult)compare:(NSString *)string;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange;
- (NSComparisonResult)compare:(NSString *)string options:(NSStringCompareOptions)mask range:(NSRange)compareRange locale:(id)locale;
- (NSComparisonResult)caseInsensitiveCompare:(NSString *)string;
- (NSComparisonResult)localizedCompare:(NSString *)string;
- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string;
- (NSComparisonResult)localizedStandardCompare:(NSString *)string;
- (BOOL)isEqualToString:(NSString *)str;
- (BOOL)hasPrefix:(NSString *)str;
- (BOOL)hasSuffix:(NSString *)str;
- (NSRange)rangeOfString:(NSString *)str;
- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask;
- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange;
- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale;
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet;
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask;
- (NSRange)rangeOfCharacterFromSet:(NSCharacterSet *)aSet options:(NSStringCompareOptions)mask range:(NSRange)searchRange;
- (NSRange)rangeOfComposedCharacterSequenceAtIndex:(NSUInteger)index;
- (NSRange)rangeOfComposedCharacterSequencesForRange:(NSRange)range;
- (NSString *)stringByAppendingString:(NSString *)str;
- (NSString *)stringByAppendingFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (double)doubleValue;
- (float)floatValue;
- (int)intValue;
- (NSInteger)integerValue;
- (long long)longLongValue;
- (BOOL)boolValue;
- (NSArray *)componentsSeparatedByString:(NSString *)separator;
- (NSArray *)componentsSeparatedByCharactersInSet:(NSCharacterSet *)separator;
- (NSString *)commonPrefixWithString:(NSString *)str options:(NSStringCompareOptions)mask;
- (NSString *)uppercaseString;
- (NSString *)lowercaseString;
- (NSString *)capitalizedString;
- (NSString *)uppercaseStringWithLocale:(NSLocale *)locale;
- (NSString *)lowercaseStringWithLocale:(NSLocale *)locale;
- (NSString *)capitalizedStringWithLocale:(NSLocale *)locale;
- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set;
- (NSString *)stringByPaddingToLength:(NSUInteger)newLength withString:(NSString *)padString startingAtIndex:(NSUInteger)padIndex;
- (void)getLineStart:(NSUInteger *)startPtr end:(NSUInteger *)lineEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range;
- (NSRange)lineRangeForRange:(NSRange)range;
- (void)getParagraphStart:(NSUInteger *)startPtr end:(NSUInteger *)parEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range;
- (NSRange)paragraphRangeForRange:(NSRange)range;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateSubstringsInRange:(NSRange)range options:(NSStringEnumerationOptions)opts usingBlock:(void (^)(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop))block;
- (void)enumerateLinesUsingBlock:(void (^)(NSString *line, BOOL *stop))block;
#endif
- (NSString *)description;
- (NSUInteger)hash;
- (NSStringEncoding)fastestEncoding;
- (NSStringEncoding)smallestEncoding;
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy;
- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding;
- (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding;
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding NS_RETURNS_INNER_POINTER;
- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding;
- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount usedLength:(NSUInteger *)usedBufferCount encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options range:(NSRange)range remainingRange:(NSRangePointer)leftover;
- (NSUInteger)maximumLengthOfBytesUsingEncoding:(NSStringEncoding)enc;
- (NSUInteger)lengthOfBytesUsingEncoding:(NSStringEncoding)enc;
- (NSString *)decomposedStringWithCanonicalMapping;
- (NSString *)precomposedStringWithCanonicalMapping;
- (NSString *)decomposedStringWithCompatibilityMapping;
- (NSString *)precomposedStringWithCompatibilityMapping;
- (NSString *)stringByFoldingWithOptions:(NSStringCompareOptions)options locale:(NSLocale *)locale;
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement;
- (NSString *)stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement;
- (const char *)UTF8String NS_RETURNS_INNER_POINTER;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error;

@end

@interface NSMutableString : NSString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;

@end

@interface NSMutableString (NSMutableStringExtensionMethods)

+ (id)stringWithCapacity:(NSUInteger)capacity;
- (void)insertString:(NSString *)str atIndex:(NSUInteger)loc;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)appendString:(NSString *)str;
- (void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)setString:(NSString *)str;
- (id)initWithCapacity:(NSUInteger)capacity;
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;

@end

@interface NSString (NSExtendedStringPropertyListParsing)

- (id)propertyList;
- (NSDictionary *)propertyListFromStringsFileFormat;

@end

@interface NSString (NSStringDeprecated)

+ (id)stringWithContentsOfFile:(NSString *)path;
+ (id)stringWithContentsOfURL:(NSURL *)url;
+ (id)stringWithCString:(const char *)bytes length:(NSUInteger)length;
+ (id)stringWithCString:(const char *)bytes;
- (const char *)cString;
- (const char *)lossyCString;
- (NSUInteger)cStringLength;
- (void)getCString:(char *)bytes;
- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength;

- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength range:(NSRange)aRange remainingRange:(NSRangePointer)leftoverRange;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;
- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithCStringNoCopy:(char *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;
- (id)initWithCString:(const char *)bytes length:(NSUInteger)length;
- (id)initWithCString:(const char *)bytes;

- (void)getCharacters:(unichar *)buffer;

@end

#if !defined(_OBJC_UNICHAR_H_)
#define _OBJC_UNICHAR_H_
#endif
#define NS_UNICHAR_IS_EIGHT_BIT 0

@interface NSSimpleCString : NSString {
@package
    char *bytes;
    int numBytes;
#if __LP64__
    int _unused;
#endif
}
@end

@interface NSConstantString : NSSimpleCString
@end

#if __LP64__
#else
extern void *_NSConstantStringClassReference;
#endif
