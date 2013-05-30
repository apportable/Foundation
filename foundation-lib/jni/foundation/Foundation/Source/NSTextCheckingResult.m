#import "Foundation/NSTextCheckingResult.h"
#import "Foundation/NSRegularExpression.h"
#import <GNUstepBase/GNUstep.h>

#include <string.h>

/**
 * Private class encapsulating a regular expression match.
 */
@interface GSRegularExpressionCheckingResult : NSTextCheckingResult
{
    // TODO: This could be made more efficient by adding a variant that only
    // contained a single range.
    @public
    /** The number of ranges matched */
    NSUInteger rangeCount;
    /** The array of ranges. */
    NSRange *ranges;
    /** The regular expression object that generated this match. */
    NSRegularExpression *regularExpression;
}
@end

@implementation NSTextCheckingResult

@synthesize addressComponents = _addressComponents;
@synthesize components = _components;
@synthesize date = _date;
@synthesize duration = _duration;
@synthesize grammarDetails = _grammarDetails;
@synthesize numberOfRanges = _numberOfRanges;
@synthesize orthography = _orthography;
@synthesize phoneNumber = _phoneNumber;
@synthesize range = _range;
@synthesize regularExpression = _regularExpression;
@synthesize replacementString = _replacementString;
@synthesize resultType = _resultType;
@synthesize timeZone = _timeZone;
@synthesize URL = _URL;

+ (NSTextCheckingResult*)regularExpressionCheckingResultWithRanges:(NSRangePointer)ranges
    count:(NSUInteger)count
    regularExpression:(NSRegularExpression*)regularExpression
{
    GSRegularExpressionCheckingResult *result = [GSRegularExpressionCheckingResult new];
    result->rangeCount = count;
    result->ranges = calloc(sizeof(NSRange), count);
    memcpy(result->ranges, ranges, (sizeof(NSRange) * count));
    ASSIGN(result->regularExpression, regularExpression);
    return [result autorelease];
}

VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)orthographyCheckingResultWithRange:(NSRange)range orthography:(NSOrthography *)orthography);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)spellCheckingResultWithRange:(NSRange)range);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)grammarCheckingResultWithRange:(NSRange)range details:(NSArray *)details);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)addressCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)linkCheckingResultWithRange:(NSRange)range URL:(NSURL *)url);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)quoteCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)dashCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)replacementCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)correctionCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)phoneNumberCheckingResultWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber);
VERDE_UNIMPLEMENTED_FN(+(NSTextCheckingResult *)transitInformationCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components);

@end


@implementation GSRegularExpressionCheckingResult
- (NSUInteger)rangeCount
{
    return rangeCount;
}
- (NSRange)range
{
    return ranges[0];
}
- (NSRange)rangeAtIndex:(NSUInteger)idx
{
    if (idx >= rangeCount)
    {
        return NSMakeRange(0, NSNotFound);
    }
    return ranges[idx];
}
- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeRegularExpression;
}
- (void)dealloc
{
    [regularExpression release];
    free(ranges);
    [super dealloc];
}
@end

