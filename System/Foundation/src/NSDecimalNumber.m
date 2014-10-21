//
//  NSDecimalNumber.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <pthread.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSString.h>
#import "NSObjectInternal.h"
#import <Foundation/NSException.h>
#import <Foundation/NSThread.h>
#import <math.h>
#import <Foundation/NSCoder.h>
#import <dispatch/dispatch.h>
#import <Foundation/NSKeyedArchiver.h>

static NSString *const KEY_EXPONENT = @"NS.exponent";
static NSString *const KEY_LENGTH = @"NS.length";
static NSString *const KEY_NEGATIVE = @"NS.negative";
static NSString *const KEY_COMPACT = @"NS.compact";
static NSString *const KEY_RESERVED = @"NS.mantissa.bo";
static NSString *const KEY_MANTISSA = @"NS.mantissa";

NSString *const NSDecimalNumberExactnessException = @"NSDecimalNumberExactnessException";
NSString *const NSDecimalNumberOverflowException = @"NSDecimalNumberOverflowException";
NSString *const NSDecimalNumberUnderflowException = @"NSDecimalNumberUnderflowException";
NSString *const NSDecimalNumberDivideByZeroException = @"NSDecimalNumberDivideByZeroException";


CF_PRIVATE
@interface NSDecimalNumberPlaceholder : NSDecimalNumber

+ (BOOL)supportsSecureCoding;
+ (id)allocWithZone:(NSZone *)zone;
- (id)initWithCoder:(NSCoder *)coder;
- (id)initWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag;
- (id)initWithDecimal:(NSDecimal)dcm;
- (id)initWithString:(NSString *)numberValue;
- (id)initWithString:(NSString *)numberValue locale:(id)locale;
- (id)init;
- (NSUInteger)retainCount;
- (id)autorelease;
- (oneway void)release;
- (id)retain;

@end

@implementation NSDecimalNumber

static NSString *NSDecimalNumberBehaviors = @"NSDecimalNumberBehaviors";

+ (id<NSDecimalNumberBehaviors>)defaultBehavior
{
    static id<NSDecimalNumberBehaviors> numberHandler = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        numberHandler = [NSDecimalNumberHandler new];
    });
    
    NSMutableDictionary *tls = [[NSThread currentThread] threadDictionary];
    id<NSDecimalNumberBehaviors> defaultBehavior = [tls objectForKey:NSDecimalNumberBehaviors];
    if (defaultBehavior == nil)
    {
        defaultBehavior = numberHandler;
    }
    return defaultBehavior;
}

+ (void)setDefaultBehavior:(id<NSDecimalNumberBehaviors>)behavior
{
    NSMutableDictionary *tls = [[NSThread currentThread] threadDictionary];
    [tls setObject:behavior forKey:NSDecimalNumberBehaviors];
}

+ (NSDecimalNumber *)zero
{
    static NSDecimalNumber *zero = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        zero = (NSDecimalNumber *)NSAllocateObject([self class], 0, NSDefaultMallocZone());
        zero->_exponent = 0;
        zero->_length = 0;
        zero->_isNegative = 0;
        zero->_isCompact = 0;
        zero->_reserved = 0;
        zero->_hasExternalRefCount = 0;
        zero->_refs = 0;
        zero->_mantissa[0] = 0;
    });

    return zero;
}

+ (NSDecimalNumber *)one
{
    static NSDecimalNumber *one = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        one = (NSDecimalNumber *)NSAllocateObject([self class], 0, NSDefaultMallocZone());
        one->_exponent = 0;
        one->_length = 1;
        one->_isNegative = 0;
        one->_isCompact = 1;
        one->_reserved = 0;
        one->_hasExternalRefCount = 0;
        one->_refs = 0;
        one->_mantissa[0] = 1;
    });

    return one;
}

