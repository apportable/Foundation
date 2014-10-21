//
//  NSPurgeableDataTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSPurgeableData)

test(Allocate)
{
    NSPurgeableData *d1 = [NSPurgeableData alloc];
    NSPurgeableData *d2 = [NSPurgeableData alloc];

    testassert(d1 != d2);

    return YES;
}

test(Init)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] init] autorelease];
    testassert(d != nil);

    return YES;
}

test(InitWithContentsOfFileNil)
{
    NSPurgeableData *data = [[NSPurgeableData alloc] initWithContentsOfFile:nil];
    testassert(data == nil);
    return YES;
}

test(PurgeableDataWithContentsOfFileNil)
{
    NSPurgeableData *data = [NSPurgeableData dataWithContentsOfFile:nil];
    testassert(data == nil);
    return YES;
}

test(PurgeableDataWithContentsOfMappedFileNil)
{
    NSPurgeableData *data = [NSPurgeableData dataWithContentsOfMappedFile:nil];
    testassert(data == nil);
    return YES;
}

test(InitWithContentsOfURLNil)
{
    NSPurgeableData *data = [[NSPurgeableData alloc] initWithContentsOfURL:nil];
    testassert(data == nil);
    return YES;
}

test(PurgeableDataWithContentsOfURLNil)
{
    NSPurgeableData *data = [NSPurgeableData dataWithContentsOfURL:nil];
    testassert(data == nil);
    return YES;
}

test(InitWithContentsOfURLNilOptionsError)
{
    void (^block)() = ^{
        [[NSPurgeableData alloc] initWithContentsOfURL:nil options:0 error:NULL];
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
        [[NSPurgeableData alloc] initWithContentsOfFile:nil options:0 error:NULL];
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
    NSPurgeableData *data = [[NSPurgeableData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.apportable.com/about"]];
    testassert(data != nil);
    [data release];
    return YES;
}

test(InitWithContentsOfURLBad)
{
    NSPurgeableData *data = [[NSPurgeableData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://www.apportablexxxx.com/about"]];
    testassert(data == nil);
    [data release];
    return YES;
}

test(PurgeableDataWithLength)
{
    NSPurgeableData *data = [NSPurgeableData dataWithLength:7];
    testassert([data length] == 7);
    return YES;
}

test(PurgeableDataWithPurgeableData)
{
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:"abc" length:3];
    NSPurgeableData *data2 = [NSPurgeableData dataWithData:data];
    testassert([data2 length] == 3);
    return YES;
}

test(PurgeableDataAppendBytes)
{
    NSPurgeableData *data = [NSPurgeableData dataWithLength:7];
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

test(PurgeableDataAppendBytesForcingRealloc)
{
    NSPurgeableData *data = [NSPurgeableData dataWithLength:2];
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

test(PurgeableDataReplaceBytes)
{
    NSPurgeableData *data = [NSPurgeableData dataWithLength:16];
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

test(PurgeableDataReplaceBytesExtend)
{
    const char *letters = "abcdefghijklmnop";
    testassert(strlen(letters) == 16);
    NSPurgeableData *data = [NSMutableData dataWithLength:strlen(letters)];
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

test(PurgeableDataReplaceBytesLength)
{
    NSPurgeableData *d = [NSPurgeableData dataWithBytes:"abcdefgh" length:8];
    testassert(d != nil);

    [d replaceBytesInRange:NSMakeRange(2, 4) withBytes:"wxyz" length:2];
    testassert(!strncmp([d bytes], "abwxghgh", 8));

    return YES;
}

test(PurgeableDataReplaceBytesSameLength)
{
    NSPurgeableData *d = [NSPurgeableData dataWithBytes:"abcdefgh" length:8];
    testassert(d != nil);

    [d replaceBytesInRange:NSMakeRange(2, 4) withBytes:"wxyz" length:4];
    testassert(!strncmp([d bytes], "abwxyzgh", 8));

    return YES;
}

test(PurgeableDataReplaceBytesLengthNull)
{
    NSPurgeableData *d = [NSPurgeableData dataWithBytes:"abc" length:3];
    testassert(d != nil);

    [d replaceBytesInRange:NSMakeRange(1, 1) withBytes:NULL length:0];
    testassert(!strncmp([d bytes], "ac", 2));

    return YES;
}

test(MutableDataReplaceBytesLengthOverlap)
{
    NSPurgeableData *d = [NSPurgeableData dataWithBytes:"abcdefgh" length:8];
    const char *bytes = [d bytes];
    [d replaceBytesInRange:NSMakeRange(2, 4) withBytes:bytes + 4 length:2];
    testassert(!strncmp([d bytes], "abefgh", 6));

    return YES;
}

test(PurgeableDataResetBytes)
{
    NSPurgeableData *data = [NSPurgeableData dataWithLength:16];
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

test(RangeOfPurgeableData)
{
    const char *bytes = "abcdabcdbcd";
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:strlen(bytes)];
    NSPurgeableData *searchPurgeableData4 = [NSPurgeableData dataWithBytes:"abcd" length:4];
    NSPurgeableData *searchPurgeableData3 = [NSPurgeableData dataWithBytes:"bcd" length:3];
    NSPurgeableData *searchPurgeableData0 = [NSPurgeableData data];
    NSRange range;

    range = [data rangeOfData:searchPurgeableData0 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchPurgeableData4 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == 0);
    testassert(range.length == 4);

    range = [data rangeOfData:searchPurgeableData4 options:0 range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 4);
    testassert(range.length == 4);

    range = [data rangeOfData:searchPurgeableData4 options:NSDataSearchAnchored range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchPurgeableData4 options:NSDataSearchBackwards range:NSMakeRange(0, [data length])];
    testassert(range.location == 4);
    testassert(range.length == 4);

    range = [data rangeOfData:searchPurgeableData4 options:NSDataSearchAnchored|NSDataSearchBackwards range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchPurgeableData3 options:0 range:NSMakeRange(0, [data length])];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchPurgeableData3 options:0 range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchPurgeableData3 options:0 range:NSMakeRange(1, 2)];
    testassert(range.location == NSNotFound);
    testassert(range.length == 0);

    range = [data rangeOfData:searchPurgeableData3 options:NSDataSearchAnchored range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 1);
    testassert(range.length == 3);

    range = [data rangeOfData:searchPurgeableData3 options:NSDataSearchBackwards range:NSMakeRange(0, [data length])];
    testassert(range.location == 8);
    testassert(range.length == 3);

    range = [data rangeOfData:searchPurgeableData3 options:NSDataSearchAnchored|NSDataSearchBackwards range:NSMakeRange(1, [data length] - 1)];
    testassert(range.location == 8);
    testassert(range.length == 3);

    return YES;
}

test(NSPurgeableData_writeToFileAtomicallyYes)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSPurgeableDataOutput0"];

    BOOL result = [data writeToFile:filePath atomically:YES];
    testassert(result);

    NSPurgeableData *data2 = [NSPurgeableData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSPurgeableData_writeToFileAtomically_withNilValue)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];
    BOOL result = [data writeToFile:nil atomically:YES];
    testassert(!result);
    return YES;
}

test(NSPurgeableData_writeToFileAtomically_withEmptyValue)
{
    NSPurgeableData *data = [NSPurgeableData data];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];

    BOOL result = [data writeToFile:filePath atomically:YES];
    testassert(result);

    NSPurgeableData *data2 = [NSPurgeableData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSPurgeableData_writeToURLAtomicallyYes)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSPurgeableDataOutput0"];

    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSPurgeableData *data2 = [NSPurgeableData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSPurgeableData_writeToURLAtomically_withNilValue)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];
    BOOL result = [data writeToURL:nil atomically:YES];
    testassert(!result);
    return YES;
}

test(NSPurgeableData_writeToURLAtomically_withEmptyValue)
{
    NSPurgeableData *data = [NSPurgeableData data];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DictionaryTest1"];

    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
    testassert(result);

    NSPurgeableData *data2 = [NSPurgeableData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSPurgeableData_writeToFile_options_error)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSPurgeableDataOutput100"];

    NSError *error = nil;
    BOOL result = [data writeToFile:filePath options:0 error:&error];
    testassert(result);

    NSPurgeableData *data2 = [NSPurgeableData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSPurgeableData_writeToNilFile_options_error)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];

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

test(NSPurgeableData_writeToURL_options_error)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"NSPurgeableDataOutput100"];

    NSError *error = nil;
    BOOL result = [data writeToURL:[NSURL fileURLWithPath:filePath] options:0 error:&error];
    testassert(result);

    NSPurgeableData *data2 = [NSPurgeableData dataWithContentsOfFile:filePath];
    testassert([data2 isEqualToData:data]);

    return YES;
}

test(NSPurgeableData_writeToNilURL_options_error)
{
    const char bytes[] = {"foo"};
    NSPurgeableData *data = [NSPurgeableData dataWithBytes:bytes length:4];

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

#pragma mark - NSDiscardableContent tests

test(DiscardableContentProtocol)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] init] autorelease];

    testassert([d respondsToSelector:@selector(beginContentAccess)]);
    testassert([d respondsToSelector:@selector(endContentAccess)]);
    testassert([d respondsToSelector:@selector(discardContentIfPossible)]);
    testassert([d respondsToSelector:@selector(isContentDiscarded)]);

    return YES;
}

