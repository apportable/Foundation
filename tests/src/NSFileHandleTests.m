//
//  NSFileHandleTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSFileHandle)
static inline NSString *TestFilePath() {
    NSString *path = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"test.txt"]];
    static BOOL created = NO;
    if(!created) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        created = YES;
    }
    return path;
}
test(NSFileHandlePathNonString)
{
    BOOL raised;
    @try {
       [NSFileHandle fileHandleForReadingAtPath:(id)@(0)];
    } @catch(NSException *e) {
        raised = YES;
        testassert([e.name isEqualToString:NSInvalidArgumentException]);
    }
    testassert(raised);
    
    return YES;
}
test(NSFileHandleNullDevice)
{
    NSFileHandle *h = [NSFileHandle fileHandleWithNullDevice];
    int fd = h.fileDescriptor;
    testassert(fd == -1);
    NSData *d = [h readDataOfLength:NSUIntegerMax];
    testassert(nil != d && d.length < 1);
    unsigned long long o = h.offsetInFile;
    testassert(o < 1);
    unsigned long long e = h.seekToEndOfFile;
    testassert(e < 1);
    NSData *ad = [h readDataOfLength:NSUIntegerMax];
    testassert(nil != ad && ad.length < 1);
    NSData *ed = [h readDataToEndOfFile];
    testassert(nil != ed && ed.length < 1);
    return YES;
}
test(NSFileHandleStandardIn)
{
    NSFileHandle *h = [NSFileHandle fileHandleWithStandardInput];
    testassert(nil != h);
    NSData *d = [h readDataToEndOfFile];
    testassert(nil != d && d.length < 1);
    return YES;
}