+ (NSDecimalNumber *)notANumber
{
    static NSDecimalNumber *notANumber = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        notANumber = (NSDecimalNumber *)NSAllocateObject([self class], 0, NSDefaultMallocZone());
        notANumber->_exponent = 0;
        notANumber->_length = 0;
        notANumber->_isNegative = 1;
        notANumber->_isCompact = 0;
        notANumber->_reserved = 0;
        notANumber->_hasExternalRefCount = 0;
        notANumber->_refs = 0;
        notANumber->_mantissa[0] = 0;
    });

    return notANumber;
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSDecimalNumber class])
    {
        return [NSDecimalNumberPlaceholder allocWithZone:zone];
    }
    else
    {
        return (id)NSAllocateObject(self, 0, zone);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    [self release];
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag
{
    [self release];
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithDecimal:(NSDecimal)dcm
{
    [self release];
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithString:(NSString *)numberValue
{
    [self release];
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithString:(NSString *)numberValue locale:(id)locale
{
    [self release];
    NSRequestConcreteImplementation();
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if ([encoder allowsKeyedCoding])
    {
        NSDecimal decimal = [self decimalValue];
        [encoder encodeInt32:decimal._exponent forKey:KEY_EXPONENT];
        [encoder encodeInt32:decimal._length forKey:KEY_LENGTH];
        [encoder encodeBool:decimal._isNegative forKey:KEY_NEGATIVE];
        [encoder encodeBool:decimal._isCompact forKey:KEY_COMPACT];
        [encoder encodeInt32:1 forKey:KEY_RESERVED];
        [encoder encodeBytes:(const u_int8_t *)decimal._mantissa length:decimal._length * sizeof(decimal._mantissa[0]) forKey:KEY_MANTISSA];
    }
    else
    {
        DEBUG_LOG("%s not supported with a coder that disallows keyed coding", __PRETTY_FUNCTION__);
        DEBUG_BREAK();
    }
}

- (NSDecimal)decimalValue
{
    NSDecimal decimal = {0};
    NSDecimalCopy(&decimal, (NSDecimal *)((char *)self + sizeof(Class)));

    return decimal;
}

- (double)doubleValue
{
    if ([self isEqual:[NSDecimalNumber notANumber]]) {
        return NAN;
    }

    double result = 0.0;

    if (!_length)
    {
        return _isNegative ? -result : result;
    }

    for (int length = _length; length > 0; length--)
    {
        result *= (double)USHRT_MAX + 1.0;
        result += (double)(_mantissa[length - 1]);
    }

    if (_exponent != 0)
    {
        int exponent = _exponent;
        if (_exponent < 0)
        {
            for (; exponent < 0; exponent++)
            {
                result /= 10.0;
            }
        }
        else
        {
            for (int neg_exponent = -exponent; neg_exponent < 0; neg_exponent++)
            {
                result *= 10.0;
            }
        }
    }
    
    return _isNegative ? -result : result;
}

- (float)floatValue
{
    return (float)[self doubleValue];
}

- (unsigned long long)unsignedLongLongValue
{
    return (unsigned long long)[self doubleValue];
}

- (long long)longLongValue
{
    return (long long)[self doubleValue];
}

- (unsigned long)unsignedLongValue
{
    return (unsigned long)[self doubleValue];
}

- (long)longValue
{
    return (long)[self doubleValue];
}

- (unsigned int)unsignedIntValue
{
    return (unsigned int)[self doubleValue];
}

- (int)intValue
{
    return (int)[self doubleValue];
}

- (unsigned short)unsignedShortValue
{
    return (unsigned short)[self doubleValue];
}

- (short)shortValue
{
    return (short)[self doubleValue];
}

- (unsigned char)unsignedCharValue
{
    return (unsigned char)[self doubleValue];
}

- (char)charValue
{
    return (char)[self doubleValue];
}

- (BOOL)boolValue
{
    return ([self doubleValue] != 0.0);
}

- (void)getValue:(void *)buffer
{
    double d = [self doubleValue];
    memset(buffer, 0, sizeof(buffer));
    if ((unsigned long long)d & ULONG_LONG_MAX)
    {
        memcpy(buffer, &d, sizeof(d));
    }
}

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)decimalNumber
{
    return [self decimalNumberByAdding:decimalNumber withBehavior:[NSDecimalNumber defaultBehavior]];
}

- (NSDecimalNumber *)decimalNumberByAdding:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val1 = [self decimalValue];
    NSDecimal val2 = [decimalNumber decimalValue];
    NSDecimal result;
    NSCalculationError err = NSDecimalAdd(&result, &val1, &val2, [behavior roundingMode]);
    NSDecimalNumber *num = nil;
    if (err != NSCalculationNoError)
    {
        num = [behavior exceptionDuringOperation:_cmd error:err leftOperand:self rightOperand:decimalNumber];
    }
    else
    {
        num = [NSDecimalNumber decimalNumberWithDecimal:result];
    }
    return num;
}

- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)decimalNumber
{
    return [self decimalNumberBySubtracting:decimalNumber withBehavior:[NSDecimalNumber defaultBehavior]];
}

- (NSDecimalNumber *)decimalNumberBySubtracting:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val1 = [self decimalValue];
    NSDecimal val2 = [decimalNumber decimalValue];
    NSDecimal result;
    NSCalculationError err = NSDecimalSubtract(&result, &val1, &val2, [behavior roundingMode]);
    NSDecimalNumber *num = nil;
    if (err != NSCalculationNoError)
    {
        num = [behavior exceptionDuringOperation:_cmd error:err leftOperand:self rightOperand:decimalNumber];
    }
    else
    {
        num = [NSDecimalNumber decimalNumberWithDecimal:result];
    }
    return num;
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)decimalNumber
{
    return [self decimalNumberByMultiplyingBy:decimalNumber withBehavior:[NSDecimalNumber defaultBehavior]];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val1 = [self decimalValue];
    NSDecimal val2 = [decimalNumber decimalValue];
    NSDecimal result;
    NSCalculationError err = NSDecimalMultiply(&result, &val1, &val2, [behavior roundingMode]);
    NSDecimalNumber *num = nil;
    if (err != NSCalculationNoError)
    {
        num = [behavior exceptionDuringOperation:_cmd error:err leftOperand:self rightOperand:decimalNumber];
    }
    else
    {
        num = [NSDecimalNumber decimalNumberWithDecimal:result];
    }
    return num;
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)decimalNumber
{
    return [self decimalNumberByDividingBy:decimalNumber withBehavior:[NSDecimalNumber defaultBehavior]];
}

