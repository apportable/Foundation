//
//  NSDataTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSData)

test(Allocate)
{
    NSData *d1 = [NSData alloc];
    NSData *d2 = [NSData alloc];

    testassert(d1 == d2);

    return YES;
}

test(InitWithContentsOfFileNil)
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:nil];
    testassert(data == nil);
    return YES;
}

test(DataWithContentsOfFileNil)
{
    NSData *data = [NSData dataWithContentsOfFile:nil];
    testassert(data == nil);
    return YES;
}

test(DataWithContentsOfMappedFileNil)
{
    NSData *data = [NSData dataWithContentsOfMappedFile:nil];
    testassert(data == nil);
    return YES;
}

test(InitWithContentsOfURLNil)
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:nil];
    testassert(data == nil);
    return YES;
}

test(DataWithContentsOfURLNil)
{
    NSData *data = [NSData dataWithContentsOfURL:nil];
    testassert(data == nil);
    return YES;
}

test(InitWithContentsOfURLNilOptionsError)
{
    void (^block)() = ^{
        [[NSData alloc] initWithContentsOfURL:nil options:0 error:NULL];
    };

    // initWithContentsOfURL:options:error: should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

test(InitWithContentsOfFileNilOptionsError)
{
    void (^block)() = ^{
        [[NSData alloc] initWithContentsOfFile:nil options:0 error:NULL];
    };

    // initWithContentsOfFile:options:error: should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

test(InitWithContentsOfURLGood)
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.apportable.com/about"]];
    testassert(data != nil);
    [data release];
    return YES;
}

test(InitWithContentsOfURLBad)
{
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.apportablexxxx.com/about"]];
    testassert(data == nil);
    [data release];
    return YES;
}

test(InitWithBytesNoCopy)
{
    NSData *data = [[NSData alloc] initWithBytes:"abcdefghi" length:9];
    char *bytes = (char *)[data bytes];
    NSData *data2 = [[NSData alloc] initWithBytesNoCopy:bytes length:[data length] freeWhenDone:NO];
    testassert([data length] == [data2 length]);
    testassert([data bytes] == [data2 bytes]);
    [data release];
    [data2 release];
    return YES;
}

test(InitWithBytesNoCopyFromConstantCString)
{
    char *abcdefg = "abcdefg";
    NSData *data = [[NSData alloc] initWithBytesNoCopy:abcdefg length:7 freeWhenDone:NO];
    testassert(abcdefg == [data bytes]);
    [data release];
    return YES;
}

test(SubdataWithRange)
{
    NSData *data = [[NSData alloc] initWithBytes:"abcdefghi" length:9];
    NSData *data3 = [data subdataWithRange:NSMakeRange(0, 9)];
    testassert([data3 length] == 9);
    const char *bytes  = [data  bytes];
    const char *bytes3 = [data3 bytes];
    
    for (int i = 0; i < 9; i++)
    {
        testassert(bytes[i] == bytes3[i]);
        testassert(bytes3[i] == 'a'+i); //typeof('a') => int
    }
    // now the interesting ones
    testassert(bytes == bytes3);
    [data release];
    return YES;
}

test(SubdataWithRange2)
{
    NSData *data = [[NSData alloc] initWithBytes:"abcdefghi" length:9];
    NSData *data2 = [data subdataWithRange:NSMakeRange(3, 3)];
    testassert([data2 length] == 3);
    const char *bytes  = [data  bytes];
    const char *bytes2 = [data2 bytes];
    
    testassert(bytes2[0] == 'd');
    testassert(bytes2[1] == 'e');
    testassert(bytes2[2] == 'f');
    // now the interesting ones
    testassert(bytes2 - bytes != 3); // they are not (part of) the same object
    [data release];
    return YES;
}

test(SubdataWithRange3)
{
    //behavior persists when both happen
    NSData *data = [[NSData alloc] initWithBytes:"abcdefghi" length:9];
    NSData *data2 = [data subdataWithRange:NSMakeRange(3, 3)];
    NSData *data3 = [data subdataWithRange:NSMakeRange(0, 9)];
    testassert([data2 length] == 3);
    testassert([data3 length] == 9);
    const char *bytes  = [data  bytes];
    const char *bytes2 = [data2 bytes];
    const char *bytes3 = [data3 bytes];

    testassert(bytes2[0] == 'd');
    testassert(bytes2[1] == 'e');
    testassert(bytes2[2] == 'f');
    for (int i = 0; i < 9; i++)
    {
        testassert(bytes[i] == bytes3[i]);
        testassert(bytes3[i] == 'a'+i); //typeof('a') => int
    }
    // now the interesting ones
    testassert(bytes == bytes3);
    testassert(bytes2 - bytes != 3); // they are not the same object
    [data release];
    return YES;
}

test(SubdataWithShorterRange)
{
    NSData *data = [[NSData alloc] initWithBytes:"abcdefghi" length:9];
    NSData *data3 = [data subdataWithRange:NSMakeRange(0, 7)];
    testassert([data3 length] == 7);
    const char *bytes  = [data  bytes];
    const char *bytes3 = [data3 bytes];
    
    for (int i = 0; i < 7; i++)
    {
        testassert(bytes[i] == bytes3[i]);
        testassert(bytes3[i] == 'a'+i); //typeof('a') => int
    }
    // now the interesting ones
    testassert(bytes != bytes3);
    [data release];
    return YES;
}

test(MutableDataWithLength)
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    testassert([data length] == 7);
    return YES;
}

