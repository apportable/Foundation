//
//  NSScanner.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSScanner.h>
#import "NSConcreteScanner.h"
#import <Foundation/NSLocale.h>
#import "NSObjectInternal.h"
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDecimal.h>
#import <Foundation/NSDecimalNumber.h>

@interface NSScanner(Private)
- (id)_invertedSkipSet;
- (BOOL)_scanDecimal:(unsigned int)decimal into:(int *)addr;
- (id)_remainingString;
@end

@implementation NSScanner

static inline NSUInteger skipLeading(unichar** ptrRef, NSUInteger length, NSCharacterSet* skipSet)
{
    NSUInteger i = 0;
    if (skipSet)
    {
        unichar* ptr = *ptrRef;
        for (; i < length && [skipSet characterIsMember:*ptr]; i++, ptr++) { }
        *ptrRef = ptr;
    }
    return i;
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSScanner class]) {
        return [NSConcreteScanner allocWithZone:zone];
    }
    return [super allocWithZone:zone];
}

+ (id)scannerWithString:(NSString *)string
{
    return [[[NSConcreteScanner alloc] initWithString:string] autorelease];
}

+ (id)localizedScannerWithString:(NSString *)string
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
    [scanner setLocale:[NSLocale currentLocale]];
    return [scanner autorelease];
}

- (id)initWithString:(NSString *)string
{
    return [super init];
}

- (NSString *)string
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSUInteger)scanLocation
{
    NSRequestConcreteImplementation();
    return 0;
}

- (void)setScanLocation:(NSUInteger)pos
{
    NSRequestConcreteImplementation();
}

- (void)setCharactersToBeSkipped:(NSCharacterSet *)set
{
    NSRequestConcreteImplementation();
}

- (void)setCaseSensitive:(BOOL)flag
{
    NSRequestConcreteImplementation();
}

- (void)setLocale:(id)locale
{
    NSRequestConcreteImplementation();
}

- (NSCharacterSet *)charactersToBeSkipped
{
    static NSCharacterSet *defaultSkipSet = nil;
    if (defaultSkipSet == nil)
    {
        defaultSkipSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
    }
    return defaultSkipSet;
}

- (BOOL)caseSensitive
{
    return NO;
}

- (id)locale
{
    return nil;
}

- (BOOL)scanInteger:(NSInteger *)value
{
    if (sizeof(NSInteger) != sizeof(int))
    {
        DEBUG_BREAK(); // unimplemented
    }
    return [self scanInt:value];
}

- (BOOL)scanHexInt:(unsigned *)value
{
    NSString *scanString = [self string];
    NSUInteger scanLocation = [self scanLocation];
    NSUInteger length = [scanString length] - scanLocation;
    if (length == 0)
    {
        return NO;
    }
    unichar *buf = malloc((length+1) * sizeof(unichar));
    buf[length] = (unichar)0x0;
    unichar *ptr = buf;
    [scanString getCharacters:ptr range:NSMakeRange(scanLocation, length)];

    NSUInteger i = skipLeading(&ptr, length, [self charactersToBeSkipped]);
    if (i == length)
    {
        free(buf);
        return NO;
    }

    if (*ptr == '0' && i < length - 1 && (ptr[1] == 'x' || ptr[1] == 'X'))
    {
        ptr += 2;
        i += 2;
    }
    if (i == length)
    {
        free(buf);
        return NO;
    }

    long long counter = 0;
    BOOL foundInt = NO;
    BOOL overflow = NO;
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];

    for (; *ptr; ptr++)
    {
        int increment;
        if ([digits characterIsMember:*ptr])
        {
            increment = *ptr - '0';
        }
        else if (*ptr >= 'A' && *ptr <= 'F')
        {
            increment = *ptr - 'A' + 10;
        }
        else if (*ptr >= 'a' && *ptr <= 'f')
        {
            increment = *ptr - 'a' + 10;
        }
        else
        {
            break;
        }
        foundInt = YES;
        counter = counter * 16 + increment;
        if (counter > (long long)UINT_MAX)
        {
            overflow = YES;
        }
    }
    if (foundInt)
    {
        [self setScanLocation:scanLocation+(ptr - buf)];
        if (value)
        {
            *value = overflow ? UINT_MAX : (int)counter;
        }
    }
    free(buf);
    return foundInt;
}

