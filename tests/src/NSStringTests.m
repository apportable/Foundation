//
//  NSStringTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#define ASCII_SAMPLE \
'T','h','i','s',' ','i','s',' ','a',' ', \
's','i','m','p','l','e',' ','A','S','C', \
'I','I',' ','s','t','r','i','n','g',' ', \
'r','a','n','g','i','n','g',' ','f','r', \
'o','m',' ','\1',' ','t','o',' ','\127','.'


// this is the worst possible case of string expansion 13 characters -> 23 bytes
static char *UTF8Sample = "مرحبا العالم"; // hello world
static NSString *UTF8SampleNSString = @"مرحبا العالم";
static NSUInteger UTF8SampleLen = 23;

// Sample strings are mutable to avoid warnings.
static char AsciiSample[] = {ASCII_SAMPLE, 0};
static const NSUInteger AsciiSampleLength = sizeof(AsciiSample) - 1;
static unichar AsciiSampleUnicode[] = {ASCII_SAMPLE};
static const NSUInteger AsciiSampleMaxUnicodeLength = 100;
static const NSUInteger AsciiSampleMaxUTF8Length = 150;

@interface NSString (TestInternal)
- (BOOL)_getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(CFStringEncoding)encoding;
- (unsigned int)unsignedIntValue;
@end

@testcase(NSString)

test(Allocate)
{
    NSString *s1 = [NSString alloc];
    NSString *s2 = [NSString alloc];
    
    testassert(s1 == s2);
    
    return YES;
}

test(stringByReplacingOccurrencesOfString)
{
    NSString *s = @"abcdefghij+1234+567";
    NSString *s2 = [s stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    testassert([s2 isEqualToString:@"abcdefghij 1234 567"]);
    return YES;
}

test(stringByReplacingPercentEscapesUsingEncoding)
{
    NSString *s = @"abcd7";
    NSString *s2 = [s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    testassert([s2 isEqualToString:s]);
    return YES;
}

test(stringByReplacingPercentEscapesUsingEncodingNil)
{
    NSString *s = @"abcdefg%hij+1234+56%7";
    NSString *s2 = [s stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    testassert(s2 == nil);
    return YES;
}

test(CreationWithNil)
{
    void (^block)() = ^{
        [[NSString alloc] initWithString:nil];
    };

    // Creation with nil string is invalid
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

test(CreationWithAscii)
{
    // Sample with ascii encoding must not throw
    [NSString stringWithCString:AsciiSample encoding:NSASCIIStringEncoding];

    return YES;
}

test(CreationWithUnicode)
{
    // Sample with unicode must not throw
    [NSString stringWithCharacters:AsciiSampleUnicode length:AsciiSampleMaxUnicodeLength];

    return YES;
}

test(MutableCreationWithUnicode)
{
    // Sample with unicode must not throw
    [NSMutableString stringWithCharacters:AsciiSampleUnicode length:AsciiSampleMaxUnicodeLength];

    return YES;
}

test(MutableCreationWithUnicodeSuccess)
{
    // Sample with unicode must not throw
    NSMutableString *aString = [NSMutableString stringWithCharacters:AsciiSampleUnicode length:50];
    testassert(aString != nil);
    testassert([aString isEqualToString:@"This is a simple ASCII string ranging from  to W."]);
    return YES;
}

test(DepreciatedCStringCreation1)
{
    // Creation with cstring of NULL and zero length must not throw
    [NSString stringWithCString:NULL length:0];

    return YES;
}

test(DepreciatedCStringCreation2)
{
    // Creation with cstring of sample must not throw
    [NSString stringWithCString:AsciiSample length:AsciiSampleLength];

    return YES;
}

test(cStringUsingEncoding)
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = [s2 cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    testassert(strlen(cString) == 3);
    return YES;
}


test(cStringUsingEncoding2)
{
    NSString *s = @"¡™£¢∞§¶";
    const char *cString = [s cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cString == NULL);
    return YES;
}


test(cStringUsingEncoding3)
{
    NSString *s = @"¡™£¢∞§¶";
    const char *cString = [s cStringUsingEncoding:NSUnicodeStringEncoding];
    testassert(cString != NULL);
    testassert(strlen(cString) == 1);
    return YES;
}


// Fails with XCode 4
test(CFStringGetCStringPtr)
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingASCII);
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

test(CFStringGetCStringPtr2)
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingInvalidId);
    testassert(cString == NULL);
    return YES;
}

// Fails with XCode 4
test(CFStringGetCStringPtr3)
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingDOSRussian);
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

test(CFStringGetCStringPtr4)
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingUnicode);
    testassert(cString == NULL);
    return YES;
}

test(CFStringGetCStringPtr5)
{
    NSString *s = @"abcd";
    NSString *s2 = [s substringToIndex:3];
    const char *cString = CFStringGetCStringPtr((CFStringRef)s2, kCFStringEncodingUTF32);
    testassert(cString == NULL);
    return YES;
}