- (NSDecimalNumber *)decimalNumberByDividingBy:(NSDecimalNumber *)decimalNumber withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val1 = [self decimalValue];
    NSDecimal val2 = [decimalNumber decimalValue];
    NSDecimal result;
    NSCalculationError err = NSDecimalDivide(&result, &val1, &val2, [behavior roundingMode]);
    NSDecimalNumber *num = nil;
    if (err != NSCalculationNoError)
    {
        num = [behavior exceptionDuringOperation:_cmd error:err leftOperand:self rightOperand:decimalNumber];
    }
    else
    {
        num = [NSDecimalNumber decimalNumberWithDecimal:result];
    }
    return num;
}

- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSUInteger)power
{
    return [self decimalNumberByRaisingToPower:power withBehavior:[NSDecimalNumber defaultBehavior]];
}

- (NSDecimalNumber *)decimalNumberByRaisingToPower:(NSUInteger)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val = [self decimalValue];
    NSDecimal result;
    NSCalculationError err = NSDecimalPower(&result, &val, power, [behavior roundingMode]);
    NSDecimalNumber *num = nil;
    if (err != NSCalculationNoError)
    {
        num = [behavior exceptionDuringOperation:_cmd error:err leftOperand:self rightOperand:nil];
    }
    else
    {
        num = [NSDecimalNumber decimalNumberWithDecimal:result];
    }
    return num;
}

- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(short)power
{
    return [self decimalNumberByMultiplyingByPowerOf10:power withBehavior:[NSDecimalNumber defaultBehavior]];
}