- (BOOL)scanHexLongLong:(unsigned long long *)value
{
    NSString *scanString = [self string];
    NSUInteger scanLocation = [self scanLocation];
    NSUInteger length = [scanString length] - scanLocation;
    if (length == 0)
    {
        return NO;
    }
    unichar *buf = malloc((length+1) * sizeof(unichar));
    buf[length] = (unichar)0x0;
    unichar *ptr = buf;
    [scanString getCharacters:ptr range:NSMakeRange(scanLocation, length)];

    NSUInteger i = skipLeading(&ptr, length, [self charactersToBeSkipped]);
    if (i == length)
    {
        free(buf);
        return NO;
    }

    if (*ptr == '0' && i < length - 1 && (ptr[1] == 'x' || ptr[1] == 'X'))
    {
        ptr += 2;
        i += 2;
    }
    if (i == length)
    {
        free(buf);
        return NO;
    }

    unsigned long long counter = 0;
    BOOL foundInt = NO;
    BOOL overflow = NO;
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];

    for (; *ptr; ptr++)
    {
        int increment;
        if ([digits characterIsMember:*ptr])
        {
            increment = *ptr - '0';
        }
        else if (*ptr >= 'A' && *ptr <= 'F')
        {
            increment = *ptr - 'A' + 10;
        }
        else if (*ptr >= 'a' && *ptr <= 'f')
        {
            increment = *ptr - 'a' + 10;
        }
        else
        {
            break;
        }
        foundInt = YES;

        if (counter > ULONG_LONG_MAX / 16 ||
            (counter == ULONG_LONG_MAX / 16 && increment > ULONG_LONG_MAX % 16))
        {
            overflow = YES;
        }
        counter = counter * 16 + increment;
    }
    if (foundInt)
    {
        [self setScanLocation:scanLocation+(ptr - buf)];
        if (value)
        {
            *value = overflow ? ULONG_LONG_MAX : counter;
        }
    }
    free(buf);
    return foundInt;
}

static inline NSUInteger skipSkipSet(NSScanner *self, NSString *s)
{
    NSUInteger strLength = [s length];
    NSCharacterSet* inverted = [self _invertedSkipSet];
    if (!inverted)
    {
        return strLength;
    }
    NSUInteger location = [self scanLocation];
    NSUInteger length = strLength - location;
    NSRange skipRange = [s rangeOfCharacterFromSet:inverted options:0 range:NSMakeRange(location, length)];
    return skipRange.location == NSNotFound ? strLength : skipRange.location;
}

- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value
{
    NSString *s = [self string];
    NSUInteger location = skipSkipSet(self, s);
    NSUInteger length = [[self string] length] - location;
    if (length == 0)
    {
        return NO;
    }
    NSRange foundRange = [s rangeOfCharacterFromSet:set options:([self caseSensitive] ? 0 : NSCaseInsensitiveSearch)
        range:NSMakeRange(location, length)];
    if (foundRange.location == location)
    {
        return NO;
    }

    NSUInteger newLocation = foundRange.location == NSNotFound ? (location + length) : foundRange.location;
    if (value)
    {
        *value = [s substringWithRange:NSMakeRange(location, newLocation - location)];
    }
    [self setScanLocation:newLocation];
    return YES;
}

- (BOOL)scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value
{
    NSString *s = [self string];
    NSUInteger location = skipSkipSet(self, s);
    NSUInteger length = [[self string] length] - location;
    if (length == 0)
    {
        return NO;
    }
    NSRange foundRange = [s rangeOfCharacterFromSet:[set invertedSet] options:([self caseSensitive] ? 0 : NSCaseInsensitiveSearch)
        range:NSMakeRange(location, length)];
    if (foundRange.location == location)
    {
        return NO;
    }

    NSUInteger newLocation = foundRange.location == NSNotFound ? (location + length) : foundRange.location;
    if (value)
    {
        *value = [s substringWithRange:NSMakeRange(location, newLocation - location)];
    }
    [self setScanLocation:newLocation];
    return YES;
}