// Fails with XCode 4
test(CFStringGetCStringPtr6)
{
    CFStringRef s = CFSTR("abc");
    const char *cString = CFStringGetCStringPtr(s, kCFStringEncodingASCII);
    testassert(cString != NULL);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

// Fails with XCode 4
test(CFStringGetCStringPtr7)
{
    CFStringRef s = CFSTR("a/bc");
    const char *cString = CFStringGetCStringPtr(s, kCFStringEncodingASCII);
    testassert(cString != NULL);
    testassert(strcmp(cString, "a/bc") == 0);
    return YES;
}

test(CFStringGetCString)
{
    CFStringRef s = CFSTR("abc");
    char cString[4];
    CFStringGetCString(s, cString, 4, kCFStringEncodingASCII);
    testassert(strcmp(cString, "abc") == 0);
    return YES;
}

test(Lengths)
{
    // TODO

    return YES;
}

test(ConstantStrings)
{
    const char *s = [UTF8SampleNSString UTF8String];

    // Pointers should be re-used from constant strings
    testassert(strcmp(s, UTF8Sample) == 0);
    NSUInteger len = [UTF8SampleNSString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    testassert(len == UTF8SampleLen);
    for (NSUInteger i = 0; i < len; i++)
    {
        // Bytes at each index must be equal
        testassert(s[i] == UTF8Sample[i]);
    }

    return YES;
}

test(ConstantEquality)
{
    testassert(@"foo" != @"bar");
    testassert(@"foo" == @"foo");
    return YES;
}

test(ConstantEqualityFromExternal)
{
    extern NSString *const externalFoo;
    testassert(externalFoo == @"foo");
    return YES;
}

test(InitAndLength)
{
    NSString *s1 = @"abc";
    NSString *s2 = [NSString stringWithUTF8String:"abc"];
    NSString *s3 = [NSString stringWithFormat:@"%c%s", 'a', "bc"];

    testassert([s1 isEqualToString:s2]);
    testassert([s2 isEqualToString:s3]);
    testassert([s1 length] == 3);
    testassert([s2 length] == 3);
    testassert([s3 length] == 3);

    return YES;
}


test(StringWithFormat)
{
    NSString *str = @"/abc";
    char *str2 = "~/Documents";
    NSString *out = [NSString stringWithFormat:@"%@%s", str, &str2[1]];
    testassert([out isEqualToString:@"/abc/Documents"]);

    return YES;
}

test(NullCharacters)
{
    testassert(([[NSString stringWithFormat:@"%c", '\0'] length] == 0));

    unichar zero = 0;
    NSString *weirdStr = [NSString stringWithCharacters:&zero length:1];

    testassert(weirdStr.length == 1);

    weirdStr = [weirdStr stringByAppendingString:@"123"];

    testassert(weirdStr.length == 4);

    weirdStr = [NSString stringWithFormat:@"%@", weirdStr];

    testassert(weirdStr.length == 4);

    weirdStr = [NSString stringWithFormat:@"%c%@", '\0', weirdStr];

    testassert(weirdStr.length == 4);

    weirdStr = [weirdStr stringByAppendingString:[NSString stringWithCharacters:&zero length:1]];

    testassert(weirdStr.length == 5);

    testassert([weirdStr characterAtIndex:0] == 0);
    testassert([weirdStr characterAtIndex:1] == '1');
    testassert([weirdStr characterAtIndex:2] == '2');
    testassert([weirdStr characterAtIndex:3] == '3');
    testassert([weirdStr characterAtIndex:4] == 0);

    testassert([@"foo\0bar" length] == 7);
    testassert([@"\0foobar" length] == 7);
    testassert([@"foobar\0" length] == 7);

    return YES;
}

test(StringByDeletingLastPathComponent)
{
    testassert([[@"" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"/" stringByDeletingLastPathComponent] isEqualToString:@"/"]);
    testassert([[@"a" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"a/" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"b/asdf" stringByDeletingLastPathComponent] isEqualToString:@"b"]);
    testassert([[@"a/b/c" stringByDeletingLastPathComponent] isEqualToString:@"a/b"]);
    testassert([[@"a/b/asldfkjalskjdfasfdasfdlkasdfjasldkjfasdlkjf" stringByDeletingLastPathComponent] isEqualToString:@"a/b"]);
    testassert([[@"a//////b" stringByDeletingLastPathComponent] isEqualToString:@"a"]);
    testassert([[@"a////" stringByDeletingLastPathComponent] isEqualToString:@""]);
    testassert([[@"/a" stringByDeletingLastPathComponent] isEqualToString:@"/"]);
    testassert([[@"/b/c" stringByDeletingLastPathComponent] isEqualToString:@"/b"]);
    return YES;
}


/* stringByDeletingLastPathComponent should get rid of earlier duplicate slashes */

test(StringByDeletingLastPathComponentTODO)
{
    testassert([[@"a//b/////c///" stringByDeletingLastPathComponent] isEqualToString:@"a/b"]);
    return YES;
}

test(StringByAppendingPathComponent)
{
    testassert([[@"" stringByAppendingPathComponent:@""] isEqualToString:@""]);
    testassert([[@"a" stringByAppendingPathComponent:@""] isEqualToString:@"a"]);
    testassert([[@"a/" stringByAppendingPathComponent:@""] isEqualToString:@"a"]);
    testassert([[@"" stringByAppendingPathComponent:@"b"] isEqualToString:@"b"]);
    testassert([[@"a" stringByAppendingPathComponent:@"b"] isEqualToString:@"a/b"]);
    testassert([[@"a/" stringByAppendingPathComponent:@"b"] isEqualToString:@"a/b"]);
    testassert([[@"a" stringByAppendingPathComponent:@"/b"] isEqualToString:@"a/b"]);
    testassert([[@"a//////" stringByAppendingPathComponent:@"b"] isEqualToString:@"a/b"]);
    testassert([[@"a////" stringByAppendingPathComponent:@"///b"] isEqualToString:@"a/b"]);
    testassert([[@"a" stringByAppendingPathComponent:@"b/"] isEqualToString:@"a/b"]);
    testassert([[@"/" stringByAppendingPathComponent:@""] isEqualToString:@"/"]);
    testassert([[@"/" stringByAppendingPathComponent:@"b"] isEqualToString:@"/b"]);
    testassert([[@"/" stringByAppendingPathComponent:@"/b"] isEqualToString:@"/b"]);
    return YES;
}


- (BOOL)runLossyEncodingTest:(NSStringEncoding)encoding
{
    NSString *baseString = @"🄰🄱🄲🄳🄴🄵🄶🄷🄸🄹🄺🄻🄼🄽🄾🄿🅀🅁🅂🅃🅄🅅🅆🅇🅈🅉";

    NSUInteger len = [baseString maximumLengthOfBytesUsingEncoding:encoding];
    char *buf = malloc(len);
    NSUInteger outLen = 0;

    BOOL res = [baseString getBytes:buf maxLength:len usedLength:&outLen encoding:encoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, [baseString length]) remainingRange:NULL];
    testassert(res);
    testassert(outLen > 0);

    NSString *encoded = [[NSString alloc] initWithBytesNoCopy:buf length:outLen encoding:encoding freeWhenDone:YES];
    testassert(encoded != nil);
    [encoded release];

    return YES;
}


test(StringWithString)
{
    NSString *s = @"I'm constant";
    NSString *s2 = [NSString stringWithString:s];
    testassert([s isEqualToString:s2]);
    return YES;
}

test(StringWithNullUTF8String)
{
    void (^block)() = ^{
        [NSString stringWithUTF8String:NULL];
    };
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

test(StringWithNullUTF8String2)
{
    void (^block)() = ^{
        [[NSString alloc] initWithUTF8String:NULL];
    };
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

test(GetCharacters)
{
    NSString *s = @"I'm constant";
    NSUInteger length = [s length];
    unichar buffer[length];
    [s getCharacters:buffer];
    testassert(buffer[0] == 'I' && buffer[length - 1] == 't');

    return YES;
}

test(GetCharacters_isNotNilTerminated)
{
    NSString *s = @"föo";
    NSUInteger length = [s length];
    testassert(length == 3);
    NSRange range = NSMakeRange(0, length);

    struct {
        unichar buffer[4];
        uint32_t cap;
    } a_struct;

    memset(a_struct.buffer, 0xff, sizeof(a_struct.buffer));
    a_struct.cap = 0x0;

    testassert(sizeof(a_struct.buffer) > length*sizeof(unichar));
    [s getCharacters:a_struct.buffer range:range];
    testassert(a_struct.buffer[3] == 0xffff);

    // test bufover...
    unichar *ptr = a_struct.buffer;
    unsigned int i=0;
    for (; *ptr != '\0'; ptr++, i++)
    {
        // ...
    }

    testassert(i == sizeof(a_struct.buffer)/sizeof(unichar));

    return YES;
}

test(StringByTrimmingCharactersInSet)
{
    NSString *abc = [@"##A#BCD#D##" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    testassert([abc isEqualToString:@"A#BCD#D"]);

    return YES;
}

test(StringByTrimmingCharactersInSet2)
{
    NSString *abc = [@"##A#BCD#D@@" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@"A#BCD#D"]);

    return YES;
}

test(StringByTrimmingCharactersInSet3)
{
    NSString *abc = [@"@@" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@""]);

    return YES;
}

test(StringByTrimmingCharactersInSet4)
{
    NSString *abc = [@"@123" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@"123"]);

    return YES;
}

test(StringByTrimmingCharactersInSet5)
{
    NSString *abc = [@"123#" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@"123"]);

    return YES;
}

