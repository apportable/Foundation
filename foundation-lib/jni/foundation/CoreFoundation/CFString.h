//
// CFString.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFSTRING_H_
#define _CFSTRING_H_

#import <CoreFoundation/CFArray.h>
#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFLocale.h>
#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFCharacterSet.h>
#import <stdarg.h>

typedef CFOptionFlags CFStringCompareFlags;

typedef CFUInteger CFStringEncoding;

#define kCFStringEncodingInvalidId (0xffffffffU)

enum {
   kCFCompareCaseInsensitive      = (1<<0),
   kCFCompareBackwards            = (1<<2),
   kCFCompareAnchored             = (1<<3),
   kCFCompareNonliteral           = (1<<4),
   kCFCompareLocalized            = (1<<5),
   kCFCompareNumerically          = (1<<6),
   kCFCompareDiacriticInsensitive = (1<<7),
   kCFCompareWidthInsensitive     = (1<<8),
   kCFCompareForcedOrdering       = (1<<9),
};

typedef enum  {
   kCFStringEncodingUTF8          = 0x08000100,
   kCFStringEncodingUTF16         = 0x00000100,
   kCFStringEncodingUTF16BE       = 0x10000100,
   kCFStringEncodingUTF16LE       = 0x14000100,
   kCFStringEncodingUTF32         = 0x0c000100,
   kCFStringEncodingUTF32BE       = 0x18000100,
   kCFStringEncodingUTF32LE       = 0x1c000100,
   kCFStringEncodingMacRoman      = 0,
   kCFStringEncodingWindowsLatin1 = 0x0500,
   kCFStringEncodingISOLatin1     = 0x0201,
   kCFStringEncodingNextStepLatin = 0x0B01,
   kCFStringEncodingASCII         = 0x0600,
   kCFStringEncodingUnicode       = kCFStringEncodingUTF16,
   kCFStringEncodingNonLossyASCII = 0x0BFF,
} CFStringBuiltInEncodings;

enum {
   kCFStringEncodingConversionSuccess,
   kCFStringEncodingConverterUnavailable
};

typedef struct CFStringInlineBuffer {
  int nothing;
} CFStringInlineBuffer;

CF_EXPORT CFTypeID CFStringGetTypeID(void);

CF_EXPORT CFStringEncoding CFStringGetSystemEncoding(void);
CF_EXPORT const CFStringEncoding *CFStringGetListOfAvailableEncodings(void);
CF_EXPORT Boolean CFStringIsEncodingAvailable(CFStringEncoding encoding);
CF_EXPORT CFStringRef CFStringGetNameOfEncoding(CFStringEncoding encoding);
CF_EXPORT CFStringEncoding CFStringGetMostCompatibleMacStringEncoding(CFStringEncoding encoding);
CF_EXPORT CFIndex CFStringGetMaximumSizeForEncoding(CFIndex length, CFStringEncoding encoding);

#ifdef __OBJC__
#define CFSTR(s) (CFStringRef)(@s)
#else
CF_EXPORT CFStringRef CFStringMakeConstant(const char *cString);
#define CFSTR(s) CFStringMakeConstant(s)
#endif