- (NSDecimalNumber *)decimalNumberByMultiplyingByPowerOf10:(short)power withBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val = [self decimalValue];
    NSDecimal result;
    NSCalculationError err = NSDecimalMultiplyByPowerOf10(&result, &val, power, [behavior roundingMode]);
    NSDecimalNumber *num = nil;
    if (err != NSCalculationNoError)
    {
        num = [behavior exceptionDuringOperation:_cmd error:err leftOperand:self rightOperand:nil];
    }
    else
    {
        num = [NSDecimalNumber decimalNumberWithDecimal:result];
    }
    return num;
}

- (NSDecimalNumber *)decimalNumberByRoundingAccordingToBehavior:(id <NSDecimalNumberBehaviors>)behavior
{
    NSDecimal val = [self decimalValue];
    NSDecimal result;
    NSDecimalRound(&result, &val, [behavior scale], [behavior roundingMode]);
    return [NSDecimalNumber decimalNumberWithDecimal:result];
}

- (NSComparisonResult)compare:(NSNumber *)decimalNumber
{
    NSDecimal d1 = [self decimalValue];
    NSDecimal d2 = [decimalNumber decimalValue];
    return NSDecimalCompare(&d1, &d2);
}


+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)numberValue
{
    return [[[self alloc] initWithString:numberValue] autorelease];
}

+ (NSDecimalNumber *)decimalNumberWithString:(NSString *)numberValue locale:(id)locale
{
    return [[[self alloc] initWithString:numberValue locale:locale] autorelease];
}

+ (NSDecimalNumber *)decimalNumberWithDecimal:(NSDecimal)decimal
{
    return [[[self alloc] initWithDecimal:decimal] autorelease];
}

+ (NSDecimalNumber *)decimalNumberWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag
{
    return [[[self alloc] initWithMantissa:mantissa exponent:exponent isNegative:flag] autorelease];
}

- (const char *)objCType
{
    return @encode(double);
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
    {
        return YES;
    }
    else if ([object isNSNumber__]) 
    {
        return [self compare:object] == NSOrderedSame;
    }
    else
    {
        return NO;
    }
}

- (NSString *)description
{
    #warning NSDecimalNumber description needs a real implementation
    NSString *string = nil;
    if ([self isEqual:[NSDecimalNumber notANumber]])
    {
        string = @"NaN";
    }
    else
    {
        // add 1 for decimal point, 1 for sign, 5 for e+308 (max)
        // and 1 for null termination  = 1 + 1 + 1 + 5 = 8
        char buffer[DBL_DIG + 8] = {0};
        double d = [self doubleValue];
        int success = snprintf(buffer, sizeof(buffer), "%g", d);

        if (success)
        {
            string = [NSString stringWithUTF8String:buffer];
        }
    }

    return string;
}

@end


@implementation NSDecimalNumberPlaceholder

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t once = 0L;
    static NSDecimalNumberPlaceholder *placeholder = nil;
    dispatch_once(&once, ^{
        placeholder = NSAllocateObject(self, 0, NULL);
    });
    return placeholder;
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSDecimalNumber *number = nil;
    if ([coder allowsKeyedCoding])
    {
        NSDecimal decimal = {0};
        decimal._exponent = [coder decodeInt32ForKey:KEY_EXPONENT];
        decimal._length = [coder decodeInt32ForKey:KEY_LENGTH];
        decimal._isNegative = [coder decodeBoolForKey:KEY_NEGATIVE];
        decimal._isCompact = [coder decodeBoolForKey:KEY_COMPACT];
        decimal._reserved = [coder decodeInt32ForKey:KEY_RESERVED];
        
        NSUInteger length;
        const uint8_t *bytes = [coder decodeBytesForKey:KEY_MANTISSA returnedLength:&length];
        
        if (length > (NSDecimalMaxSize * sizeof(decimal._mantissa[0])))
        {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"%@", @"data encoded in mantissa is too large"];
        }
        
        if (length)
        {
            memcpy(&decimal._mantissa, bytes, length);
        }
        
        number = [self initWithDecimal:decimal];
    }

    else 
    {
        DEBUG_LOG("%s not supported with a coder that disallows keyed coding", __PRETTY_FUNCTION__);
        DEBUG_BREAK();
    }
    
    return (id)number;
}

