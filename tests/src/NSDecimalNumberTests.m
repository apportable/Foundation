//
//  NSDecimalNumberTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSDecimalNumber)

test(AllocPattern)
{
    testassert([NSDecimalNumber alloc] == [NSDecimalNumber alloc]);
    
    return YES;
}

test(DecimalValue1)
{
    NSDecimal decimal1;
    decimal1._exponent = 0;
    decimal1._isNegative = 0;
    decimal1._length = 1;
    decimal1._mantissa[0] = 1;
    decimal1._mantissa[1] = 0;
    decimal1._mantissa[2] = 0;
    decimal1._mantissa[3] = 0;
    decimal1._mantissa[4] = 0;
    decimal1._mantissa[5] = 0;
    decimal1._mantissa[6] = 0;
    decimal1._mantissa[7] = 0;
    decimal1._reserved = 0;
    
    NSDecimalCompact(&decimal1);
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal1];
    NSDecimal decimal2 = [number decimalValue];
    
    testassert(decimal1._exponent == decimal2._exponent);
    testassert(decimal1._isCompact == decimal2._isCompact);
    testassert(decimal1._isNegative == decimal2._isNegative);
    testassert(decimal1._length == decimal2._length);
    testassert(decimal1._mantissa[0] == decimal2._mantissa[0]);
    testassert(decimal1._mantissa[1] == decimal2._mantissa[1]);
    testassert(decimal1._mantissa[2] == decimal2._mantissa[2]);
    testassert(decimal1._mantissa[3] == decimal2._mantissa[3]);
    testassert(decimal1._mantissa[4] == decimal2._mantissa[4]);
    testassert(decimal1._mantissa[5] == decimal2._mantissa[5]);
    testassert(decimal1._mantissa[6] == decimal2._mantissa[6]);
    testassert(decimal1._mantissa[7] == decimal2._mantissa[7]);
    testassert(decimal1._reserved == decimal2._reserved);
    
    return YES;
}

test(DecimalValue2)
{
    NSDecimal decimal1;
    decimal1._exponent = 1;
    decimal1._isNegative = 1;
    decimal1._length = 8;
    decimal1._mantissa[0] = 1;
    decimal1._mantissa[1] = 2;
    decimal1._mantissa[2] = 3;
    decimal1._mantissa[3] = 4;
    decimal1._mantissa[4] = 5;
    decimal1._mantissa[5] = 6;
    decimal1._mantissa[6] = 7;
    decimal1._mantissa[7] = 8;
    decimal1._reserved = 9;
    
    NSDecimalCompact(&decimal1);
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal1];
    NSDecimal decimal2 = [number decimalValue];
    
    testassert(decimal1._exponent == decimal2._exponent);
    testassert(decimal1._isCompact == decimal2._isCompact);
    testassert(decimal1._isNegative == decimal2._isNegative);
    testassert(decimal1._length == decimal2._length);
    testassert(decimal1._mantissa[0] == decimal2._mantissa[0]);
    testassert(decimal1._mantissa[1] == decimal2._mantissa[1]);
    testassert(decimal1._mantissa[2] == decimal2._mantissa[2]);
    testassert(decimal1._mantissa[3] == decimal2._mantissa[3]);
    testassert(decimal1._mantissa[4] == decimal2._mantissa[4]);
    testassert(decimal1._mantissa[5] == decimal2._mantissa[5]);
    testassert(decimal1._mantissa[6] == decimal2._mantissa[6]);
    testassert(decimal1._mantissa[7] == decimal2._mantissa[7]);
    testassert(decimal1._reserved != decimal2._reserved);
    
    return YES;
}

test(InitWithCoderBytes1)
{
    NSDecimal decimal;
    decimal._exponent = -127;
    decimal._isCompact = 1;
    decimal._isNegative = 1;
    decimal._length = 8;
    decimal._mantissa[0] = 65535;
    decimal._mantissa[1] = 65535;
    decimal._mantissa[2] = 65535;
    decimal._mantissa[3] = 65535;
    decimal._mantissa[4] = 65535;
    decimal._mantissa[5] = 65535;
    decimal._mantissa[6] = 65535;
    decimal._mantissa[7] = 65535;
    decimal._reserved = 262143;
    
    NSDecimalNumber *number1 = [[NSDecimalNumber alloc] initWithDecimal:decimal];
    
#if __LP64__
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:number1];
    NSDecimalNumber *number2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    unsigned char expectedArchiveBytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30, 0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x21, 0x22, 0x58, 0x24, 0x76, 0x65, 0x72, 0x73, 0x69,
        0x6f, 0x6e, 0x58, 0x24, 0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72, 0x54, 0x24, 0x74,
        0x6f, 0x70, 0x12, 0x00, 0x01, 0x86, 0xa0, 0xa3, 0x07, 0x08, 0x17, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c, 0xd7, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
        0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x12, 0x56, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x5b, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69,
        0x73, 0x73, 0x61, 0x5b, 0x4e, 0x53, 0x2e, 0x6e, 0x65, 0x67, 0x61, 0x74, 0x69, 0x76, 0x65, 0x5b, 0x4e, 0x53, 0x2e, 0x65, 0x78, 0x70, 0x6f, 0x6e,
        0x65, 0x6e, 0x74, 0x5e, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x2e, 0x62, 0x6f, 0x59, 0x4e, 0x53, 0x2e, 0x6c, 0x65,
        0x6e, 0x67, 0x74, 0x68, 0x5a, 0x4e, 0x53, 0x2e, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0x80, 0x02, 0x4f, 0x10, 0x10, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x09, 0x13, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x81, 0x10, 0x01,
        0x10, 0x08, 0x09, 0xd2, 0x18, 0x19, 0x1a, 0x1b, 0x5a, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x6e, 0x61, 0x6d, 0x65, 0x58, 0x24, 0x63, 0x6c, 0x61,
        0x73, 0x73, 0x65, 0x73, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x50, 0x6c,
        0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0xa5, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69,
        0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x5f, 0x10, 0x0f, 0x4e,
        0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x58, 0x4e, 0x53, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x57,
        0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x58, 0x4e, 0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x4b, 0x65, 0x79,
        0x65, 0x64, 0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72, 0xd1, 0x23, 0x24, 0x54, 0x72, 0x6f, 0x6f, 0x74, 0x80, 0x01, 0x00, 0x08, 0x00, 0x11,
        0x00, 0x1a, 0x00, 0x23, 0x00, 0x2d, 0x00, 0x32, 0x00, 0x37, 0x00, 0x3b, 0x00, 0x41, 0x00, 0x50, 0x00, 0x57, 0x00, 0x63, 0x00, 0x6f, 0x00, 0x7b,
        0x00, 0x8a, 0x00, 0x94, 0x00, 0x9f, 0x00, 0xa1, 0x00, 0xb4, 0x00, 0xb5, 0x00, 0xbe, 0x00, 0xc0, 0x00, 0xc2, 0x00, 0xc3, 0x00, 0xc8, 0x00, 0xd3,
        0x00, 0xdc, 0x00, 0xf9, 0x00, 0xff, 0x01, 0x1c, 0x01, 0x2e, 0x01, 0x37, 0x01, 0x3f, 0x01, 0x48, 0x01, 0x5a, 0x01, 0x5d, 0x01, 0x62, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x64,
    };
    
    NSData *bytesToCompare = [NSData dataWithBytes:expectedArchiveBytes length:sizeof(expectedArchiveBytes)];
    
    testassert([archive isEqualToData:bytesToCompare]);
    testassert([number1 isEqual:number2]);