- (BOOL)scanUpToString:(NSString *)string intoString:(NSString **)value
{
    NSString *s = [self string];
    NSUInteger location = skipSkipSet(self, s);
    NSUInteger length = [[self string] length] - location;
    if (length == 0)
    {
        return NO;
    }
    NSRange foundRange = [s rangeOfString:string options:([self caseSensitive] ? 0 : NSCaseInsensitiveSearch)
        range:NSMakeRange(location, length)];

    if (foundRange.location == location)
    {
        return NO;
    }
    NSUInteger newLocation = foundRange.location == NSNotFound ? (location + length) : foundRange.location;
    if (value)
    {
        *value = [s substringWithRange:NSMakeRange(location, newLocation - location)];
    }
    [self setScanLocation:newLocation];
    return YES;
}

- (BOOL)scanString:(NSString *)string intoString:(NSString **)value
{
    NSString *s = [self string];
    NSUInteger location = skipSkipSet(self, s);
    NSUInteger length = [[self string] length] - location;
    if (length == 0)
    {
        return NO;
    }
    NSRange foundRange = [s rangeOfString:string options:(([self caseSensitive] ? 0 : NSCaseInsensitiveSearch) | NSAnchoredSearch)
        range:NSMakeRange(location, length)];

    if (foundRange.location != location)
    {
        return NO;
    }
    NSUInteger newLocation = foundRange.location + foundRange.length;
    if (value)
    {
        *value = [s substringWithRange:NSMakeRange(location, newLocation - location)];
    }
    [self setScanLocation:newLocation];
    return YES;
}

- (BOOL)isAtEnd
{
    NSString *s = [self string];
    NSUInteger length = [s length];
    return [self scanLocation] == length || skipSkipSet(self, s) == length;
}

@end

@implementation NSScanner (NSDecimalNumberScanning)