test(MutableDataWithData)
{
    NSData *data = [NSData dataWithBytes:"abc" length:3];
    NSMutableData *data2 = [NSMutableData dataWithData:data];
    testassert([data2 length] == 3);
    return YES;
}

test(MutableDataWithDataMutable)
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    NSMutableData *data2 = [NSMutableData dataWithData:data];
    testassert([data2 length] == 7);
    return YES;
}

test(MutableDataFromInitWithBytesNoCopyFromConstantCString)
{
    char *abcdefg = "abcdefg";
    NSMutableData *data = [[NSMutableData alloc] initWithBytesNoCopy:abcdefg length:7 freeWhenDone:NO];
    testassert(abcdefg != [data bytes]);
    testassert(abcdefg != [data mutableBytes]);
    [data release];
    return YES;
}

test(MutableDataAppendBytes)
{
    NSMutableData *data = [NSMutableData dataWithLength:7];
    [data appendBytes:"abc" length:3];
    [data appendBytes:"def" length:3];

    testassert([data length] == 13);

    const char *bytes = [data bytes];

    for (int i = 0; i < 7; i++)
    {
        testassert(bytes[i] == 0);
    }
    testassert(!strncmp("abcdef", bytes + 7, 6));

    return YES;
}

test(MutableDataAppendBytesForcingRealloc)
{
    NSMutableData *data = [NSMutableData dataWithLength:2];
    [data appendBytes:"abc" length:3];
    [data appendBytes:"def" length:3];

    testassert([data length] == 8);

    const char *bytes = [data bytes];

    for (int i = 0; i < 2; i++)
    {
        testassert(bytes[i] == 0);
    }
    testassert(!strncmp("abcdef", bytes + 2, 6));

    return YES;
}

test(MutableBytesVsBytes)
{
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:"abcdefghi" length:9];
    const char *bytes = [data bytes];
    char *mutableBytes = [data mutableBytes];
    testassert(bytes == mutableBytes);
    [data release];
    return YES;
}

test(MutableBytesChangedVsBytes)
{
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:"abcdefghi" length:9];
    const char *bytes = [data bytes];
    char *mutableBytes = [data mutableBytes];
    mutableBytes[0] = 'z';
    testassert(bytes == mutableBytes);
    testassert(bytes[0] == 'z');
    [data release];
    return YES;
}

test(MutableSubdata)
{
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:"abcdefghi" length:9];
    NSMutableData *data2 = [NSMutableData dataWithData:[data subdataWithRange:NSMakeRange(0, 9)]];
    testassert([data bytes] != [data2 bytes]);
    testassert([data isEqual:data2]);
    [data release];
    return YES;
}

test(MutableDataFromInitWithBytesNoCopy)
{
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:"abcdefghi" length:9];
    char *mutableBytes = [data mutableBytes];
    NSMutableData *data2 = [[NSMutableData alloc] initWithBytesNoCopy:mutableBytes length:9 freeWhenDone:NO];
    const char *bytes = [data bytes];
    const char *bytes2 = [data2 bytes];
    char *mutableBytes2 = [data2 mutableBytes];
    testassert(bytes != bytes2);
    testassert(mutableBytes != mutableBytes2); // So much for NoCopy.
    [data release];
    [data2 release];
    return YES;
}

test(MutableDataFromInitWithBytesNoCopyFromImmutableBytes)
{
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:"abcdefghi" length:9];
    char *bytes = (char *)[data bytes];
    NSMutableData *data2 = [[NSMutableData alloc] initWithBytesNoCopy:bytes length:9 freeWhenDone:NO];
    char *mutableBytes = [data mutableBytes];
    const char *bytes2 = [data2 bytes];
    char *mutableBytes2 = [data2 mutableBytes];
    testassert(bytes != bytes2);
    testassert(mutableBytes != mutableBytes2); // So much for NoCopy.
    [data release];
    [data2 release];
    return YES;
}

