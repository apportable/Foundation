/* Definition of class NSNumberFormatter
   Copyright (C) 1999 Free Software Foundation, Inc.

   Written by:  Fred Kiefer <FredKiefer@gmx.de>
   Date:        July 2000
   Updated by: Richard Frith-Macdonald <rfm@gnu.org> Sept 2001

   This file is part of the GNUstep Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
 */

#ifndef _NSNumberFormatter_h_GNUSTEP_BASE_INCLUDE
#define _NSNumberFormatter_h_GNUSTEP_BASE_INCLUDE
#import <GNUstepBase/GSVersionMacros.h>

#if OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)

#import <Foundation/NSObject.h>
#import <Foundation/NSFormatter.h>
#import <Foundation/NSDecimalNumber.h>

#if defined(__cplusplus)
extern "C" {
#endif

@class NSString, NSAttributedString, NSDictionary;

// TODO(jackson) Implement number formatting. For now, just forward declare the
// formatting options
enum {
    NSNumberFormatterNoStyle,
    NSNumberFormatterDecimalStyle,
    NSNumberFormatterCurrencyStyle,
    NSNumberFormatterPercentStyle,
    NSNumberFormatterScientificStyle,
    NSNumberFormatterSpellOutStyle
};
typedef NSUInteger NSNumberFormatterStyle;

enum {
    NSNumberFormatterBehaviorDefault = 0,
    NSNumberFormatterBehavior10_0 = 1000,
    NSNumberFormatterBehavior10_4 = 1040,
};
typedef NSUInteger NSNumberFormatterBehavior;

/**
 * <p><em><strong>This class is currently not implemented in GNUstep!  All set
 * methods will work, but stringForObject: will ignore the format completely.
 * The documentation below describes what the behavior SHOULD
 * be...</strong></em></p>
 *
 * <p>A specialization of the [NSFormatter] class for generating string
 * representations of numbers ([NSNumber] and [NSDecimalNumber] instances) and
 * for parsing numeric values in strings.</p>
 *
 *  <p>See the [NSFormatter] documentation for description of the basic methods
 *  for formatting and parsing that are available.</p>
 *
 * <p>There are no convenience initializers or constructors for this class.
 *  Instead, to obtain an instance, call alloc init and then -setFormat: .</p>
 *
 *  <p>The basic format of a format string uses "#" signs to represent digits,
 *  and other characters to represent themselves, in a context-dependent way.
 *  Thus, for example, <code>@"#,###.00"</code> means to print the number
 *  ending in .00 if it has no decimal part, otherwise print two decimal
 *  places, and to print one comma if it is greater than 1000.  Thus, 1000
 *  prints as "1,000.00", and 1444555.979 prints as "1444,555.98" (see
 *  -setRoundingBehavior:).</p>
 *
 * <p>After setting the format, you may change the thousands separator and
 * decimal point using set methods, or by calling -setLocalizesFormat: .</p>
 *
 * <p>You may set separate formats to be used for positive numbers, negative
 * numbers, and zero independently.</p>
 *
 * <p>In addition, this class supports attributed strings (see
 * [NSAttributedString]), so that you can specify font and color attributes,
 * among others, to display aspects of a number.  You can assign specific sets
 * of attributes for positive and negative numbers, and for specific cases
 * including 0, NaN, and nil... </p>
 */
@interface NSNumberFormatter : NSFormatter
{
#if GS_EXPOSE(NSNumberFormatter)
    @private
    BOOL _hasThousandSeparators;
    BOOL _allowsFloats;
    BOOL _localizesFormat;
    BOOL _alwaysShowDecimalSeparator;
    unichar _thousandSeparator;
    unichar _decimalSeparator;
    NSDecimalNumberHandler *_roundingBehavior;
    NSDecimalNumber *_maximum;
    NSDecimalNumber *_minimum;
    NSAttributedString *_attributedStringForNil;
    NSAttributedString *_attributedStringForNotANumber;
    NSAttributedString *_attributedStringForZero;
    NSString *_negativeFormat;
    NSString *_positiveFormat;
    NSDictionary *_attributesForPositiveValues;
    NSDictionary *_attributesForNegativeValues;
#endif
#if !GS_NONFRAGILE
    void      *_unused;
#endif
}

- (NSNumberFormatterStyle)numberStyle;
- (void)setNumberStyle:(NSNumberFormatterStyle)style;

// Format
/**
 * Returns the format string this instance was initialized with.
 */
- (NSString*)format;

/**
 * Sets format string.  See class description for more information.
 */
- (void)setFormat:(NSString*)aFormat;

/**
 * Returns whether this format should defer to the locale in determining
 * thousands separator and decimal point.  The default is to NOT localize.
 */
- (BOOL)localizesFormat;

/**
 * Set whether this format should defer to the locale in determining thousands
 * separator and decimal point.  The default is to NOT localize.
 */
- (void)setLocalizesFormat:(BOOL)flag;

/**
 * Set the local.
 */
- (void)setLocale:(NSLocale*)locale;

/**
 * Returns format used for negative numbers.
 */
- (NSString*)negativeFormat;

/**
 * Sets format used for negative numbers.  See class description for more
 * information.
 */
- (void)setNegativeFormat:(NSString*)aFormat;

/**
 * Returns format used for positive numbers.
 */
- (NSString*)positiveFormat;

/**
 * Sets format used for positive numbers.  See class description for more
 * information.
 */
- (void)setPositiveFormat:(NSString*)aFormat;


// Attributed Strings
/**
 *  Returns the exact attributed string used for nil values.  By default this
 *  is an empty string.
 */
- (NSAttributedString*)attributedStringForNil;

/**
 *  Sets the exact attributed string used for nil values.  By default this
 *  is an empty string.
 */
- (void)setAttributedStringForNil:(NSAttributedString*)newAttributedString;

/**
 *  Returns the exact attributed string used for NaN values.  By default this
 *  is the string "NaN" with no attributes.
 */
- (NSAttributedString*)attributedStringForNotANumber;

/**
 *  Sets the exact attributed string used for NaN values.  By default this
 *  is the string "NaN" with no attributes.
 */
- (void)setAttributedStringForNotANumber:(NSAttributedString*)newAttributedString;

/**
 *  Returns the exact attributed string used for zero values.  By default this
 *  is based on the format for zero values, if set, or the format for positive
 *  values otherwise.
 */
- (NSAttributedString*)attributedStringForZero;

/**
 *  Sets the exact attributed string used for zero values.  By default this
 *  is based on the format for zero values, if set, or the format for positive
 *  values otherwise.
 */
- (void)setAttributedStringForZero:(NSAttributedString*)newAttributedString;

/**
 * Returns the attributes to apply to negative values (whole string), when
 * -attributedStringForObjectValue:withDefaultAttributes: is called.  Default
 * is none.
 */
- (NSDictionary*)textAttributesForNegativeValues;

/**
 * Sets the attributes to apply to negative values (whole string), when
 * -attributedStringForObjectValue:withDefaultAttributes: is called.  Default
 * is none.
 */
- (void)setTextAttributesForNegativeValues:(NSDictionary*)newAttributes;

/**
 * Returns the attributes to apply to positive values (whole string), when
 * -attributedStringForObjectValue:withDefaultAttributes: is called.  Default
 * is none.
 */
- (NSDictionary*)textAttributesForPositiveValues;

/**
 * Sets the attributes to apply to positive values (whole string), when
 * -attributedStringForObjectValue:withDefaultAttributes: is called.  Default
 * is none.
 */
- (void)setTextAttributesForPositiveValues:(NSDictionary*)newAttributes;


// Rounding.. this should be communicated as id<NSDecimalNumberBehaviors>,
// not NSDecimalNumberHandler, but this is the way OpenStep and OS X do it..

/**
 * Returns object specifying the rounding behavior used when truncating
 * decimal digits in formats.  Default is
 * [NSDecimalNumberHandler+defaultDecimalNumberHandler].
 */
- (NSDecimalNumberHandler*)roundingBehavior;

/**
 * Sets object specifying the rounding behavior used when truncating
 * decimal digits in formats.  Default is
 * [NSDecimalNumberHandler+defaultDecimalNumberHandler].
 */
- (void)setRoundingBehavior:(NSDecimalNumberHandler*)newRoundingBehavior;

// Separators

/**
 * Returns whether thousands separator should be used, regardless of whether
 * it is set in format.  (Default is YES if explicitly set in format.)
 */
- (BOOL)hasThousandSeparators;

/**
 * Sets whether thousands separator should be used, regardless of whether
 * it is set in format.  (Default is YES if explicitly set in format.)
 */
- (void)setHasThousandSeparators:(BOOL)flag;


/**
 * Returns thousands separator used; default is ','.
 */
- (NSString*)thousandSeparator;

/**
 * Sets thousands separator used; default is ','.
 */
- (void)setThousandSeparator:(NSString*)newSeparator;

/**
 * Returns whether number parsing will accept floating point values or generate
 * an exception (only int values are valid).  Default is YES.
 */
- (BOOL)allowsFloats;

/**
 * Sets whether number parsing will accept floating point values or generate
 * an exception (only int values are valid).  Default is YES.
 */
- (void)setAllowsFloats:(BOOL)flag;

/**
 * Returns thousands separator used; default is '.'.
 */
- (NSString*)decimalSeparator;

/**
 * Sets thousands separator used; default is '.'.
 */
- (void)setDecimalSeparator:(NSString*)newSeparator;

// Maximum/minimum

/**
 * Returns maximum value that will be accepted as valid in number parsing.
 * Default is none.
 */
- (NSDecimalNumber*)maximum;

/**
 * Sets maximum value that will be accepted as valid in number parsing.
 * Default is none.
 */
- (void)setMaximum:(NSDecimalNumber*)aMaximum;

/**
 * Returns minimum value that will be accepted as valid in number parsing.
 * Default is none.
 */
- (NSDecimalNumber*)minimum;

/**
 * Sets minimum value that will be accepted as valid in number parsing.
 * Default is none.
 */
- (void)setMinimum:(NSDecimalNumber*)aMinimum;

/**
 * Returns the string version of this number based on the format
 * specified.
 */
- (NSString *)stringFromNumber:(NSNumber *)number;

/**
 * Returns the number for this string.
 */
- (NSNumber *)numberFromString:(NSString *)string;

- (NSNumberFormatterBehavior)formatterBehavior;

- (void)setFormatterBehavior:(NSNumberFormatterBehavior)behavior;

- (NSUInteger)minimumIntegerDigits;
- (void)setMinimumIntegerDigits:(NSUInteger)number;

- (NSUInteger)maximumIntegerDigits;
- (void)setMaximumIntegerDigits:(NSUInteger)number;

- (NSUInteger)minimumFractionDigits;
- (void)setMinimumFractionDigits:(NSUInteger)number;

- (NSUInteger)maximumFractionDigits;
- (void)setMaximumFractionDigits:(NSUInteger)number;

- (NSString *)positivePrefix;
- (void)setPositivePrefix:(NSString *)string;

- (NSString *)positiveSuffix;
- (void)setPositiveSuffix:(NSString *)string;

- (NSString *)negativePrefix;
- (void)setNegativePrefix:(NSString *)string;

- (NSString *)negativeSuffix;
- (void)setNegativeSuffix:(NSString *)string;

- (BOOL)alwaysShowsDecimalSeparator;
- (void)setAlwaysShowsDecimalSeparator:(BOOL)flag;

- (BOOL)usesGroupingSeparator;
- (void)setUsesGroupingSeparator:(BOOL)b;

- (NSString *)groupingSeparator;
- (void)setGroupingSeparator:(NSString *)string;

/* Configuring Numeric Symbols */

- (void)setPercentSymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)percentSymbol NS_UNIMPLEMENTED;

