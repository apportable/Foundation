//
//  NSFileManagerTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <objc/runtime.h>

@interface NSFileManager (Internal)
- (BOOL)getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxLength withPath:(NSString *)path;
@end

@testcase(NSFileManager)


test(URLsForDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    testassert([directories count] > 0);
    return YES;
}

test(FileDoesNotExist)
{
    NSFileManager* manager = [NSFileManager defaultManager];
    testassert([manager fileExistsAtPath:@"IDontExist"] == NO);
    return YES;
}

static NSString *makePath(NSFileManager *manager, NSString *name)
{
    NSError *error;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES );
    NSString* dir = [paths objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:name];
    [manager removeItemAtPath:path error:&error];
    return path;
}

test(CreateFile)
{
    NSFileManager* manager = [NSFileManager defaultManager];
    testassert([manager createFileAtPath:makePath(manager, @"createTest") contents:nil attributes:nil] == YES);
    return YES;
}

test(FileSize)
{
    NSError* error;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *path = makePath(manager, @"fileSizeTest");
    testassert([manager createFileAtPath:path contents:nil attributes:nil]);
    NSDictionary* attrs = [manager attributesOfItemAtPath:path error:&error];
    NSNumber* size = [attrs objectForKey:NSFileSize];
    testassert(size.longValue == 0);
    return YES;
}

static NSDictionary* AttributesOfFileSystemForPath(NSString *path)
{
    char pathbuf[PATH_MAX];
    if (![path getFileSystemRepresentation:pathbuf maxLength:PATH_MAX])
    {
        return nil;
    }
    
    struct statfs statbuf;
    if (statfs(pathbuf, &statbuf) != 0)
    {
        return nil;
    }
    
    const int numAttributes = 5;
    
    NSString *keys[numAttributes] = {
        NSFileSystemNumber,
        NSFileSystemSize,
        NSFileSystemFreeSize,
        NSFileSystemNodes,
        NSFileSystemFreeNodes
    };
    
    unsigned long long blocksize = statbuf.f_bsize;
    long fsnumber;
    memcpy(&fsnumber, &statbuf.f_fsid, sizeof(fsnumber));
    
    NSNumber *objects[numAttributes] = {
        [NSNumber numberWithUnsignedLong:fsnumber],
        [NSNumber numberWithUnsignedLongLong:blocksize * (unsigned long long)statbuf.f_blocks],
        [NSNumber numberWithUnsignedLongLong:blocksize * (unsigned long long)statbuf.f_bavail],
        [NSNumber numberWithLong:statbuf.f_files],
        [NSNumber numberWithLong:statbuf.f_ffree],
    };
    
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys count:numAttributes];
}

test(FileSystemAttributes)
{
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *attributes = [manager attributesOfFileSystemForPath:paths[0] error:&error];
    testassert(attributes != nil);
    testassert(error == nil);
    
    NSDictionary *testAttributes = AttributesOfFileSystemForPath(paths[0]);
    testassert([attributes isEqualToDictionary:testAttributes]);
    
    return YES;
}

test(ContentsOfDirectoryAtPath)
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents count] >= 8);   /* more items are likely to be added over time */
    testassert([bundleContents containsObject:@"Info.plist"]);
    testassert(error == nil);
    return YES;
}

test(ContentsOfDirectoryAtPathWithHiddenFile)
{
    NSError *error = nil;
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"ihavehiddenfile"];
    NSArray *hiddenContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    testassert([hiddenContents containsObject:@".hidden"]);
    testassert(error == nil);
    return YES;
}

/* Android and iOS main bundle matches except for FoundationTests and PkgInfo */

test(MainBundleContentsTODO)
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents containsObject:@"FoundationTests"]);
    testassert([bundleContents containsObject:@"PkgInfo"]);
    return YES;
}

test(ContentsOfDirectoryAtPathWithExtension)
{
    NSError *error = nil;
    NSArray *bundleContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle mainBundle] bundlePath] error:&error];
    testassert([bundleContents count] >= 8);   /* more items are likely to be added over time */
    testassert([bundleContents containsObject:@"Info.plist"]);
    testassert(error == nil);
    return YES;
}

