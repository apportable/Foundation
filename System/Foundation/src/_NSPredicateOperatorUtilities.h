#import <Foundation/NSPredicate.h>
#import <Foundation/NSString.h>
#import "NSMatchingPredicateOperator.h"
#import "_NSPredicateUtilities.h"
#import <CoreFoundation/CFLocale.h>

@interface _NSPredicateOperatorUtilities : NSObject

+ (long long)copyRegexFindSafePattern:(NSString *)pattern toBuffer:(unichar *)buffer;
+ (BOOL)doRegexForString:(NSString *)string pattern:(NSString *)pattern likeProtect:(BOOL)protect flags:(NSComparisonPredicateOptions)flags context:(struct regexContext *)context;
+ (NSString *)newStringFrom:(NSString *)string usingUnicodeTransforms:(CFStringCompareFlags)transforms;
+ (CFLocaleRef)retainedLocale;

@end