#else
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:number1];
    NSDecimalNumber *number2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    unsigned char expectedArchiveBytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30, 0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x08, 0x23, 0x24, 0x54, 0x24, 0x74, 0x6f, 0x70, 0x58, 0x24,
        0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x58, 0x24, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76,
        0x65, 0x72, 0xd1, 0x06, 0x07, 0x54, 0x72, 0x6f, 0x6f, 0x74, 0x80, 0x01, 0xa3, 0x09, 0x0a, 0x19, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c, 0xd7, 0x0b,
        0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x12, 0x16, 0x17, 0x18, 0x5b, 0x4e, 0x53, 0x2e, 0x6e, 0x65, 0x67, 0x61, 0x74, 0x69, 0x76,
        0x65, 0x56, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x5e, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x2e, 0x62, 0x6f, 0x5a,
        0x4e, 0x53, 0x2e, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0x5b, 0x4e, 0x53, 0x2e, 0x65, 0x78, 0x70, 0x6f, 0x6e, 0x65, 0x6e, 0x74, 0x5b, 0x4e,
        0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x59, 0x4e, 0x53, 0x2e, 0x6c, 0x65, 0x6e, 0x67, 0x74, 0x68, 0x09, 0x80, 0x02, 0x10,
        0x01, 0x09, 0x13, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x81, 0x4f, 0x10, 0x10, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x10, 0x08, 0xd2, 0x1a, 0x1b, 0x1c, 0x22, 0x58, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x65, 0x73, 0x5a, 0x24,
        0x63, 0x6c, 0x61, 0x73, 0x73, 0x6e, 0x61, 0x6d, 0x65, 0xa5, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69,
        0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x5f, 0x10, 0x0f, 0x4e,
        0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x58, 0x4e, 0x53, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x57,
        0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x58, 0x4e, 0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63,
        0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x12, 0x00, 0x01,
        0x86, 0xa0, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x4b, 0x65, 0x79, 0x65, 0x64, 0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72, 0x00, 0x08, 0x00, 0x11,
        0x00, 0x16, 0x00, 0x1f, 0x00, 0x28, 0x00, 0x32, 0x00, 0x35, 0x00, 0x3a, 0x00, 0x3c, 0x00, 0x40, 0x00, 0x46, 0x00, 0x55, 0x00, 0x61, 0x00, 0x68,
        0x00, 0x77, 0x00, 0x82, 0x00, 0x8e, 0x00, 0x9a, 0x00, 0xa4, 0x00, 0xa5, 0x00, 0xa7, 0x00, 0xa9, 0x00, 0xaa, 0x00, 0xb3, 0x00, 0xc6, 0x00, 0xc8,
        0x00, 0xcd, 0x00, 0xd6, 0x00, 0xe1, 0x00, 0xe7, 0x01, 0x04, 0x01, 0x16, 0x01, 0x1f, 0x01, 0x27, 0x01, 0x30, 0x01, 0x4d, 0x01, 0x52, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x01, 0x64,
    };
    
    NSData *bytesToCompare = [NSData dataWithBytes:expectedArchiveBytes length:sizeof(expectedArchiveBytes)];
    
    testassert([archive isEqualToData:bytesToCompare]);
    testassert([number1 isEqual:number2]);
#endif
    
    [number1 release];
    
    return YES;
}