test(DirectoryEnumeratorAtPath)
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    testassert(enumerator != nil);
    NSString *item = nil;
    NSUInteger count = 0;
    BOOL asset0Found = NO;
    BOOL bundle0Found = NO;
    BOOL bundle0ContentsFound = NO;
    BOOL enLprojInfoPlistStringsFound = NO;
    while (item = [enumerator nextObject])
    {
        if ([item isEqualToString:@"0.asset"])
        {
            asset0Found = YES;
        }
        else if ([item isEqualToString:@"0.bundle"])
        {
            bundle0Found = YES;
        }
        else if ([item isEqualToString:@"0.bundle/0-0.bundle"])
        {
            bundle0ContentsFound = YES;
        }
        else if ([item isEqualToString:@"en.lproj/InfoPlist.strings"])
        {
            enLprojInfoPlistStringsFound = YES;
        }
        count++;
    }
    testassert(count > 1);
    testassert(asset0Found);
    testassert(bundle0Found);
    testassert(bundle0ContentsFound);
    testassert(enLprojInfoPlistStringsFound);
    return YES;
}

test(DirectoryEnumeratorAtNilURL)
{
    void (^block)() = ^{
        [[NSFileManager defaultManager] enumeratorAtURL:nil includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    };
    
    // Enumerator with nil URL is invalid
    BOOL raised = NO;
    
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSInvalidArgumentException];
    }
    
    testassert(raised);
    return YES;
}

test(DirectoryEnumeratorAtPathOrder)
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *item = NULL;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while (item = [enumerator nextObject]) {
        [results addObject:item];
    }
    NSMutableArray *resultsBeforeSort = [NSMutableArray arrayWithArray:results];
    [results sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int i = 0; i < [resultsBeforeSort count]; i++) {
        testassert([[resultsBeforeSort objectAtIndex:i] isEqualToString:[results objectAtIndex:i]]);
    }
    return YES;
}

test(DirectoryEnumeratorAtPathNoStandardPath)
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"."];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *item = NULL;
    while (item = [enumerator nextObject]) {
        testassert([item isEqualToString:[item stringByStandardizingPath]]);
    }

    return YES;
}

test(DirectoryEnumeratorAtURLOrder)
{
    __block BOOL errorOccurred = NO;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        errorOccurred = YES;
        return YES;
    }];
    NSURL *item = NULL;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableArray *resultsInStr = [[NSMutableArray alloc] init];
    while (item = [enumerator nextObject]) {
        [results addObject:item];
        [resultsInStr addObject:item.path];
    }
    [resultsInStr sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int i = 0; i < [resultsInStr count]; i++) {
        testassert([[resultsInStr objectAtIndex:i] isEqualToString:[[results objectAtIndex:i] path]]);
    }
    return YES;
}


test(DirectoryEnumeratorAtURLNoStandardPath)
{
    __block BOOL errorOccurred = NO;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingPathComponent:@"."];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        errorOccurred = YES;
        return YES;
    }];
    NSURL *item = NULL;
    while (item = [enumerator nextObject]) {
        testassert([item.path isEqualToString:[item.path stringByStandardizingPath]]);
    }
    return YES;
}

test(DirectoryEnumeratorAtURL1)
{
    __block BOOL errorOccurred = NO;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        errorOccurred = YES;
        return YES;
    }];
    testassert(enumerator != nil);
    NSURL *item = nil;
    NSUInteger count = 0;
    BOOL asset0Found = NO;
    BOOL bundle0Found = NO;
    BOOL bundle0ContentsFound = NO;
    BOOL enLprojInfoPlistStringsFound = NO;
    while (item = [enumerator nextObject])
    {
        item = [item URLByStandardizingPath];
        if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"0.asset"]]])
        {
            asset0Found = YES;
        }
        else if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"0.bundle"]]])
        {
            bundle0Found = YES;
        }
        else if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"0.bundle/0-0.bundle"]]])
        {
            bundle0ContentsFound = YES;
        }
        else if ([item isEqual:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"en.lproj/InfoPlist.strings"]]])
        {
            enLprojInfoPlistStringsFound = YES;
        }
        count++;
    }
    testassert(count > 1);
    testassert(asset0Found);
    testassert(bundle0Found);
    testassert(!bundle0ContentsFound);
    testassert(!enLprojInfoPlistStringsFound);
    testassert(!errorOccurred);
    return YES;
}

