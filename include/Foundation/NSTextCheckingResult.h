#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

@class NSArray;
@class NSDate;
@class NSDictionary;
@class NSOrthography;
@class NSRegularExpression;
@class NSString;
@class NSTimeZone;
@class NSURL;

typedef uint64_t NSTextCheckingType;

static const NSTextCheckingType NSTextCheckingTypeOrthography = 1ULL << 0;
static const NSTextCheckingType NSTextCheckingTypeSpelling = 1ULL << 1;
static const NSTextCheckingType NSTextCheckingTypeGrammar = 1ULL << 2;
static const NSTextCheckingType NSTextCheckingTypeDate = 1ULL << 3;
static const NSTextCheckingType NSTextCheckingTypeAddress = 1ULL << 4;
static const NSTextCheckingType NSTextCheckingTypeLink = 1ULL << 5;
static const NSTextCheckingType NSTextCheckingTypeQuote = 1ULL << 6;
static const NSTextCheckingType NSTextCheckingTypeDash = 1ULL << 7;
static const NSTextCheckingType NSTextCheckingTypeReplacement = 1ULL << 8;
static const NSTextCheckingType NSTextCheckingTypeCorrection = 1ULL << 9;
static const NSTextCheckingType NSTextCheckingTypeRegularExpression = 1ULL << 10;
static const NSTextCheckingType NSTextCheckingTypePhoneNumber = 1ULL << 11;
static const NSTextCheckingType NSTextCheckingTypeTransitInformation = 1ULL << 12;

typedef NS_OPTIONS (uint64_t, NSTextCheckingTypes) {
    NSTextCheckingAllSystemTypes    = 0xffffffffULL,
    NSTextCheckingAllCustomTypes    = 0xffffffffULL << 32,
        NSTextCheckingAllTypes          = (NSTextCheckingAllSystemTypes | NSTextCheckingAllCustomTypes)
};


/**
 * NSTextCheckingResult is an abstract class encapsulating the result of some
 * operation that checks
 */
@interface NSTextCheckingResult : NSObject

@property(readonly) NSDictionary *addressComponents;
@property(readonly) NSDictionary *components;
@property(readonly) NSDate *date;
@property(readonly) NSTimeInterval duration;
@property(readonly) NSArray *grammarDetails;
@property(readonly) NSUInteger numberOfRanges;
@property(readonly) NSOrthography *orthography;
@property(readonly) NSString *phoneNumber;
@property(readonly) NSRange range;
@property(readonly) NSRegularExpression *regularExpression;
@property(readonly) NSString *replacementString;
@property(readonly) NSTextCheckingType resultType;
@property(readonly) NSTimeZone *timeZone;
@property(readonly) NSURL *URL;

+ (NSTextCheckingResult*)regularExpressionCheckingResultWithRanges:(NSRangePointer)ranges
    count:(NSUInteger)count
    regularExpression:(NSRegularExpression*)regularExpression;

+ (NSTextCheckingResult *)orthographyCheckingResultWithRange:(NSRange)range orthography:(NSOrthography *)orthography NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)spellCheckingResultWithRange:(NSRange)range NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)grammarCheckingResultWithRange:(NSRange)range details:(NSArray *)details NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)addressCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)linkCheckingResultWithRange:(NSRange)range URL:(NSURL *)url NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)quoteCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)dashCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)replacementCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)correctionCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)phoneNumberCheckingResultWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber NS_UNIMPLEMENTED;
+ (NSTextCheckingResult *)transitInformationCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components NS_UNIMPLEMENTED;

@end
