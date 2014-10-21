#import <Foundation/NSString.h>
#import "NSObjectInternal.h"
#import "NSCFType.h"

CF_EXPORT CFStringRef _CFStringCreateWithFormatAndArgumentsAux(CFAllocatorRef alloc, CFStringRef (*copyDescFunc)(void *, const void *), CFDictionaryRef formatOptions, CFStringRef format, va_list arguments);
CF_EXPORT void _CFStringAppendFormatAndArgumentsAux(CFMutableStringRef outputString, CFStringRef (*copyDescFunc)(void *, const void *), CFDictionaryRef formatOptions, CFStringRef formatString, va_list args);
CF_EXPORT Boolean _CFStringIsMutable(CFStringRef str);
CF_EXPORT CFIndex __CFStringEncodeByteStream(CFStringRef string, CFIndex rangeLoc, CFIndex rangeLen, Boolean generatingExternalFile, CFStringEncoding encoding, char lossByte, uint8_t *buffer, CFIndex max, CFIndex *usedBufLen);

CF_EXPORT CFIndex _CFStringGetLength2(CFStringRef str);
CF_EXPORT CFHashCode __CFStringHash(CFTypeRef cf);
CF_EXPORT CFHashCode CFStringHashNSString(CFStringRef str);

CF_EXPORT CFTypeRef _CFPropertyListCreateFromXMLString(CFAllocatorRef allocator, CFStringRef xmlString, CFOptionFlags option, CFStringRef *errorString, Boolean allowNewTypes, CFPropertyListFormat *format);

CF_EXPORT Boolean (*__CFCharToUniCharFunc)(UInt32 flags, UInt8 ch, UniChar *unicodeChar);

@interface NSString (StringsFormat)
- (NSString *)quotedStringRepresentation;
@end

@interface NSString (CFPrivate)
- (const char *)_fastCStringContents:(BOOL)getContents;
@end

@interface NSMutableString (Internal)
- (NSUInteger)_replaceOccurrencesOfRegularExpressionPattern:(NSString *)pattern withTemplate:(NSString *)replacementTemplate options:(NSStringCompareOptions)options range:(NSRange)searchRange;
@end

@interface NSPlaceholderString : NSString

- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
- (id)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList;
- (id)initWithString:(NSString *)str;
- (id)initWithCString:(const char *)str;
- (id)initWithCString:(const char *)str length:(NSUInteger)length;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;
- (id)initWithCStringNoCopy:(char *)str length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;
- (id)initWithCString:(const char *)str encoding:(NSStringEncoding)encoding;
- (id)initWithCharacters:(const unichar *)characters length:(NSUInteger)length;
- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;
- (id)init;
- (void)dealloc;
- (oneway void)release;
- (unsigned int)retainCount;
- (id)retain;

@end


@interface NSPlaceholderMutableString : NSMutableString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)replacement;
- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;
- (id)initWithFormat:(NSString *)format locale:(id)locale arguments:(va_list)argList;
- (id)initWithCStringNoCopy:(char *)str length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;
- (id)initWithCString:(const char *)str encoding:(NSStringEncoding)encoding;
- (id)initWithCharactersNoCopy:(unichar *)characters length:(NSUInteger)length freeWhenDone:(BOOL)freeBuffer;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding freeWhenDone:(BOOL)freeBuffer;
- (id)initWithUTF8String:(const char *)str;
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;
- (id)initWithString:(NSString *)string;
- (id)initWithCapacity:(NSUInteger)capacity;
- (id)init;
- (void)dealloc;
- (BOOL)_tryRetain;
- (BOOL)_isDeallocating;
- (oneway void)release;
- (unsigned int)retainCount;
- (id)retain;
- (id)autorelease;

@end

CF_PRIVATE
@interface __NSCFString : __NSCFType

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (NSUInteger)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange;
- (void)appendCharacters:(unichar *)characters length:(NSUInteger)length;
- (void)setString:(NSString *)str;
- (void)appendFormat:(NSString *)format, ...;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)appendString:(NSString *)str;
- (void)insertString:(NSString *)str atIndex:(NSUInteger)index;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)replacement;
- (BOOL)_isCString;
- (Class)classForCoder;
- (NSStringEncoding)smallestEncoding;
- (NSStringEncoding)fastestEncoding;
- (BOOL)_encodingCantBeStoredInEightBitCFString;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (void)getLineStart:(NSUInteger *)startPtr end:(NSUInteger *)lineEndPtr contentsEnd:(NSUInteger *)contentsEndPtr forRange:(NSRange)range;
- (BOOL)hasSuffix:(NSString *)prefix;
- (BOOL)hasPrefix:(NSString *)suffix;
- (BOOL)isEqualToString:(NSString *)other;
- (BOOL)isEqual:(id)other;
- (id)substringWithRange:(NSRange)range;
- (id)_newSubstringWithRange:(NSRange)range zone:(NSZone *)zone;
- (BOOL)getCString:(char *)bytes maxLength:(NSUInteger)maxLength encoding:(NSStringEncoding)encoding;
- (BOOL)_getCString:(char *)bytes maxLength:(NSUInteger)maxLength encoding:(CFStringEncoding)encoding;
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding;
- (NSUInteger)cStringLength;
- (const char *)UTF8String;
- (const char *)cString;
- (const char *)_fastCStringContents:(BOOL)getContents;
- (const unichar*)_fastCharacterContents;
- (void)getCharacters:(unichar *)buffer range:(NSRange)range;
- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;
- (NSUInteger)hash;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (BOOL)isNSString__;

@end

CF_PRIVATE
@interface __NSCFConstantString : __NSCFString

- (id)autorelease;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)retain;
- (id)copyWithZone:(NSZone *)zone;
- (BOOL)isKindOfClass:(Class)cls;

@end