test(InitWithCoderBytes2)
{
    NSDecimalNumber *number1 = [[NSDecimalNumber alloc] initWithDouble:123];
    
#if __LP64__
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:number1];
    NSDecimalNumber *number2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    unsigned char expectedArchiveBytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30, 0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x20, 0x21, 0x58, 0x24, 0x76, 0x65, 0x72, 0x73, 0x69,
        0x6f, 0x6e, 0x58, 0x24, 0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72, 0x54, 0x24, 0x74,
        0x6f, 0x70, 0x12, 0x00, 0x01, 0x86, 0xa0, 0xa3, 0x07, 0x08, 0x16, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c, 0xd7, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
        0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x14, 0x15, 0x56, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x5b, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69,
        0x73, 0x73, 0x61, 0x5b, 0x4e, 0x53, 0x2e, 0x6e, 0x65, 0x67, 0x61, 0x74, 0x69, 0x76, 0x65, 0x5b, 0x4e, 0x53, 0x2e, 0x65, 0x78, 0x70, 0x6f, 0x6e,
        0x65, 0x6e, 0x74, 0x5e, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x2e, 0x62, 0x6f, 0x59, 0x4e, 0x53, 0x2e, 0x6c, 0x65,
        0x6e, 0x67, 0x74, 0x68, 0x5a, 0x4e, 0x53, 0x2e, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0x80, 0x02, 0x4f, 0x10, 0x10, 0x7b, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x10, 0x00, 0x10, 0x01, 0x09, 0xd2, 0x17, 0x18, 0x19, 0x1a, 0x5a,
        0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x6e, 0x61, 0x6d, 0x65, 0x58, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x65, 0x73, 0x5f, 0x10, 0x1a, 0x4e, 0x53,
        0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72,
        0xa5, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72,
        0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e,
        0x75, 0x6d, 0x62, 0x65, 0x72, 0x58, 0x4e, 0x53, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x58, 0x4e,
        0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x4b, 0x65, 0x79, 0x65, 0x64, 0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65,
        0x72, 0xd1, 0x22, 0x23, 0x54, 0x72, 0x6f, 0x6f, 0x74, 0x80, 0x01, 0x00, 0x08, 0x00, 0x11, 0x00, 0x1a, 0x00, 0x23, 0x00, 0x2d, 0x00, 0x32, 0x00,
        0x37, 0x00, 0x3b, 0x00, 0x41, 0x00, 0x50, 0x00, 0x57, 0x00, 0x63, 0x00, 0x6f, 0x00, 0x7b, 0x00, 0x8a, 0x00, 0x94, 0x00, 0x9f, 0x00, 0xa1, 0x00,
        0xb4, 0x00, 0xb5, 0x00, 0xb7, 0x00, 0xb9, 0x00, 0xba, 0x00, 0xbf, 0x00, 0xca, 0x00, 0xd3, 0x00, 0xf0, 0x00, 0xf6, 0x01, 0x13, 0x01, 0x25, 0x01,
        0x2e, 0x01, 0x36, 0x01, 0x3f, 0x01, 0x51, 0x01, 0x54, 0x01, 0x59, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x5b,
    };
    
    NSData *bytesToCompare = [NSData dataWithBytes:expectedArchiveBytes length:sizeof(expectedArchiveBytes)];
    
    testassert([archive isEqualToData:bytesToCompare]);
    testassert([number1 isEqual:number2]);

#else
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:number1];
    NSDecimalNumber *number2 = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
    
    unsigned char expectedArchiveBytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30, 0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x08, 0x22, 0x23, 0x54, 0x24, 0x74, 0x6f, 0x70, 0x58, 0x24,
        0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x58, 0x24, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76,
        0x65, 0x72, 0xd1, 0x06, 0x07, 0x54, 0x72, 0x6f, 0x6f, 0x74, 0x80, 0x01, 0xa3, 0x09, 0x0a, 0x18, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c, 0xd7, 0x0b,
        0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x14, 0x5b, 0x4e, 0x53, 0x2e, 0x6e, 0x65, 0x67, 0x61, 0x74, 0x69, 0x76,
        0x65, 0x56, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x5e, 0x4e, 0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x2e, 0x62, 0x6f, 0x5a,
        0x4e, 0x53, 0x2e, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0x5b, 0x4e, 0x53, 0x2e, 0x65, 0x78, 0x70, 0x6f, 0x6e, 0x65, 0x6e, 0x74, 0x5b, 0x4e,
        0x53, 0x2e, 0x6d, 0x61, 0x6e, 0x74, 0x69, 0x73, 0x73, 0x61, 0x59, 0x4e, 0x53, 0x2e, 0x6c, 0x65, 0x6e, 0x67, 0x74, 0x68, 0x08, 0x80, 0x02, 0x10,
        0x01, 0x09, 0x10, 0x00, 0x4f, 0x10, 0x10, 0x7b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd2,
        0x19, 0x1a, 0x1b, 0x21, 0x58, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x65, 0x73, 0x5a, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73, 0x6e, 0x61, 0x6d, 0x65,
        0xa5, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72,
        0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e,
        0x75, 0x6d, 0x62, 0x65, 0x72, 0x58, 0x4e, 0x53, 0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x58, 0x4e,
        0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x5f, 0x10, 0x1a, 0x4e, 0x53, 0x44, 0x65, 0x63, 0x69, 0x6d, 0x61, 0x6c, 0x4e, 0x75, 0x6d, 0x62, 0x65,
        0x72, 0x50, 0x6c, 0x61, 0x63, 0x65, 0x68, 0x6f, 0x6c, 0x64, 0x65, 0x72, 0x12, 0x00, 0x01, 0x86, 0xa0, 0x5f, 0x10, 0x0f, 0x4e, 0x53, 0x4b, 0x65,
        0x79, 0x65, 0x64, 0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72, 0x00, 0x08, 0x00, 0x11, 0x00, 0x16, 0x00, 0x1f, 0x00, 0x28, 0x00, 0x32, 0x00,
        0x35, 0x00, 0x3a, 0x00, 0x3c, 0x00, 0x40, 0x00, 0x46, 0x00, 0x55, 0x00, 0x61, 0x00, 0x68, 0x00, 0x77, 0x00, 0x82, 0x00, 0x8e, 0x00, 0x9a, 0x00,
        0xa4, 0x00, 0xa5, 0x00, 0xa7, 0x00, 0xa9, 0x00, 0xaa, 0x00, 0xac, 0x00, 0xbf, 0x00, 0xc4, 0x00, 0xcd, 0x00, 0xd8, 0x00, 0xde, 0x00, 0xfb, 0x01,
        0x0d, 0x01, 0x16, 0x01, 0x1e, 0x01, 0x27, 0x01, 0x44, 0x01, 0x49, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x5b
    };
    
    NSData *bytesToCompare = [NSData dataWithBytes:expectedArchiveBytes length:sizeof(expectedArchiveBytes)];
    
    testassert([archive isEqualToData:bytesToCompare]);
    testassert([number1 isEqual:number2]);
#endif

    [number1 release];

    return YES;
}

test(InitWithCoder1)
{
    NSNumber *original = [NSDecimalNumber numberWithInt:0];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:original];
    NSDecimalNumber *number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([original isEqual:number]);
    testassert([original isEqual:[NSDecimalNumber zero]]);
    
    return YES;
}