test(ContentAccessCount)
{
    NSPurgeableData *d = [NSPurgeableData data]; // Access count 1 on allocation
    [d beginContentAccess]; // Access count 2
    [d endContentAccess]; // 1
    [d endContentAccess]; // 0

    BOOL raised = NO;
    @try {
        [d endContentAccess]; // -1, will throw
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSGenericException];
    }
    testassert(raised);

    return YES;
}

test(ContentAccessScope_Bytes)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] initWithBytes:"abc" length:3] autorelease];

    testassert([d bytes] != NULL);

    [d endContentAccess];

    BOOL raised = NO;
    @try {
        [d bytes];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSGenericException];
    }
    testassert(raised);

    return YES;
}

test(ContentAccessScope_MutableBytes)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] initWithBytes:"abc" length:3] autorelease];

    testassert([d mutableBytes] != NULL);

    [d endContentAccess];

    BOOL raised = NO;
    @try {
        [d mutableBytes];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSGenericException];
    }
    testassert(raised);

    return YES;
}

test(ContentAccessScope_Length)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] initWithBytes:"abc" length:3] autorelease];

    testassert([d length] == 3);

    [d endContentAccess];

    BOOL raised = NO;
    @try {
        [d length];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSGenericException];
    }
    testassert(raised);

    return YES;
}

test(ContentAccessScope_SetLength)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] initWithBytes:"abc" length:3] autorelease];

    [d setLength:5];
    testassert([d length] == 5);

    [d endContentAccess];

    BOOL raised = NO;
    @try {
        [d setLength:6];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSGenericException];
    }
    testassert(raised);

    return YES;
}

test(ContentAccessScope_Description)
{
    NSPurgeableData *d = [[[NSPurgeableData alloc] initWithBytes:"abc" length:3] autorelease];

    testassert([[d description] isEqualToString:@"<616263>"]);

    [d endContentAccess];

    testassert([[d description] isEqualToString:[NSString stringWithFormat:@"<NSPurgeableData: %p>", d]]);

    return YES;
}

@end