- (void)setPerMillSymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)perMillSymbol NS_UNIMPLEMENTED;

- (void)setMinusSign:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)minusSign NS_UNIMPLEMENTED;

- (void)setPlusSign:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)plusSign NS_UNIMPLEMENTED;

- (void)setExponentSymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)exponentSymbol NS_UNIMPLEMENTED;

- (void)setZeroSymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)zeroSymbol NS_UNIMPLEMENTED;

- (void)setNilSymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)nilSymbol NS_UNIMPLEMENTED;

- (void)setNotANumberSymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)notANumberSymbol NS_UNIMPLEMENTED;

- (void)setNegativeInfinitySymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)negativeInfinitySymbol NS_UNIMPLEMENTED;

- (void)setPositiveInfinitySymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)positiveInfinitySymbol NS_UNIMPLEMENTED;

/* Configuring the Format of Currency */

- (void)setCurrencySymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)currencySymbol NS_UNIMPLEMENTED;

- (void)setCurrencyCode:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)currencyCode NS_UNIMPLEMENTED;

- (void)setInternationalCurrencySymbol:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)internationalCurrencySymbol NS_UNIMPLEMENTED;

- (void)setCurrencyGroupingSeparator:(NSString *)string NS_UNIMPLEMENTED;
- (NSString *)currencyGroupingSeparator NS_UNIMPLEMENTED;

+ (NSString *)localizedStringFromNumber:(NSNumber *)num numberStyle:(NSNumberFormatterStyle)nstyle NS_UNIMPLEMENTED;

@end

#if defined(__cplusplus)
}
#endif

#endif  /* GS_API_MACOSX */

#endif  /* _NSNumberFormatter_h_GNUSTEP_BASE_INCLUDE */

