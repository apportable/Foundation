//
//  NSDecimal.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSDecimal.h>
#import <Foundation/NSDecimalNumber.h>

#import <Foundation/NSException.h>
#import <Foundation/NSLocale.h>

#import <math.h>
#import <stdlib.h>

enum { NSDecimalDigitPrecision = 38 };


#pragma mark - NSInteger functions

// The NSInteger* functions manipulate unsigned integers represented
// as a little-endian array of unsigned shorts paired with the length
// of the array. In particular, they do not assume that all such
// integers are the sizes used by NSDecimal and NSDecimalNumber,
// though it is of course compatible with their mantissas. It does use
// the same representation for 0, as a length of 0, rather than an
// array of exactly one zeroed short.

// Thus there are pairs of Integer arguments:
// ( ..., unsigned short *arg, unsigned short argLength, ...)

// or, for out parameters (i.e., results of computations):
// ( ..., unsigned short *result, unsigned short *newAndMaxLength, ...)
// where newAndMaxLength passes in the size of the buffer, and passes
// out the amount of the buffer used.

// These functions thus assume that their callees pass in pointers to
// at least as many shorts as the corresponing length parameters
// specify, and that there are no leading zero 'digits', and that all
// pointer arguments are non-NULL. For example, NSIntegerCompare first
// checks the length arguments of its results, and returns early if
// they are not equal, rather than checking for leading zeroes.

static void NSIntegerCopy(unsigned short *dest, unsigned short *destLength, const unsigned short *source, unsigned short sourceLength)
{
    if (sourceLength > 0)
    {
        memcpy(dest, source, sourceLength * sizeof(short));
        *destLength = sourceLength;
    }
}

static NSCalculationError NSIntegerDivideByShort(unsigned short *quotient, unsigned short *newLength, const unsigned short *dividend, unsigned short length, unsigned short divisor, unsigned short *remainder)
{
    *newLength = 0;
    if (divisor == 0)
    {
        return NSCalculationDivideByZero;
    }

    *remainder = 0;
    for (int idx = length - 1; idx >= 0; idx--)
    {
        unsigned int div = (unsigned int)(dividend[idx]) | (*remainder << 16);
        *remainder = div % divisor;
        quotient[idx] = div / divisor;
    }

    for (int idx = length - 1; idx >= 0; idx--)
    {
        *newLength = idx + 1;
        if (quotient[idx] != 0)
        {
            break;
        }
    }

    return NSCalculationNoError;
}

static NSCalculationError NSIntegerMultiplyByShort(unsigned short *product, unsigned short *newAndMaxLength, const unsigned short *integerMultiplicand, unsigned short length, unsigned short shortMultiplicand)
{
    if (shortMultiplicand == 0)
    {
        *newAndMaxLength = 0;
        return 0;
    }

    if (*newAndMaxLength < length)
    {
        return NSCalculationOverflow;
    }

    if (length == 0)
    {
        *newAndMaxLength = 0;
        return 0;
    }

    unsigned int carry = 0;

    for (int idx = 0; idx < length; idx++)
    {
        unsigned int prod = carry + (unsigned int)shortMultiplicand * (unsigned int)integerMultiplicand[idx];
        product[idx] = prod;
        carry = prod >> 16;
    }

    if (carry != 0)
    {
        if (*newAndMaxLength == length)
        {
            return NSCalculationOverflow;
        }
        product[length] = carry;
        length++;
    }
    *newAndMaxLength = length;

    return NSCalculationNoError;
}

static NSCalculationError NSIntegerAddShort(unsigned short *sum, unsigned short *newLength, const unsigned short *integerSummand, unsigned short length, unsigned short shortSummand)
{
    for (int idx = 0; idx < length; idx++)
    {
        unsigned int sumWithOverflow = (unsigned int)shortSummand + (unsigned int)(integerSummand[idx]);
        sum[idx] = sumWithOverflow;
        unsigned int overflow = sumWithOverflow >> 16;
        shortSummand = overflow;
    }

    if (shortSummand != 0)
    {
        if (*newLength == length)
        {
            return NSCalculationOverflow;
        }

        sum[length] = shortSummand;
        *newLength = length + 1;
    }
    else
    {
        *newLength = length;
    }

    return NSCalculationNoError;
}

static NSCalculationError NSIntegerSubtract(unsigned short *diff, unsigned short *diffLength, const unsigned short *left, unsigned short leftLength, const unsigned short *right, unsigned short rightLength)
{
    unsigned short sharedLength = MIN(leftLength, rightLength);

    unsigned int overflow = 1;
    for (int idx = 0; idx < sharedLength; idx++)
    {
        overflow += USHRT_MAX + left[idx] - right[idx];
        diff[idx] = overflow;
        overflow >>= 16;
    }

    unsigned short length = rightLength;
    if (rightLength < leftLength)
    {
        while (length < leftLength && overflow == 0)
        {
            overflow = USHRT_MAX + left[length];
            diff[length] = overflow;
            overflow >>= 16;
            length++;
        }
        memmove(diff + length, left + length, (leftLength - length) * sizeof(short));
    }

    *diffLength = length;

    return NSCalculationNoError;
}

