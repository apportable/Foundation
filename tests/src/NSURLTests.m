//
//  NSURLTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSURL)

test(StandardizedURL)
{
    NSURL *url = [[NSURL alloc] initWithString:@"base://foo/bar/../bar/./././/baz"];
    testassert([[[url standardizedURL] absoluteString] isEqualToString:@"base://foo/bar//baz"]);

    [url release];

    return YES;
}

test(URLdescription)
{
    NSURL *url = [[NSURL alloc] initWithString:@"basestring" relativeToURL:[NSURL URLWithString:@"relative://url"]];
    NSString *expected = @"basestring -- relative://url";
    testassert([[url description] isEqualToString:expected]);
    [url release];

    return YES;
}

test(URLByAppendingPathComponent)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [directories objectAtIndex:0];
    NSURL *u = [documentDirectory URLByAppendingPathComponent:@"myFile"];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/myFile"];
    testassert([[u relativePath] isEqualToString:check]);
    return YES;
}

test(NSSearchPathForDirectoriesInDomains)
{
    NSArray *a1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSLocalDomainMask, YES);
    NSArray *a2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSNetworkDomainMask, YES);
    NSArray *a3 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSSystemDomainMask, YES);
    testassert([a1 count] == 0);
    testassert([a2 count] == 0);
    testassert([a3 count] == 0);

    NSString *s = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    testassert([s isEqualToString:check]);
    return YES;
}

test(InitFileURLWithNilPath)
{
    void (^block)() = ^{
        [[NSURL alloc] initFileURLWithPath:nil];
    };

    // initFileURLWithPath should throw NSInvalidArgumentException
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

// Make sure empty non-User Domains return empty arrays

test(URLsForDirectoryDocL)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSLocalDomainMask];
    testassert([directories count] == 0);
    return YES;
}
test(URLsForDirectoryDocN)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSNetworkDomainMask];
    testassert([directories count] == 0);
    return YES;
}
test(URLsForDirectoryDocS)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSSystemDomainMask];
    testassert([directories count] == 0);
    return YES;
}

// Test all NS*Directory
//NSApplicationDirectory = 1,             // supported applications (Applications)
//NSDemoApplicationDirectory = 2,         // unsupported applications, demonstration versions (Applications/GrabBag)
//NSDeveloperApplicationDirectory = 3,    // developer applications (Developer/Applications)
//NSAdminApplicationDirectory = 4,        // system and network administration applications (Applications/Utilities)
//NSLibraryDirectory = 5,                 // various user-visible documentation, support, and configuration files, resources (Library)
//NSDeveloperDirectory = 6,               // developer resources (Developer)
//NSUserDirectory = 7,                    // user home directories (Users)
//NSDocumentationDirectory = 8,           // documentation (Library/Documentation)
//NSDocumentDirectory = 9,                // documents (Documents)
//NSCoreServiceDirectory = 10,            // location of core services (System/Library/CoreServices)
//NSAutosavedInformationDirectory = 11,   // location of user's directory for use with autosaving (Library/Autosave Information)
//NSDesktopDirectory = 12,                // location of user's Desktop (Desktop)
//NSCachesDirectory = 13,                 // location of discardable cache files (Library/Caches)
//NSApplicationSupportDirectory = 14,     // location of application support files (plug-ins, etc) (Library/Application Support)
//NSDownloadsDirectory = 15,              // location of user's Downloads directory (Downloads)
//NSInputMethodsDirectory = 16,           // input methods (Library/Input Methods)
//NSMoviesDirectory = 17,                 // location of user's Movies directory (~/Movies)
//NSMusicDirectory = 18,                  // location of user's Music directory (~/Music)
//NSPicturesDirectory = 19,               // location of user's Pictures directory (~/Pictures)
//NSPrinterDescriptionDirectory = 20,     // location of system's PPDs directory (Library/Printers/PPDs)
//NSSharedPublicDirectory = 21,           // location of user's Public sharing directory (~/Public)
//NSPreferencePanesDirectory = 22,        // location of the PreferencePanes directory for use with System Preferences (Library/PreferencePanes)
//NSAllApplicationsDirectory = 100,       // all directories where applications can occur (Applications, Applications/Utilities, Developer/Applications, ...)
//NSAllLibrariesDirectory = 101


test(URLsForDirectoryNSApplicationDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSApplicationDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Applications"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}


test(URLsForDirectoryNSDemoApplicationDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDemoApplicationDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Applications/Demos"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSDeveloperApplicationDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDeveloperApplicationDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Developer/Applications"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSAdminApplicationDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSAdminApplicationDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Applications/Utilities"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSDeveloperDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDeveloperDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Developer"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSLibraryDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSUserDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSUserDirectory inDomains:NSUserDomainMask];
    testassert([directories count] == 0);
    return YES;
}

test(URLsForDirectoryNSDocumentationDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentationDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Documentation"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSDocument)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSCoreServiceDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSCoreServiceDirectory inDomains:NSUserDomainMask];
    testassert([directories count] == 0);
    return YES;
}

test(URLsForDirectoryNSAutosavedInformationDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSAutosavedInformationDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Autosave Information"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSDesktopDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSCachesDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSApplicationSupportDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSDownloadsDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSInputMethodsDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSInputMethodsDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Input Methods"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSMoviesDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSMoviesDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Movies"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSMusicDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSMusicDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Music"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSPicturesDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSPicturesDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSPrinterDescriptionDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSPrinterDescriptionDirectory inDomains:NSUserDomainMask];
    testassert([directories count] == 0);
    return YES;
}

test(URLsForDirectoryNSSharedPublicDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSSharedPublicDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Public"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSPreferencePanesDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSPreferencePanesDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/PreferencePanes"];
    testassert([[directory relativePath] isEqualToString:check]);
    return YES;
}

test(URLsForDirectoryNSAllApplicationsDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSAllApplicationsDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Applications"];
    testassert([[directory relativePath] isEqualToString:check]);
    testassert([directories count] == 4);
    return YES;
}

test(URLsForDirectoryNSAllLibrariesDirectory)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *directories = [fm URLsForDirectory:NSAllLibrariesDirectory inDomains:NSUserDomainMask];
    NSURL *directory = [directories objectAtIndex:0];
    NSString *check = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    testassert([[directory relativePath] isEqualToString:check]);
    testassert([directories count] == 2);
    return YES;
}

test(URLByStandardizingPath)
{
    NSURL *url = [NSURL fileURLWithPath:@"/foo/bar/baz/../foo/./.././baz"];
    NSURL *standardized = [url URLByStandardizingPath];
    testassert([[standardized path] isEqualToString:@"/foo/bar/baz"]);
    return YES;
}

test(LongFileURL)
{
    NSMutableString *str = [NSMutableString stringWithString:@"/foo"];
    while ([str length] + 4 < PATH_MAX)
    {
        [str appendString:@"/foo"];
    }
    NSURL *url = [NSURL fileURLWithPath:str];
    testassert(url != NULL);
    testassert([[url path] isEqualToString:str]);
    return YES;
}

test(LongFileURLfileSystemRepresentation)
{
    NSMutableString *str = [NSMutableString stringWithString:@"/foo"];
    while ([str length] + 4 < PATH_MAX)
    {
        [str appendString:@"/foo"];
    }
    NSURL *url = [NSURL fileURLWithPath:str];
    int s = strlen([url fileSystemRepresentation]);
    testassert(s != PATH_MAX);
    testassert(s == 1020);
    return YES;
}

test(FilePathEquality)
{
    NSURL *url1 = [NSURL fileURLWithPath:@"/foo/bar/baz"];
    NSURL *url2 = [NSURL URLWithString:@"file://localhost/foo/bar/baz"];
    testassert(![url1 isEqual:url2]);
    return YES;
}

test(FilePathIsDirectory)
{
    NSURL *url1 = [NSURL fileURLWithPath:@"/foo/bar/baz" isDirectory:YES];
    testassert(url1 != nil);
    return YES;
}

test(ConstructedFilePathEquality)
{
    NSURL *url1 = [NSURL fileURLWithPath:@"/foo/bar/baz"];
    NSURL *url2 = [NSURL URLWithString:@"file:///foo/bar/baz"];
    testassert([url1 isEqual:url2]);
    return YES;
}

@end