- (id)initWithString:(NSString *)numberValue locale:locale
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:numberValue];
    if (locale != nil)
    {
        [scanner setLocale:locale];
    }
    NSDecimal decimal = { 0 };
    [scanner scanDecimal:&decimal];
    [scanner release];
    return [self initWithDecimal:decimal];
}

- (id)initWithString:(NSString *)numberValue
{
    return [self initWithString:numberValue locale:nil];
}

- (id)initWithDecimal:(NSDecimal)dcm
{
    NSDecimalCompact(&dcm);
    NSDecimalNumber *number = (NSDecimalNumber *)NSAllocateObject(objc_getClass("NSDecimalNumber"), dcm._length * sizeof(dcm._mantissa[0]), NULL);
    NSDecimalCopy((NSDecimal *)((char *)number + sizeof(Class)), &dcm);
    
    return (id)number;
}

- (id)initWithMantissa:(unsigned long long)mantissa exponent:(short)exponent isNegative:(BOOL)flag
{
    NSDecimal dcm = {0};   

    dcm._exponent = exponent;
    dcm._isNegative = flag ? 1 : 0;
    memcpy(&(dcm._mantissa), &mantissa, sizeof(unsigned long long));
    for (int i = NSDecimalMaxSize - 1; i >= 0; i--)
    {
        if (dcm._mantissa[i] != 0)
        {
            dcm._length = i + 1;
            break;
        }
    }
    return [self initWithDecimal:dcm];
}

- (id)initWithLongLong:(long long)value
{
    return value < 0 ? [self initWithMantissa:-value exponent:0 isNegative:YES] : [self initWithMantissa:value exponent:0 isNegative:NO];
}

- (id)initWithBool:(BOOL)value
{
    return [self initWithLongLong:(long long)value];
}

- (id)initWithChar:(char)value
{
    return [self initWithLongLong:(long long)value];
}

- (id)initWithShort:(short)value
{
    return [self initWithLongLong:(long long)value];
}

- (id)initWithInt:(int)value
{
    return [self initWithLongLong:(long long)value];
}

- (id)initWithLong:(long)value
{
    return [self initWithLongLong:(long long)value];
}

- (id)initWithInteger:(NSInteger)value
{
    return [self initWithLongLong:(long long)value];
}

- (id)initWithUnsignedLongLong:(unsigned long long)value
{
    return [self initWithMantissa:value exponent:0 isNegative:NO];
}

- (id)initWithUnsignedChar:(unsigned char)value
{
    return [self initWithUnsignedLongLong:(unsigned long long)value];
}

- (id)initWithUnsignedShort:(unsigned short)value
{
    return [self initWithUnsignedLongLong:(unsigned long long)value];
}

- (id)initWithUnsignedInt:(unsigned int)value
{
    return [self initWithUnsignedLongLong:(unsigned long long)value];
}

- (id)initWithUnsignedLong:(unsigned long)value
{
    return [self initWithUnsignedLongLong:(unsigned long long)value];
}

- (id)initWithUnsignedInteger:(NSUInteger)value
{
    return [self initWithUnsignedLongLong:(unsigned long long)value];
}

- (id)initWithFloat:(float)value
{
    double d = (double)value;
    return [self initWithDouble:d];
}