static NSCalculationError NSIntegerAdd(unsigned short *sum, unsigned short *sumLength, const unsigned short *leftSummand, unsigned short leftLength, const unsigned short *rightSummand, unsigned short rightLength)
{
    unsigned short sharedLength = MIN(leftLength, rightLength);

    unsigned int overflow = 0;
    for (int idx = 0; idx < sharedLength; idx++)
    {
        overflow += leftSummand[idx] + rightSummand[idx];
        sum[idx] = overflow;
        overflow >>= 16;
    }

    if (leftLength != rightLength)
    {
        const unsigned short *remainingSummand;
        unsigned short remainingLength;
        if (leftLength > rightLength)
        {
            remainingSummand = leftSummand;
            remainingLength = leftLength;
        }
        else
        {
            remainingSummand = rightSummand;
            remainingLength = rightLength;
        }

        for (int idx = sharedLength; idx < remainingLength; idx++)
        {
            overflow += remainingSummand[idx];
            sum[idx] = overflow;
            overflow >>= 16;
        }
    }

    if (overflow == 0)
    {
        *sumLength = sharedLength;
        return NSCalculationNoError;
    }

    unsigned short maxLength = MAX(leftLength, rightLength);
    if (*sumLength >= maxLength + 1)
    {
        sum[maxLength] = overflow;
        *sumLength = maxLength + 1;
        return NSCalculationNoError;
    }

    return NSCalculationOverflow;
}

static NSCalculationError NSIntegerMultiply(unsigned short *product, unsigned short *productLength, const unsigned short *left, unsigned short leftLength, const unsigned short *right, unsigned short rightLength)
{
    if (leftLength == 0 || rightLength == 0)
    {
        *productLength = 0;
        return NSCalculationNoError;
    }

    unsigned short *dest = product;
    if (product == left)
    {
        dest = malloc(*productLength * sizeof(short));
        if (dest == NULL)
        {
            [NSException raise:NSMallocException format:@"Could not allocate buffer"];
            return NSCalculationOverflow;
        }
    }

    unsigned short sharedLength = MIN(*productLength, leftLength + rightLength);
    memset(dest, 0, sharedLength * sizeof(short));
    unsigned short *multResult = malloc(sizeof(*multResult) * sharedLength);

    if (multResult == NULL)
    {
        if (product == left)
        {
            free(dest);
        }
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return NSCalculationOverflow;
    }

    // This is like how you learned multiple digit
    // multiplication when you were a kid, except that
    // it is in base 65536.
    // Each digit is one element of the mantissa array,
    // and each pair is handled by NSIntegerMultiplyByShort.

    // e.g. 423 x 32 =
    // 3 * 2  + 20 * 2  + 400 * 2 +   ==> PSUEDOmultiplyByShort(432, 2) +
    // 3 * 30 + 20 * 30 + 400 + 30    ==> PSUEDOmultiplyByShort(432, 30)

    for (int lDigit = 0; lDigit < leftLength; lDigit++) {
        unsigned short addLength = sharedLength;
        unsigned short multResultLength = sharedLength - lDigit;
        memset(multResult, 0, sharedLength * sizeof(short));

        // move the multResult pointer to the corresponding digit to
        // effectively shift by 2^16 as we go up each digit.
        NSIntegerMultiplyByShort(multResult + lDigit, &multResultLength, right, rightLength, left[lDigit]);

        // when adding it to the sum, use the normal multResult to
        // get the shifted effect.
        NSIntegerAdd(dest, &addLength, dest, sharedLength, multResult, sharedLength);
        *productLength = addLength;
    }


    // cleanup
    free(multResult);

    if (product == left) {
        // write into product
        // assumes the length exists in product
        NSIntegerCopy(product, productLength, dest, sharedLength);
        free(dest);
    }

    return NSCalculationNoError;
}

static NSCalculationError NSIntegerDivide(unsigned short *sum, unsigned short *sumLength, const unsigned short *leftSummand, unsigned short leftLength, const unsigned short *rightSummand, unsigned short rightLength)
{
    if (rightLength == 0)
    {
        return NSCalculationDivideByZero;
    }

    DEBUG_BREAK();
    return NSCalculationNoError;
}