test(NSFileHandleStandardOut)
{
    NSFileHandle *h = [NSFileHandle fileHandleWithStandardOutput];
    NSLog(@"The next two lines should be written using NSFileHandle: ");
    [h writeData:[@"********************************************This was written to standard out using NSFileHandle.\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [h synchronizeFile];
    return YES;
}
test(NSFileHandleStandardErr)
{
    NSFileHandle *h = [NSFileHandle fileHandleWithStandardError];
    [h writeData:[@"********************************************This was written to standard error using NSFileHandle.\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [h synchronizeFile];
    return YES;
}
test(NSFileHandleInvalidFD)
{
    NSFileHandle *h = [[NSFileHandle alloc] initWithFileDescriptor:-1];
    testassert(nil != h);
    BOOL raised;
    @try {
        [h readDataToEndOfFile];
    }
    @catch (NSException *exception) {
        raised = YES;
        testassert([exception.name isEqualToString:NSFileHandleOperationException]);
    }
    testassert(raised);
    return YES;
}
test(NSFileHandleAllocInit)
{
    NSFileHandle *h = [[NSFileHandle alloc] init];
    testassert(h == nil);
    
    return YES;
}
test(NSFileHandleWriteToReader)
{
    NSFileHandle *h = [NSFileHandle fileHandleForReadingAtPath:TestFilePath()];
    BOOL raised;
    @try {
        [h writeData:[@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]];
    } @catch (NSException *e) {
        raised = YES;
        testassert([e.name isEqualToString:NSFileHandleOperationException]);
    }
    testassert(raised);
    
    return YES;
}
test(NSFileHandleSeekBeyondEnd)
{
    NSFileHandle *hw = [NSFileHandle fileHandleForWritingAtPath:TestFilePath()];
    [hw writeData:[@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]];
    [hw synchronizeFile];
    [hw closeFile];
    
    NSFileHandle *h = [NSFileHandle fileHandleForReadingAtPath:TestFilePath()];

    unsigned long long eof = [h seekToEndOfFile];
    [h seekToFileOffset:eof * 2];
    testassert(h.offsetInFile == eof * 2);
    testassert(h.availableData && h.availableData.length < 1);
    testassert(h.readDataToEndOfFile && h.readDataToEndOfFile.length < 1);
    
    
    return YES;
}
test(NSFileHandleInvalidURLScheme)
{
    NSError *error = nil;
    NSFileHandle *h = [NSFileHandle fileHandleForReadingFromURL:[NSURL URLWithString:@"willywonka://glasss.elevator/ballin.json"] error:&error];
    testassert(nil == h && nil != error);
    return YES;
}
test(NSFileHandleReadFromWriter)
{
    NSFileHandle *h = [NSFileHandle fileHandleForWritingAtPath:TestFilePath()];
    [h writeData:[@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]];
    BOOL raised;
    @try {
        [h readDataToEndOfFile];
    } @catch (NSException *e) {
        raised = YES;
        testassert([e.name isEqualToString:NSFileHandleOperationException]);
    }
    testassert(raised);
    
    return YES;
}
test(NSFileHandleWriteAfterClose)
{
    NSFileHandle *h = [NSFileHandle fileHandleForWritingAtPath:TestFilePath()];
    [h closeFile];
    BOOL raised;
    @try {
        [h writeData:[@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding]];
    } @catch (NSException *e) {
        raised = YES;
        testassert([e.name isEqualToString:NSFileHandleOperationException]);
    }
    testassert(raised);
    
    return YES;
}
test(NSFileHandlePathNil)
{
    id result = [NSFileHandle fileHandleForReadingAtPath:nil];
    if(!result) result = [NSFileHandle fileHandleForWritingAtPath:nil];
    if(!result) result = [NSFileHandle fileHandleForUpdatingAtPath:nil];
    testassert(result == nil);
    return YES;
}
test(NSFileHandleURLString)
{
    NSString *path = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"test.txt"]];
    BOOL raised;
    @try{
        [NSFileHandle fileHandleForReadingFromURL:(id)path error:NULL];
    } @catch (NSException *exception) {
        raised = YES;
        testassert([exception.name isEqualToString:NSInvalidArgumentException]);
    }
    testassert(raised);
    return YES;
}
test(NSFileHandleURLNil)
{
    id result0 = nil, result1 = nil, result2 = nil;
    NSError *error0 = nil, *error1 = nil, *error2 = nil;
    result0 = [NSFileHandle fileHandleForReadingFromURL:nil error:&error0];
    result1 = [NSFileHandle fileHandleForWritingToURL:nil error:&error1];
    result2 = [NSFileHandle fileHandleForUpdatingURL:nil error:&error2];
    testassert(result0 == result1 && result1 == result2 && result2 == nil);
    testassert(error0 == error1 && error1 == error2 && error2 == nil);
    return YES;
}

test(NSFileHandleReadData)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = @"NSFileHandleReadData";
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename];
    NSData *data = [NSData dataWithBytes:"abcxyz" length:6];
    
    // Ensure any file from a previous test run is removed
    [fileManager removeItemAtPath:path error:nil];
    
    testassert([data writeToFile:path atomically:NO]);
    
    NSFileHandle *f = [NSFileHandle fileHandleForReadingAtPath:path];
    testassert(f != nil);
    
    NSData* start = [f readDataOfLength:3];
    NSData* end = [f readDataOfLength:-1];
    NSData* extra = [f readDataOfLength:1];
    [f closeFile];
    
    NSMutableData *checkData = [NSMutableData dataWithData:start];
    [checkData appendData:end];
    testassert([checkData isEqualToData:data]);
    testassert(extra.length == 0);
    
    testassert([fileManager removeItemAtPath:path error:nil]);
    
    return YES;
}

test(NSFileHandleWriteData)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = @"NSFileHandleWriteData";
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@", filename];
    NSData *data = [NSData dataWithBytes:"abc" length:3];
    
    // Ensure any file from a previous test run is removed
    [fileManager removeItemAtPath:path error:nil];
    
    testassert([fileManager createFileAtPath:path contents:nil attributes:nil]);
    
    NSFileHandle *f = [NSFileHandle fileHandleForWritingAtPath:path];
    testassert(f != nil);

    [f writeData:data];
    [f closeFile];
    
    NSData *checkData = [NSData dataWithContentsOfFile:path];
    testassert([checkData isEqualToData:data]);
    
    testassert([fileManager removeItemAtPath:path error:nil]);
    
    return YES;
}

@end
