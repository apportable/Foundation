//
//  NSTextCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSTransitInformationCheckingResult.h"
#import "NSPhoneNumberCheckingResult.h"
#import "NSRegularExpressionCheckingResult.h"
#import "NSSubstitutionCheckingResult.h"
#import "NSLinkCheckingResult.h"
#import "NSDateCheckingResult.h"
#import "NSGrammarCheckingResult.h"
#import "NSSpellCheckingResult.h"
#import "NSOrthographyCheckingResult.h"
#import "NSAddressCheckingResult.h"

NSString * const NSTextCheckingNameKey = @"Name";
NSString * const NSTextCheckingJobTitleKey = @"JobTitle";
NSString * const NSTextCheckingOrganizationKey = @"Organization";
NSString * const NSTextCheckingStreetKey = @"Street";
NSString * const NSTextCheckingCityKey = @"City";
NSString * const NSTextCheckingStateKey = @"State";
NSString * const NSTextCheckingZIPKey = @"ZIP";
NSString * const NSTextCheckingCountryKey = @"Country";
NSString * const NSTextCheckingPhoneKey = @"Phone";
NSString * const NSTextCheckingAirlineKey = @"Airline";
NSString * const NSTextCheckingFlightKey = @"Flight";

@implementation NSTextCheckingResult

+ (void)initialize
{

}

+ (NSTextCheckingResult *)transitInformationCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components
{
    return [[[NSTransitInformationCheckingResult alloc] initWithRange:range components:components] autorelease];
}

+ (NSTextCheckingResult *)phoneNumberCheckingResultWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber
{
    return [[[NSPhoneNumberCheckingResult alloc] initWithRange:range phoneNumber:phoneNumber] autorelease];
}

+ (NSTextCheckingResult *)regularExpressionCheckingResultWithRanges:(NSRangePointer)ranges count:(NSUInteger)count regularExpression:(NSRegularExpression *)regularExpression
{
    if (count <= 3)
    {
        return [[[NSSimpleRegularExpressionCheckingResult alloc] initWithRanges:ranges count:count regularExpression:regularExpression] autorelease];    
    }
    else if (count <= 7)
    {
        return [[[NSExtendedRegularExpressionCheckingResult alloc] initWithRanges:ranges count:count regularExpression:regularExpression] autorelease];    
    }
    else
    {
        return [[[NSComplexRegularExpressionCheckingResult alloc] initWithRanges:ranges count:count regularExpression:regularExpression] autorelease];       
    }
}

+ (NSTextCheckingResult *)correctionCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString
{
    return [[[NSCorrectionCheckingResult alloc] initWithRange:range replacementString:replacementString] autorelease];
}

+ (NSTextCheckingResult *)replacementCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString
{
    return [[[NSSubstitutionCheckingResult alloc] initWithRange:range replacementString:replacementString] autorelease];
}

+ (NSTextCheckingResult *)dashCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString
{
    return [[[NSDashCheckingResult alloc] initWithRange:range replacementString:replacementString] autorelease];
}

+ (NSTextCheckingResult *)quoteCheckingResultWithRange:(NSRange)range replacementString:(NSString *)replacementString
{
    return [[[NSQuoteCheckingResult alloc] initWithRange:range replacementString:replacementString] autorelease];
}

+ (NSTextCheckingResult *)linkCheckingResultWithRange:(NSRange)range URL:(NSURL *)url
{
    return [[[NSLinkCheckingResult alloc] initWithRange:range URL:url] autorelease];
}

+ (NSTextCheckingResult *)addressCheckingResultWithRange:(NSRange)range components:(NSDictionary *)components
{
    return [[[NSAddressCheckingResult alloc] initWithRange:range components:components] autorelease];
}

+ (NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration
{
    return [[[NSDateCheckingResult alloc] initWithRange:range date:date timeZone:timeZone duration:duration] autorelease];
}

+ (NSTextCheckingResult *)dateCheckingResultWithRange:(NSRange)range date:(NSDate *)date
{
    return [[[NSDateCheckingResult alloc] initWithRange:range date:date] autorelease];   
}

+ (NSTextCheckingResult *)grammarCheckingResultWithRange:(NSRange)range details:(NSArray *)details
{
    return [[[NSGrammarCheckingResult alloc] initWithRange:range details:details] autorelease];
}

+ (NSTextCheckingResult *)spellCheckingResultWithRange:(NSRange)range
{
    return [[[NSSpellCheckingResult alloc] initWithRange:range] autorelease];
}

+ (NSTextCheckingResult *)orthographyCheckingResultWithRange:(NSRange)range orthography:(NSOrthography *)orthography
{
    return [[[NSOrthographyCheckingResult alloc] initWithRange:range orthography:orthography] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}


@end

