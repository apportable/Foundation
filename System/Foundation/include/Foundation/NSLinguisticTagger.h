#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@class NSArray, NSOrthography;

FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeTokenType;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeLexicalClass;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeNameType;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeNameTypeOrLexicalClass;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeLemma;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeLanguage;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSchemeScript;
FOUNDATION_EXPORT NSString *const NSLinguisticTagWord;
FOUNDATION_EXPORT NSString *const NSLinguisticTagPunctuation;
FOUNDATION_EXPORT NSString *const NSLinguisticTagWhitespace;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOther;
FOUNDATION_EXPORT NSString *const NSLinguisticTagNoun;
FOUNDATION_EXPORT NSString *const NSLinguisticTagVerb;
FOUNDATION_EXPORT NSString *const NSLinguisticTagAdjective;
FOUNDATION_EXPORT NSString *const NSLinguisticTagAdverb;
FOUNDATION_EXPORT NSString *const NSLinguisticTagPronoun;
FOUNDATION_EXPORT NSString *const NSLinguisticTagDeterminer;
FOUNDATION_EXPORT NSString *const NSLinguisticTagParticle;
FOUNDATION_EXPORT NSString *const NSLinguisticTagPreposition;
FOUNDATION_EXPORT NSString *const NSLinguisticTagNumber;
FOUNDATION_EXPORT NSString *const NSLinguisticTagConjunction;
FOUNDATION_EXPORT NSString *const NSLinguisticTagInterjection;
FOUNDATION_EXPORT NSString *const NSLinguisticTagClassifier;
FOUNDATION_EXPORT NSString *const NSLinguisticTagIdiom;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOtherWord;
FOUNDATION_EXPORT NSString *const NSLinguisticTagSentenceTerminator;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOpenQuote;
FOUNDATION_EXPORT NSString *const NSLinguisticTagCloseQuote;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOpenParenthesis;
FOUNDATION_EXPORT NSString *const NSLinguisticTagCloseParenthesis;
FOUNDATION_EXPORT NSString *const NSLinguisticTagWordJoiner;
FOUNDATION_EXPORT NSString *const NSLinguisticTagDash;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOtherPunctuation;
FOUNDATION_EXPORT NSString *const NSLinguisticTagParagraphBreak;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOtherWhitespace;
FOUNDATION_EXPORT NSString *const NSLinguisticTagPersonalName;
FOUNDATION_EXPORT NSString *const NSLinguisticTagPlaceName;
FOUNDATION_EXPORT NSString *const NSLinguisticTagOrganizationName;

typedef NS_OPTIONS(NSUInteger, NSLinguisticTaggerOptions) {
    NSLinguisticTaggerOmitWords       = 1 << 0,
    NSLinguisticTaggerOmitPunctuation = 1 << 1,
    NSLinguisticTaggerOmitWhitespace  = 1 << 2,
    NSLinguisticTaggerOmitOther       = 1 << 3,
    NSLinguisticTaggerJoinNames       = 1 << 4
};

@interface NSLinguisticTagger : NSObject

+ (NSArray *)availableTagSchemesForLanguage:(NSString *)language;
- (id)initWithTagSchemes:(NSArray *)tagSchemes options:(NSUInteger)opts;
- (NSArray *)tagSchemes;
- (void)setString:(NSString *)string;
- (NSString *)string;
- (void)setOrthography:(NSOrthography *)orthography range:(NSRange)range;
- (NSOrthography *)orthographyAtIndex:(NSUInteger)charIndex effectiveRange:(NSRangePointer)effectiveRange;
- (void)stringEditedInRange:(NSRange)newRange changeInLength:(NSInteger)delta;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts usingBlock:(void (^)(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop))block;
#endif
- (NSRange)sentenceRangeForRange:(NSRange)range;
- (NSString *)tagAtIndex:(NSUInteger)charIndex scheme:(NSString *)tagScheme tokenRange:(NSRangePointer)tokenRange sentenceRange:(NSRangePointer)sentenceRange;
- (NSArray *)tagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts tokenRanges:(NSArray **)tokenRanges;
- (NSArray *)possibleTagsAtIndex:(NSUInteger)charIndex scheme:(NSString *)tagScheme tokenRange:(NSRangePointer)tokenRange sentenceRange:(NSRangePointer)sentenceRange scores:(NSArray **)scores;

@end

@interface NSString (NSLinguisticAnalysis)

- (NSArray *)linguisticTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts orthography:(NSOrthography *)orthography tokenRanges:(NSArray **)tokenRanges;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateLinguisticTagsInRange:(NSRange)range scheme:(NSString *)tagScheme options:(NSLinguisticTaggerOptions)opts orthography:(NSOrthography *)orthography usingBlock:(void (^)(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop))block;
#endif

@end
