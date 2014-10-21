#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSTextCheckingResult.h>

@class NSArray;

typedef NS_OPTIONS(NSUInteger, NSRegularExpressionOptions) {
    NSRegularExpressionCaseInsensitive            = 1 << 0,
    NSRegularExpressionAllowCommentsAndWhitespace = 1 << 1,
    NSRegularExpressionIgnoreMetacharacters       = 1 << 2,
    NSRegularExpressionDotMatchesLineSeparators   = 1 << 3,
    NSRegularExpressionAnchorsMatchLines          = 1 << 4,
    NSRegularExpressionUseUnixLineSeparators      = 1 << 5,
    NSRegularExpressionUseUnicodeWordBoundaries   = 1 << 6

};

@interface NSRegularExpression : NSObject <NSCopying, NSCoding> {
    NSString *_pattern;
    NSRegularExpressionOptions _options;
    void *_internal;
    id _reserved1;
    int _checkout;
    int _reserved2;
}

@property (readonly) NSString *pattern;
@property (readonly) NSRegularExpressionOptions options;
@property (readonly) NSUInteger numberOfCaptureGroups;
+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error;
+ (NSString *)escapedPatternForString:(NSString *)string;
- (id)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error;

@end

typedef NS_OPTIONS(NSUInteger, NSMatchingOptions) {
   NSMatchingReportProgress         = 1 << 0,
   NSMatchingReportCompletion       = 1 << 1,
   NSMatchingAnchored               = 1 << 2,
   NSMatchingWithTransparentBounds  = 1 << 3,
   NSMatchingWithoutAnchoringBounds = 1 << 4
};

typedef NS_OPTIONS(NSUInteger, NSMatchingFlags) {
   NSMatchingProgress               = 1 << 0,
   NSMatchingCompleted              = 1 << 1,
   NSMatchingHitEnd                 = 1 << 2,
   NSMatchingRequiredEnd            = 1 << 3,
   NSMatchingInternalError          = 1 << 4
};

@interface NSRegularExpression (NSMatching)

#if NS_BLOCKS_AVAILABLE
- (void)enumerateMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block;
#endif
- (NSArray *)matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
- (NSUInteger)numberOfMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
- (NSTextCheckingResult *)firstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range;

@end

@interface NSRegularExpression (NSReplacement)

+ (NSString *)escapedTemplateForString:(NSString *)string;
- (NSString *)stringByReplacingMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range withTemplate:(NSString *)templ;
- (NSUInteger)replaceMatchesInString:(NSMutableString *)string options:(NSMatchingOptions)options range:(NSRange)range withTemplate:(NSString *)templ;
- (NSString *)replacementStringForResult:(NSTextCheckingResult *)result inString:(NSString *)string offset:(NSInteger)offset template:(NSString *)templ;

@end

@interface NSDataDetector : NSRegularExpression

@property (readonly) NSTextCheckingTypes checkingTypes;
+ (NSDataDetector *)dataDetectorWithTypes:(NSTextCheckingTypes)checkingTypes error:(NSError **)error;
- (id)initWithTypes:(NSTextCheckingTypes)checkingTypes error:(NSError **)error;

@end