test(InitWithCoder2)
{
    NSNumber *original = [NSDecimalNumber numberWithInt:1];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:original];
    NSDecimalNumber *number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([original isEqual:number]);
    testassert([original isEqual:[NSDecimalNumber one]]);
        
    return YES;
}

test(InitWithCoder3)
{
    NSNumber *original = [NSDecimalNumber notANumber];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:original];
    NSDecimalNumber *number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([original isEqual:number]);
    testassert([original isEqual:[NSDecimalNumber notANumber]]);
    
    return YES;
}

test(InitWithCoder4)
{
    NSNumber *original = [NSDecimalNumber numberWithLongLong:LONG_LONG_MAX];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:original];
    NSDecimalNumber *number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([original isEqual:number]);
    
    return YES;
}

test(InitWithCoder5)
{
    NSNumber *original = [NSDecimalNumber numberWithDouble:123456.7890];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:original];
    NSDecimalNumber *number = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([original isEqual:number]);
    
    return YES;
}

test(InitWithDouble1)
{
    double original = SCHAR_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 127);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble2)
{
    double original = SCHAR_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 128);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble3)
{
    double original = UCHAR_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 255);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble4)
{
    double original = CHAR_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 127);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble5)
{
    double original = CHAR_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 128);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble6)
{
    double original = USHRT_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble7)
{
    double original = SHRT_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 32767);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble8)
{
    double original = SHRT_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 32768);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble9)
{
    double original = UINT_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble10)
{
    double original = INT_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 32767);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble11)
{
    double original = INT_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 32768);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble12)
{
#if __LP64__
    double original = ULONG_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#else
    double original = ULONG_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#endif
    return YES;
}

test(InitWithDouble13)
{
#if __LP64__
    double original = LONG_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 32768);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#else
    double original = LONG_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 32767);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#endif
    return YES;
}

test(InitWithDouble14)
{
#if __LP64__
    double original = LONG_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 32768);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#else
    double original = LONG_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 32768);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#endif
    return YES;
}

test(InitWithDouble15)
{
    double original = ULLONG_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble16)
{
    double original = LLONG_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 32768);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble17)
{
    double original = LLONG_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 1);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 32768);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble18)
{
    double original = FLT_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 20);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 12288);
    testassert(decimal._mantissa[1] == 60226);
    testassert(decimal._mantissa[2] == 16873);
    testassert(decimal._mantissa[3] == 12089);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble19)
{
    double original = DBL_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 65535);
    testassert(decimal._mantissa[3] == 65535);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble20)
{
    double original = LDBL_MAX;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 65535);
    testassert(decimal._mantissa[3] == 65535);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble21)
{
    double original = FLT_EPSILON;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == -25);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 36864);
    testassert(decimal._mantissa[1] == 10242);
    testassert(decimal._mantissa[2] == 10796);
    testassert(decimal._mantissa[3] == 4235);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble22)
{
    double original = DBL_EPSILON;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == -33);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 13184);
    testassert(decimal._mantissa[1] == 18649);
    testassert(decimal._mantissa[2] == 56420);
    testassert(decimal._mantissa[3] == 788);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble23)
{
#if TARGET_IPHONE_SIMULATOR
    double original = LDBL_EPSILON;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == -38);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 32768);
    testassert(decimal._mantissa[1] == 46349);
    testassert(decimal._mantissa[2] == 39248);
    testassert(decimal._mantissa[3] == 38518);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#else
    double original = LDBL_EPSILON;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == -33);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 13184);
    testassert(decimal._mantissa[1] == 18649);
    testassert(decimal._mantissa[2] == 56420);
    testassert(decimal._mantissa[3] == 788);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
#endif
    return YES;
}

test(InitWithDouble24)
{
    double original = FLT_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == -57);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 38912);
    testassert(decimal._mantissa[1] == 8808);
    testassert(decimal._mantissa[2] == 62167);
    testassert(decimal._mantissa[3] == 41761);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble25)
{
    double original = DBL_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble26)
{
    double original = LDBL_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble27)
{
    double original = FLT_TRUE_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == -64);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 45056);
    testassert(decimal._mantissa[1] == 65487);
    testassert(decimal._mantissa[2] == 8009);
    testassert(decimal._mantissa[3] == 49784);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble28)
{
    double original = DBL_TRUE_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble29)
{
    double original = LDBL_TRUE_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble30)
{
    double original = LDBL_TRUE_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble31)
{
    double original = 1.0e-110;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 8192);
    testassert(decimal._mantissa[1] == 35304);
    testassert(decimal._mantissa[2] == 8964);
    testassert(decimal._mantissa[3] == 35527);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble32)
{
    double original = 1.0e-110 - DBL_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 8192);
    testassert(decimal._mantissa[1] == 35304);
    testassert(decimal._mantissa[2] == 8964);
    testassert(decimal._mantissa[3] == 35527);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble33)
{
    double original = 1.8e146;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 50440);
    testassert(decimal._mantissa[2] == 55457);
    testassert(decimal._mantissa[3] == 63948);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble34)
{
    double original = 1.8e146 + DBL_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 127);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 50440);
    testassert(decimal._mantissa[2] == 55457);
    testassert(decimal._mantissa[3] == 63948);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble35)
{
    double original = 1.8446744073709551616e19;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDouble36)
{
    double original = 1.8446744073709551616e19 + DBL_MIN;
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDouble:original];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(InitWithDecimal1)
{
#if __LP64__
    NSDecimal decimal;
    decimal._mantissa[0] = 65535;
    decimal._mantissa[1] = 65535;
    decimal._mantissa[2] = 65535;
    decimal._mantissa[3] = 65535;
    decimal._mantissa[4] = 65535;
    decimal._mantissa[5] = 65535;
    decimal._mantissa[6] = 65535;
    decimal._mantissa[7] = 65535;
    decimal._exponent = 0;
    decimal._isNegative = 0;
    decimal._length = NSDecimalMaxSize;
    
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 8);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 98047);
    for (int i = 0; i < NSDecimalMaxSize; i++) {
        testassert(decimal._mantissa[i] == 65535);
    }
