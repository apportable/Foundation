#import <Foundation/NSComparisonPredicate.h>

#import <Foundation/NSCoder.h>
#import <Foundation/NSObject.h>

#import <CoreFoundation/CFLocale.h>
#import <CoreFoundation/CFString.h>

@class NSDate;
@class NSNumber;

typedef enum {
    NSPredicateInvalidMathType = 4,
    NSPredicateIntegerMathType = 2,
    NSPredicateLongLongMathType = 1,
    NSPredicateDoubleMathType = 0,
} NSPredicateMathType;

CF_PRIVATE
@interface _NSPredicateUtilities : NSObject

+ (NSPredicateMathType)_getCommonTypeFor:(id)arg1;
+ (NSPredicateMathType)_getITypeFor:(const char *)arg1;

+ (NSSet *)_constantValueClassesForSecureCoding;
+ (NSSet *)_operatorClassesForSecureCoding;
+ (NSSet *)_extendedExpressionClassesForSecureCoding;
+ (NSSet *)_expressionClassesForSecureCoding;
+ (NSSet *)_compoundPredicateClassesForSecureCoding;
+ (NSSet *)_predicateClassesForSecureCoding;

+ (NSString *)_parserableCollectionDescription:(id)collection;
+ (NSString *)_parserableDateDescription:(NSDate *)date;
+ (NSString *)_parserableStringDescription:(NSString *)string;
+ (BOOL)_isReservedWordInParser:(NSString *)word;

+ (NSNumber *)_convertStringToNumber:(NSString *)string;
+ (NSString *)lowercase:(NSString *)string;
+ (NSString *)uppercase:(NSString *)string;
+ (id)tokenize:(id)arg1 using:(id)arg2;
+ (NSSet *)_collapseAndTokenize:(id)collection flags:(CFStringCompareFlags)flags locale:(CFLocaleRef)locale;
+ (NSSet *)_processAndTokenize:(NSString *)string flags:(CFStringCompareFlags)flags locale:(CFLocaleRef)locale;
+ (NSSet *)_doTokenization:(NSString *)string locale:(CFLocaleRef)locale;

+ (id)inverseOrderKey:(id)arg1;
+ (id)distinct:(id)arg1;
+ (id)noindex:(id)object;
+ (NSNumber *)onesComplement:(NSNumber *)number;
+ (NSNumber *)rightshift:(NSNumber *)number1 by:(NSNumber *)number2;
+ (NSNumber *)leftshift:(NSNumber *)number1 by:(NSNumber *)number2;
+ (NSNumber *)bitwiseXor:(NSNumber *)number1 with:(NSNumber *)number2;
+ (NSNumber *)bitwiseOr:(NSNumber *)number1 with:(NSNumber *)number2;
+ (NSNumber *)bitwiseAnd:(NSNumber *)number1 with:(NSNumber *)number2;
+ (id)distanceToLocation:(id)arg1 fromLocation:(id)arg2;
+ (id)objectFrom:(id)arg1 withIndex:(id)arg2;
+ (NSNumber *)randomn:(NSNumber *)number;
+ (id)random;
+ (id)castObject:(id)object toType:(NSString *)typeName;
+ (NSNumber *)abs:(NSNumber *)number;
+ (NSNumber *)trunc:(NSNumber *)number;
+ (NSNumber *)floor:(NSNumber *)number;
+ (NSNumber *)ceiling:(NSNumber *)number;
+ (NSNumber *)exp:(NSNumber *)number;
+ (NSNumber *)raise:(NSNumber *)base toPower:(NSNumber *)power;
+ (NSNumber *)ln:(NSNumber *)number;
+ (NSNumber *)log:(NSNumber *)number;
+ (NSNumber *)sqrt:(NSNumber *)number;
+ (NSNumber *)modulus:(NSNumber *)number1 by:(NSNumber *)number2;
+ (NSNumber *)divide:(NSNumber *)number1 by:(NSNumber *)number2;
+ (NSNumber *)multiply:(NSNumber *)number1 by:(NSNumber *)number2;
+ (NSNumber *)from:(NSNumber *)number1 subtract:(NSNumber *)number2;
+ (NSNumber *)add:(NSNumber *)number1 to:(NSNumber *)number2;
+ (NSNumber *)stddev:(NSArray *)numbers;
+ (NSNumber *)mode:(NSArray *)numbers;
+ (NSNumber *)median:(NSArray *)numbers;
+ (NSNumber *)average:(NSArray *)numbers;
+ (NSNumber *)max:(NSArray *)numbers;
+ (NSNumber *)min:(NSArray *)numbers;
+ (NSNumber *)count:(NSArray *)numbers;
+ (NSNumber *)sum:(NSArray *)numbers;
+ (NSDate *)now;

@end

@interface _NSPredicateUtilities (Compiler)

- (double)distanceFromLocation:(id)arg1;

@end

static inline NSSet *_NSPredicateAllowedClasses(NSCoder *decoder, NSSet *predicateAllowedClasses)
{
    NSSet *decoderAllowedClasses = [decoder allowedClasses];

    if ([decoderAllowedClasses count] == 0)
    {
        return predicateAllowedClasses;
    }
    else
    {
        NSMutableSet *copy = [decoderAllowedClasses mutableCopy];
        [copy unionSet:predicateAllowedClasses];
        return [copy autorelease];
    }
}