- (BOOL)scanDecimal:(NSDecimal *)dcm
{
    NSString *s = [self string];
    NSUInteger location = skipSkipSet(self, s);
    NSUInteger length = [[self string] length] - location;
    if (length == 0)
    {
        return NO;
    }
    NSLocale *locale = [self locale];
    NSString *separator = [locale objectForKey:NSLocaleDecimalSeparator] ?: @".";
    if ([separator length] > 1)
    {
        RELEASE_LOG("Unimplemented decimal separator length > 1");
        DEBUG_BREAK(); // TODO - handle bigger separators
    }
    unichar sepChar = [separator characterAtIndex:0];

    unichar *buf = malloc((length+1) * sizeof(unichar) );
    buf[length] = (unichar)0x0;
    unichar *ptr = buf;
    [s getCharacters:ptr range:NSMakeRange(location, length)];

    const int MIN_EXPONENT = -128;
    const int MAX_EXPONENT = 127;
    BOOL sawValue = NO;
    BOOL isNegative;
    if (*ptr == '-')
    {
        isNegative = YES;
        ptr++;
    }
    else
    {
        if (*ptr == '+')
        {
            ptr++;
            // FIXME: Single '+' is not a value in and of itself, but multiple +'s are. Go figure.
        }
        isNegative = NO;
    }
    BOOL sawDecimal = NO;
    BOOL valueIsNonZero = NO;
    
    int exponent = 0; // Both location of decimal separator, and explicit 'e'
    int valueDigitsScanned = 0;
    int totalDigitsScanned = 0;
    int exponentDigitsScanned = 0;
    
    // Go through the entire string in a first pass
    // to get the real start and end, as well as the
    // exponent. A second pass actually loads the mantissa.
    for (;*ptr != '\0'; ptr++)
    {
        if (*ptr == sepChar)
        {
            if (sawDecimal)
            {
                break; // Two decimal separators
            }
            sawDecimal = YES;
            totalDigitsScanned++;
            continue;
        }
        
        if (*ptr < '0' || *ptr > '9')
        {
            // Sub-scan: Scan for an explicit exponent
            if (*ptr == 'e' || *ptr == 'E')
            {
                ptr++;
                exponentDigitsScanned++;
                
                int explicitExponent = 0;
                int explicitExponentSign = +1;
                BOOL sawExponentSign = NO;
                BOOL sawExponentValue = NO;
                
                for (;*ptr != '\0'; ptr++)
                {
                    exponentDigitsScanned++;
                    
                    // Collect exponent sign
                    if (*ptr == '+' || *ptr == '-')
                    {
                        if (sawExponentSign || sawExponentValue)
                        {
                            break;
                        }
                        sawExponentSign = YES;
                        
                        if (*ptr == '-' )
                        {
                            explicitExponentSign = -1;
                        }
                    }
                    else if (*ptr >= '0' || *ptr <= '9')
                    {
                        sawExponentValue = YES;
                        // Collect exponent magnitude
                        unichar cDigit = *ptr;
                        explicitExponent *= 10;
                        explicitExponent += (cDigit - '0');
                    }
                    else
                    {
                        break; // Unrecognized character
                    }
                    
                    // Check for overflow
                    int tmpExponent = explicitExponentSign * explicitExponent + exponent;
                    if (tmpExponent < MIN_EXPONENT || tmpExponent > MAX_EXPONENT)
                    {
                        // FIXME exponent overflow should produce NaN
                        break;
                    }
                }
                
                exponent += explicitExponentSign * explicitExponent;
            }
            
            break; // Unrecognized character, or exponent parsed
        }
        else
        {
            
            if (exponent <= MIN_EXPONENT)
            {
                totalDigitsScanned++;
                continue; // Scan but don't store any subsequent digits. Reached maximum precision.
            }
            
            sawValue = YES;
            valueDigitsScanned++;
            totalDigitsScanned++;
            
            if (*ptr - '0')
            {
                valueIsNonZero = YES;
            }
            
            // if we saw the decimal point, track the exponent that the
            // value will have.
            if (sawDecimal)
            {
                exponent--;
            }
        }
    }
    
    if (sawValue)
    {
        [self setScanLocation:location + (ptr - buf)];
        if (dcm)
        {
            NSDecimal tempDcm = {0};
            *dcm = tempDcm;
            int secondValueDigitsScanned = 0;
            dcm->_length = 0;
            // tempDcm will only have a value in the first
            // short of the mantissa, and only added if
            // non zero.
            tempDcm._length = 1;
            
            // restore ptr to the start of the number
            ptr = ptr - totalDigitsScanned - exponentDigitsScanned;
            
            for (int i = 0; i < totalDigitsScanned; i++)
            {
                unichar cDigit = ptr[i];
                if (cDigit == sepChar)
                {
                    continue;
                }
                
                // read in and append the digit to value
                tempDcm._mantissa[0] = (cDigit - '0');
                // store the 10's digit place - should be zero at the rightmost value
                tempDcm._exponent = valueDigitsScanned - (secondValueDigitsScanned + 1);
                secondValueDigitsScanned++;
                
                if (tempDcm._mantissa[0])
                {
                    NSDecimalAdd(dcm, dcm, &tempDcm, NSRoundPlain);
                }
            }
            // adjust for the decimal place as scanned
            // on the first pass.
            dcm->_exponent += exponent;
            dcm->_isNegative = (valueIsNonZero && isNegative);
        }
    }
    
    free(buf);
    return sawValue;
}
@end

@implementation NSConcreteScanner

- (void)dealloc
{
    [locale release];
    [scanString release];
    [skipSet release];
    [invertedSkipSet release];
    [super dealloc];
}

- (BOOL)scanLongLong:(long long *)value
{
    NSUInteger length = [scanString length] - scanLocation;
    if (length == 0)
    {
        return NO;
    }
    unichar *buf = malloc((length+1) * sizeof(unichar));
    buf[length] = (unichar)0x0;
    unichar *ptr = buf;
    [scanString getCharacters:ptr range:NSMakeRange(scanLocation, length)];

    length -= skipLeading(&ptr, length, skipSet);
    if (length == 0)
    {
        free(buf);
        return NO;
    }

    BOOL isNegative;
    if (*ptr == '-') {
        isNegative = YES;
        ptr++;
    }
    else
    {
        isNegative = NO;
    }
    long long counter = 0;
    BOOL foundInt = NO;
    BOOL overflow = NO;

    while (*ptr >= '0' && *ptr <= '9')
    {
        if (!overflow)
        {
            foundInt = YES;
            int increment = *ptr - '0';
            if (counter > LONG_LONG_MAX / 10 ||
                (counter == LONG_LONG_MAX / 10 && increment > LONG_LONG_MAX % 10))
            {
                overflow = YES;
            }
            counter = counter * 10 + increment;
        }
        ptr++;
    }
    if (foundInt)
    {
        scanLocation += (ptr - buf);
        if (value)
        {
            if (overflow)
            {
                *value = isNegative ? LONG_LONG_MIN : LONG_LONG_MAX;
            }
            else
            {
                *value = isNegative ? -counter : counter;
            }
        }
    }
    free(buf);
    return foundInt;
}