union ive_seen_it_all {
    int i;
    struct {
        BOOL saw0:1;
        BOOL saw1:1;
        BOOL saw2:1;
        BOOL saw3:1;
        BOOL saw4:1;
        BOOL saw5:1;
        BOOL saw6:1;
        BOOL saw7:1;
        BOOL saw8:1;
        BOOL saw9:1;
        BOOL saw10:1;
        BOOL saw11:1;
        BOOL saw12:1;
        BOOL saw13:1;
        BOOL saw14:1;
        BOOL saw15:1;
        BOOL saw16:1;
        BOOL saw17:1;
        BOOL saw18:1;
        BOOL saw19:1;
        BOOL saw20:1;
        BOOL saw21:1;
        BOOL saw22:1;
        BOOL saw23:1;
        BOOL saw24:1;
        BOOL saw25:1;
        BOOL saw26:1;
        BOOL saw27:1;
        BOOL saw28:1;
    };
};

test(DirectoryEnumeratorAtURL2)
{
    // Tests completeness of enumeration
    union ive_seen_it_all seenitall = { 0 };
    NSURL *url = [[NSBundle mainBundle] bundleURL];
    NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:0 errorHandler:nil ];
    
    NSURL *nextURL = nil;
    while ((nextURL = [dirEnum nextObject]) != nil) {
        
        testassert([[NSFileManager defaultManager] fileExistsAtPath:[nextURL path]]);
        
        // We keep track of line numbers to ensure that we find resources in the correct order
        if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset"]]) {
            seenitall.saw0 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"bundle"]]) {
            seenitall.saw1 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0" withExtension:@"bundle" subdirectory:@"0.bundle"]]) {
            seenitall.saw2 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0-0" withExtension:@"bundle" subdirectory:@"0.bundle/0-0.bundle"]]) {
            seenitall.saw3 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0-0" withExtension:@"asset" subdirectory:@"0.bundle/0-0.bundle/0-0-0.bundle"]]) {
            seenitall.saw4 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0" withExtension:@"asset" subdirectory:@"0.bundle/0-0.bundle"]]) {
            seenitall.saw5 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"0.bundle"]]) {
            seenitall.saw6 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"ATestPlist" withExtension:@"plist"]]) {
            seenitall.saw7 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"bigfile" withExtension:@"txt"]]) {
            seenitall.saw8 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"data" withExtension:@"json"]]) {
            seenitall.saw9 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default-568h@2x" withExtension:@"png"]]) {
            seenitall.saw10 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default" withExtension:@"png"]]) {
            seenitall.saw11 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default@2x" withExtension:@"png"]]) {
            seenitall.saw12 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"en" withExtension:@"lproj"]]) {
            seenitall.saw13 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"InfoPlist" withExtension:@"strings" subdirectory:@"en.lproj"]]) {
            seenitall.saw14 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"folderref0" withExtension:nil]]) {
            seenitall.saw15 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0"]]) {
            seenitall.saw16 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"folderref0-0" withExtension:nil subdirectory:@"folderref0"]]) {
            seenitall.saw17 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0/folderref0-0"]]) {
            seenitall.saw18 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"bundle" subdirectory:@"folderref0/folderref0-0"]]) {
            seenitall.saw19 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0/folderref0-0/0.bundle"]]) {
            seenitall.saw20 = YES;
        }
        
        // Isn't implemented on platform, so it will appear as NO
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"FoundationTests" withExtension:nil]]) {
            seenitall.saw21 = NO;//YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Info" withExtension:@"plist"]]) {
            seenitall.saw22 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Localizable" withExtension:@"strings"]]) {
            seenitall.saw23 = YES;
        }
        
        // Isn't implemented on platform, so it will appear as NO
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"PkgInfo" withExtension:nil]]) {
            seenitall.saw24 = NO;// YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"SpecialCharactersJSONTest" withExtension:@"json"]]) {
            seenitall.saw25 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"stringData" withExtension:@"bin"]]) {
            seenitall.saw26 = YES;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"utf8" withExtension:@"txt"]]) {
            seenitall.saw27 = YES;
        }
    }
    
    // Remove this test when the above items are implemented
    testassert(seenitall.i == 249561087);
    
    // Enable the below test when above items are implemented
    //    testassert(seenitall.i == 536870911);
    
    return YES;
}

