#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSDate.h>

@class NSString, NSArray, NSDictionary, NSDate, NSTimeZone, NSOrthography, NSURL, NSRegularExpression;

FOUNDATION_EXPORT NSString * const NSTextCheckingNameKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingJobTitleKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingOrganizationKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingStreetKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingCityKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingStateKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingZIPKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingCountryKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingPhoneKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingAirlineKey;
FOUNDATION_EXPORT NSString * const NSTextCheckingFlightKey;

typedef NS_OPTIONS(uint64_t, NSTextCheckingType) {
    NSTextCheckingTypeOrthography        = 1ULL << 0,
    NSTextCheckingTypeSpelling           = 1ULL << 1,
    NSTextCheckingTypeGrammar            = 1ULL << 2,
    NSTextCheckingTypeDate               = 1ULL << 3,
    NSTextCheckingTypeAddress            = 1ULL << 4,
    NSTextCheckingTypeLink               = 1ULL << 5,
    NSTextCheckingTypeQuote              = 1ULL << 6,
    NSTextCheckingTypeDash               = 1ULL << 7,
    NSTextCheckingTypeReplacement        = 1ULL << 8,
    NSTextCheckingTypeCorrection         = 1ULL << 9,
    NSTextCheckingTypeRegularExpression  = 1ULL << 10,
    NSTextCheckingTypePhoneNumber        = 1ULL << 11,
    NSTextCheckingTypeTransitInformation = 1ULL << 12
};

typedef NS_OPTIONS(uint64_t, NSTextCheckingTypes) {
    NSTextCheckingAllSystemTypes = 0xffffffffULL,
    NSTextCheckingAllCustomTypes = 0xffffffffULL << 32,
    NSTextCheckingAllTypes       = (NSTextCheckingAllSystemTypes | NSTextCheckingAllCustomTypes)
};

@interface NSTextCheckingResult : NSObject <NSCopying, NSCoding>

@property (readonly) NSTextCheckingType resultType;
@property (readonly) NSRange range;

@end

@interface NSTextCheckingResult (NSTextCheckingResultOptional)

@property (readonly) NSOrthography *orthography;
@property (readonly) NSArray *grammarDetails;
@property (readonly) NSDate *date;
@property (readonly) NSTimeZone *timeZone;
@property (readonly) NSTimeInterval duration;
@property (readonly) NSDictionary *components;
@property (readonly) NSURL *URL;
@property (readonly) NSString *replacementString;
@property (readonly) NSRegularExpression *regularExpression;
@property (readonly) NSString *phoneNumber;
@property (readonly) NSDictionary *addressComponents;
@property (readonly) NSUInteger numberOfRanges;

- (NSRange)rangeAtIndex:(NSUInteger)idx;
- (NSTextCheckingResult *)resultByAdjustingRangesWithOffset:(NSInteger)offset;

@end

@interface NSTextCheckingResult (NSTextCheckingResultCreation)

+ (NSTextCheckingResult *)orthographyCheckingResultWithRange:(NSRange)range orthography:(NSOrthography *)orthography;
+ (NSTextCheckingResult *)spellCheckingResultWithRange:(NSRange)range;
+ (NSTextCheckingResult *)grammarCheckingResultWithRange:(NSRange)range details:(NSArray *)details;
+ (NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date;
+ (NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration;
+ (NSTextCheckingResult *)addressCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components;
+ (NSTextCheckingResult *)linkCheckingResultWithRange:(NSRange)range URL:(NSURL *)url;
+ (NSTextCheckingResult *)quoteCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString;
+ (NSTextCheckingResult *)dashCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString;
+ (NSTextCheckingResult *)replacementCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString;
+ (NSTextCheckingResult *)correctionCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString;
+ (NSTextCheckingResult *)regularExpressionCheckingResultWithRanges:(NSRangePointer)ranges count:(NSUInteger)count regularExpression:(NSRegularExpression *)regularExpression;
+ (NSTextCheckingResult *)phoneNumberCheckingResultWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber;
+ (NSTextCheckingResult *)transitInformationCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components;

@end
