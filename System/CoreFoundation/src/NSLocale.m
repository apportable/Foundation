//
//  NSLocale.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSLocale.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import "NSObjectInternal.h"
#import "ForFoundationOnly.h"

CF_PRIVATE
@interface __NSCFLocale : NSLocale
@end

NSString *const NSCurrentLocaleDidChangeNotification = @"kCFLocaleCurrentLocaleDidChangeNotification";
NSString *const NSLocaleIdentifier = @"kCFLocaleIdentifierKey";
NSString *const NSLocaleLanguageCode = @"kCFLocaleLanguageCodeKey";
NSString *const NSLocaleCountryCode = @"kCFLocaleCountryCodeKey";
NSString *const NSLocaleScriptCode = @"kCFLocaleScriptCodeKey";
NSString *const NSLocaleVariantCode = @"kCFLocaleVariantCodeKey";
NSString *const NSLocaleExemplarCharacterSet = @"kCFLocaleExemplarCharacterSetKey";
NSString *const NSLocaleCalendar = @"kCFLocaleCalendarKey";
NSString *const NSLocaleCollationIdentifier = @"collation";
NSString *const NSLocaleUsesMetricSystem = @"kCFLocaleUsesMetricSystemKey";
NSString *const NSLocaleMeasurementSystem = @"kCFLocaleMeasurementSystemKey";
NSString *const NSLocaleDecimalSeparator = @"kCFLocaleDecimalSeparatorKey";
NSString *const NSLocaleGroupingSeparator = @"kCFLocaleGroupingSeparatorKey";
NSString *const NSLocaleCurrencySymbol = @"kCFLocaleCurrencySymbolKey";
NSString *const NSLocaleCurrencyCode = @"currency";
NSString *const NSLocaleCollatorIdentifier = @"kCFLocaleCollatorIdentifierKey";
NSString *const NSLocaleQuotationBeginDelimiterKey = @"kCFLocaleQuotationBeginDelimiterKey";
NSString *const NSLocaleQuotationEndDelimiterKey = @"kCFLocaleQuotationEndDelimiterKey";
NSString *const NSLocaleAlternateQuotationBeginDelimiterKey = @"kCFLocaleAlternateQuotationBeginDelimiterKey";
NSString *const NSLocaleAlternateQuotationEndDelimiterKey = @"kCFLocaleAlternateQuotationEndDelimiterKey";
NSString *const NSGregorianCalendar = @"gregorian";
NSString *const NSBuddhistCalendar = @"buddhist";
NSString *const NSChineseCalendar = @"chinese";
NSString *const NSHebrewCalendar = @"hebrew";
NSString *const NSIslamicCalendar = @"islamic";
NSString *const NSIslamicCivilCalendar = @"islamic-civil";
NSString *const NSJapaneseCalendar = @"japanese";
NSString *const NSRepublicOfChinaCalendar = @"roc";
NSString *const NSPersianCalendar = @"persian";
NSString *const NSIndianCalendar = @"indian";
NSString *const NSISO8601Calendar = @"iso8601";

NSString *const NSLocaleCalendarIdentifierKey = @"calendar";
NSString *const NSLocaleCalendarKey = @"kCFLocaleCalendarKey";
NSString *const NSLocaleCollationIdentifierKey = @"collation";
NSString *const NSLocaleCollatorIdentifierKey = @"kCFLocaleCollatorIdentifierKey";
NSString *const NSLocaleCountryCodeKey = @"kCFLocaleCountryCodeKey";
NSString *const NSLocaleCurrencyCodeKey = @"currency";
NSString *const NSLocaleCurrencySymbolKey = @"kCFLocaleCurrencySymbolKey";
NSString *const NSLocaleDecimalSeparatorKey = @"kCFLocaleDecimalSeparatorKey";
NSString *const NSLocaleExemplarCharacterSetKey = @"kCFLocaleExemplarCharacterSetKey";
NSString *const NSLocaleGroupingSeparatorKey = @"kCFLocaleGroupingSeparatorKey";
NSString *const NSLocaleIdentifierKey = @"kCFLocaleIdentifierKey";
NSString *const NSLocaleLanguageCodeKey = @"kCFLocaleLanguageCodeKey";
NSString *const NSLocaleMeasurementSystemKey = @"kCFLocaleMeasurementSystemKey";
NSString *const NSLocaleScriptCodeKey = @"kCFLocaleScriptCodeKey";
NSString *const NSLocaleUsesMetricSystemKey = @"kCFLocaleUsesMetricSystemKey";
NSString *const NSLocaleVariantCodeKey = @"kCFLocaleVariantCodeKey";

@implementation NSLocale

+ (id)internetServicesRegion
{
    // huh wha? ok...
    return nil;
}