test(StringByTrimmingCharactersInSet6)
{
    NSString *abc = [@"" stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@"]];
    testassert([abc isEqualToString:@""]);

    return YES;
}

test(ComponentsSeparatedByStringEmpty)
{
    NSArray *a = [@"" componentsSeparatedByString: @"a"];
    testassert([a count] == 1);
    testassert([[a objectAtIndex:0] isEqualToString:@""]);
    return YES;
}

test(ComponentsSeparatedByStringEmptySeparator)
{
    NSArray *a = [@"" componentsSeparatedByString: @""];
    testassert([a count] == 1);
    testassert([[a objectAtIndex:0] isEqualToString:@""]);
    return YES;
}

test(ComponentsSeparatedByStringEmptySeparator2)
{
    NSArray *a = [@"abcdefghij" componentsSeparatedByString: @""];
    testassert([a count] == 1);
    testassert([[a objectAtIndex:0] isEqualToString:@"abcdefghij"]);
    return YES;
}

test(ComponentsSeparatedByStringNilSeparator)
{
    BOOL foundException = NO;
    NSArray *a;
    @try {
        a = [@"" componentsSeparatedByString:nil];
    }
    @catch (NSException *e) {
        foundException = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }

    testassert(foundException);
    return YES;
}

test(ComponentsSeparatedByCharactersInSetNilSeparator)
{
    BOOL foundException = NO;
    NSArray *a;
    @try {
        a = [@"" componentsSeparatedByCharactersInSet:nil];
    }
    @catch (NSException *e) {
        foundException = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(foundException);
    return YES;
}


test(ComponentsSeparatedByStringOne)
{
    NSArray *a = [@" " componentsSeparatedByString: @" "];
    testassert([a count] == 2);
    return YES;
}

test(ComponentsSeparatedByString) // issue 574
{
    NSArray *a = [@"\n\nQWERTY\n" componentsSeparatedByString: @"\n"];
    testassert([a count] == 4);
    return YES;
}

test(RangeOfCharacterFromSet574) // issue 574
{
    NSString *s = @"\n\nQWERTY\n";;
    NSRange range = [s rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:0 range:NSMakeRange(0, [s length])];
    testassert(range.location == 0 && range.length == 1);
    return YES;
}


test(ComponentsSeparatedByCharactersInSet574) // issue 574
{
    NSArray *a = [@"\n\nQWERTY\n" componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    testassert([[a objectAtIndex:0] isEqualToString:@""]);
    testassert([a count] == 4);
    return YES;
}

test(ComponentsSeparatedByCharactersInSet) // issue 569
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString: @", "];
    NSString *pointString = @"0,0 -124,0";
    NSArray *pointArray = [pointString componentsSeparatedByCharactersInSet:characterSet];
    NSArray *testArray = @[@"0", @"0", @"-124", @"0"];
    testassert([pointArray isEqualToArray:testArray]);
    return YES;
}

test(StringByDeletingPathExtension)
{
    NSString *abc = [@"abc.xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@"abc"]);
    return YES;
}

test(StringByDeletingPathExtension2)
{
    NSString *abc = [@".xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@".xyz"]);
    return YES;
}

test(StringByDeletingPathExtension3)
{
    NSString *abc = [@"xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@"xyz"]);
    return YES;
}

test(StringByDeletingPathExtension4)
{
    NSString *abc = [@"" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@""]);
    return YES;
}

test(StringByDeletingPathExtension5)
{
    NSString *abc = [@"abc..xyz" stringByDeletingPathExtension];
    testassert([abc isEqualToString:@"abc."]);
    return YES;
}

test(StringByStandardizingPath1)
{
    NSString *abc = [@"/abc/" stringByStandardizingPath];
    testassert([abc isEqualToString:@"/abc"]);
    return YES;
}

test(StringByStandardizingPath2)
{
    NSString *baz = [@"/abc/../bar/../baz" stringByStandardizingPath];
    testassert([baz isEqualToString:@"/baz"]);
    return YES;
}

test(StringByStandardizingPath3)
{
    NSString *abc = [@"~/abc/" stringByStandardizingPath];
    testassert([abc isEqualToString:[NSHomeDirectory() stringByAppendingPathComponent:@"abc"]]);
    return YES;
}

test(LossyEncodingNSASCIIStringEncoding)
{
    return [self runLossyEncodingTest:NSASCIIStringEncoding];
}

test(LossyEncodingNSNEXTSTEPStringEncoding)
{
    return [self runLossyEncodingTest:NSNEXTSTEPStringEncoding];
}

test(LossyEncodingNSUTF8StringEncoding)
{
    return [self runLossyEncodingTest:NSUTF8StringEncoding];
}

test(LossyEncodingNSISOLatin1StringEncoding)
{
    return [self runLossyEncodingTest:NSISOLatin1StringEncoding];
}

test(LossyEncodingNSNonLossyASCIIStringEncoding)
{
    return [self runLossyEncodingTest:NSNonLossyASCIIStringEncoding];
}

test(LossyEncodingNSUnicodeStringEncoding)
{
    return [self runLossyEncodingTest:NSUnicodeStringEncoding];
}

test(LossyEncodingNSWindowsCP1252StringEncoding)
{
    return [self runLossyEncodingTest:NSWindowsCP1252StringEncoding];
}

test(LossyEncodingNSMacOSRomanStringEncoding)
{
    return [self runLossyEncodingTest:NSMacOSRomanStringEncoding];
}

test(LossyEncodingNSUTF16StringEncoding)
{
    return [self runLossyEncodingTest:NSUTF16StringEncoding];
}

test(LossyEncodingNSUTF16BigEndianStringEncoding)
{
    return [self runLossyEncodingTest:NSUTF16BigEndianStringEncoding];
}

test(LossyEncodingNSUTF16LittleEndianStringEncoding)
{
    return [self runLossyEncodingTest:NSUTF16LittleEndianStringEncoding];
}

test(LossyEncodingNSUTF32BigEndianStringEncoding)
{
    return [self runLossyEncodingTest:NSUTF32BigEndianStringEncoding];
}

test(LossyEncodingNSUTF32LittleEndianStringEncoding)
{
    return [self runLossyEncodingTest:NSUTF32LittleEndianStringEncoding];
}

// these tests should be run when we have a icu database for the encodings
#if ICU_DATA

test(LossyEncodingNSJapaneseEUCStringEncoding)
{
    return [self runLossyEncodingTest:NSJapaneseEUCStringEncoding];
}

test(LossyEncodingNSSymbolStringEncoding)
{
    return [self runLossyEncodingTest:NSSymbolStringEncoding];
}

test(LossyEncodingNSShiftJISStringEncoding)
{
    return [self runLossyEncodingTest:NSShiftJISStringEncoding];
}

test(LossyEncodingNSISOLatin2StringEncoding)
{
    return [self runLossyEncodingTest:NSISOLatin2StringEncoding];
}

test(LossyEncodingNSWindowsCP1251StringEncoding)
{
    return [self runLossyEncodingTest:NSWindowsCP1251StringEncoding];
}

test(LossyEncodingNSWindowsCP1253StringEncoding)
{
    return [self runLossyEncodingTest:NSWindowsCP1253StringEncoding];
}

test(LossyEncodingNSWindowsCP1254StringEncoding)
{
    return [self runLossyEncodingTest:NSWindowsCP1254StringEncoding];
}

test(LossyEncodingNSWindowsCP1250StringEncoding)
{
    return [self runLossyEncodingTest:NSWindowsCP1250StringEncoding];
}

test(LossyEncodingNSISO2022JPStringEncoding)
{
    return [self runLossyEncodingTest:NSISO2022JPStringEncoding];
}

#endif

test(StringComparisons)
{
    NSComparisonResult result = [[NSString stringWithString:@"foo"] compare:nil];
    testassert(result == NSOrderedDescending);

    result = [@"foo" compare:nil];
    testassert(result == NSOrderedDescending);

#warning TODO : this is incomplete ...
    return YES;
}

test(ExtraEncodings)
{
    NSString *string = @"√∫˜µƒ©˙∆˚¬®†¥¨ˆøπ";
    const char *cstring = [string cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cstring == NULL);
    
    const char *cstringutf8 = [string cStringUsingEncoding:NSUTF8StringEncoding];
    testassert(cstringutf8 != NULL);
    
    NSString *base64 = @"validbase64=";
    const char *cbase64 = [base64 cStringUsingEncoding:NSASCIIStringEncoding];
    testassert(cbase64 != NULL);
    
    return YES;
}

test(FloatFormat1)
{
    NSString *string = [NSString stringWithFormat:@"%g", 2.9f];
    testassert([string isEqualToString:@"2.9"]);
    return YES;
}

test(FloatFormat2)
{
    NSString *string = [NSString stringWithFormat:@"%f", 2.9f];
    testassert([string isEqualToString:@"2.900000"]);
    return YES;
}

test(FloatFormat3)
{
    CGSize sz = CGSizeMake(1.1f, 2.9f);
    NSString *string = [NSString stringWithFormat:@"%.*g", 8, sz.height];
    testassert([string isEqualToString:@"2.9000001"]);
    return YES;
}

test(FloatFormat4)
{
    NSString *string = [NSString stringWithFormat:@"%.*g", 8, 2.9f];
    testassert([string isEqualToString:@"2.9000001"]);
    return YES;
}

test(FloatFormat5)
{
    NSString *string = [NSString stringWithFormat:@"%.8g", 2.9f];
    testassert([string isEqualToString:@"2.9000001"]);
    return YES;
}

test(BoolValue)
{
    testassert([@"1" boolValue] == YES);
    testassert([@"-1" boolValue] == YES);
    testassert([@"1000000" boolValue] == YES);
    testassert([@"10000000000" boolValue] == YES); // long overflow

    testassert([@"0" boolValue] == NO);
    testassert([@"0000000000000" boolValue] == NO);

    testassert([@"YES" boolValue] == YES);
    testassert([@"YEs" boolValue] == YES);
    testassert([@"true" boolValue] == YES);
    testassert([@"True" boolValue] == YES);

    testassert([@"NO" boolValue] == NO);
    testassert([@"no" boolValue] == NO);
    testassert([@"FALSE" boolValue] == NO);
    testassert([@"faLse" boolValue] == NO);

    testassert([@"" boolValue] == NO);
    testassert([@"apple" boolValue] == NO);

    return YES;
}

test(DoubleValue)
{
    testassert([@"256" doubleValue] == 256.);
    
    return YES;
}

test(FloatValue)
{
    testassert([@"128" floatValue] == 128.);
    
    return YES;
}

test(IntValue)
{
    testassert([@"123456" intValue] == 123456);
    
    return YES;
}

test(IntegerValue)
{
    testassert([@"7654321" integerValue] == 7654321);
    
    return YES;
}

test(LongLongValue)
{
    testassert([@"12345654321" longLongValue] == 12345654321LL);
    
    return YES;
}

#if !defined(__IPHONE_8_0)
test(UnsignedIntValue)
{
    testassert([@"42" unsignedIntValue] == 42);
    
    return YES;
}
#endif

#if __LP64__
#warning "Integer overflow tests not implemented for 64-bit"
#else
#if INT32_MAX == 2147483647
test(IntValueMax)
{
    testassert([@"2147483647" intValue] == INT32_MAX);
    
    return YES;
}

test(IntValueMin)
{
    testassert([@"-2147483648" intValue] == INT32_MIN);
    
    return YES;
}

test(IntValueOverflow)
{
    testassert([@"1232147483647" intValue] == INT32_MAX);
    
    return YES;
}

test(IntValueUnderflow)
{
    testassert([@"-1232147483647" intValue] == INT32_MIN);
    
    return YES;
}
#else
#error "INT32_MAX != 2147483647"
#endif
#endif

#if __LP64__ || defined(__IPHONE_8_0)
#warning "Unsigned integer overflow tests not implemented for 64-bit"
#else
#if UINT32_MAX == 4294967295U
test(UnsignedIntValueMax)
{
    testassert([@"4294967295" unsignedIntValue] == UINT32_MAX);
    
    return YES;
}

test(UnsignedIntValueOverflow)
{
    testassert([@"1232147483647" unsignedIntValue] == 3786836991);
    
    return YES;
}
#else
#error "UINT32_MAX != 4294967295U"
#endif
#endif

test(SimpleConstruction)
{
    NSSimpleCString *str = [[NSSimpleCString alloc] initWithCStringNoCopy:strdup("foo") length:3];
    testassert(str != nil);
    testassert([str length] == 3);
    [str release];
    return YES;
}

test(GetCStringMaxBufferCount)
{
   NSString *string = @"this is a string with 35 characters";

   char buffer[36];
   testassert([string getCString:buffer maxLength:36 encoding:NSUTF8StringEncoding]);
   testassert(!strcmp(buffer, "this is a string with 35 characters"));

   testassert(![string getCString:buffer maxLength:35 encoding:NSUTF8StringEncoding]);

   // What happens when the initial buffer has more?
   char longer_buff[46];
   strcpy(longer_buff, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
   testassert([string getCString:longer_buff maxLength:36 encoding:NSUTF8StringEncoding]);
   testassert(!strcmp(longer_buff, "this is a string with 35 characters"));

   return YES;
}

test(InternalGetCStringMaxBufferCount)
{
    NSString *string = @"this is a string with 35 characters";
    
    char buffer[36];
    testassert([string _getCString:buffer maxLength:35 encoding:kCFStringEncodingUTF8]);
    testassert(!strcmp(buffer, "this is a string with 35 characters"));
    
    testassert(![string _getCString:buffer maxLength:34 encoding:kCFStringEncodingUTF8]);
    
    // What happens when the initial buffer has more?
    char longer_buff[46];
    strcpy(longer_buff, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    testassert([string _getCString:longer_buff maxLength:35 encoding:kCFStringEncodingUTF8]);
    testassert(!strcmp(longer_buff, "this is a string with 35 characters"));

    return YES;
}

test(HasPrefix)
{
    NSString *str1 = @"the quick brown fox jumped over the lazy dog";
    NSString *str2 = @"the quick";
    NSString *str3 = @"the dead";
    
    testassert([str1 hasPrefix:str2]);
    testassert(![str1 hasPrefix:str3]);
    testassert(![str2 hasPrefix:str1]);
    testassert(![str3 hasPrefix:str1]);
    
    return YES;
}

test(PlaceholderMutableInit)
{
    NSMutableString* ms = [[NSMutableString alloc] initWithString:@"foo"];
    testassert([ms isEqualToString:@"foo"]);
    
    return YES;
}

test(PlaceholderMutableInitWithPathStore)
{
    NSString* pathString = [NSString pathWithComponents:@[@"foo", @"bar", @"baz"]];
    testassert([pathString isKindOfClass:objc_getClass("NSPathStore2")]);
    
    NSMutableString* mutablePathString = [[NSMutableString alloc] initWithString:pathString];
    testassert([pathString isEqualToString:mutablePathString]);
    
    return YES;
}

#pragma mark -
#pragma mark test [NSString initWithFormat:arguments:]

+ (NSString *)aStringWithFormat:(NSString *)fmt andParameters:(va_list)ap
{
    NSString *str=[[NSString alloc] initWithFormat:fmt arguments:ap];
    return [str autorelease];
}

+ (NSString *)aStringWithFormat:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *str = [[NSString alloc] initWithFormat:fmt arguments:ap];
    va_end(ap);
    return [str autorelease];
}

+ (NSString *)aStringWithFormat2:(NSString *)fmt, ...
{
    va_list ap;
    va_start(ap, fmt);
    NSString *str = [[self class] aStringWithFormat:fmt andParameters:ap];
    va_end(ap);
    return str;
}

test(InitWithFormat1)
{
    NSString *str = [[self class] aStringWithFormat:@"a string '%@' and another string '%@'", @"foo", @"bar"];
    testassert([str isEqualToString:@"a string 'foo' and another string 'bar'"]);
    return YES;
}

test(InitWithFormat2)
{
    NSString *str = [[self class] aStringWithFormat2:@"a string '%@' and another string '%@'", @"foo", @"bar"];
    testassert([str isEqualToString:@"a string 'foo' and another string 'bar'"]);
    return YES;
}

test(InitWithFormat_fromNSPathStore2)
{
    NSString *defaultPngPath = [[NSBundle mainBundle] pathForResource:@"ATestPlist" ofType:@"plist"];
    testassert([defaultPngPath isKindOfClass:NSClassFromString(@"__NSCFString")]);
    defaultPngPath = [defaultPngPath stringByDeletingPathExtension];
    testassert([defaultPngPath isKindOfClass:NSClassFromString(@"NSPathStore2")]);
    
    NSString *str = [[self class] aStringWithFormat2:@"Path file : %@", defaultPngPath];
    
    testassert([[str substringToIndex:12] isEqualToString:@"Path file : "]);
    
    return YES;
}

test(StringByDeletingPathExtension_fromNSPathStore2)
{
    NSString *path = [NSString pathWithComponents:@[@"foo", @"bar", @"baz_file.txt"]];
    testassert([path isKindOfClass:NSClassFromString(@"NSPathStore2")]);
    path = [path stringByDeletingPathExtension];
    testassert([path isEqualToString:@"foo/bar/baz_file"]);
    testassert(!strcmp([path UTF8String], "foo/bar/baz_file"));
    
    return YES;
}

test(SubstringWithRange)
{
    NSString *str = [@"foo-bar-baz" substringWithRange:NSMakeRange(4, 3)];
    testassert([str isEqualToString:@"bar"]);
    return YES;
}

test(IsEqualToStringWithNSPathStore2)
{
    NSString *str1 = @"name";
    NSString *str2 = @"name.ttf";
    NSString *str3 = [str2 stringByDeletingPathExtension];
    testassert([str1 isEqualToString:str3]);
    return YES;
}

test(HashValue)
{
    NSString *str = @"Hello world";
#if __LP64__
    testassert([str hash] == 16216313663434135879ull);
#else
    testassert([str hash] == 4081981767u);
#endif
    return YES;
}

test(HashValueEmptyStr)
{
    NSString *str = @"";
    testassert([str hash] == 0);
    return YES;
}

test(HashValueNil)
{
    NSString *str = nil;
    testassert([str hash] == 0);
    return YES;
}

test(HashValueUnicode)
{
    NSString *str = @"你好世界";
#if __LP64__
    testassert([str hash] == 52948922483ull);
#else
    testassert([str hash] == 1409314931u);
#endif
    return YES;
}

test(HashValueSpaces)
{
    NSString *str = @"    ";
#if __LP64__
    testassert([str hash] == 13860460740ull);
#else
    testassert([str hash] == 975558852u);
#endif
    return YES;
}

#pragma mark - Test [NSString initWithData: encoding:]

test(InitWithNSUTF16BigEndianStringEncoding)
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"stringData.bin" ofType:nil];
    NSData * dataStr = [NSData dataWithContentsOfFile:strPath];
    NSString *str = [[NSString alloc] initWithData:dataStr encoding:NSUTF16BigEndianStringEncoding];
    testassert([str isEqualToString:@"Muscle: Leavator Scapulae\nArticulation: Glenohumeral\nRange of Motion: Elevation 0°-40°"]);
    return YES;
}

test(InitWithNSUTF16StringEncoding)
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"stringData.bin" ofType:nil];
    NSData * dataStr = [NSData dataWithContentsOfFile:strPath];
    NSString *str = [[NSString alloc] initWithData:dataStr encoding:NSUTF16StringEncoding];
    testassert([str isEqualToString:@"Muscle: Leavator Scapulae\nArticulation: Glenohumeral\nRange of Motion: Elevation 0°-40°"]);
    return YES;
}