test(DirectoryEnumeratorAtURL3)
{
    // Tests completion and order
    union ive_seen_it_all seenitall = { 0 };
    NSURL *url = [[NSBundle mainBundle] bundleURL];
    NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:url includingPropertiesForKeys:nil options:0 errorHandler:nil ];
    
    NSURL *nextURL = nil;
    while ((nextURL = [dirEnum nextObject]) != nil) {
        static int previousLine = 0;
        
        testassert([[NSFileManager defaultManager] fileExistsAtPath:[nextURL path]]);
        
        // We keep track of line numbers to ensure that we find resources in the correct order
        if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset"]]) {
            seenitall.saw0 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"bundle"]]) {
            seenitall.saw1 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0" withExtension:@"bundle" subdirectory:@"0.bundle"]]) {
            seenitall.saw2 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0-0" withExtension:@"bundle" subdirectory:@"0.bundle/0-0.bundle"]]) {
            seenitall.saw3 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0-0" withExtension:@"asset" subdirectory:@"0.bundle/0-0.bundle/0-0-0.bundle"]]) {
            seenitall.saw4 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0-0" withExtension:@"asset" subdirectory:@"0.bundle/0-0.bundle"]]) {
            seenitall.saw5 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"0.bundle"]]) {
            seenitall.saw6 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"ATestPlist" withExtension:@"plist"]]) {
            seenitall.saw7 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"bigfile" withExtension:@"txt"]]) {
            seenitall.saw8 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"data" withExtension:@"json"]]) {
            seenitall.saw9 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default-568h@2x" withExtension:@"png"]]) {
            seenitall.saw10 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default" withExtension:@"png"]]) {
            seenitall.saw11 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Default@2x" withExtension:@"png"]]) {
            seenitall.saw12 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"en" withExtension:@"lproj"]]) {
            seenitall.saw13 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"InfoPlist" withExtension:@"strings" subdirectory:@"en.lproj"]]) {
            seenitall.saw14 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"folderref0" withExtension:nil]]) {
            seenitall.saw15 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0"]]) {
            seenitall.saw16 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"folderref0-0" withExtension:nil subdirectory:@"folderref0"]]) {
            seenitall.saw17 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0/folderref0-0"]]) {
            seenitall.saw18 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"bundle" subdirectory:@"folderref0/folderref0-0"]]) {
            seenitall.saw19 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"asset" subdirectory:@"folderref0/folderref0-0/0.bundle"]]) {
            seenitall.saw20 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }

        // Isn't implemented on platform, so it will appear as NO
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"FoundationTests" withExtension:nil]]) {
            seenitall.saw21 = NO;//1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Info" withExtension:@"plist"]]) {
            seenitall.saw22 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"Localizable" withExtension:@"strings"]]) {
            seenitall.saw23 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        // Isn't implemented on platform, so it will appear as NO
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"PkgInfo" withExtension:nil]]) {
            seenitall.saw24 = NO;// 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"SpecialCharactersJSONTest" withExtension:@"json"]]) {
            seenitall.saw25 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"stringData" withExtension:@"bin"]]) {
            seenitall.saw26 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
        
        else if ([nextURL isEqual:[[NSBundle mainBundle] URLForResource:@"utf8" withExtension:@"txt"]]) {
            seenitall.saw27 = 1 & (previousLine < __LINE__);
            previousLine = __LINE__;
        }
    }
    
    // Remove this test when the above items are implemented
    testassert(seenitall.i == 249561087);
    
    // Enable the below test when above items are implemented
    //    testassert(seenitall.i == 536870911);
    
    return YES;
}