test(MutableDataFromInitWithBytesNoCopyFromImmutableDataBytes)
{
    NSData *data = [[NSData alloc] initWithBytes:"abcdefghi" length:9];
    char *bytes = (char *)[data bytes];
    NSMutableData *data2 = [[NSMutableData alloc] initWithBytesNoCopy:bytes length:9 freeWhenDone:NO];
    const char *bytes2 = [data2 bytes];
    char *mutableBytes2 = [data2 mutableBytes];
    testassert(bytes != bytes2); // still does copy.
    testassert(mutableBytes2 == bytes2);
    [data release];
    [data2 release];
    return YES;
}

test(MutableDataReplaceBytes)
{
    NSMutableData *data = [NSMutableData dataWithLength:16];
    testassert([data length] == 16);

    [data replaceBytesInRange:NSMakeRange(0, 4) withBytes:"wxyz"];
    testassert([data length] == 16);

    const char *bytes = [data bytes];
    testassert(!strncmp(bytes, "wxyz", 4));

    for (int i = 4; i < 16; i++)
    {
        testassert(bytes[i] == 0);
    }

    return YES;
}

test(MutableDataReplaceBytesExtend)
{
    const char *letters = "abcdefghijklmnop";
    testassert(strlen(letters) == 16);
    NSMutableData *data = [NSMutableData dataWithLength:strlen(letters)];
    [data replaceBytesInRange:NSMakeRange(8, 16) withBytes:letters];

    testassert([data length] == 24);

    const char *bytes = [data bytes];
    for (int i = 0; i < 8; i++)
    {
        testassert(bytes[i] == 0);
    }

    testassert(!strncmp(bytes + 8, letters, strlen(letters)));

    return YES;
}

test(MutableDataReplaceBytesLength)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"abcdefghij" length:10];
    testassert(d != nil);

    [d replaceBytesInRange:NSMakeRange(2, 4) withBytes:"wxyz" length:2];
    testassert(!strncmp([d bytes], "abwxghij", 8));
    testassert([d length] == 8);

    return YES;
}

test(MutableDataReplaceBytesSameLength)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"abcdefgh" length:8];
    testassert(d != nil);

    [d replaceBytesInRange:NSMakeRange(2, 4) withBytes:"wxyz" length:4];
    testassert(!strncmp([d bytes], "abwxyzgh", 8));
    testassert([d length] == 8);

    return YES;
}

test(MutableDataReplaceBytesLengthNull)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"abcdefgh" length:8];
    testassert(d != nil);

    [d replaceBytesInRange:NSMakeRange(1, 1) withBytes:NULL length:0];
    testassert(!strncmp([d bytes], "acdefgh", 7));
    testassert([d length] == 7);

    [d replaceBytesInRange:NSMakeRange(2, 4) withBytes:NULL length:2];
    testassert([d length] == 5);
    char expectedBytes[5] = { 0x61, 0x63, 0x0, 0x0, 0x68 };
    const char *bytes = [d bytes];
    for (int i = 0; i < 5; i++)
    {
        testassert(bytes[i] == expectedBytes[i]);
    }

    return YES;
}

test(MutableDataReplaceBytesLengthExtendByPrepend)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"abcdefgh" length:8];
    testassert(d != nil);
    
    [d replaceBytesInRange:NSMakeRange(0, 0) withBytes:"zyxwvut" length:7];
    testassert(!strncmp([d bytes], "zyxwvutabcdefgh", 15));
    testassert([d length] == 15);
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapStartGrow)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(0, 0) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "2234411122344555", 16));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapStartGrowLess)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(0, 1) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "223441122344555", 15));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapStartEven)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(0, 5) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "22344344555", 11));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapStartEvenSameContent)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(0, 5) withBytes:bytes length:5];
    testassert(!strncmp([d bytes], "11122344555", 11));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapStartShrink)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(0, 6) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "2234444555", 10));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapStartShrinkMost)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(0, [d length]) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "22344", 5));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapMidGrow)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(5, 0) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "1112222344344555", 16));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapMidGrowLess)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(5, 1) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "111222234444555", 15));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapMidGrowEven)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(3, 5) withBytes:bytes length:5];
    testassert(!strncmp([d bytes], "11111122555", 11));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapMidGrowEvenSameContent)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(3, 5) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "11122344555", 11));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapMidShrink)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(2, 7) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "112234455", 9));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapMidShrinkMore)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(1, 9) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "1223445", 7));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapEndGrow)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(11, 0) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "1112234455522344", 16));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapEndGrowLess)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(10, 1) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "111223445522344", 15));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapEndEven)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(6, 5) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "11122322344", 11));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapEndEvenSameContent)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(6, 5) withBytes:bytes + 6 length:5];
    testassert(!strncmp([d bytes], "11122344555", 11));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapEndShrink)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(5, 6) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "1112222344", 10));
    
    return YES;
}