#else
    NSDecimal decimal;
    decimal._mantissa[0] = 65535;
    decimal._mantissa[1] = 65535;
    decimal._mantissa[2] = 65535;
    decimal._mantissa[3] = 65535;
    decimal._mantissa[4] = 65535;
    decimal._mantissa[5] = 65535;
    decimal._mantissa[6] = 65535;
    decimal._mantissa[7] = 65535;
    decimal._exponent = 0;
    decimal._isNegative = 0;
    decimal._length = NSDecimalMaxSize;
    
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithDecimal:decimal];
    
    testassert(number != nil);
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 8);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._reserved == 0);
    for (int i = 0; i < NSDecimalMaxSize; i++) {
        testassert(decimal._mantissa[i] == 65535);
    }
#endif
    return YES;
}

test(testSingletons)
{
    NSDecimalNumber *one1 = [NSDecimalNumber one];
    NSDecimalNumber *one2 = [NSDecimalNumber one];
    
    testassert(one1 == one2);
    
    return YES;
}

test(DecimalNumberWithString1)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimal decimal = [number decimalValue];
    
    testassert(number != [NSDecimalNumber zero]);
    testassert([number isEqual:[NSDecimalNumber zero]]);
    
    testassert(decimal._exponent == -1);
    testassert(decimal._length == 0);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 0);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(DecimalNumberWithString2)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"18446744073709551616"];
    NSDecimal decimal = [number decimalValue];
    
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 5);
    testassert(decimal._isNegative == 0);
    testassert(decimal._isCompact == 1);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 1);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(initWithMantissa1)
{
    NSDecimalNumber *number = [[NSDecimalNumber alloc] initWithMantissa:0ULL exponent:0 isNegative:NO];
    
    testassert(number != [NSDecimalNumber zero]);
    
    return YES;
}

test(NSDecimalNumberRepresentation1)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithInt:1] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 1);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(NSDecimalNumberRepresentation2)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithInt:(unsigned short)-1] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 1);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 0);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(NSDecimalNumberRepresentation3)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithInt:65536] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 2);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 1);
    testassert(decimal._mantissa[2] == 0);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(NSDecimalNumberRepresentation4)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:65536.65535] decimalValue];
    testassert(decimal._exponent == -14);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 14336);
    testassert(decimal._mantissa[1] == 52837);
    testassert(decimal._mantissa[2] == 19476);
    testassert(decimal._mantissa[3] == 23283);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(NSDecimalNumberRepresentation5)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:65536.65536] decimalValue];
    testassert(decimal._exponent == -5);
    testassert(decimal._length == 3);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 34465);
    testassert(decimal._mantissa[2] == 1);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(NSDecimalNumberRepresentation6)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:-65536.65536] decimalValue];
    testassert(decimal._exponent == -5);
    testassert(decimal._length == 3);
    testassert(decimal._isNegative == YES);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._mantissa[1] == 34465);
    testassert(decimal._mantissa[2] == 1);
    testassert(decimal._mantissa[3] == 0);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(NSDecimalNumberRepresentation7)
{
    NSDecimal decimal = [[NSDecimalNumber numberWithDouble:1345.231534661346] decimalValue];
    testassert(decimal._exponent == -16);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 20480);
    testassert(decimal._mantissa[1] == 51566);
    testassert(decimal._mantissa[2] == 14728);
    testassert(decimal._mantissa[3] == 47792);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);

    return YES;
}

test(NSDecimalNumberRepresentation8)
{
    NSDecimal decimal = [[[NSDecimalNumber alloc] initWithMantissa:18446744073709551615ULL exponent:0 isNegative:NO] decimalValue];
    testassert(decimal._exponent == 0);
    testassert(decimal._length == 4);
    testassert(decimal._isNegative == NO);
    testassert(decimal._isCompact == YES);
    testassert(decimal._mantissa[0] == 65535);
    testassert(decimal._mantissa[1] == 65535);
    testassert(decimal._mantissa[2] == 65535);
    testassert(decimal._mantissa[3] == 65535);
    testassert(decimal._mantissa[4] == 0);
    testassert(decimal._mantissa[5] == 0);
    testassert(decimal._mantissa[6] == 0);
    testassert(decimal._mantissa[7] == 0);
    
    return YES;
}

test(ObjCType)
{
    NSDecimalNumber *n = [[NSDecimalNumber alloc] initWithDouble:1.99];
    testassert(strcmp([n objCType], "d") == 0);
    [n release];
    return YES;
}

test(cfNumberType)
{
    NSDecimalNumber *n = [[NSDecimalNumber alloc] initWithDouble:1.99];
    testassert([n _cfNumberType] == kCFNumberDoubleType);
    [n release];
    return YES;
}

test(DoubleValue1)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:0];
    testassert([n doubleValue] == 0.0);
    [n release];

    return YES;
}

test(DoubleValue2)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:0.0];
    testassert([n doubleValue] == 0.0);
    [n release];

    return YES;
}

test(DoubleValue3)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:-0];
    testassert([n doubleValue] == +0.0);
    testassert([n doubleValue] == -0.0);
    [n release];

    return YES;
}

test(DoubleValue4)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:-0.0];
    testassert([n doubleValue] == +0.0);
    testassert([n doubleValue] == -0.0);
    [n release];

    return YES;
}

test(DoubleValue5)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:0.33];
    testassert([n doubleValue] != 0.33);
    testassert([n doubleValue] - 0.33 < DBL_MIN);
    [n release];

    return YES;
}

test(DoubleValue6)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:(double)USHRT_MAX];
    testassert([n doubleValue] == (double)USHRT_MAX);
    [n release];
    
    return YES;
}

test(DoubleValue7)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:(double)USHRT_MAX + 1.0];
    testassert([n doubleValue] == 1.0 + (double)USHRT_MAX);
    [n release];

    return YES;
}

test(DoubleValue8)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:65536];
    testassert([n doubleValue] == 65536.0);
    [n release];

    return YES;
}