#pragma mark - Test [NSString stringWithContentsOfFile:encoding:error:]

test(StringWithContentsOfFileUTF8)
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"utf8" ofType:@"txt"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    testassert(str != nil);
    testassert(error == nil);
    testassert([str isKindOfClass:[objc_getClass("NSString") class]]);
    testassert([str isEqualToString:
        @"Lorem ipsum dolor sit amet, consectetür adipisicing élit, sed do eiusmod tempor incididunt."]);
    return YES;
}

test(LengthOfBytesUsingEncoding)
{
    NSString *string = @("√∫˜µƒ©˙∆˚¬®†¥¨ˆøπ");
    
    struct { NSStringEncoding encoding; NSUInteger length; } tests[] =
    {
        { NSASCIIStringEncoding,    0 },
        { NSUTF8StringEncoding,     38 },
        { NSUnicodeStringEncoding,  34 },
        { NSUTF16StringEncoding,    34 },
        { NSUTF32StringEncoding,    68 },
    };
    int num = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<num; ++i)
    {
        testassert([string lengthOfBytesUsingEncoding:tests[i].encoding] == tests[i].length);
    }
    
    return YES;
}

test(GetBytes)
{
    const char originalBuffer[]      = { 0xde, 0xad, 0xbe, 0xef };
    const char endPartialBuffer[]    = { 'b', 'c', 0xbe, 0xef };
    const char middlePartialBuffer[] = { 'b', 0xad, 0xbe, 0xef };
    const char startPartialBuffer[]  = { 'a', 'b', 'c', 0xef };
    const char partialBuffer[]       = { 'a', 0xad, 0xbe, 0xef };
    
    struct { NSString *string; NSStringEncoding encoding; NSUInteger options; NSRange range;
        BOOL result; NSUInteger usedLength; NSRange remainingRange; const char* data; } tests[] =
    {
        { @"",        NSUTF8StringEncoding,  0, NSMakeRange(0, 0), YES, 0, NSMakeRange(0, 0), originalBuffer },
        { @"",        NSUTF8StringEncoding,  0, NSMakeRange(0, 1), YES, 0, NSMakeRange(0, 1), originalBuffer },
        { @"",        NSUTF8StringEncoding,  0, NSMakeRange(2, 3), YES, 0, NSMakeRange(2, 3), originalBuffer },
        { @"abc",     NSUTF8StringEncoding,  0, NSMakeRange(1, 0), NO,  0, NSMakeRange(1, 0), originalBuffer },
        { @"abc",     NSUTF8StringEncoding,  0, NSMakeRange(1, 2), YES, 2, NSMakeRange(3, 0), endPartialBuffer },
        { @"abc",     NSASCIIStringEncoding, 0, NSMakeRange(1, 1), YES, 1, NSMakeRange(2, 0), middlePartialBuffer },
        { @"√∫˜µƒ©",  NSASCIIStringEncoding, 0, NSMakeRange(0, 6), NO,  0, NSMakeRange(0, 6), originalBuffer },
        { @"abc√∫˜µ", NSASCIIStringEncoding, 0, NSMakeRange(0, 7), YES, 3, NSMakeRange(3, 4), startPartialBuffer },
        { @"abc",     NSASCIIStringEncoding, 0, NSMakeRange(0, 4), YES, 4, NSMakeRange(4, 0), "abc" },
        // Apple bug: getBytes will happily read garbage after the end of a string!
        { @"xy",      NSASCIIStringEncoding, 0, NSMakeRange(0, 4), YES, 4, NSMakeRange(4, 0), NULL },
        // Private encoding option to not return success on partial encoding
        { @"a√",      NSASCIIStringEncoding, 4, NSMakeRange(0, 2), NO,  1, NSMakeRange(1, 1), partialBuffer },
    };
    int num = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<num; ++i)
    {
        char buffer[sizeof(originalBuffer)];
        memcpy(buffer, originalBuffer, sizeof(buffer));
        NSRange remainingRange = NSMakeRange(-1, -1);
        NSUInteger usedLength = -1;
        
        BOOL result = [tests[i].string getBytes:buffer maxLength:sizeof(buffer)
            usedLength:&usedLength encoding:tests[i].encoding options:tests[i].options
            range:tests[i].range remainingRange:&remainingRange];
        
        testassert(result == tests[i].result);
        if (tests[i].data)
            testassert(!memcmp(buffer, tests[i].data, sizeof(buffer)));
        testassert(NSEqualRanges(remainingRange, tests[i].remainingRange));
        testassert(usedLength == tests[i].usedLength);
    }
    
    return YES;
}