test(MutableDataReplaceBytesLengthOverlapEndShrinkMost)
{
    NSMutableData *d = [NSMutableData dataWithBytes:"11122344555" length:11];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(1, 10) withBytes:bytes + 3 length:5];
    testassert(!strncmp([d bytes], "122344", 6));
    
    return YES;
}

test(MutableDataResetBytes)
{
    NSMutableData *data = [NSMutableData dataWithLength:16];
    testassert([data length] == 16);

    [data replaceBytesInRange:NSMakeRange(0, 6) withBytes:"wxyzab"];
    [data resetBytesInRange:NSMakeRange(4, 16)];
    testassert([data length] == 20);

    const char *bytes = [data bytes];
    testassert(!strncmp(bytes, "wxyz", 4));

    for (int i = 4; i < 20; i++)
    {
        testassert(bytes[i] == 0);
    }

    return YES;
}

test(RangeOfData)
{
    const char *bytes = "abcdabcdbcd";
    NSData *data = [NSData dataWithBytes:bytes length:strlen(bytes)];
    NSData *searchData4 = [NSData dataWithBytes:"abcd" length:4];
    NSData *searchData3 = [NSData dataWithBytes:"bcd" length:3];
    NSData *searchData0 = [NSData data];
    NSRange range;

    range = [data rangeOfData:searchData0 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData4 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == 0);
    testassert(range.length == 4);

    range = [data rangeOfData:searchData4 options:0 range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 4);
    testassert(range.length == 4);

    range = [data rangeOfData:searchData4 options:NSDataSearchAnchored range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData4 options:NSDataSearchBackwards range:NSMakeRange(0, [data length])];
    testassert(range.location == 4);
    testassert(range.length == 4);

    range = [data rangeOfData:searchData4 options:NSDataSearchAnchored|NSDataSearchBackwards range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData3 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:0 range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:0 range:NSMakeRange(1, 2)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchData3 options:NSDataSearchAnchored range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:NSDataSearchBackwards range:NSMakeRange(0, [data length])];
    testassert(range.location == 8);
    testassert(range.length == 3);

    range = [data rangeOfData:searchData3 options:NSDataSearchAnchored|NSDataSearchBackwards range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 8);
    testassert(range.length == 3);

    return YES;
}

test(NSData_writeToFileAtomicallyYes)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput0"];

    BOOL result = [data writeToFile:filePath atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSData_writeToFileAtomically_withNilValue)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    BOOL result = [data writeToFile:nil atomically:YES];
    testassert(!result);
    return YES;
}

test(NSData_writeToFileAtomically_withEmptyValue)
{
    NSData *data = [NSData data];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];

    BOOL result = [data writeToFile:filePath atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSData_writeToURLAtomicallyYes)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput0"];

    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSData_writeToURLAtomically_withNilValue)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    BOOL result = [data writeToURL:nil atomically:YES];
    testassert(!result);
    return YES;
}

test(NSData_writeToURLAtomically_withEmptyValue)
{
    NSData *data = [NSData data];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];

    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSData_writeToFile_options_error)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput100"];

    NSError *error = nil;
    BOOL result = [data writeToFile:filePath options:0 error:&error];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSData_writeToNilFile_options_error)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];

    NSError *error = nil;

    BOOL exception = NO;
    @try {
        [data writeToFile:nil options:0 error:&error];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }

    testassert(exception);
    testassert(error == nil);

    return YES;
}

test(NSData_writeToURL_options_error)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSDataOutput100"];

    NSError *error = nil;
    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] options:0 error:&error];
    testassert(result);

    NSData *data2 = [NSData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSData_writeToNilURL_options_error)
{
    const char bytes[] = {"foo"};
    NSData *data = [NSData dataWithBytes:bytes length:4];

    NSError *error = nil;

    BOOL exception = NO;
    @try {
        [data writeToURL:nil options:0 error:&error];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }

    testassert(exception);
    testassert(error == nil);

    return YES;
}

test(NoCopySmallAllocation)
{
    char *buffer = malloc(10);
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:10 freeWhenDone:YES];
    testassert([data bytes] == buffer);
    return YES;
}

test(InitWithData)
{
    NSData *d1 = [NSData dataWithBytes:"abc" length:3];
    NSData *d2 = [[[NSData alloc] initWithData:d1] autorelease];
    testassert([d1 isEqualToData:d2]);

    return YES;
}

test(InitWithEmptyData)
{
    NSData *d1 = [NSData dataWithBytes:"" length:0];
    testassert([d1 length] == 0);

    NSData *d2 = [[[NSData alloc] initWithData:d1] autorelease];
    testassert(d2 != nil);
    testassert([d2 length] == 0);

    return YES;
}

@end
