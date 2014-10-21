#import <Foundation/NSValue.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSDecimal.h>
#import <Foundation/NSDictionary.h>

FOUNDATION_EXPORT NSString * const NSDecimalNumberExactnessException;
FOUNDATION_EXPORT NSString * const NSDecimalNumberOverflowException;
FOUNDATION_EXPORT NSString * const NSDecimalNumberUnderflowException;
FOUNDATION_EXPORT NSString * const NSDecimalNumberDivideByZeroException;

@class NSDecimalNumber;

@protocol NSDecimalNumberBehaviors

- (NSRoundingMode)roundingMode;
- (short)scale;
- (NSDecimalNumber *)exceptionDuringOperation:(SEL)operation error:(NSCalculationError)error leftOperand:(NSDecimalNumber *)leftOperand rightOperand:(NSDecimalNumber *)rightOperand;

@end

@interface NSDecimalNumber : NSNumber {
@private
    signed int _exponent:8;
    unsigned int _length:4;
    unsigned int _isNegative:1;
    unsigned int _isCompact:1;
    unsigned int _reserved:1;
    unsigned int _hasExternalRefCount:1;
    unsigned int _refs:16;
    unsigned short _mantissa[0];
}

+ (void)setDefaultBehavior:(id <NSDecimalNumberBehaviors>)behavior;
+ (id <NSDecimalNumberBehaviors>)defaultBehavior;
+ (NSDecimalNumber *)decimalNumberWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag;
+ (NSDecimalNumber *)decimalNumberWithDecimal:(NSDecimal)decimal;
+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)numberValue;
+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)numberValue locale:(id)locale;
+ (NSDecimalNumber *)zero;
+ (NSDecimalNumber *)one;
+ (NSDecimalNumber *)minimumDecimalNumber;
+ (NSDecimalNumber *)maximumDecimalNumber;
+ (NSDecimalNumber *)notANumber;
- (id)initWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag;
- (id)initWithDecimal:(NSDecimal)dcm;
- (id)initWithString:(NSString *)numberValue;
- (id)initWithString:(NSString *)numberValue locale:(id)locale;
- (NSString *)descriptionWithLocale:(id)locale;
- (NSDecimal)decimalValue;
- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)decimalNumber;
- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSUInteger)power;
- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSUInteger)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(short)power;
- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(short)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSDecimalNumber *)decimalNumberByRoundingAccordingToBehavior:(id <NSDecimalNumberBehaviors>)behavior;
- (NSComparisonResult)compare:(NSNumber *)decimalNumber;
- (const char *)objCType NS_RETURNS_INNER_POINTER;
- (double)doubleValue;

@end

@interface NSDecimalNumberHandler : NSObject <NSDecimalNumberBehaviors, NSCoding>

+ (id)defaultDecimalNumberHandler;
+ (id)decimalNumberHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(BOOL)exact raiseOnOverflow:(BOOL)overflow raiseOnUnderflow:(BOOL)underflow raiseOnDivideByZero:(BOOL)divideByZero;
- (id)initWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(BOOL)exact raiseOnOverflow:(BOOL)overflow raiseOnUnderflow:(BOOL)underflow raiseOnDivideByZero:(BOOL)divideByZero;

@end

@interface NSNumber (NSDecimalNumberExtensions)

- (NSDecimal)decimalValue;

@end

@interface NSScanner (NSDecimalNumberScanning)

- (BOOL)scanDecimal:(NSDecimal *)dcm;

@end