static NSCalculationError NSIntegerMultiplyByPowerOf10(unsigned short *dest, unsigned short *destLength, const unsigned short *source, unsigned short sourceLength, short power)
{
    static const struct {
        unsigned short length;
        unsigned short digits[NSDecimalMaxSize];
    } powersOfTen[NSDecimalDigitPrecision + 1] = {
        [ 0] = { 1, { 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 1] = { 1, { 0x000a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 2] = { 1, { 0x0064, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 3] = { 1, { 0x03e8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 4] = { 1, { 0x2710, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 5] = { 2, { 0x86a0, 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 6] = { 2, { 0x4240, 0x000f, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 7] = { 2, { 0x9680, 0x0098, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 8] = { 2, { 0xe100, 0x05f5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [ 9] = { 2, { 0xca00, 0x3b9a, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [10] = { 3, { 0xe400, 0x540b, 0x0002, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [11] = { 3, { 0xe800, 0x4876, 0x0017, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [12] = { 3, { 0x1000, 0xd4a5, 0x00e8, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [13] = { 3, { 0xa000, 0x4e72, 0x0918, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [14] = { 3, { 0x4000, 0x107a, 0x5af3, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [15] = { 4, { 0x8000, 0xa4c6, 0x8d7e, 0x0003, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [16] = { 4, { 0x0000, 0x6fc1, 0x86f2, 0x0023, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [17] = { 4, { 0x0000, 0x5d8a, 0x4578, 0x0163, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [18] = { 4, { 0x0000, 0xa764, 0xb6b3, 0x0de0, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [19] = { 4, { 0x0000, 0x89e8, 0x2304, 0x8ac7, 0x0000, 0x0000, 0x0000, 0x0000, } },
        [20] = { 5, { 0x0000, 0x6310, 0x5e2d, 0x6bc7, 0x0005, 0x0000, 0x0000, 0x0000, } },
        [21] = { 5, { 0x0000, 0xdea0, 0xadc5, 0x35c9, 0x0036, 0x0000, 0x0000, 0x0000, } },
        [22] = { 5, { 0x0000, 0xb240, 0xc9ba, 0x19e0, 0x021e, 0x0000, 0x0000, 0x0000, } },
        [23] = { 5, { 0x0000, 0xf680, 0xe14a, 0x02c7, 0x152d, 0x0000, 0x0000, 0x0000, } },
        [24] = { 5, { 0x0000, 0xa100, 0xcced, 0x1bce, 0xd3c2, 0x0000, 0x0000, 0x0000, } },
        [25] = { 6, { 0x0000, 0x4a00, 0x0148, 0x1614, 0x4595, 0x0008, 0x0000, 0x0000, } },
        [26] = { 6, { 0x0000, 0xe400, 0x0cd2, 0xdcc8, 0xb7d2, 0x0052, 0x0000, 0x0000, } },
        [27] = { 6, { 0x0000, 0xe800, 0x803c, 0x9fd0, 0x2e3c, 0x033b, 0x0000, 0x0000, } },
        [28] = { 6, { 0x0000, 0x1000, 0x0261, 0x3e25, 0xce5e, 0x204f, 0x0000, 0x0000, } },
        [29] = { 7, { 0x0000, 0xa000, 0x17ca, 0x6d72, 0x0fae, 0x431e, 0x0001, 0x0000, } },
        [30] = { 7, { 0x0000, 0x4000, 0xedea, 0x4674, 0x9cd0, 0x9f2c, 0x000c, 0x0000, } },
        [31] = { 7, { 0x0000, 0x8000, 0x4b26, 0xc091, 0x2022, 0x37be, 0x007e, 0x0000, } },
        [32] = { 7, { 0x0000, 0x0000, 0xef81, 0x85ac, 0x415b, 0x2d6d, 0x04ee, 0x0000, } },
        [33] = { 7, { 0x0000, 0x0000, 0x5b0a, 0x38c1, 0x8d93, 0xc644, 0x314d, 0x0000, } },
        [34] = { 8, { 0x0000, 0x0000, 0x8e64, 0x378d, 0x87c0, 0xbead, 0xed09, 0x0001, } },
        [35] = { 8, { 0x0000, 0x0000, 0x8fe8, 0x2b87, 0x4d82, 0x72c7, 0x4261, 0x0013, } },
        [36] = { 8, { 0x0000, 0x0000, 0x9f10, 0xb34b, 0x0715, 0x7bc9, 0x97ce, 0x00c0, } },
        [37] = { 8, { 0x0000, 0x0000, 0x36a0, 0x00f4, 0x46d9, 0xd5da, 0xee10, 0x0785, } },
        [38] = { 8, { 0x0000, 0x0000, 0x2240, 0x098a, 0xc47a, 0x5a86, 0x4ca8, 0x4b3b, } },
    };

    if (power == 0)
    {
        memmove(dest, source, sourceLength * sizeof(short));
        *destLength = sourceLength;
        return NSCalculationNoError;
    }

    unsigned short *buf = dest;
    if (source == dest)
    {
        buf = malloc(*destLength * sizeof(short));
        if (buf == NULL)
        {
            [NSException raise:NSMallocException format:@"Could not allocate buffer"];
            return NSCalculationOverflow;
        }
    }

    memmove(buf, source, sourceLength * sizeof(short));

    NSCalculationError err;
    unsigned short newDestLength = *destLength;

    while (abs(power) > NSDecimalDigitPrecision)
    {
        if (power >= 0)
        {
            err = NSIntegerMultiply(buf, &newDestLength, buf, sourceLength, powersOfTen[NSDecimalDigitPrecision].digits, powersOfTen[NSDecimalDigitPrecision].length);
            power -= NSDecimalDigitPrecision;
        }
        else
        {
            err = NSIntegerDivide(buf, &newDestLength, buf, sourceLength, powersOfTen[NSDecimalDigitPrecision].digits, powersOfTen[NSDecimalDigitPrecision].length);
            power += NSDecimalDigitPrecision;
        }
        if (err != NSCalculationNoError)
        {
            if (source == dest)
            {
                free(buf);
            }
            return err;
        }
    }

    if (power >= 0)
    {
        err = NSIntegerMultiply(buf, &newDestLength, buf, sourceLength, powersOfTen[power].digits, powersOfTen[power].length);
    }
    else
    {
        err = NSIntegerDivide(buf, &newDestLength, buf, sourceLength, powersOfTen[-power].digits, powersOfTen[-power].length);
    }

    if (buf != dest)
    {
        memmove(dest, buf, newDestLength * sizeof(short));
        free(buf);
    }

    *destLength = newDestLength;

    return err;
}

static NSComparisonResult NSIntegerCompare(const unsigned short *left, unsigned short leftLength, const unsigned short *right, unsigned short rightLength)
{
    if (leftLength < rightLength)
    {
        return NSOrderedAscending;
    }

    if (rightLength < leftLength)
    {
        return NSOrderedDescending;
    }

    for (int idx = leftLength; idx >= 0; idx--)
    {
        unsigned short l = left[idx];
        unsigned short r = right[idx];

        if (l < r)
        {
            return NSOrderedAscending;
        }
        if (r < l)
        {
            return NSOrderedDescending;
        }
    }

    return NSOrderedSame;
}

static short NSIntegerMaxPowerOf10Multiplier(const unsigned short *integer, unsigned short currentLength, unsigned short maxLength)
{
    unsigned short shortDigits = maxLength - currentLength;
    double base10DigitsPerShortDigit = log10(USHRT_MAX + 1);
    double base10Digits = shortDigits * base10DigitsPerShortDigit;
    return (short)base10Digits;
}


#pragma mark - NSDecimal helper functions

// These check for, and set, whether an NSDecimal is zero or not a
// number. NSDecimalIsNotANumber is used, and thus defined, outside
// this file.

static inline BOOL NSDecimalIsZero(const NSDecimal *number)
{
    return number->_length == 0 && number->_isNegative == 0;
}

static inline void NSDecimalSetZero(NSDecimal *number)
{
    number->_length = 0;
    number->_isNegative = 0;
}

static inline void NSDecimalSetNotANumber(NSDecimal *number)
{
    number->_length = 0;
    number->_isNegative = 1;
}

// Set _exponent, checking for overflow/underflow.
static inline NSCalculationError NSDecimalSetExponent(NSDecimal *number, int exponent)
{
    if (exponent < -128)
    {
        NSDecimalSetNotANumber(number);
        return NSCalculationUnderflow;
    }

    if (exponent > 127)
    {
        NSDecimalSetNotANumber(number);
        return NSCalculationOverflow;
    }

    number->_exponent = exponent;

    return NSCalculationNoError;
}

static inline void NSDecimalRecompact(NSDecimal *number)
{
    number->_isCompact = 0;
    NSDecimalCompact(number);
}

// Make an arbritry-sized Integer fit into NSDecimalMaxSize short
// digits by dividing by the smallest possible power of 10, and
// rounding as dictacted by the specified rounding mode. Returns the
// power of ten thus divided by.
static inline unsigned short NSDecimalReduceLength(unsigned short *digits, unsigned short length, NSRoundingMode roundingMode)
{
    BOOL earlyRemainder = NO;
    unsigned short remainder = 0;
    unsigned short power = 0;
    while (length > NSDecimalMaxSize + 1)
    {
        power += 4;
        NSIntegerDivideByShort(digits, &length, digits, length, 10000, &remainder);
        if (remainder != 0)
        {
            earlyRemainder = YES;
        }
    }
    while (length > NSDecimalMaxSize)
    {
        power++;
        NSIntegerDivideByShort(digits, &length, digits, length, 10, &remainder);
        if (remainder != 0)
        {
            earlyRemainder = YES;
        }
    }
    remainder %= 10;
    if (earlyRemainder && (remainder == 0 || remainder == 5))
    {
        remainder++;
    }

    if (remainder != 0)
    {
        switch (roundingMode)
        {
            case NSRoundPlain:
                if (remainder >= 5)
                {
                    NSIntegerAddShort(digits, &length, digits, length, 1);
                    // we don't need to check overflow or adjust length
                    // because we divided by at least 10 to get here
                }
                break;
            case NSRoundDown:
            case NSRoundUp:
            case NSRoundBankers:
                DEBUG_BREAK();
        }
    }

    return power;
}


#pragma mark - NSDecimal functions

// Note that all of these functions (except Compact) assume that any
// NSDecimal argument is already compact, and will produce NSDecimals
// that are compact as well.

void NSDecimalCompact(NSDecimal *decimal)
{
    if (decimal->_isCompact || NSDecimalIsNotANumber(decimal) || NSDecimalIsZero(decimal))
    {
        return;
    }

    BOOL isZero = YES;
    for (unsigned short idx = 0; idx < decimal->_length; idx++)
    {
        if (decimal->_mantissa[idx] != 0)
        {
            isZero = NO;
            break;
        }
    }
    if (isZero)
    {
        decimal->_length = 0;
        decimal->_isCompact = YES;
        return;
    }

    unsigned short remainder;
    unsigned short newLength;

    int e = decimal->_exponent - 1;

    do {
        newLength = NSDecimalMaxSize;
        NSIntegerDivideByShort(decimal->_mantissa, &newLength, decimal->_mantissa, decimal->_length, 10, &remainder);
        decimal->_length = newLength;
        ++e;
    } while (remainder == 0);

    newLength = NSDecimalMaxSize;
    NSIntegerMultiplyByShort(decimal->_mantissa, &newLength, decimal->_mantissa, decimal->_length, 10);
    decimal->_length = newLength;

    newLength = NSDecimalMaxSize;
    NSIntegerAddShort(decimal->_mantissa, &newLength, decimal->_mantissa, decimal->_length, remainder);
    decimal->_length = newLength;

    while (e > 127)
    {
        newLength = NSDecimalMaxSize;
        NSIntegerMultiplyByShort(decimal->_mantissa, &newLength, decimal->_mantissa, decimal->_length, 10);
        decimal->_length = newLength;
        e--;
    }

    decimal->_exponent = e;
    decimal->_isCompact = 1;
}

void NSDecimalCopy(NSDecimal *destination, const NSDecimal *source)
{
    destination->_exponent = source->_exponent;
    destination->_length = source->_length;
    destination->_isNegative = source->_isNegative;
    destination->_isCompact = source->_isCompact;
    // _reserved is not copied, it is omitted on purpose
    for (int i = 0; i < source->_length; i++)
    {
        destination->_mantissa[i] = source->_mantissa[i];
    }
}

NSComparisonResult NSDecimalCompare(const NSDecimal *leftOperand, const NSDecimal *rightOperand)
{
    if (leftOperand == rightOperand)
    {
        return NSOrderedSame;
    }
    else if (NSDecimalIsNotANumber(leftOperand))
    {
        if (NSDecimalIsNotANumber(rightOperand))
        {
            return NSOrderedSame;
        }
        return NSOrderedAscending;
    }
    else if (NSDecimalIsNotANumber(rightOperand))
    {
        return NSOrderedDescending;
    }
    else if (leftOperand->_isNegative && !rightOperand->_isNegative)
    {
        return NSOrderedAscending;
    }
    else if (!leftOperand->_isNegative && rightOperand->_isNegative)
    {
        return NSOrderedDescending;
    }
    else if (leftOperand->_exponent < rightOperand->_exponent && rightOperand->_length)
    {
        return leftOperand->_isNegative ? NSOrderedDescending : NSOrderedAscending;
    }
    else if (leftOperand->_exponent > rightOperand->_exponent && leftOperand->_length)
    {
        return leftOperand->_isNegative ? NSOrderedAscending : NSOrderedDescending;
    }

    if (leftOperand->_length < rightOperand->_length)
    {
        return leftOperand->_isNegative ? NSOrderedDescending : NSOrderedAscending;
    }
    else if (leftOperand->_length > rightOperand->_length)
    {
        return leftOperand->_isNegative ? NSOrderedAscending : NSOrderedDescending;
    }

    for (int i = leftOperand->_length - 1; i >= 0; i--)
    {
        if (leftOperand->_mantissa[i] < rightOperand->_mantissa[i])
        {
            return leftOperand->_isNegative ? NSOrderedDescending : NSOrderedAscending;
        }
        if (leftOperand->_mantissa[i] > rightOperand->_mantissa[i])
        {
            return leftOperand->_isNegative ? NSOrderedAscending : NSOrderedDescending;
        }
    }

    return NSOrderedSame;
}

void NSDecimalRound(NSDecimal *result, const NSDecimal *number, NSInteger scale, NSRoundingMode roundingMode)
{
    if (scale == NSDecimalNoScale || number->_exponent + scale >= 0)
    {
        if (result != number)
        {
            NSDecimalCopy(result, number);
        }
        return;
    }

    NSDecimalCopy(result, number);

    NSInteger adjustedExponent = -(number->_exponent + scale);
    BOOL hasEarlyRemainder = NO;
    unsigned short newResultLength = 8;
    unsigned short remainder = 0;
    while (adjustedExponent > 0)
    {
        if (remainder != 0)
        {
            hasEarlyRemainder = YES;
        }
        NSInteger power = MAX(adjustedExponent, 4);
        static const unsigned short shortPowersOfTen[] = { 1, 10, 100, 1000, 10000 };
        NSIntegerDivideByShort(result->_mantissa, &newResultLength, result->_mantissa, result->_length, shortPowersOfTen[power], &remainder);
        result->_length = newResultLength;
        adjustedExponent -= power;
    }

    if (hasEarlyRemainder && (remainder % 10 == 0 || remainder % 10 == 5))
    {
        remainder++;
    }

    if (result->_isNegative)
    {
        switch (roundingMode)
        {
            case NSRoundPlain:
            case NSRoundDown:
            case NSRoundUp:
            case NSRoundBankers:
                DEBUG_BREAK();
        }
    }
    else
    {
        switch (roundingMode)
        {
            case NSRoundPlain:
            case NSRoundDown:
            case NSRoundUp:
            case NSRoundBankers:
                DEBUG_BREAK();
        }
    }

    DEBUG_BREAK();

    NSDecimalRecompact(result);
}

NSCalculationError NSDecimalNormalize(NSDecimal *number1, NSDecimal *number2, NSRoundingMode roundingMode)
{
    if (number1->_exponent == number2->_exponent)
    {
        return NSCalculationNoError;
    }

    NSDecimal *larger = number1;
    NSDecimal *smaller = number2;
    if (number1->_exponent < number2->_exponent)
    {
        larger = number2;
        smaller = number1;
    }

    unsigned short exponentDelta = larger->_exponent - smaller->_exponent;

    NSDecimal largerCopy;
    NSDecimalCopy(&largerCopy, larger);

    unsigned short scratch[NSDecimalMaxSize] = {0};
    unsigned short scratchLength = NSDecimalMaxSize;

    NSCalculationError result = NSIntegerMultiplyByPowerOf10(scratch, &scratchLength, larger->_mantissa, larger->_length, exponentDelta);
    if (result == NSCalculationNoError)
    {
        NSIntegerCopy(larger->_mantissa, &scratchLength, scratch, scratchLength);
        larger->_exponent = smaller->_exponent;
        larger->_isCompact = 0;
        larger->_length = scratchLength;
        return NSCalculationNoError;
    }

    NSDecimalCopy(larger, &largerCopy);

    short powerForLarger = NSIntegerMaxPowerOf10Multiplier(larger->_mantissa, larger->_length, NSDecimalMaxSize);
    short powerForSmaller = powerForLarger - exponentDelta;

    scratchLength = 8;
    NSIntegerMultiplyByPowerOf10(scratch, &scratchLength, smaller->_mantissa, smaller->_length, powerForSmaller);
    NSIntegerCopy(smaller->_mantissa, &scratchLength, scratch, scratchLength);
    smaller->_length = scratchLength;
    smaller->_isCompact = 0;
    smaller->_exponent -= powerForSmaller;

    if (smaller->_length == 0)
    {
        smaller->_exponent = larger->_exponent;
        smaller->_isCompact = 0;
        return NSCalculationLossOfPrecision;
    }

    scratchLength = 8;
    NSIntegerMultiplyByPowerOf10(scratch, &scratchLength, larger->_mantissa, larger->_length, powerForLarger);
    NSIntegerCopy(larger->_mantissa, &scratchLength, scratch, scratchLength);
    larger->_length = scratchLength;
    larger->_isCompact = 0;
    larger->_exponent -= powerForLarger;

    return NSCalculationLossOfPrecision;
}

NSCalculationError NSDecimalAdd(NSDecimal *result, const NSDecimal *left, const NSDecimal *right, NSRoundingMode roundingMode)
{
    if (NSDecimalIsNotANumber(left) || NSDecimalIsNotANumber(right))
    {
        NSDecimalSetNotANumber(result);
        return NSCalculationOverflow;
    }

    if (NSDecimalIsZero(left))
    {
        NSDecimalCopy(result, right);
        return NSCalculationNoError;
    }

    if (NSDecimalIsZero(right))
    {
        NSDecimalCopy(result, left);
        return NSCalculationNoError;
    }

    NSDecimal lhs = { 0 };
    NSDecimalCopy(&lhs, left);

    NSDecimal rhs = { 0 };
    NSDecimalCopy(&rhs, right);

    NSCalculationError err = NSDecimalNormalize(&lhs, &rhs, roundingMode);
    if (lhs._length == 0)
    {
        NSDecimalCopy(result, &rhs);
        return err;
    }
    if (rhs._length == 0)
    {
        NSDecimalCopy(result, &lhs);
        return err;
    }

    result->_exponent = lhs._exponent;

    if ((lhs._isNegative && rhs._isNegative) ||
        (!lhs._isNegative && !rhs._isNegative))
    {
        result->_isNegative = lhs._isNegative;

        short newMantissa[NSDecimalMaxSize + 1] = { 0 };
        unsigned short newLength = NSDecimalMaxSize + 1;

        NSIntegerAdd(newMantissa, &newLength, lhs._mantissa, lhs._length, rhs._mantissa, rhs._length);

        int newExponent = lhs._exponent;
        newExponent += NSDecimalReduceLength(newMantissa, newLength, roundingMode);
        NSCalculationError expErr = NSDecimalSetExponent(result, newExponent);
        if (expErr != NSCalculationNoError)
        {
            NSDecimalSetNotANumber(result);
            return expErr;
        }

        newLength = 8;
        NSIntegerCopy(result->_mantissa, &newLength, newMantissa, NSDecimalMaxSize);
        result->_length = newLength;
    }
    else
    {
        unsigned short newLength = 8;
        switch (NSIntegerCompare(lhs._mantissa, lhs._length, rhs._mantissa, rhs._length))
        {
            case NSOrderedSame:
                NSDecimalSetZero(result);
                break;
            case NSOrderedAscending:
                NSIntegerSubtract(result->_mantissa, &newLength, rhs._mantissa, rhs._length, lhs._mantissa, lhs._length);
                result->_length = newLength;
                result->_isNegative = rhs._isNegative;
                break;
            case NSOrderedDescending:
                NSIntegerSubtract(result->_mantissa, &newLength, lhs._mantissa, lhs._length, rhs._mantissa, rhs._length);
                result->_length = newLength;
                result->_isNegative = lhs._isNegative;
                break;
        }
    }

    NSDecimalRecompact(result);

    return err;
}

NSCalculationError NSDecimalSubtract(NSDecimal *result, const NSDecimal *leftOperand, const NSDecimal *rightOperand, NSRoundingMode roundingMode)
{
    NSDecimal negativeRight;
    NSDecimalCopy(&negativeRight, rightOperand);

    // Flip sign, unless being asked to do "L - 0" as NSDecimal cannot represent negative zero
    if (!NSDecimalIsNotANumber(rightOperand) && !NSDecimalIsZero(rightOperand))
    {
        negativeRight._isNegative = !negativeRight._isNegative;
    }

    return NSDecimalAdd(result, leftOperand, &negativeRight, roundingMode);
}

NSCalculationError NSDecimalMultiply(NSDecimal *result, const NSDecimal *left, const NSDecimal *right, NSRoundingMode roundingMode)
{
    if (NSDecimalIsNotANumber(left) || NSDecimalIsNotANumber(right))
    {
        NSDecimalSetNotANumber(result);
        return NSCalculationOverflow;
    }

    if (NSDecimalIsZero(left) || NSDecimalIsZero(right))
    {
        NSDecimalSetZero(result);
        return NSCalculationNoError;
    }

    result->_isNegative = left->_isNegative ^ right->_isNegative;
    int newExponent = left->_exponent + right->_exponent;

    unsigned short product[NSDecimalMaxSize * 2] = {0};
    unsigned short productLength = NSDecimalMaxSize * 2;
    NSIntegerMultiply(product, &productLength, left->_mantissa, left->_length, right->_mantissa, right->_length);
    newExponent += NSDecimalReduceLength(product, productLength, roundingMode);

    NSCalculationError err = NSDecimalSetExponent(result, newExponent);
    if (err != NSCalculationNoError)
    {
        NSDecimalSetNotANumber(result);
        return err;
    }

    unsigned short length = NSDecimalMaxSize;
    NSIntegerCopy(result->_mantissa, &length, product, productLength);
    result->_length = productLength;

    NSDecimalRecompact(result);

    return NSCalculationNoError;
}

NSCalculationError NSDecimalDivide(NSDecimal *result, const NSDecimal *left, const NSDecimal *right, NSRoundingMode roundingMode)
{
    if (NSDecimalIsNotANumber(left) || NSDecimalIsNotANumber(right))
    {
        NSDecimalSetNotANumber(result);
        return NSCalculationOverflow;
    }

    if (NSDecimalIsZero(right))
    {
        return NSCalculationDivideByZero;
    }

    if (NSDecimalIsZero(left))
    {
        NSDecimalSetZero(result);
        return NSCalculationNoError;
    }

#warning TODO: NSDecimalDivide using lossy float implementation that is no better that normal float division
    NSDecimalNumber *leftNumber = [NSDecimalNumber decimalNumberWithDecimal:*left];
    NSDecimalNumber *rightNumber = [NSDecimalNumber decimalNumberWithDecimal:*right];

    // FIXME: Complete this partially fixed-point, partially floating-point implementation.
    // TRICKY: Fixed point only for dividing by powers of 10.

    BOOL isRightPowerOfTen = NO;
    if (right->_mantissa[0] == 1)
    {
        isRightPowerOfTen = YES; // Tentative, confirm below
        
        for (int mi = 1; mi < right->_length; ++mi)
        {
            if (right->_mantissa[mi] != 0)
            {
                isRightPowerOfTen = NO;
                break;
            }
        }
    }
    
    if (isRightPowerOfTen)
    {
        NSDecimal resultDecimal = {0};
        
        // Divide by the power-of-ten exponent
        NSCalculationError err = NSDecimalMultiplyByPowerOf10(&resultDecimal, left, -1 * right->_exponent, roundingMode);

        NSDecimalCopy(result, &resultDecimal);
        
        return err;
    }
    else
    {
        double leftDouble = leftNumber.doubleValue;
        double rightDouble = rightNumber.doubleValue;

        if (0.0 == rightDouble)
        {
            return NSCalculationDivideByZero;
        }

        double resultDouble = leftDouble / rightDouble;

        // check NaN
        if (resultDouble != resultDouble)
        {
            NSDecimalSetNotANumber(result);
            return NSCalculationOverflow;
        }

        NSDecimalNumber *resultNumber = [[NSDecimalNumber alloc] initWithDouble:resultDouble];
        NSDecimal resultDecimal = resultNumber.decimalValue;
        NSDecimalCopy(result, &resultDecimal);

        [resultNumber release];

        return  NSCalculationNoError;
    }
}

NSCalculationError NSDecimalPower(NSDecimal *result, const NSDecimal *number, NSUInteger power, NSRoundingMode roundingMode)
{
    static const NSDecimal one = {
        ._length = 1,
        ._isCompact = 1,
        ._mantissa[0] = 1,
    };

    if (NSDecimalIsNotANumber(number))
    {
        NSDecimalSetNotANumber(result);
        return NSCalculationOverflow;
    }

    NSDecimal squaring;
    NSDecimalCopy(&squaring, number);
    NSDecimalCopy(result, &one);

    NSCalculationError err;

    while (power > 0)
    {
        if ((power & 1) != 0)
        {
            err = NSDecimalMultiply(result, result, &squaring, roundingMode);
            if (err)
            {
                NSDecimalSetNotANumber(result);
                return err;
            }
        }
        err = NSDecimalMultiply(&squaring, &squaring, &squaring, roundingMode);
        if (err)
        {
            NSDecimalSetNotANumber(result);
            return err;
        }
        power >>= 1;
    }

    NSDecimalRecompact(result);

    return NSCalculationNoError;
}

NSCalculationError NSDecimalMultiplyByPowerOf10(NSDecimal *result, const NSDecimal *number, short power, NSRoundingMode roundingMode)
{
    // Note that this function will only modify _exponent. It makes no
    // attempt to change the mantissa if the new exponent does not fit
    // in 8 bits. We therefore do not have to call NSDecimalCompact at
    // the end of the function.

    if (NSDecimalIsNotANumber(number))
    {
        NSDecimalSetNotANumber(result);
        return NSCalculationOverflow;
    }

    if (NSDecimalIsZero(number))
    {
        NSDecimalSetZero(result);
        return NSCalculationNoError;
    }

    if (result != number)
    {
        NSDecimalCopy(result, number);
    }

    int newExponent = number->_exponent + power;
    return NSDecimalSetExponent(result, newExponent);
}

NSString *NSDecimalString(const NSDecimal *dcm, id locale)
{
    if (NSDecimalIsNotANumber(dcm))
    {
        return @"NaN";
    }
    
#warning NSDecimalString using lossy unsigned long long version is no better than primitive number stringizing
    unsigned long long resultNum = 0ULL;
    
    for (int i = 0; i < MAX(dcm->_length, sizeof(unsigned long long) / sizeof(short)); i++)
    {
        // stamp successive unsigned shorts into place inside result
        resultNum |= (unsigned long long)dcm->_mantissa[i] << (i * 16);
    }
    
    NSString *sign = dcm->_isNegative ? @"-" : @"";
    
    NSString *decimalString = [NSString stringWithFormat:@"%llu",resultNum];
    
    if (dcm->_exponent > 0)
    {
        NSUInteger padLength = [decimalString length] + dcm->_exponent;
        
        decimalString = [decimalString stringByPaddingToLength:padLength withString:@"0" startingAtIndex:0];
    }
    else if (dcm->_exponent < 0)
    {
        NSString *left = nil;
        NSUInteger leftLength = [decimalString length] + dcm->_exponent;
        if (leftLength == 0)
        {
            left = @"0"; // As in "0.123"
        }
        else
        {
            left = [decimalString substringToIndex:leftLength];
        }
        
        NSString *right = [decimalString substringFromIndex:leftLength];
        
        NSString *separator = [locale objectForKey:NSLocaleDecimalSeparator] ?: @".";
        
        decimalString = [NSString stringWithFormat:@"%@%@%@", left, separator, right];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@",
                        sign,
                        decimalString];
    
    return result;
}
