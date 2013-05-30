#import <Foundation/NSObject.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTextCheckingResult.h>

typedef NS_OPTIONS (NSUInteger, NSRegularExpressionOptions) {
    NSRegularExpressionCaseInsensitive            = 1 << 0,
        NSRegularExpressionAllowCommentsAndWhitespace = 1 << 1,
        NSRegularExpressionIgnoreMetacharacters       = 1 << 2,
        NSRegularExpressionDotMatchesLineSeparators   = 1 << 3,
        NSRegularExpressionAnchorsMatchLines          = 1 << 4,
        NSRegularExpressionUseUnixLineSeparators      = 1 << 5,
        NSRegularExpressionUseUnicodeWordBoundaries   = 1 << 6
};

typedef NS_OPTIONS (NSUInteger, NSMatchingOptions) {
    NSMatchingReportProgress         = 1 << 0,
        NSMatchingReportCompletion       = 1 << 1,
        NSMatchingAnchored               = 1 << 2,
        NSMatchingWithTransparentBounds  = 1 << 3,
        NSMatchingWithoutAnchoringBounds = 1 << 4
};

typedef NS_OPTIONS (NSUInteger, NSMatchingFlags) {
    NSMatchingProgress      = 1 << 0,
        NSMatchingCompleted     = 1 << 1,
        NSMatchingHitEnd        = 1 << 2,
        NSMatchingRequiredEnd   = 1 << 3,
        NSMatchingInternalError = 1 << 4
};

#ifndef GSREGEXTYPE
#define GSREGEXTYPE void
#endif

@interface NSRegularExpression : NSObject <NSCoding, NSCopying> {
    @private
    GSREGEXTYPE *regex;
    NSRegularExpressionOptions options;
}
@property (readonly) NSRegularExpressionOptions options;
@property (readonly) NSUInteger numberOfCaptureGroups;

+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)aPattern
    options:(NSRegularExpressionOptions)opts
    error:(NSError **)e;
- (id)initWithPattern:(NSString *)aPattern
    options:(NSRegularExpressionOptions)opts
    error:(NSError **)e;
+ (NSRegularExpression*)regularExpressionWithPattern:(NSString *)aPattern
    options:(NSRegularExpressionOptions)opts
    error:(NSError **)e;
- (id)initWithPattern:(NSString *)aPattern
    options:(NSRegularExpressionOptions)opts
    error:(NSError **)e;
- (NSString *)pattern;
- (void)enumerateMatchesInString:(NSString *)string
    options:(NSMatchingOptions)options
    range:(NSRange)range
    usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block;
- (NSUInteger)numberOfMatchesInString:(NSString *)string
    options:(NSMatchingOptions)options
    range:(NSRange)range;

- (NSTextCheckingResult*)firstMatchInString:(NSString *)string
    options:(NSMatchingOptions)options
    range:(NSRange)range;
- (NSArray *)matchesInString:(NSString *)string
    options:(NSMatchingOptions)options
    range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInString:(NSString *)string
    options:(NSMatchingOptions)options
    range:(NSRange)range;
- (NSUInteger)replaceMatchesInString:(NSMutableString *)string
    options:(NSMatchingOptions)options
    range:(NSRange)range
    withTemplate:(NSString *)templateString;
- (NSString *)stringByReplacingMatchesInString:(NSString*)string
    options:(NSMatchingOptions)options
    range:(NSRange)range
    withTemplate:(NSString*)templateString;
- (NSString *)replacementStringForResult:(NSTextCheckingResult *)result
    inString:(NSString *)string
    offset:(NSInteger)offset
    template:(NSString *)templateString;


@end

@interface NSDataDetector : NSRegularExpression

@property (readonly) NSTextCheckingTypes checkingTypes;

+ (NSDataDetector *)dataDetectorWithTypes:(NSTextCheckingTypes)checkingTypes error:(NSError **)error;
- (id)initWithTypes:(NSTextCheckingTypes)checkingTypes error:(NSError **)error;


@end