test(DoubleValue9)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:(double)ULLONG_MAX];
    testassert([n doubleValue] == 0.0); // WAT WAT WAT
    [n release];

    return YES;
}

test(DoubleValue10)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:1.0 + (double)ULLONG_MAX];
    testassert([n doubleValue] == 0.0);
    [n release];

    return YES;
}

test(DoubleValue11)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:2.0 * (double)ULLONG_MAX];
    testassert([n doubleValue] == 2.0 * (double)ULLONG_MAX);
    [n release];

    return YES;
}

test(DoubleValue12)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:123234623564.12351251345134];
    testassert([n doubleValue] != 123234623564.1235);
    testassert([n doubleValue] - 123234623564.1235 == 0.000030517578125);
    [n release];

    return YES;
}

test(DoubleValue13)
{
    NSDecimalNumber *n = nil;
    n = [[NSDecimalNumber alloc] initWithDouble:14143994781733811022ULL];
    testassert([n doubleValue] == 1.414399478173381E+19);
    [n release];

    return YES;
}

test(NanEquality)
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &nanDec);
    testassert(result == NSOrderedSame);
    return YES;
}

test(NanEquality2)
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal nanDec2 = [[NSDecimalNumber notANumber] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &nanDec2);
    testassert(result == NSOrderedSame);
    return YES;
}


test(NanEquality3)
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal zeroDec = [[NSDecimalNumber zero] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &zeroDec);
    testassert(result == NSOrderedAscending);
    return YES;
}

test(NanEquality4)
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal zeroDec = [[NSDecimalNumber zero] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&zeroDec, &nanDec);
    testassert(result == NSOrderedDescending);
    return YES;
}

test(NanEquality5)
{
    NSDecimal nanDec = [[NSDecimalNumber notANumber] decimalValue];
    NSDecimal oneDec = [[NSDecimalNumber one] decimalValue];
    NSComparisonResult result = NSDecimalCompare(&nanDec, &oneDec);
    testassert(result == NSOrderedAscending);
    return YES;
}

test(DecimalNumberDoubleValue)
{
    double zero = [[NSDecimalNumber zero] doubleValue];
    testassert(zero == 0.0);
    
    double one = [[NSDecimalNumber one] doubleValue];
    testassert(one == 1.0);
    
    double ten = [[NSDecimalNumber numberWithInt:10] doubleValue];
    testassert(ten == 10.0);
    
    double leet = [[NSDecimalNumber numberWithInt:1337] doubleValue];
    testassert(leet == 1337.0);
    
    double ushortMax = [[NSDecimalNumber numberWithInt:(unsigned short)-1] doubleValue];
    testassert(ushortMax == 65535.0);
    
    double uShortMaxPlusOne = [[NSDecimalNumber numberWithInt:((unsigned short)-1) + 1] doubleValue];
    testassert(uShortMaxPlusOne == 65536.0);
    
    NSDecimalNumber *dn = [[NSDecimalNumber alloc] initWithDouble:1.99];
    double d = [dn doubleValue];
    testassert(d >= 1.98999 && d <= 1.990001);
    
    return YES;
}
//
//test(DecimalNumberGetValueForType)
//{
//    NSDecimalNumber *dn = [[NSDecimalNumber alloc] initWithDouble:1.99];
//    double d;
//    [dn _getValue:&d forType:@encode(double)];
//    testassert(d >= 1.98999 && d <= 1.990001);
//    return YES;
//}

test(DecimalNumberInitWithDecimal)
{
    NSDecimalNumber *dn = [[NSDecimalNumber alloc] initWithDouble:1.99];
    NSDecimal dv = [dn decimalValue];
    NSDecimalNumber *dn2 = [[NSDecimalNumber alloc] initWithDecimal:dv];
    double d = [dn2 doubleValue];
    testassert(d >= 1.98999 && d <= 1.990001);
    
    [dn release];
    [dn2 release];
    
    return YES;
}

test(DecimalNumberCopy)
{
    NSDecimal decimalSource = [[NSDecimalNumber numberWithInt:1337] decimalValue];
    NSDecimal decimalDestination;
    NSDecimalCopy(&decimalDestination, &decimalSource);
        
    testassert(decimalDestination._exponent == decimalSource._exponent);
    testassert(decimalDestination._isCompact == decimalSource._isCompact);
    testassert(decimalDestination._isNegative == decimalSource._isNegative);
    testassert(decimalDestination._length == decimalSource._length);

    // _reserved is not copied
    for (int i = 0; i < decimalSource._length; i++) {
        testassert(decimalDestination._mantissa[i] == decimalSource._mantissa[i]);
    }
    
    return YES;
}

test(DecimalNumberGetValueForDecimal)
{
    NSDecimalNumber *dn = [[NSDecimalNumber alloc] initWithDouble:1.99];
    NSDecimal decimal = [dn decimalValue];
    decimal._mantissa[0] = 33;
    decimal._isNegative = YES;
    NSDecimalNumber *dn2 = [NSDecimalNumber decimalNumberWithDecimal:decimal];
    double d = [dn2 doubleValue];
    testassert(d >= -0.330001 && d <= -0.32999);
    
    [dn release];
    
    return YES;
}

test(DecimalNumberZeroOne)
{
    NSDecimalNumber *one = [NSDecimalNumber one];
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    NSDecimal decimal1 = [one decimalValue];
    NSDecimal decimal0 = [zero decimalValue];
    testassert(decimal1._mantissa[0] == 1);
    testassert(decimal0._mantissa[0] == 0);
    return YES;
}

test(DecimalNumber_notANumber)
{
    NSDecimalNumber *aNaN = [NSDecimalNumber notANumber];
    testassert(isnan([aNaN doubleValue]) != 0);
    return YES;
}

test(DecimalNumber_notANumber2)
{
    NSDecimalNumber *aNAN = [[NSDecimalNumber alloc] initWithDouble:NAN];
    NSDecimalNumber *notANumber = [NSDecimalNumber notANumber];
    
    testassert([aNAN isEqual:notANumber]);

    [aNAN release];
    return YES;
}

