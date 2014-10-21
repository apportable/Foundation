//
//  NSPathUtilitiesTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include "objc/runtime.h"

@testcase(NSPathUtilities)

test(PathExtension)
{
    NSString *s = @"abc.xyz";
    testassert([[s pathExtension] isEqualToString:@"xyz"]);
    return YES;
}

test(PathExtensionEmpty)
{
    NSString *s = @"abc";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}


test(PathExtensionEmptyStart)
{
    NSString *s = @"";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}


test(PathExtensionDot)
{
    NSString *s = @".";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}

test(PathExtensionDotEnd)
{
    NSString *s = @"abc.";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}

test(PathExtensionLeadingDot)
{
    NSString *s = @".xyz";
    testassert([[s pathExtension] isEqualToString:@""]);
    return YES;
}

test(PathExtensionDouble)
{
    NSString *s = @"abc.xyz.uvw";
    testassert([[s pathExtension] isEqualToString:@"uvw"]);
    return YES;
}

test(PathExtension_forNSPathStore2_1)
{
    NSString *path = @"abc";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@""]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_1b)
{
    NSString *path = @"a/bc";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"a/bc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@""]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_1c)
{
    NSString *path = @".abc.xyz";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@".abc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@""]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_1d)
{
    NSString *path = @"1.abc.xyz";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"1.abc"]);
    
    testassert([[subpath pathExtension] isEqualToString:@"abc"]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_2)
{
    NSString *path = @"abc.xyz.";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc.xyz"]);
    
    testassert([[subpath stringByDeletingPathExtension] isEqualToString:@"abc"]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_2b)
{
    NSString *path = @".abc.xyz";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@".abc"]);
    
    testassert([[subpath stringByDeletingPathExtension] isEqualToString:@".abc"]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_2c)
{
    NSString *path = @"abc.xyz.uvw";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc.xyz"]);
    
    testassert([[subpath stringByDeletingPathExtension] isEqualToString:@"abc"]);
    
    return YES;
}

test(PathExtension_forNSPathStore2_3)
{
    NSString *path = @"abc.xyz.uvw";
    
    NSString *subpath = [path stringByDeletingPathExtension];
    testassert([subpath class] == objc_getClass("NSPathStore2"));
    testassert([subpath isEqualToString:@"abc.xyz"]);
    
    testassert([[subpath pathExtension] isEqualToString:@"xyz"]);
    
    return YES;
}

test(PathWithComponentsNil)
{
    BOOL raised = NO;

    @try {
        [NSString pathWithComponents:nil];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSInvalidArgumentException];
    }

    testassert(raised);

    return YES;
}

test(PathWithComponentsClass)
{
    NSString* path = [NSString pathWithComponents:@[@"foo"]];

    testassert([path class] == objc_getClass("NSPathStore2"));

    return YES;
}

test(StringByDeletingLastPathComponentReturnValueType)
{
    id path = [@"/foo/bar/baz" stringByDeletingLastPathComponent];
    testassert([path class] == objc_getClass("NSPathStore2"));
    return YES;
}


test(PathWithComponentsEmpty)
{
    NSString* path = [NSString pathWithComponents:@[@""]];

    testassert([path isEqualToString:@""]);

    return YES;
}

test(PathWithComponentsSimple)
{
    NSString* path = [NSString pathWithComponents:@[@"foo"]];

    testassert([path isEqualToString:@"foo"]);

    return YES;
}

test(PathWithComponentsPair)
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @"bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

test(PathWithComponentsWacky)
{
    NSString* path = [NSString pathWithComponents:@[@"~`!@#%^&*()-_{}[];:\",.<>?/\\|"]];

    testassert([path isEqualToString:@"~`!@#%^&*()-_{}[];:\",.<>?/\\|"]);

    return YES;
}

test(PathWithComponentsSingleSlash)
{
    NSString* path = [NSString pathWithComponents:@[@"/"]];

    testassert([path isEqualToString:@"/"]);

    return YES;
}

test(PathWithComponentsDoubleSlash)
{
    NSString* path = [NSString pathWithComponents:@[@"/", @"/"]];

    testassert([path isEqualToString:@"/"]);

    return YES;
}

