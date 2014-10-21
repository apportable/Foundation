//
//  NSBundleTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSBundle)

#define RELEASEANDNIL(obj) \
{   \
    [obj release]; \
    obj = nil; \
} \

// Static vars to use in tests
NSString *mainBundlePath = nil;
static NSBundle *zeroLevelBundle, *firstLevelBundle, *secondLevelBundle;

#pragma mark - Instantiation Tests
test(MainBundle)
{
    NSBundle *bundle = [NSBundle mainBundle];
    testassert(nil != bundle);
    
    return YES;
}

test(CFBundleGetMainBundle)
{
    CFBundleRef cfBundle = CFBundleGetMainBundle();
    testassert(nil != cfBundle);
    
    return YES;
}

test(MainBundlePath)
{
    mainBundlePath = [[[NSBundle mainBundle] bundlePath] copy];
    testassert(nil != mainBundlePath);
    testassert([mainBundlePath rangeOfString:@"FoundationTests"].location != NSNotFound);
    
    return YES;
}


test(MainBundleIdentifier)
{
    NSString *s = [[NSBundle mainBundle] bundleIdentifier];
    testassert([s isEqualToString:@"com.apportable.FoundationTests"]);
    return YES;
}

test(ValidNonMainBundleAllocInitCreation)
{
    zeroLevelBundle = [[NSBundle alloc] initWithPath:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]];
    testassert(
        nil != zeroLevelBundle &&
        [[zeroLevelBundle bundlePath] isEqualToString:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]]
    );
    
    firstLevelBundle = [[NSBundle alloc] initWithPath:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]];
    testassert(
        nil != zeroLevelBundle &&
        nil != firstLevelBundle &&
        [[firstLevelBundle bundlePath] isEqualToString:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]]
    );
    
    secondLevelBundle = [[NSBundle alloc] initWithPath:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]];
    testassert(
        nil != firstLevelBundle &&
        nil != secondLevelBundle &&
        [[secondLevelBundle bundlePath] isEqualToString:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]]
    );
    
    return YES;
}

test(ValidNonMainBundleClassMethodCreation)
{
    if (zeroLevelBundle)
        RELEASEANDNIL(zeroLevelBundle);
    if (firstLevelBundle)
        RELEASEANDNIL(firstLevelBundle);
    if (secondLevelBundle)
        RELEASEANDNIL(secondLevelBundle);
    
    zeroLevelBundle = [[NSBundle alloc] initWithPath:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]];
    testassert(
       nil != zeroLevelBundle &&
       [[zeroLevelBundle bundlePath] isEqualToString:[mainBundlePath stringByAppendingPathComponent:@"0.bundle"]]
   );
    
    firstLevelBundle = [[NSBundle alloc] initWithPath:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]];
    testassert(
       nil != zeroLevelBundle &&
       nil != firstLevelBundle &&
       [[firstLevelBundle bundlePath] isEqualToString:[zeroLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0.bundle"]]
    );
    
    secondLevelBundle = [[NSBundle alloc] initWithPath:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]];
    testassert(
       nil != firstLevelBundle &&
       nil != secondLevelBundle &&
       [[secondLevelBundle bundlePath] isEqualToString:[firstLevelBundle.bundlePath stringByAppendingPathComponent:@"0-0-0.bundle"]]
    );
        
    return YES;
}

test(InvalidNonMainBundleCreation)
{
    NSBundle *badZeroLevelBundle = [NSBundle bundleWithPath:@"0.bundle"];
    testassert(nil == badZeroLevelBundle);
    
    NSBundle *badFirstLevelBundle = [NSBundle bundleWithPath:@"0-0.bundle"];
    testassert(nil == badFirstLevelBundle);
    
    NSBundle *badSecondLevelBundle = [NSBundle bundleWithPath:@"0-0-0.bundle"];
    testassert(nil == badSecondLevelBundle);
    
    return YES;
}

test(LocalizedStrings)
{
    NSString *localizedString = NSLocalizedString(@"Hello,\n“foo bar.”\n", @"a comment");
    testassert(localizedString != nil);
    testassert([localizedString isEqualToString:@"Hello,\n“foo bar.”\n"]);
    return YES;
}

test(LocalizedInfoDictionary)
{
	NSDictionary *localizedInfoDictionary = [[NSBundle mainBundle] localizedInfoDictionary];
	testassert(localizedInfoDictionary != nil);
	return YES;
}

test(BuiltInPlugInsPath)
{
	NSString *builtInPlugInsPath = [[NSBundle mainBundle] builtInPlugInsPath];
	testassert(builtInPlugInsPath != nil);
    testassert([builtInPlugInsPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"PlugIns"]]);
	return YES;
}

test(SharedSupportPath)
{
	NSString *sharedSupportPath = [[NSBundle mainBundle] sharedSupportPath];
	testassert(sharedSupportPath != nil);
    testassert([sharedSupportPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"SharedSupport"]]);
	return YES;
}

test(SharedFrameworksPath)
{
	NSString *sharedFrameworksPath = [[NSBundle mainBundle] sharedFrameworksPath];
	testassert(sharedFrameworksPath != nil);
    testassert([sharedFrameworksPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"SharedFrameworks"]]);
	return YES;
}

test(PrivateFrameworksPath)
{
	NSString *privateFrameworksPath = [[NSBundle mainBundle] privateFrameworksPath];
	testassert(privateFrameworksPath != nil);
    testassert([privateFrameworksPath isEqualToString:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"]]);
	return YES;
}

#if defined(__IPHONE_7_0)
test(AppStoreReceiptURL)
{
	NSURL *appStoreReceiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    testassert(appStoreReceiptURL != nil);
#if !defined(__IPHONE_8_0)
    testassert([appStoreReceiptURL isEqual:[[[[[NSBundle mainBundle] bundleURL] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"StoreKit"] URLByAppendingPathComponent:@"receipt"]]);
#endif
	return YES;
}
#endif

@end
