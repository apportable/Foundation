//
// CFCharacterSet.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFCHARACTERSET_H_

typedef struct __NSMutableCharacterSet *CFCharacterSetRef;
typedef struct __NSMutableCharacterSet *CFMutableCharacterSetRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFData.h>

enum {
   kCFCharacterSetControl              = 1,
   kCFCharacterSetWhitespace           = 2,
   kCFCharacterSetWhitespaceAndNewline = 3,
   kCFCharacterSetDecimalDigit         = 4,
   kCFCharacterSetLetter               = 5,
   kCFCharacterSetLowercaseLetter      = 6,
   kCFCharacterSetUppercaseLetter      = 7,
   kCFCharacterSetNonBase              = 8,
   kCFCharacterSetDecomposable         = 9,
   kCFCharacterSetAlphaNumeric         = 10,
   kCFCharacterSetPunctuation          = 11,
   kCFCharacterSetIllegal              = 12,
   kCFCharacterSetCapitalizedLetter    = 13,
   kCFCharacterSetSymbol               = 14,
   kCFCharacterSetNewline              = 15,
};
typedef CFIndex CFCharacterSetPredefinedSet;


CF_EXPORT CFTypeID CFCharacterSetGetTypeID(void);

CF_EXPORT CFCharacterSetRef CFCharacterSetGetPredefined(CFCharacterSetPredefinedSet predefined);

CF_EXPORT CFCharacterSetRef CFCharacterSetCreateWithBitmapRepresentation(CFAllocatorRef allocator, CFDataRef data);
CF_EXPORT CFCharacterSetRef CFCharacterSetCreateWithCharactersInRange(CFAllocatorRef allocator, CFRange range);
CF_EXPORT CFCharacterSetRef CFCharacterSetCreateWithCharactersInString(CFAllocatorRef allocator, CFStringRef string);

CF_EXPORT CFCharacterSetRef CFCharacterSetCreateCopy(CFAllocatorRef allocator, CFCharacterSetRef self);

CF_EXPORT Boolean CFCharacterSetHasMemberInPlane(CFCharacterSetRef self, CFIndex plane);
CF_EXPORT Boolean CFCharacterSetIsCharacterMember(CFCharacterSetRef self, UniChar character);
CF_EXPORT Boolean CFCharacterSetIsLongCharacterMember(CFCharacterSetRef self, UTF32Char character);
CF_EXPORT Boolean CFCharacterSetIsSupersetOfSet(CFCharacterSetRef self, CFCharacterSetRef other);

CF_EXPORT CFDataRef CFCharacterSetCreateBitmapRepresentation(CFAllocatorRef allocator, CFCharacterSetRef self);
CF_EXPORT CFCharacterSetRef CFCharacterSetCreateInvertedSet(CFAllocatorRef allocator, CFCharacterSetRef self);

// mutable

CF_EXPORT CFMutableCharacterSetRef CFCharacterSetCreateMutable(CFAllocatorRef alloc);
CF_EXPORT CFMutableCharacterSetRef CFCharacterSetCreateMutableCopy(CFAllocatorRef allocator, CFCharacterSetRef self);

CF_EXPORT void CFCharacterSetAddCharactersInRange(CFMutableCharacterSetRef self, CFRange range);
CF_EXPORT void CFCharacterSetAddCharactersInString(CFMutableCharacterSetRef self, CFStringRef string);
CF_EXPORT void CFCharacterSetRemoveCharactersInRange(CFMutableCharacterSetRef self, CFRange range);
CF_EXPORT void CFCharacterSetRemoveCharactersInString(CFMutableCharacterSetRef self, CFStringRef string);
CF_EXPORT void CFCharacterSetIntersect(CFMutableCharacterSetRef self, CFCharacterSetRef other);
CF_EXPORT void CFCharacterSetUnion(CFMutableCharacterSetRef self, CFCharacterSetRef other);
CF_EXPORT void CFCharacterSetInvert(CFMutableCharacterSetRef self);

#endif /* _CFCHARACTERSET_H_ */