test(GetFileSystemRepresentationBlank)
{
    NSUInteger sz = PATH_MAX;
    char buffer[sz];
    buffer[0] = -1;
    BOOL success = [[NSFileManager defaultManager] getFileSystemRepresentation:buffer maxLength:sz withPath:@""];
    testassert(!success);
    testassert(buffer[0] == -1);
    return YES;
}

test(GetFileSystemRepresentation)
{
    NSUInteger sz = PATH_MAX;
    char buffer[sz];
    buffer[0] = -1;
    BOOL success = [[NSFileManager defaultManager] getFileSystemRepresentation:buffer maxLength:sz withPath:@"/System"];
    testassert(success);
    testassert(buffer[0] != -1);
    testassert(strcmp(buffer, "/System") == 0);
    return YES;
}

test(CurrentDirectoryIsFSRoot)
{
    testassert([[[NSFileManager defaultManager] currentDirectoryPath] isEqualToString:@"/"]);
    
    NSUInteger sz = PATH_MAX;
    char buffer[sz];
    getcwd(buffer, sz);
    testassert([[[NSFileManager defaultManager] currentDirectoryPath] isEqualToString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]]);
    
    return YES;
}

test(RelativePathWithBundleCWD)
{
    NSString* oldCWD = [[NSFileManager defaultManager] currentDirectoryPath];
    
    FILE* fd = NULL;
    
    @try
    {
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:[[NSBundle mainBundle] bundlePath]];
        testassert([[[NSFileManager defaultManager] currentDirectoryPath] isEqualToString:[[NSBundle mainBundle] bundlePath]]);
        
        NSString* realPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        testassert(realPath != nil);
        
        // These should resolve to a file inside the bundle
        NSUInteger sz = PATH_MAX;
        char buffer[sz];
        
        fd = fopen("./Info.plist", "r");
        testassert(fd != NULL);
        fclose(fd);
        
        realpath("./Info.plist", buffer);
        testassert([realPath isEqualToString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]]);
        
        fd = fopen("Info.plist", "r");
        testassert(fd != NULL);
        fclose(fd);
        
        realpath("Info.plist", buffer);
        testassert([realPath isEqualToString:[NSString stringWithCString:buffer encoding:NSUTF8StringEncoding]]);
        
        fd = NULL;
    }
    @finally
    {
        if (fd != NULL)
        {
            fclose(fd);
        }
        testassert([[NSFileManager defaultManager] changeCurrentDirectoryPath:oldCWD]);
    }
    
    return YES;
}

test(CopyItemAtPath)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *src = [documentDir stringByAppendingPathComponent:@"copyItemAtPath.txt"];
    NSString *dst = [documentDir stringByAppendingPathComponent:@"copyItemAtPath copy.txt"];
    
    [manager removeItemAtPath:src error:nil];
    [manager removeItemAtPath:dst error:nil];
    
    testassert([manager createFileAtPath:src contents:nil attributes:nil]);
    testassert([manager copyItemAtPath:src toPath:dst error:&error]);
    testassert(error == nil);
    
    testassert([manager fileExistsAtPath:src isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst isDirectory:NULL]);
    
    return YES;
}

test(MoveItemAtPath)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *src = [documentDir stringByAppendingPathComponent:@"moveItemAtPath.txt"];
    NSString *dst = [documentDir stringByAppendingPathComponent:@"moveItemAtPath move.txt"];
    
    [manager removeItemAtPath:src error:nil];
    [manager removeItemAtPath:dst error:nil];
    
    testassert([manager createFileAtPath:src contents:nil attributes:nil]);
    testassert([manager moveItemAtPath:src toPath:dst error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:src isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst isDirectory:NULL]);
    
    return YES;
}