test(GetCStringEncoding)
{
    const char originalBuffer[]   = { 0xca, 0xfe, 0xba, 0xbe };
    const char terminatedBuffer[] = { '\0', 0xfe, 0xba, 0xbe };
    const char choppedBuffer[]    = { '\0', 'b', 0xba, 0xbe };
    const char partialBuffer[]    = { 'a', 'b', '\0', 0xbe };
    const char fullBuffer[]       = { '\0', 'b', 'c', 0xbe };
    
// TODO commented lines now failing on iOS
    
    struct { NSString *string; NSUInteger maxLen; NSStringEncoding encoding; BOOL result; const char* data; } tests[] =
    {
        { @"",    4, NSUTF8StringEncoding, YES, terminatedBuffer },
        { @"abc", 0, NSUTF8StringEncoding, NO,  originalBuffer },
//        { @"abc", 1, NSUTF8StringEncoding, NO,  terminatedBuffer },
//        { @"abc", 2, NSUTF8StringEncoding, NO,  terminatedBuffer },
//        { @"abc", 3, NSUTF8StringEncoding, NO,  choppedBuffer },
        { @"abc", 4, NSUTF8StringEncoding, YES, "abc" },
        { @"ab",  4, NSUTF8StringEncoding, YES, partialBuffer },
//        { @"abcd",4, NSUTF8StringEncoding, NO,  fullBuffer },
        { @"√",   4, NSASCIIStringEncoding,NO,  terminatedBuffer },
        { @"ab√", 4, NSASCIIStringEncoding,NO,  choppedBuffer }
    };
    int num = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<num; ++i)
    {
        char buffer[sizeof(originalBuffer)];
        memcpy(buffer, originalBuffer, sizeof(buffer));
        
        BOOL result = [tests[i].string getCString:buffer maxLength:tests[i].maxLen encoding:tests[i].encoding];
        
        testassert(result == tests[i].result);
        testassert(!memcmp(buffer, tests[i].data, sizeof(buffer)));
    }
    
    return YES;
}