test(PathWithComponetnsTrailingEmpty)
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @""]];

    // Apple docs say:
    // "To include a trailing path divider, use an empty string as the last component."
    // they lied.
    testassert([path isEqualToString:@"foo"]);

    return YES;
}

test(PathWithComponentsTrailingSlash)
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @"/"]];

    testassert([path isEqualToString:@"foo"]);

    return YES;
}

test(PathWithComponentsSlashComponent)
{
    NSString* path = [NSString pathWithComponents:@[@"foo", @"/", @"bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

test(PathWithComponentsContainedSeparator)
{
    NSString* path = [NSString pathWithComponents:@[@"foo/bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

test(PathWithComponentsContainedDoubleSeparator)
{
    NSString* path = [NSString pathWithComponents:@[@"foo//bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

test(PathWithComponentsContainedTripleSeparator)
{
    NSString* path = [NSString pathWithComponents:@[@"foo///bar"]];

    testassert([path isEqualToString:@"foo/bar"]);

    return YES;
}

test(PathWithComponentsContainedLeadingSlash)
{
    NSString* path = [NSString pathWithComponents:@[@"/foo"]];

    testassert([path isEqualToString:@"/foo"]);

    return YES;
}

test(PathWithComponentsContainedTerminator)
{
    NSString* path = [NSString pathWithComponents:@[@"foo\0bar"]];

    testassert([path isEqualToString:@"foo\0bar"]);

    return YES;
}

test(PathWithComponentsContainedTailingSlash)
{
    NSString* path = [NSString pathWithComponents:@[@"foo/"]];

    testassert([path isEqualToString:@"foo"]);

    return YES;
}

test(PathWithComponentsParentDirectory)
{
    NSString* path = [NSString pathWithComponents:@[@"/", @"foo", @"..", @"bar"]];

    testassert([path isEqualToString:@"/foo/../bar"]);

    return YES;
}

test(PathWithComponentsCurrentDirectory)
{
    NSString* path = [NSString pathWithComponents:@[@"/", @"foo", @".", @"bar"]];

    testassert([path isEqualToString:@"/foo/./bar"]);

    return YES;
}

test(PathWithComponentsParentDirectoryContained)
{
    NSString* path = [NSString pathWithComponents:@[@"foo/../bar"]];

    testassert([path isEqualToString:@"foo/../bar"]);

    return YES;
}

test(PathWithComponentsCurrentDirectoryContained)
{
    NSString* path = [NSString pathWithComponents:@[@"foo/./bar"]];

    testassert([path isEqualToString:@"foo/./bar"]);

    return YES;
}

test(PathWithComponentsComponentsSplit)
{
    NSString* path = [NSString pathWithComponents:@[@"/foo"]];

    BOOL match = [[path pathComponents] isEqualToArray:@[@"/", @"foo"]];

    testassert(match);

    return YES;
}

test(PathWithComponentsComponentsTwin)
{
    NSString* path = [NSString pathWithComponents:@[@"foo/bar"]];

    BOOL match = [[path pathComponents] isEqualToArray:@[@"foo", @"bar"]];

    testassert(match);

    return YES;
}

test(LastPathComponentEmpty)
{
    NSString* lastPathComponent = [@"" lastPathComponent];
    
    testassert([lastPathComponent isEqualToString:@""]);
    
    return YES;
}

test(LastPathComponentSlash)
{
    NSString* lastPathComponent = [@"/" lastPathComponent];
    
    testassert([lastPathComponent isEqualToString:@"/"]);
    
    return YES;
}

test(LastPathComponentSlashDot)
{
    NSString* lastPathComponent = [@"/." lastPathComponent];
    
    testassert([lastPathComponent isEqualToString:@"."]);
    
    return YES;
}

test(LastPathComponentTrailingSlash)
{
    NSString* lastPathComponent = [@"/foo/" lastPathComponent];
    
    testassert([lastPathComponent isEqualToString:@"foo"]);
    
    return YES;
}

test(LastPathComponentSplit)
{
    NSString* lastPathComponent = [@"foo/bar" lastPathComponent];
    
    testassert([lastPathComponent isEqualToString:@"bar"]);
    
    return YES;
}

test(StringByAppendingPathExtension1)
{
    NSString *str = [@"foo" stringByAppendingPathExtension:@"bar"];
    testassert([str isEqualToString:@"foo.bar"]);
    return YES;
}

test(StringByAppendingPathExtension2)
{
    NSString *str = [@"foo." stringByAppendingPathExtension:@"bar"];
    testassert([str isEqualToString:@"foo..bar"]);
    return YES;
}

test(StringByAppendingPathExtension3)
{
    NSString *str = [@"foo" stringByAppendingPathExtension:@".bar"];
    testassert([str isEqualToString:@"foo..bar"]);
    return YES;
}

test(StringByAppendingPathExtension4)
{
    NSString *str = [@"foo.bar" stringByAppendingPathExtension:@"baz"];
    testassert([str isEqualToString:@"foo.bar.baz"]);
    return YES;
}

test(StringByAppendingPathExtension5)
{
    NSString *str = [@"foo.bar" stringByAppendingPathExtension:@"bar"];
    testassert([str isEqualToString:@"foo.bar.bar"]);
    return YES;
}

test(StringByAppendingPathExtensionNil)
{
    BOOL thrown = NO;
    @try {
        NSString *str = [@"foo" stringByAppendingPathExtension:nil];
    } @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        thrown = YES;
    }
    testassert(thrown);
    return YES;
}

test(StringByExpandingTildeInPath1)
{
    NSString *str = [@"~/test" stringByExpandingTildeInPath];
    testassert([str isEqualToString:[NSHomeDirectory() stringByAppendingPathComponent:@"test"]]);
    return YES;
}

test(StringByExpandingTildeInPath2)
{
    NSString *str = [@"/foo/../~/test" stringByExpandingTildeInPath];
    testassert([str isEqualToString:@"/foo/../~/test"]);
    return YES;
}


test(URLFromPathStore)
{
    NSString *str = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([str class] == NSClassFromString(@"NSPathStore2"));
    testassert([str isEqualToString:@"/foo/bar/baz"]);
    NSURL *url = [NSURL fileURLWithPath:str];
    testassert(url != nil);
    testassert([url isEqual:[NSURL URLWithString:@"file:///foo/bar/baz"]]);
    return YES;
}

test(StringByDeletingPathExtension1)
{
    NSString *str = [@"foo/bar/baz.bar" stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/baz"]);
    testassert([str class] == NSClassFromString(@"NSPathStore2"));
    return YES;
}

test(StringByDeletingPathExtension2)
{
    NSString *str = [@"foo/bar/baz" stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/baz"]);
    return YES;
}

test(StringByDeletingPathExtension3)
{
    NSString *str = [@"foo/bar/.baz" stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/.baz"]);
    return YES;
}

test(StringByDeletingPathExtension4)
{
    NSString *str = [@"foo/bar/." stringByDeletingPathExtension];
    testassert([str isEqualToString:@"foo/bar/."]);
    return YES;
}

test(SubstringWithRange)
{
    NSString *str = [[NSString pathWithComponents:@[@"foo", @"bar", @"baz"]] substringWithRange:NSMakeRange(4, 3)];
    testassert([str isEqualToString:@"bar"]);
    return YES;
}

test(NSPathStore2Hash)
{
    NSString *path = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([path class] == NSClassFromString(@"NSPathStore2"));
    testassert([path isEqualToString:@"/foo/bar/baz"]);

#if __LP64__
    testassert([path hash] == 15732706541598988367ull);
#else
    testassert([path hash] == 2138626127);
#endif
    
    return YES;
}

test(NSPathStore2HashComparison)
{
    NSString *path = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([path class] == NSClassFromString(@"NSPathStore2"));
    testassert([path isEqualToString:@"/foo/bar/baz"]);
    
    NSString *str = @"/foo/bar/baz";
    
    testassert([path hash] == [str hash]);
    
    return YES;
}

test(NSPathStore2InDictionary)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *path = [NSString pathWithComponents:@[@"/", @"foo", @"bar", @"baz"]];
    testassert([path class] == NSClassFromString(@"NSPathStore2"));
    testassert([path isEqualToString:@"/foo/bar/baz"]);
    
    [dict setObject:@"foo" forKey:path];
    
    NSString *str = @"/foo/bar/baz";
    
    testassert([str isEqualToString:path]);
    
    [dict setObject:@"foo" forKey:str];

    testassert([dict count] == 1);
    
    return YES;
}

@end