test(DecimalNumber_notANumber3a)
{
    NSDecimalNumber *notANumber = [NSDecimalNumber notANumber];
    
    NSDecimal dcm = [notANumber decimalValue];
    testassert(dcm._exponent == 0);
    testassert(dcm._length == 0);
    testassert(dcm._isNegative == 1);
    testassert(dcm._isCompact == 0);
    testassert(dcm._reserved == 0);
    for (unsigned int i=0; i<NSDecimalMaxSize; i++)
    {
        testassert(dcm._mantissa[i] == 0);
    }
    
    return YES;
}

test(DecimalNumber_notANumber3b)
{
    NSDecimalNumber *notANumber = [NSDecimalNumber notANumber];
    
    NSDecimal dcm = [notANumber decimalValue];
    testassert(dcm._exponent == 0);
    testassert(dcm._length == 0);
    testassert(dcm._isNegative == 1);
    testassert(dcm._isCompact == 0);
    testassert(dcm._reserved == 0);
    uint8_t *ptr = (uint8_t *)&dcm._mantissa;
    for (unsigned int i=0; i<NSDecimalMaxSize; i++)
    {
        testassert(ptr[i] == 0);
    }
    
    return YES;
}

test(DecimalNumber_notANumber4)
{
    NSDecimal dcm = { 0 };
    dcm._isNegative = 1;
    
    NSDecimalNumber *constructedNaN = [[NSDecimalNumber alloc] initWithDecimal:dcm];
    testassert([[NSDecimalNumber notANumber] isEqual:constructedNaN]);
    [constructedNaN release];
    
    return YES;
}

test(DecimalNumber_constructedNaN)
{
    NSDecimal dcm = { 0 };
    dcm._isNegative = 1;
    
    NSDecimalNumber *constructedNaN = [[NSDecimalNumber alloc] initWithDecimal:dcm];
    testassert(isnan([constructedNaN doubleValue]));
    [constructedNaN release];
    
    return YES;
}

test(DecimalNumber_notANumber_doubleBits)
{
    double d = [[NSDecimalNumber notANumber] doubleValue];
    uint8_t *buf = (uint8_t *)&d;
    
    testassert(sizeof(double) == 8);
    
    testassert(buf[0] == 0x0);
    testassert(buf[1] == 0x0);
    testassert(buf[2] == 0x0);
    testassert(buf[3] == 0x0);
    testassert(buf[4] == 0x0);
    testassert(buf[5] == 0x0);
    testassert(buf[6] == 0xf8);
    testassert(buf[7] == 0x7f);
    
    return YES;
}

test(DecimalNumberDefaultBehavior)
{
    id<NSDecimalNumberBehaviors> defaultBehavior = [NSDecimalNumber defaultBehavior];
    
    testassert([defaultBehavior roundingMode] == NSRoundPlain);
    testassert([defaultBehavior scale] == NSDecimalNoScale);
    
    SEL selectors[] = { 0, @selector(decimalNumberByAdding:), @selector(decimalNumberByDividingBy:),
        @selector(decimalNumberByMultiplyingBy:), @selector(decimalNumberByDividingBy:) };
    NSString *exceptionName[] = { nil, nil, @"NSDecimalNumberUnderflowException",
        @"NSDecimalNumberOverflowException", @"NSDecimalNumberDivideByZeroException" };
    NSString *exceptionReason[] = { nil, nil, @"NSDecimalNumber underflow exception",
        @"NSDecimalNumber overflow exception", @"NSDecimalNumber divide by zero exception" };
    BOOL expectException[] = { NO, NO, YES, YES, YES };
    
    for (int i=NSCalculationLossOfPrecision; i<=NSCalculationDivideByZero; ++i)
    {
        BOOL exception = NO;
        @try
        {
            NSDecimalNumber* result =
                [defaultBehavior exceptionDuringOperation:selectors[i] error:(NSCalculationError)i
                                              leftOperand:[NSDecimalNumber one] rightOperand:[NSDecimalNumber zero]];
            testassert(result == nil);
        }
        @catch (NSException *e)
        {
            testassert([exceptionName[i] isEqualToString:e.name]);
            testassert([exceptionReason[i] isEqualToString:e.reason]);
            exception = YES;
        }
        testassert(exception == expectException[i]);
    }
    
    return YES;
}

test(DecimalNumberDefaultBehaviorInternal)
{
    id<NSDecimalNumberBehaviors> defaultBehavior = [NSDecimalNumber defaultBehavior];
    testassert([(id)defaultBehavior class] == NSClassFromString(@"NSDecimalNumberHandler"));
    
    [NSDecimalNumber setDefaultBehavior:defaultBehavior];
    id<NSDecimalNumberBehaviors> tlsBehaviour =
        [[[NSThread currentThread] threadDictionary] objectForKey:@"NSDecimalNumberBehaviors"];
    testassert(defaultBehavior == tlsBehaviour);
    
    return YES;
}

test(DecimalNumberByAdding)
{
    NSDecimalNumber *result = [[NSDecimalNumber one] decimalNumberByAdding:[NSDecimalNumber one]];
    NSDecimalNumber *two = [NSDecimalNumber decimalNumberWithString:@"2"];
    
    testassert([result isEqualToNumber:two]);
    
    return YES;
}

test(DecimalNumberBySubtracting)
{
    NSDecimalNumber *result = [[NSDecimalNumber one] decimalNumberBySubtracting:[NSDecimalNumber one]];
    NSDecimalNumber *zero = [NSDecimalNumber zero];
    
    testassert([result isEqualToNumber:zero]);
    
    return YES;
}

test(DecimalNumberByMultiplyingBy)
{
    NSDecimalNumber *result = [[NSDecimalNumber decimalNumberWithString:@"2"] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
    NSNumber *four = [NSDecimalNumber numberWithInt:4];
    
    testassert([result isEqualToNumber:four]);
    
    return YES;
}

test(DecimalNumberByDividingBy)
{
    NSDecimalNumber *result = [[NSDecimalNumber decimalNumberWithString:@"2"] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"2"]];
    NSDecimalNumber *one = [NSDecimalNumber one];
    
    testassert([result isEqualToNumber:one]);
    
    return YES;
}