- (id)initWithDouble:(double)value
{   
    NSDecimalNumber *number = nil;
    if (isnan(value))
    {
        number = [self initWithMantissa:0x0 exponent:0x0 isNegative:0x1];
    }
    else
    {
        double result = fabs(value);
        
        if (result < 1.0e-110 || result  == ULONG_LONG_MAX) // weird ass edge case
        {
            number = [self initWithMantissa:0x0 exponent:0x0 isNegative:0x0];
        }
        else
        {
            if (result > 1.8e146)
            {
                number = [self initWithMantissa:ULONG_LONG_MAX exponent:0x7f isNegative:(value < 0 ? YES : NO)];
            }
            else
            {
                // Determine the base 10 exponent and rotate around 2^64
                int i = 0;
                for (; result < 1.8446744073709551616e19; i--) // that constant is 2^64
                {
                    result *= 10.0;
                }
                for (; result > 1.8446744073709551616e19; i++)
                {
                    result /= 10.0;
                }
                
                number = [self initWithMantissa:(unsigned long long)result exponent:i isNegative:value < 0.0];
            }
        }
    }
 
    return (id)number;
}

SINGLETON_RR()

@end

@interface NSDecimalNumberHandler ()
@property (nonatomic) NSRoundingMode roundingMode;
@property (nonatomic) short scale;
@property (nonatomic) BOOL raiseOnExact;
@property (nonatomic) BOOL raiseOnOverflow;
@property (nonatomic) BOOL raiseOnUnderflow;
@property (nonatomic) BOOL raiseOnDivideByZero;
@end

@implementation NSDecimalNumberHandler

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)method error:(NSCalculationError)error
                                  leftOperand:(NSDecimalNumber *)leftOperand
                                 rightOperand:(NSDecimalNumber *)rightOperand
{
    if (error == NSCalculationUnderflow)
    {
        [[NSException exceptionWithName:NSDecimalNumberUnderflowException
                                 reason:@"NSDecimalNumber underflow exception" userInfo:@{}] raise];
    }
    else if (error == NSCalculationOverflow)
    {
        [[NSException exceptionWithName:NSDecimalNumberOverflowException
                                 reason:@"NSDecimalNumber overflow exception" userInfo:@{}] raise];
    }
    else if (error == NSCalculationDivideByZero)
    {
        [[NSException exceptionWithName:NSDecimalNumberDivideByZeroException
                                 reason:@"NSDecimalNumber divide by zero exception" userInfo:@{}] raise];
    }
    
    return nil;
}

+ (id)defaultDecimalNumberHandler {
    static NSDecimalNumberHandler *defaultHandler;
    static pthread_mutex_t default_lock = PTHREAD_MUTEX_INITIALIZER;

    pthread_mutex_lock(&default_lock);
    if (nil == defaultHandler) {
        defaultHandler = [[NSDecimalNumberHandler alloc]
                             initWithRoundingMode:NSRoundPlain
                                            scale:NSDecimalNoScale
                                 raiseOnExactness:NO
                                  raiseOnOverflow:NO
                                 raiseOnUnderflow:NO
                              raiseOnDivideByZero:NO];
    }
    pthread_mutex_unlock(&default_lock);
    return defaultHandler;
}

+ (id)decimalNumberHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(BOOL)exact raiseOnOverflow:(BOOL)overflow raiseOnUnderflow:(BOOL)underflow raiseOnDivideByZero:(BOOL)divideByZero {
    return [[[NSDecimalNumberHandler alloc]
               initWithRoundingMode:roundingMode
                              scale:scale
                   raiseOnExactness:exact
                    raiseOnOverflow:overflow
                   raiseOnUnderflow:underflow
                raiseOnDivideByZero:divideByZero
            ] autorelease];
}

- (id)initWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale raiseOnExactness:(BOOL)exact raiseOnOverflow:(BOOL)overflow raiseOnUnderflow:(BOOL)underflow raiseOnDivideByZero:(BOOL)divideByZero {
    if ((self = [super init])) {
        self.roundingMode = roundingMode;
        self.scale = scale;
        self.raiseOnExact = exact;
        self.raiseOnOverflow = overflow;
        self.raiseOnUnderflow = underflow;
        self.raiseOnDivideByZero = divideByZero;
    }
    return self;
}

@end
