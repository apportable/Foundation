//
// CFLocale.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFLOCALE_H_
#define _CFLOCALE_H_

typedef struct __NSLocale *CFLocaleRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFArray.h>
#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFString.h>

CF_EXPORT const CFStringRef kCFLocaleIdentifier;
CF_EXPORT const CFStringRef kCFLocaleLanguageCode;
CF_EXPORT const CFStringRef kCFLocaleCountryCode;
CF_EXPORT const CFStringRef kCFLocaleScriptCode;
CF_EXPORT const CFStringRef kCFLocaleVariantCode;
CF_EXPORT const CFStringRef kCFLocaleExemplarCharacterSet;
CF_EXPORT const CFStringRef kCFLocaleCalendarIdentifier;
CF_EXPORT const CFStringRef kCFLocaleCalendar;
CF_EXPORT const CFStringRef kCFLocaleCollationIdentifier;
CF_EXPORT const CFStringRef kCFLocaleUsesMetricSystem;

CF_EXPORT const CFStringRef kCFLocaleMeasurementSystem;
CF_EXPORT const CFStringRef kCFLocaleDecimalSeparator;
CF_EXPORT const CFStringRef kCFLocaleGroupingSeparator;
CF_EXPORT const CFStringRef kCFLocaleCurrencySymbol;
CF_EXPORT const CFStringRef kCFLocaleCurrencyCode;
   
CF_EXPORT const CFStringRef kCFGregorianCalendar;
CF_EXPORT const CFStringRef kCFBuddhistCalendar;
CF_EXPORT const CFStringRef kCFChineseCalendar;
CF_EXPORT const CFStringRef kCFHebrewCalendar;
CF_EXPORT const CFStringRef kCFIslamicCalendar;
CF_EXPORT const CFStringRef kCFIslamicCivilCalendar;
CF_EXPORT const CFStringRef kCFJapaneseCalendar;

CF_EXPORT const CFStringRef kCFLocaleCurrentLocaleDidChangeNotification;


CF_EXPORT CFTypeID CFLocaleGetTypeID(void);
CF_EXPORT CFArrayRef CFLocaleCopyAvailableLocaleIdentifiers(void);
CF_EXPORT CFArrayRef CFLocaleCopyCommonISOCurrencyCodes(void);
CF_EXPORT CFLocaleRef CFLocaleCopyCurrent(void);
CF_EXPORT CFArrayRef CFLocaleCopyISOCountryCodes(void);
CF_EXPORT CFArrayRef CFLocaleCopyISOCurrencyCodes(void);
CF_EXPORT CFArrayRef CFLocaleCopyISOLanguageCodes(void);
CF_EXPORT CFArrayRef CFLocaleCopyPreferredLanguages(void);
CF_EXPORT CFLocaleRef CFLocaleGetSystem(void);

CF_EXPORT CFLocaleRef CFLocaleCreate(CFAllocatorRef allocator,CFStringRef identifier);
CF_EXPORT CFStringRef CFLocaleCreateCanonicalLanguageIdentifierFromString(CFAllocatorRef allocator,CFStringRef identifier);
CF_EXPORT CFStringRef CFLocaleCreateCanonicalLocaleIdentifierFromString(CFAllocatorRef allocator,CFStringRef identifier);
CF_EXPORT CFDictionaryRef CFLocaleCreateComponentsFromLocaleIdentifier(CFAllocatorRef allocator,CFStringRef identifier);

CF_EXPORT CFLocaleRef CFLocaleCreateCopy(CFAllocatorRef allocator,CFLocaleRef self);

CF_EXPORT CFStringRef CFLocaleCopyDisplayNameForPropertyValue(CFLocaleRef self,CFStringRef key,CFStringRef value);
CF_EXPORT CFStringRef CFLocaleCreateLocaleIdentifierFromComponents(CFAllocatorRef allocator,CFDictionaryRef dictionary);
CF_EXPORT CFStringRef CFLocaleGetIdentifier(CFLocaleRef self);
CF_EXPORT CFTypeRef CFLocaleGetValue(CFLocaleRef self,CFStringRef key);

#endif /* _CFLOCALE_H_ */