test(DecimalNumberByRaisingToPower)
{
    NSDecimalNumber *result = [[NSDecimalNumber decimalNumberWithString:@"2"] decimalNumberByRaisingToPower:2];
    NSNumber *four = [NSDecimalNumber numberWithInt:4];
    
    testassert([result isEqualToNumber:four]);
    
    return YES;
}

test(DecimalNumberByMultiplyingByPowerOf10)
{
    NSDecimalNumber *result = [[NSDecimalNumber decimalNumberWithString:@"2"] decimalNumberByMultiplyingByPowerOf10:2];
    NSDecimalNumber *twohundred = [NSDecimalNumber decimalNumberWithString:@"200"];
    
    testassert([result isEqualToNumber:twohundred]);
    
    return YES;
}

test(DecimalNumberCharValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.charValue == 42);
    return YES;
}

test(DecimalNumberUnsignedCharValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.unsignedCharValue == 42);
    return YES;
}

test(DecimalNumberShortValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.shortValue == 42);
    return YES;
}

test(DecimalNumberUnsignedShortValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.unsignedShortValue == 42);
    return YES;
}

test(DecimalNumberIntValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.intValue == 42);
    return YES;
}

test(DecimalNumberUnsignedIntValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.unsignedIntValue == 42);
    return YES;
}

test(DecimalNumberLongValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.longValue == 42);
    return YES;
}

test(DecimalNumberUnsignedLongValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.unsignedLongValue == 42);
    return YES;
}

test(DecimalNumberLongLongValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.longLongValue == 42);
    return YES;
}

test(DecimalNumberUnsignedLongLongValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.unsignedLongLongValue == 42);
    return YES;
}

test(DecimalNumberFloatValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"32"];
    testassert(number.floatValue == 32.f);
    return YES;
}

test(DecimalNumberBoolValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"-1"];
    testassert(number.boolValue);
    return YES;
}

test(DecimalNumberIntegerValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.integerValue == 42);
    return YES;
}

test(DecimalNumberUnsignedIntegerValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert(number.unsignedIntegerValue == 42);
    return YES;
}

test(DecimalNumberStringValue)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:@"42"];
    testassert([number.stringValue isEqualToString:@"42"]);
    return YES;
}

test(DecimalNumberCompare)
{
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:2 isNegative:NO];
    NSDecimalNumber *number2 = [NSDecimalNumber decimalNumberWithMantissa:42 exponent:0 isNegative:NO];
    NSDecimalNumber *number3 = [NSDecimalNumber decimalNumberWithMantissa:58 exponent:0 isNegative:NO];
    testassert([number compare:number] == NSOrderedSame);
    testassert([number compare:number2] == NSOrderedDescending);
    testassert([number2 compare:number3] == NSOrderedAscending);
    testassert([[number decimalNumberBySubtracting:number2] compare:number3] == NSOrderedSame);
    testassert([number compare:[number2 decimalNumberByAdding:number3]] == NSOrderedSame);
    return YES;
}

test(DecimalNumberCompareToNumber)
{
    NSNumber *number = [NSNumber numberWithInt:33600];
    NSDecimalNumber *number2 = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:2 isNegative:NO];
    NSDecimalNumber *number3 = [NSDecimalNumber decimalNumberWithMantissa:336 exponent:2 isNegative:NO];
    NSDecimalNumber *number4 = [NSDecimalNumber decimalNumberWithMantissa:54321 exponent:0 isNegative:NO];
    testassert([number compare:number2] == NSOrderedDescending);
    testassert([number compare:number3] == NSOrderedSame);
    testassert([number compare:number4] == NSOrderedAscending);
    
    testassert([number2 compare:number] == NSOrderedAscending);
    testassert([number3 compare:number] == NSOrderedSame);
    testassert([number4 compare:number] == NSOrderedDescending);
    return YES;
}

test(BooleanHash)
{
    struct { BOOL value; NSUInteger hash; } tests[] = {
        { NO,   0 },
        { YES,  2654435761U }
    };
    const int count = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<count; ++i) {
        NSDecimalNumber *decimal = (NSDecimalNumber*)[NSDecimalNumber numberWithBool:tests[i].value];
        testassert(decimal.hash == tests[i].hash);
    }
    
    return YES;
}

test(IntegerHash)
{
    struct { NSInteger value; NSUInteger hash; } tests[] = {
        { 0,            0 },
        { 1,            2654435761U },
        { -1,           2654435761U },
        { 42,           4112119562U },
        { -42,          4112119562U },
        { INT32_MIN,    2147483648U },
        { INT32_MAX,    3788015183U },
        { UINT32_MAX,   2654435761U }
    };
    const int count = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<count; ++i) {
        NSDecimalNumber *decimal = (NSDecimalNumber*)[NSDecimalNumber numberWithInteger:tests[i].value];
        testassert(decimal.hash == tests[i].hash);
    }
    
    return YES;
}

test(UnsignedIntegerHash)
{
    struct { NSUInteger value; NSUInteger hash; } tests[] = {
        { 0,            0 },
        { 1,            2654435761U },
        { 42,           4112119562U },
        { INT32_MAX,    3788015183U },
        { UINT32_MAX,   0 }
    };
    const int count = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<count; ++i) {
        NSDecimalNumber *decimal = (NSDecimalNumber*)[NSDecimalNumber numberWithUnsignedInteger:tests[i].value];
        testassert(decimal.hash == tests[i].hash);
    }
    
    return YES;
}

test(DoubleHash)
{
    struct { double value; NSUInteger hash; } tests[] = {
        { 0.,           0 },
        { 1.,           2654435761U },
        { 42.,          4112119562U },
        { INT32_MAX,    3788015183U },
        { UINT32_MAX,   0 }
    };
    const int count = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<count; ++i) {
        NSDecimalNumber *decimal = (NSDecimalNumber*)[NSDecimalNumber numberWithDouble:tests[i].value];
        testassert(decimal.hash == tests[i].hash);
    }
    
    return YES;
}

@end