CF_EXPORT void CFStringAppendCharacters(CFMutableStringRef mutableString, const UniChar *chars, CFIndex numChars);
CF_EXPORT void CFStringAppend(CFMutableStringRef mutableString, CFStringRef appendedString);
CF_EXPORT void CFStringAppendFormat(CFMutableStringRef theString, CFDictionaryRef formatOptions, CFStringRef format, ...);
CF_EXPORT void CFStringAppendFormatAndArguments(CFMutableStringRef theString, CFDictionaryRef formatOptions, CFStringRef format, va_list arguments);
CF_EXPORT CFStringRef CFStringCreateByCombiningStrings(CFAllocatorRef allocator, CFArrayRef array, CFStringRef separator);
CF_EXPORT CFStringRef CFStringCreateCopy(CFAllocatorRef allocator, CFStringRef self);
CF_EXPORT CFMutableStringRef CFStringCreateMutable (CFAllocatorRef alloc, CFIndex maxLength);
CF_EXPORT CFMutableStringRef CFStringCreateMutableCopy(CFAllocatorRef allocator, CFIndex maxLength, CFStringRef self);
CF_EXPORT CFStringRef CFStringCreateWithBytes(CFAllocatorRef allocator, const uint8_t *bytes, CFIndex length, CFStringEncoding encoding, Boolean isExternalRepresentation);
CF_EXPORT CFStringRef CFStringCreateWithBytesNoCopy(CFAllocatorRef allocator, const uint8_t *bytes, CFIndex length, CFStringEncoding encoding, Boolean isExternalRepresentation, CFAllocatorRef contentsDeallocator);
CF_EXPORT CFStringRef CFStringCreateWithCharacters(CFAllocatorRef allocator, const UniChar *chars, CFIndex length);
CF_EXPORT CFStringRef CFStringCreateWithCharactersNoCopy(CFAllocatorRef allocator, const UniChar *chars, CFIndex length, CFAllocatorRef contentsDeallocator);
CF_EXPORT CFStringRef CFStringCreateWithCString(CFAllocatorRef allocator, const char *cString, CFStringEncoding encoding);
CF_EXPORT CFStringRef CFStringCreateWithCStringNoCopy(CFAllocatorRef allocator, const char *cString, CFStringEncoding encoding, CFAllocatorRef contentsDeallocator);
CF_EXPORT CFStringRef CFStringCreateWithFileSystemRepresentation(CFAllocatorRef allocator, const char *buffer);
CF_EXPORT CFStringRef CFStringCreateWithFormat(CFAllocatorRef allocator, CFDictionaryRef formatOptions, CFStringRef format, ...);
CF_EXPORT CFStringRef CFStringCreateWithFormatAndArguments(CFAllocatorRef allocator, CFDictionaryRef formatOptions, CFStringRef format, va_list arguments);
CF_EXPORT CFStringRef CFStringCreateFromExternalRepresentation(CFAllocatorRef allocator, CFDataRef data, CFStringEncoding encoding);

CF_EXPORT CFStringRef CFStringCreateWithSubstring(CFAllocatorRef allocator, CFStringRef self, CFRange range);

CF_EXPORT void CFShow(CFTypeRef self);
CF_EXPORT void CFShowStr(CFStringRef self);

CF_EXPORT CFComparisonResult CFStringCompare(CFStringRef self, CFStringRef other, CFOptionFlags options);
CF_EXPORT CFComparisonResult CFStringCompareWithOptions(CFStringRef self, CFStringRef other, CFRange rangeToCompare, CFOptionFlags options);
CF_EXPORT CFComparisonResult CFStringCompareWithOptionsAndLocale(CFStringRef self, CFStringRef other, CFRange rangeToCompare, CFOptionFlags options, CFLocaleRef locale);

CF_EXPORT CFStringRef CFStringConvertEncodingToIANACharSetName(CFStringEncoding encoding);
CF_EXPORT CFUInteger CFStringConvertEncodingToNSStringEncoding(CFStringEncoding encoding);
CF_EXPORT CFUInteger CFStringConvertEncodingToWindowsCodepage(CFStringEncoding encoding);

CF_EXPORT CFStringEncoding CFStringConvertIANACharSetNameToEncoding(CFStringRef self);
CF_EXPORT CFStringEncoding CFStringConvertNSStringEncodingToEncoding(CFUInteger encoding);
CF_EXPORT CFStringEncoding CFStringConvertWindowsCodepageToEncoding(CFUInteger codepage);
CF_EXPORT CFArrayRef CFStringCreateArrayBySeparatingStrings(CFAllocatorRef allocator, CFStringRef self, CFStringRef separatorString);
CF_EXPORT CFArrayRef CFStringCreateArrayWithFindResults(CFAllocatorRef allocator, CFStringRef self, CFStringRef stringToFind, CFRange range, CFOptionFlags options);
CF_EXPORT CFDataRef CFStringCreateExternalRepresentation(CFAllocatorRef allocator, CFStringRef self, CFStringEncoding encoding, uint8_t lossByte);
CF_EXPORT void CFStringDelete(CFMutableStringRef theString, CFRange range);