test(GetCStringRange)
{
    const char originalBuffer[]   = { 0xde, 0xed, 0xc0, 0xde };
    const char terminatedBuffer[] = { '\0', 0xed, 0xc0, 0xde };
    const char startBuffer[]      = { 'a', '\0', 0xc0, 0xde };
    const char sqrtBuffer[]       = { 0xc3, 0x0, 0xc0, 0xde };
    const char overflowBuffer[]   = { 'a', 'b', 'c', 0xde };
    
    struct { NSString *string; NSUInteger maxLen; NSRange range;
        BOOL raises; NSRange leftoverRange; const char* data; } tests[] =
    {
        { @"",     0, NSMakeRange(0, 0), NO,  NSMakeRange(0, 0), terminatedBuffer },
        { @"",     1, NSMakeRange(0, 0), NO,  NSMakeRange(0, 0), terminatedBuffer },
        { @"a",    1, NSMakeRange(0, 1), NO,  NSMakeRange(1, 0), startBuffer },
        { @"abc",  3, NSMakeRange(0, 1), NO,  NSMakeRange(1, 0), startBuffer },
        { @"abc",  3, NSMakeRange(0, 3), NO,  NSMakeRange(3, 0), "abc" },
        // Test range extends beyond string.
        // Apple bug: Docs say this should throw an NSRangeException, it doesn't!
        { @"ab",   3, NSMakeRange(0, 4), YES, NSMakeRange(3, 1), NULL },
        // Test buffer too small
        { @"abcd", 3, NSMakeRange(0, 4), YES, NSMakeRange(3, 1), overflowBuffer },
        { @"√",    3, NSMakeRange(0, 1), NO,  NSMakeRange(1, 0), sqrtBuffer }
    };
    int num = sizeof(tests)/sizeof(tests[0]);
    
    for (int i=0; i<num; ++i)
    {
        char buffer[sizeof(originalBuffer)];
        memcpy(buffer, originalBuffer, sizeof(buffer));
        
        BOOL didRaise = NO;
        NSRange remainingRange = NSMakeRange(-1, -1);
        @try {
            [tests[i].string getCString:buffer maxLength:tests[i].maxLen range:tests[i].range remainingRange:&remainingRange];
        }
        @catch (NSException *exception) {
            didRaise = YES;
            testassert([exception.name isEqualToString:NSCharacterConversionException]);
        }
        
        testassert(didRaise == tests[i].raises);
        if (tests[i].data)
            testassert(!memcmp(buffer, tests[i].data, sizeof(buffer)));
        testassert(NSEqualRanges(remainingRange, tests[i].leftoverRange));
    }
    
    return YES;
}

