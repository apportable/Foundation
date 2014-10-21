#import <Foundation/NSObject.h>
#import <CoreFoundation/CFLocale.h>

typedef NS_ENUM(NSUInteger, NSLocaleLanguageDirection) {
    NSLocaleLanguageDirectionUnknown     = kCFLocaleLanguageDirectionUnknown,
    NSLocaleLanguageDirectionLeftToRight = kCFLocaleLanguageDirectionLeftToRight,
    NSLocaleLanguageDirectionRightToLeft = kCFLocaleLanguageDirectionRightToLeft,
    NSLocaleLanguageDirectionTopToBottom = kCFLocaleLanguageDirectionTopToBottom,
    NSLocaleLanguageDirectionBottomToTop = kCFLocaleLanguageDirectionBottomToTop
};

@class NSArray, NSDictionary, NSString;

FOUNDATION_EXPORT NSString * const NSCurrentLocaleDidChangeNotification;
FOUNDATION_EXPORT NSString * const NSLocaleIdentifier;
FOUNDATION_EXPORT NSString * const NSLocaleLanguageCode;
FOUNDATION_EXPORT NSString * const NSLocaleCountryCode;
FOUNDATION_EXPORT NSString * const NSLocaleScriptCode;
FOUNDATION_EXPORT NSString * const NSLocaleVariantCode;
FOUNDATION_EXPORT NSString * const NSLocaleExemplarCharacterSet;
FOUNDATION_EXPORT NSString * const NSLocaleCalendar;
FOUNDATION_EXPORT NSString * const NSLocaleCollationIdentifier;
FOUNDATION_EXPORT NSString * const NSLocaleUsesMetricSystem;
FOUNDATION_EXPORT NSString * const NSLocaleMeasurementSystem;
FOUNDATION_EXPORT NSString * const NSLocaleDecimalSeparator;
FOUNDATION_EXPORT NSString * const NSLocaleGroupingSeparator;
FOUNDATION_EXPORT NSString * const NSLocaleCurrencySymbol;
FOUNDATION_EXPORT NSString * const NSLocaleCurrencyCode;
FOUNDATION_EXPORT NSString * const NSLocaleCollatorIdentifier;
FOUNDATION_EXPORT NSString * const NSLocaleQuotationBeginDelimiterKey;
FOUNDATION_EXPORT NSString * const NSLocaleQuotationEndDelimiterKey;
FOUNDATION_EXPORT NSString * const NSLocaleAlternateQuotationBeginDelimiterKey;
FOUNDATION_EXPORT NSString * const NSLocaleAlternateQuotationEndDelimiterKey;
FOUNDATION_EXPORT NSString * const NSGregorianCalendar;
FOUNDATION_EXPORT NSString * const NSBuddhistCalendar;
FOUNDATION_EXPORT NSString * const NSChineseCalendar;
FOUNDATION_EXPORT NSString * const NSHebrewCalendar;
FOUNDATION_EXPORT NSString * const NSIslamicCalendar;
FOUNDATION_EXPORT NSString * const NSIslamicCivilCalendar;
FOUNDATION_EXPORT NSString * const NSJapaneseCalendar;
FOUNDATION_EXPORT NSString * const NSRepublicOfChinaCalendar;
FOUNDATION_EXPORT NSString * const NSPersianCalendar;
FOUNDATION_EXPORT NSString * const NSIndianCalendar;
FOUNDATION_EXPORT NSString * const NSISO8601Calendar;

@interface NSLocale : NSObject <NSCopying, NSSecureCoding>

- (id)objectForKey:(id)key;
- (NSString *)displayNameForKey:(id)key value:(id)value;

@end

@interface NSLocale (NSExtendedLocale)

- (NSString *)localeIdentifier;

@end

@interface NSLocale (NSLocaleCreation)

+ (id)systemLocale;
+ (id)currentLocale;
+ (instancetype)autoupdatingCurrentLocale;
+ (instancetype)localeWithLocaleIdentifier:(NSString *)identifier;
- (instancetype)initWithLocaleIdentifier:(NSString *)string;
- (id)init;

@end

@interface NSLocale (NSLocaleGeneralInfo)

+ (NSArray *)availableLocaleIdentifiers;
+ (NSArray *)ISOLanguageCodes;
+ (NSArray *)ISOCountryCodes;
+ (NSArray *)ISOCurrencyCodes;
+ (NSArray *)commonISOCurrencyCodes;
+ (NSArray *)preferredLanguages;
+ (NSDictionary *)componentsFromLocaleIdentifier:(NSString *)string;
+ (NSString *)localeIdentifierFromComponents:(NSDictionary *)dict;
+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)string;
+ (NSString *)canonicalLanguageIdentifierFromString:(NSString *)string;
+ (NSString *)localeIdentifierFromWindowsLocaleCode:(uint32_t)lcid;
+ (uint32_t)windowsLocaleCodeFromLocaleIdentifier:(NSString *)localeIdentifier;
+ (NSLocaleLanguageDirection)characterDirectionForLanguage:(NSString *)isoLangCode;
+ (NSLocaleLanguageDirection)lineDirectionForLanguage:(NSString *)isoLangCode;

@end