CF_EXPORT Boolean CFStringHasPrefix(CFStringRef self, CFStringRef prefix);
CF_EXPORT Boolean CFStringHasSuffix(CFStringRef self, CFStringRef suffix);
CF_EXPORT CFRange CFStringFind(CFStringRef self, CFStringRef stringToFind, CFOptionFlags options);
CF_EXPORT Boolean CFStringFindCharacterFromSet(CFStringRef self, CFCharacterSetRef set, CFRange range, CFOptionFlags options, CFRange *result);
CF_EXPORT Boolean CFStringFindWithOptions(CFStringRef self, CFStringRef stringToFind, CFRange range, CFOptionFlags options, CFRange *result);
CF_EXPORT Boolean CFStringFindWithOptionsAndLocale(CFStringRef self, CFStringRef stringToFind, CFRange range, CFOptionFlags options, CFLocaleRef locale, CFRange *result);
CF_EXPORT CFIndex CFStringGetBytes(CFStringRef self, CFRange range, CFStringEncoding encoding, uint8_t lossByte, Boolean isExternalRepresentation, uint8_t *bytes, CFIndex length, CFIndex *resultLength);

CF_EXPORT CFIndex CFStringGetLength(CFStringRef self);
CF_EXPORT UniChar CFStringGetCharacterAtIndex(CFStringRef self, CFIndex index);

CF_EXPORT void CFStringGetCharacters(CFStringRef self, CFRange range, UniChar *buffer);
CF_EXPORT const UniChar *CFStringGetCharactersPtr(CFStringRef self);

CF_EXPORT Boolean CFStringGetCString(CFStringRef self, char *buffer, CFIndex bufferSize, CFStringEncoding encoding);
CF_EXPORT const char *CFStringGetCStringPtr(CFStringRef self, CFStringEncoding encoding);

CF_EXPORT void CFStringInitInlineBuffer(CFStringRef self, CFStringInlineBuffer *buffer, CFRange range);
CF_EXPORT void CFStringInsert(CFMutableStringRef str, CFIndex idx, CFStringRef insertedStr);
CF_EXPORT UniChar CFStringGetCharacterFromInlineBuffer(CFStringInlineBuffer *buffer, CFIndex index);

CF_EXPORT CFInteger CFStringGetIntValue(CFStringRef self);
CF_EXPORT double CFStringGetDoubleValue(CFStringRef self);
CF_EXPORT CFStringEncoding CFStringGetFastestEncoding(CFStringRef self);
CF_EXPORT CFStringEncoding CFStringGetSmallestEncoding(CFStringRef self);

CF_EXPORT CFIndex CFStringGetMaximumSizeOfFileSystemRepresentation(CFStringRef self);
CF_EXPORT Boolean CFStringGetFileSystemRepresentation(CFStringRef self, char *buffer, CFIndex bufferCapacity);

CF_EXPORT void CFStringGetLineBounds(CFStringRef self, CFRange range, CFIndex *beginIndex, CFIndex *endIndex, CFIndex *contentsEndIndex);
CF_EXPORT void CFStringGetParagraphBounds(CFStringRef self, CFRange range, CFIndex *beginIndex, CFIndex *endIndex, CFIndex *contentsEndIndex);
CF_EXPORT CFRange CFStringGetRangeOfComposedCharactersAtIndex(CFStringRef self, CFIndex index);

CF_EXPORT uint32_t CFStringEncodingUnicodeToBytes(uint32_t encoding, uint32_t flags, const UniChar *characters, CFIndex numChars, CFIndex *usedCharLen, uint8_t *bytes, CFIndex maxByteLen, CFIndex *usedByteLen);
CF_EXPORT CFIndex CFStringEncodingByteLengthForCharacters(uint32_t encoding, uint32_t flags, const UniChar *characters, CFIndex numChars);

CF_EXPORT CFMutableStringRef CFStringCreateMutableWithExternalCharactersNoCopy(CFAllocatorRef alloc, UniChar *chars, CFIndex numChars, CFIndex capacity, CFAllocatorRef externalCharactersAllocator);

#endif /* _CFSTRING_H_ */