test(rangeOfStringRegular)
{
    NSRange range = [@"I'm gonna drink 'til I reboot!" rangeOfString:@" drink" options:0];
    testassert(range.location == 9);
    testassert(range.length == 6);
    return YES;
}

test(rangeOfStringCaseInsensitive)
{
    NSRange range = [@"I'm gonna drink 'til I reboot!" rangeOfString:@" DriNK" options:NSCaseInsensitiveSearch];
    testassert(range.location == 9);
    testassert(range.length == 6);
    return YES;
}

test(rangeOfStringRegex)
{
    NSRange range = [@"<b>Hello world" rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch];
    testassert(range.location == 0);
    testassert(range.length == 3);
    return YES;
}

test(rangeOfStringInvalidRegex)
{
    NSRange range = [@"<b>Hello world" rangeOfString:@"<[^>+>" options:NSRegularExpressionSearch];
    testassert(range.location == NSNotFound);
    return YES;
}

#ifdef APPORTABLE

test(StringWithContentsOfFileAndroidPaths)
{
    NSString* paths[] = {
        @"/proc/meminfo",
        @"/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
    };
    const int len = sizeof(paths)/sizeof(paths[0]);
    
    for (int i=0; i<len; ++i)
    {
        NSString *str = [NSString stringWithContentsOfFile:paths[i] encoding:NSUTF8StringEncoding error:nil];
        
        testassert(str.length > 0);
    }
    
    return YES;
}

#endif

#pragma mark -

@end

#warning TODO: String tests & cleanup