+ (NSLocaleLanguageDirection)lineDirectionForLanguage:(NSString *)isoLangCode
{
    return (NSLocaleLanguageDirection)CFLocaleGetLanguageLineDirection((CFStringRef)isoLangCode);
}

+ (NSLocaleLanguageDirection)characterDirectionForLanguage:(NSString *)isoLangCode
{
    return (NSLocaleLanguageDirection)CFLocaleGetLanguageCharacterDirection((CFStringRef)isoLangCode);
}

+ (uint32_t)windowsLocaleCodeFromLocaleIdentifier:(NSString *)localeIdentifier
{
    return CFLocaleGetWindowsLocaleCodeFromLocaleIdentifier((CFStringRef)localeIdentifier);
}

+ (NSString *)localeIdentifierFromWindowsLocaleCode:(uint32_t)lcid
{
    return [(NSString *)CFLocaleCreateLocaleIdentifierFromWindowsLocaleCode(kCFAllocatorDefault, lcid) autorelease];
}

+ (NSString *)canonicalLanguageIdentifierFromString:(NSString *)string
{
    return [(NSString *)CFLocaleCreateCanonicalLanguageIdentifierFromString(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)string
{
    return [(NSString *)CFLocaleCreateCanonicalLocaleIdentifierFromString(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)dict
{
    return [(NSString *)CFLocaleCreateLocaleIdentifierFromComponents(kCFAllocatorDefault, (CFDictionaryRef)dict) autorelease];
}

+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)string
{
    return [(NSDictionary *)CFLocaleCreateComponentsFromLocaleIdentifier(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (NSArray *)preferredLanguages
{
    return [(NSArray *)CFLocaleCopyPreferredLanguages() autorelease];
}

+ (NSArray *)commonISOCurrencyCodes
{
    return [(NSArray *)CFLocaleCopyCommonISOCurrencyCodes() autorelease];
}

+ (NSArray *)ISOCurrencyCodes
{
    return [(NSArray *)CFLocaleCopyISOCurrencyCodes() autorelease];
}

+ (NSArray *)ISOCountryCodes
{
    return [(NSArray *)CFLocaleCopyISOCountryCodes() autorelease];
}

+ (NSArray *)ISOLanguageCodes
{
    return [(NSArray *)CFLocaleCopyISOLanguageCodes() autorelease];
}

+ (NSArray *)availableLocaleIdentifiers
{
    return [(NSArray *)CFLocaleCopyAvailableLocaleIdentifiers() autorelease];
}

+ (id)localeWithLocaleIdentifier:(NSString *)identifier
{
    return [(NSLocale *)CFLocaleCreate(kCFAllocatorDefault, (CFStringRef)identifier) autorelease];
}

+ (id)currentLocale
{
    return [(NSLocale *)CFLocaleCopyCurrent() autorelease];
}

+ (id)systemLocale
{
    return (NSLocale *)CFLocaleGetSystem();
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSLocale class])
    {
        static __NSCFLocale *placeholderLocale = nil;
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            placeholderLocale = ___CFAllocateObject([__NSCFLocale class]);
        });
        return placeholderLocale;
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (id)_prefs
{
    return nil;
}

- (id)_copyDisplayNameForKey:(id)key value:(id)value
{
    return [[self displayNameForKey:key value:value] retain];
}

- (id)initWithLocaleIdentifier:(NSString *)identifier
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)identifier
{
    return [self localeIdentifier];
}

- (id)localeIdentifier
{
    return [self objectForKey:NSLocaleIdentifier];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    return;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [self release];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (BOOL)isEqual:(id)other
{
    return [other isKindOfClass:[NSLocale class]] && [[self localeIdentifier] isEqual:[other localeIdentifier]];
}

- (NSUInteger)hash
{
    return [[self localeIdentifier] hash];
}

- (CFTypeID)_cfTypeID
{
    return CFLocaleGetTypeID();
}

- (id)objectForKey:(id)key
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)displayNameForKey:(id)key value:(id)value
{
    NSRequestConcreteImplementation();
    return nil;
}

@end

@implementation __NSCFLocale

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (id)_prefs
{
    extern CFDictionaryRef __CFLocaleGetPrefs(CFLocaleRef locale);
    return (id)__CFLocaleGetPrefs((CFLocaleRef)self);
}

- (id)initWithLocaleIdentifier:(NSString *)identifier
{
    return (id)CFLocaleCreate(kCFAllocatorDefault, (CFStringRef)identifier);
}

- (NSString *)displayNameForKey:(id)key value:(id)value
{
    return [(NSString *)CFLocaleCopyDisplayNameForPropertyValue((CFLocaleRef)self, (CFStringRef)key, (CFStringRef)value) autorelease];
}

- (id)objectForKey:(id)key
{
    return CFLocaleGetValue((CFLocaleRef)self, (CFStringRef)key);
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
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

@end