test(RemoveItemAtPath)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSString *path = [documentDir stringByAppendingPathComponent:@"removeItemAtPath.txt"];
    
    [manager removeItemAtPath:path error:nil];
    
    testassert([manager createFileAtPath:path contents:nil attributes:nil]);
    testassert([manager removeItemAtPath:path error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:path isDirectory:NULL]);
    
    return YES;
}

test(CopyItemAtURL)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL *src = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"copyItemAtURL.txt"]];
    NSURL *dst = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"copyItemAtURL copy.txt"]];
    
    [manager removeItemAtPath:src.path error:nil];
    [manager removeItemAtPath:dst.path error:nil];
    
    testassert([manager createFileAtPath:src.path contents:nil attributes:nil]);
    testassert([manager copyItemAtURL:src toURL:dst error:&error]);
    testassert(error == nil);
    
    testassert([manager fileExistsAtPath:src.path isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst.path isDirectory:NULL]);
    
    return YES;
}

test(MoveItemAtURL)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL *src = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"moveItemAtURL.txt"]];
    NSURL *dst = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"moveItemAtURL copy.txt"]];
    
    [manager removeItemAtPath:src.path error:nil];
    [manager removeItemAtPath:dst.path error:nil];
    
    testassert([manager createFileAtPath:src.path contents:nil attributes:nil]);
    testassert([manager moveItemAtURL:src toURL:dst error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:src.path isDirectory:NULL]);
    testassert([manager fileExistsAtPath:dst.path isDirectory:NULL]);
    
    return YES;
}

test(RemoveItemAtURL)
{
    NSString *documentDir =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSError *error = nil;
    NSFileManager* manager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:[documentDir stringByAppendingPathComponent:@"removeItemAtURL.txt"]];
    
    [manager removeItemAtPath:url.path error:nil];
    
    testassert([manager createFileAtPath:url.path contents:nil attributes:nil]);
    testassert([manager removeItemAtURL:url error:&error]);
    testassert(error == nil);
    
    testassert(![manager fileExistsAtPath:url.path isDirectory:NULL]);
    
    return YES;
}

test(DirectoryEnumeratorNoCurrentOrParentPath)
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *item = NULL;
    BOOL hasCurrentOrParentPath = NO;
    while (item = [enumerator nextObject]) {
        if ([[item lastPathComponent] isEqualToString:@"."] || [[item lastPathComponent] isEqualToString:@".."]) {
            hasCurrentOrParentPath = YES;
        }
    }
    testassert(hasCurrentOrParentPath == NO);
    return YES;
}

test(ContentsOfDirectoryAtPathSorted)
{
    NSString *path = [[NSBundle mainBundle] bundlePath];

    NSError *error = nil;
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                                        error:&error];
    testassert(!error);
    testassert([paths count]);

    // Check if sorted
    NSArray *sortedPaths = [paths sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    testassert([paths isEqual:sortedPaths]);

    return YES;
}

test(ContentsOfDirectoryAtURLSorted)
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];

    NSError* error = nil;
    NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                  includingPropertiesForKeys:nil
                                                                     options:0
                                                                       error:&error];
    testassert(!error);
    testassert([urls count]);

    // Check if sorted
    NSMutableArray* sortedURLs = [[urls mutableCopy] autorelease];
    [sortedURLs sortUsingComparator:^(id url1, id url2) {
        NSString* str1 = [(NSURL*)url1 absoluteString];
        NSString* str2 = [(NSURL*)url2 absoluteString];
        return [str1 caseInsensitiveCompare:str2];
    }];

    testassert([urls isEqual:sortedURLs]);

    return YES;
}

test(ContentsOfDirectoryAtURLUnknownKey)
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];

    NSError* error = nil;
    NSArray *urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                  includingPropertiesForKeys:nil
                                                                     options:0
                                                                       error:&error];
    testassert(!error);

    NSArray *urlsWithProperties = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                                includingPropertiesForKeys:@[ @"Imagine" ]
                                                                                   options:0
                                                                                     error:&error];
    testassert(!error);

    // Presence of unknown key shouldn't mess things up
    testassert([urlsWithProperties isEqualToArray:urls]);

    return YES;
}

@end