/*
{
    NSTEST_BEGIN

    NSTEST_EXCEPTION([[NSString alloc] initWithString:Nil],
                     NSInvalidArgumentException, YES,
                     "stringWithString:Nil");
    NSTEST_EXCEPTION([[NSString alloc] initWithString:Nil],
                     NSInvalidArgumentException, YES,
                     "initWithString:Nil");

    NSString* asciiSample =
    [[[NSString allocWithZone:(NSZone*)kCFAllocatorMalloc]
      initWithCString:AsciiSample]
     autorelease];
    TestAsciiString([NSString stringWithString:asciiSample],
                    "stringWithString (ascii)");
    TestAsciiString([[[NSString alloc] initWithString:asciiSample] autorelease],
                    "initWithString (ascii)");

    NSTEST_END
}

// Empty strings.
{
    NSTEST_BEGIN

    TestEmptyString(@"",
                    "@\"\"");

    TestEmptyString((NSString*)CFSTR(""),
                    "CFSTR(\"\")");

    TestEmptyString([NSString string],
                    "string");

    TestEmptyString([NSString stringWithCharacters:NULL length:0],
                    "stringWithCharacters:(NULL)");

    TestEmptyString([NSString stringWithCharacters:EmptyUnicodeSample length:0],
                    "stringWithCharacters:(empty)");

    NSTEST_EXCEPTION([NSString stringWithCString:NULL],
                     NSInvalidArgumentException, YES,
                     "stringWithCString:(NULL)");

    TestEmptyString([NSString stringWithCString:"" length:0],
                    "stringWithCString:(empty)");

    TestEmptyString([NSString stringWithCString:NULL length:0],
                    "stringWithCString:(NULL) length:0");

    TestEmptyString([[[NSString allocWithZone:(NSZone*)kCFAllocatorMalloc] init] autorelease],
                    "(non-standard zone) init");

    //TODO test NULLs and Nils in creation methods.

    NSTEST_END
}

// sort out
{
    NSTEST_BEGIN

    //TODO test all format methods
    TEST_ASSERT((
                 [[NSString stringWithFormat:@"%d %s %@", 1, "two", @"three"]
                  isEqualToString:[NSString stringWithString:@"1 two three"]]),
                "stringWithFormat");

    NSTEST_END
}

// Ascii strings.
{
    NSTEST_BEGIN

    TestAsciiString([NSString stringWithCString:AsciiSample],
                    "stringWithCString");

    TestAsciiString([NSString stringWithCharacters:AsciiSampleUnicode length:AsciiSampleLength],
                    "stringWithCharacters:(ascii)");

    TestAsciiString([NSString stringWithString:[NSString stringWithCString:AsciiSample]],
                    "stringWithString:(ascii)");

    NSTEST_END
}

// Unicode strings.
{
    NSTEST_BEGIN

    TestUnicodeString([NSString stringWithString:
                       [NSString stringWithCString:UnicodeSampleUTF8 encoding:NSUTF8StringEncoding]],
                      "stringWithString");

    TestUnicodeString([NSString stringWithCString:UnicodeSampleUTF8 encoding:NSUTF8StringEncoding],
                      "stringCString:(unicode) encoding:(UTF8)");

    TestUnicodeString([NSString stringWithCharacters:UnicodeSample length:UnicodeSampleLength],
                      "stringWithCharacters:(unicode)");

    NSTEST_END
}

// 	rangeOfString
{
    NSTEST_BEGIN

    NSRange range;


    range = [@"I'm gonna drink 'til I reboot!"
             rangeOfString:@" DRInK" options:NSCaseInsensitiveSearch];
    TEST_ASSERT(NSEqualRanges(range, NSMakeRange(9, 6)),
                "rangeOfString:opions:(case insensitive)");

    range = [@"I'm gonna drink 'til I reboot!"
             rangeOfString:@"unrelated" options:NSCaseInsensitiveSearch];
    TEST_ASSERT(NSEqualRanges(range, RangeNotFound),
                "rangeOfString:opions:(case insensitive)");

    NSTEST_END
}

// compare
{
    NSTEST_BEGIN

    TEST_ASSERT([@"test" compare:@"test"] == NSOrderedSame,
                "compare:(equal)");
    TEST_ASSERT([@"test" compare:@"unrelated"] != NSOrderedSame,
                "compare:(not equal)");
    TEST_ASSERT([@"test" compare:@"Test"] == NSOrderedDescending,
                "compare:(ascending)");
    TEST_ASSERT([@"TEst" compare:@"Test"] == NSOrderedAscending,
                "compare:(descending)");

    TEST_ASSERT([@"test" caseInsensitiveCompare:@"tEsT"] == NSOrderedSame,
                "compare:(case insensitive)");

    //TODO all other cases

    NSTEST_END
}

// getLineStart:end:contentsEnd:forRange
{
    NSTEST_BEGIN

    NSString* lines = @"one\rtwo\nthree\r\nfour";

    AssertGetLineStart("getLineStart:(beginning)",
                       lines, NSMakeRange(0, 0), 0, 4, 3);
    AssertGetLineStart("getLineStart:(middle)",
                       lines, NSMakeRange(5, 0), 4, 8, 7);
    AssertGetLineStart("getLineStart:(end)",
                       lines, NSMakeRange(16, 0), 15, 19, 19);

    AssertGetLineStart("getLineStart:(whole)",
                       lines, NSMakeRange(0, 19), 0, 19, 19);

    AssertGetLineStart("getLineStart:(overlapping)",
                       lines, NSMakeRange(6, 3), 4, 15, 13);

    AssertGetLineStart("getLineStart:(CR in CRLF)",
                       lines, NSMakeRange(13, 1), 8, 15, 13);
    AssertGetLineStart("getLineStart:(LF in CRLF)",
                       lines, NSMakeRange(14, 1), 8, 15, 13);

    NSUInteger start;
    NSUInteger lineEnd;
    NSUInteger contentsEnd;

    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange(0, [lines length] + 1)],
                     NSRangeException, YES,
                     "getLineStart:range:(invalid length)");
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange([lines length] + 1, 0)],
                     NSRangeException, YES,
                     "getLineStart:range:(invalid location)");
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange([lines length] * 2, [lines length] + 1)],
                     NSRangeException, YES,
                     "getLineStart:range:(invalid location & length)");
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange(NSUIntegerMax / 2, 2)],
                     NSRangeException, YES,
                     "getLineStart:range:(positive overflow)");

#ifndef __APPLE__
    NSTEST_EXCEPTION(
                     [lines getLineStart:&start end:&lineEnd contentsEnd:&contentsEnd
                                forRange:NSMakeRange(NSUIntegerMax - 1, 2)],
                     NSRangeException, YES,
                     "getLineStart:range:(negative overflow)");
#endif

    NSTEST_END
}

// lowercaseString
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"aBC" lowercaseString] isEqualToString:@"abc"],
                "lowercaseString");

    TEST_ASSERT([[@"abc" lowercaseString] isEqualToString:@"abc"],
                "lowercaseString (lowercased)");

    TEST_ASSERT([[@"" lowercaseString] isEqualToString:@""],
                "lowercaseString (empty)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"abc" lowercaseString] isKindOfClass:[NSMutableString class]],
                "lowercaseString returns immutable string");
#endif

    NSTEST_END
}

// uppercaseString
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"aBc" uppercaseString] isEqualToString:@"ABC"],
                "uppercaseString");

    TEST_ASSERT([[@"ABC" uppercaseString] isEqualToString:@"ABC"],
                "uppercaseString (uppercased)");

    TEST_ASSERT([[@"" uppercaseString] isEqualToString:@""],
                "uppercaseString (empty)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"abc" uppercaseString] isKindOfClass:[NSMutableString class]],
                "uppercaseString returns immutable string");
#endif

    NSTEST_END
}

// capitalizeString
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"tEst" capitalizedString] isEqualToString:@"Test"],
                "capitalizedString (one word)");

    TEST_ASSERT([[@"a" capitalizedString] isEqualToString:@"A"],
                "capitalizedString (one letter)");

    TEST_ASSERT([[@"one t\tthree\nf\rfive\r\ns\n" capitalizedString]
                 isEqualToString:@"One T\tThree\nF\rFive\r\nS\n"],
                "capitalizedString (sentense)");

    TEST_ASSERT([[@" one\n t\r\tthree\r\n\nf \rfive\t\r\ns\n " capitalizedString]
                 isEqualToString:@" One\n T\r\tThree\r\n\nF \rFive\t\r\nS\n "],
                "capitalizedString (sentense with double separators)");

    TEST_ASSERT([[@"Test" capitalizedString] isEqualToString:@"Test"],
                "capitalizedString (capitalized)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"test" capitalizedString] isKindOfClass:[NSMutableString class]],
                "capitalizedString returns immutable string");
#endif

    NSTEST_END
}

// stringByAppendingFormat
{
    NSTEST_BEGIN

    TEST_ASSERT([[@"test" stringByAppendingFormat:@""] isEqualToString:@"test"],
                "stringByAppendingFormat (empty)");

    TEST_ASSERT(([[@"safe code: " stringByAppendingFormat:@"%s, %@, %1$s", "one", @"two"]
                  isEqualToString:@"safe code: one, two, one"]),
                "stringByAppendingFormat (format)");

    NSTEST_EXCEPTION([@"test" stringByAppendingFormat:Nil],
                     NSInvalidArgumentException, YES,
                     "stringByAppendingFormat (Nil)");

#ifndef __APPLE__
    TEST_ASSERT(![[@"test" stringByAppendingFormat:@""] isKindOfClass:[NSMutableString class]],
                "stringByAppendingFormat returns immutable string");
#endif

    NSTEST_END
}

// canBeConvertedToEncoding
{
    NSTEST_BEGIN

    TEST_ASSERT([@"test" canBeConvertedToEncoding:NSASCIIStringEncoding],
                "canBeConvertedToEncoding (ASCII)");
    TEST_ASSERT([@"test" canBeConvertedToEncoding:NSNEXTSTEPStringEncoding],
                "canBeConvertedToEncoding (NEXTSTEP)");

    TEST_ASSERT(![@"test" canBeConvertedToEncoding:-100],
                "canBeConvertedToEncoding (invalid)");

    unichar uchars[] = {
        'A', 'P', 'P', 'L', 'E',
        ' ',
        0xF8FF, // Apple logo
    };
    NSString* ustring = [NSString stringWithCharacters:uchars
                                                length:(sizeof(uchars) / sizeof(*uchars))];

    TEST_ASSERT(![ustring canBeConvertedToEncoding:NSASCIIStringEncoding],
                "canBeConvertedToEncoding (unicode -> ASCII)");
    TEST_ASSERT(![ustring canBeConvertedToEncoding:NSISOLatin1StringEncoding],
                "canBeConvertedToEncoding (unicode -> ISOLatin1)");
    TEST_ASSERT([ustring canBeConvertedToEncoding:NSMacOSRomanStringEncoding],
                "canBeConvertedToEncoding (unicode -> MacOSRoman)");
    TEST_ASSERT([ustring canBeConvertedToEncoding:NSUnicodeStringEncoding],
                "canBeConvertedToEncoding (unicode -> Unicode)");

    //TODO empty strings - should convert to any encoding

    NSTEST_END
}
*/
