#import <limits.h>
#import <Foundation/NSObjCRuntime.h>

typedef NS_ENUM(NSUInteger, NSRoundingMode) {
    NSRoundPlain,
    NSRoundDown,
    NSRoundUp,
    NSRoundBankers
};

typedef NS_ENUM(NSUInteger, NSCalculationError) {
    NSCalculationNoError = 0,
    NSCalculationLossOfPrecision,
    NSCalculationUnderflow,
    NSCalculationOverflow,
    NSCalculationDivideByZero
};

#define NSDecimalMaxSize (8)
#define NSDecimalNoScale SHRT_MAX

typedef struct {
    signed int _exponent:8;
    unsigned int _length:4;
    unsigned int _isNegative:1;
    unsigned int _isCompact:1;
    unsigned int _reserved:18;
    unsigned short _mantissa[NSDecimalMaxSize];
} NSDecimal;

@class NSDictionary;

NS_INLINE BOOL NSDecimalIsNotANumber(const NSDecimal *dcm) {
    return ((dcm->_length == 0) && dcm->_isNegative);
}

FOUNDATION_EXPORT void NSDecimalCopy(NSDecimal *destination, const NSDecimal *source);
FOUNDATION_EXPORT void NSDecimalCompact(NSDecimal *number);
FOUNDATION_EXPORT NSComparisonResult NSDecimalCompare(const NSDecimal *leftOperand, const NSDecimal *rightOperand);
FOUNDATION_EXPORT void NSDecimalRound(NSDecimal *result, const NSDecimal *number, NSInteger scale, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalNormalize(NSDecimal *number1, NSDecimal *number2, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalAdd(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalSubtract(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalMultiply(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalDivide(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalPower(NSDecimal *result, const NSDecimal *number, NSUInteger power, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSCalculationError NSDecimalMultiplyByPowerOf10(NSDecimal *result, const NSDecimal *number, short power, NSRoundingMode roundingMode);
FOUNDATION_EXPORT NSString *NSDecimalString(const NSDecimal *dcm, id locale);