- (BOOL)scanInt:(int *)value
{
    NSUInteger length = [scanString length] - scanLocation;
    if (length == 0)
    {
        return NO;
    }
    unichar *buf = malloc((length+1) * sizeof(unichar));
    buf[length] = (unichar)0x0;
    unichar *ptr = buf;
    [scanString getCharacters:ptr range:NSMakeRange(scanLocation, length)];

    length -= skipLeading(&ptr, length, skipSet);
    if (length == 0)
    {
        free(buf);
        return NO;
    }

    BOOL isNegative;
    if (*ptr == '-') {
        isNegative = YES;
        ptr++;
    }
    else
    {
        isNegative = NO;
    }
    long long counter = 0;
    BOOL foundInt = NO;
    BOOL overflow = NO;
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    while ([digits characterIsMember:*ptr])
    {
        foundInt = YES;
        counter = counter * 10 + *ptr - '0';
        ptr++;
        if (counter > (long long)INT_MAX)
        {
            overflow = YES;
        }
    }
    if (foundInt)
    {
        scanLocation += (ptr - buf);
        if (value)
        {
            if (overflow)
            {
                *value = isNegative ? INT_MIN : INT_MAX;
            }
            else
            {
                *value = (int)(isNegative ? -counter : counter);
            }
        }
    }
    free(buf);
    return foundInt;
}

- (BOOL)scanDouble:(double *)value
{
#warning TODO : implement non-naive IEEE 754 implementation -- Issue #301
    NSDecimal decimal = { 0 };
    BOOL scanned = [self scanDecimal:&decimal];
    if (scanned && value)
    {
        NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal];
        *value = [number doubleValue];
        [number release];
    }
    return scanned;
}

- (BOOL)scanFloat:(float *)value
{
    double d = 0.0;
    BOOL scanned = [self scanDouble:&d];
    if (scanned && value)
    {
        *value = (float)d;
    }
    return scanned;
}

- (id)locale
{
    return locale;
}

- (void)setLocale:(id)loc
{
    // TODO: Check if locale is just retained or copied
    if (locale != loc)
    {
        loc = [loc retain];
        [locale release];
        locale = loc;
    }
}

- (BOOL)caseSensitive
{
    return flags.caseSensitive;
}

- (void)setCaseSensitive:(BOOL)flag
{
    flags.caseSensitive = flag;
}

- (NSCharacterSet *)charactersToBeSkipped
{
    return skipSet;
}

- (void)setCharactersToBeSkipped:(NSCharacterSet *)set
{
    if (![skipSet isEqual:set])
    {
        [skipSet release];
        skipSet = [set copy];
        [invertedSkipSet release];
        invertedSkipSet = nil;
    }
}

- (NSUInteger)scanLocation
{
    return scanLocation;
}

- (void)setScanLocation:(NSUInteger)pos
{
    if (pos > [[self string] length])
    {
        [NSException raise:NSRangeException format:@"Cannot set ScanLocation (%d) beyond NSScanner string length (%d)", pos, [[self string] length]];
        return;
    }
    scanLocation = pos;
}

- (NSCharacterSet *)_invertedSkipSet
{
    if (!invertedSkipSet)
    {
        invertedSkipSet = [[skipSet invertedSet] retain];
    }
    return invertedSkipSet;
}

- (NSString *)string
{
    return scanString;
}

- (id)initWithString:(NSString *)string
{
    if (string == nil)
    {
        NSLog(@"NSScanner: nil string argument");
        string = @"";
    }
    self = [super init];
    if (self)
    {
        static NSCharacterSet *singletonSaveSkipSet = nil;
        scanLocation = 0;
        scanString = [string copy];
        if (!singletonSaveSkipSet)
        {
            singletonSaveSkipSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
        }
        skipSet = [singletonSaveSkipSet retain];
    }
    return self;
}

@end
