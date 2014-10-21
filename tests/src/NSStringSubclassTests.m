//
//  NSStringSubclassTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

static NSStringEncoding NSDefaultCStringEncoding()
{
    CFStringEncoding encoding = CFStringGetSystemEncoding();
    return CFStringConvertEncodingToNSStringEncoding(encoding);
}

@interface NSString (Internal)
- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount filledLength:(NSUInteger *)filledLength encoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy range:(NSRange)range remainingRange:(NSRangePointer)leftover;
@end

@interface NSStringSubclass : NSString

@end

@implementation NSStringSubclass {
    NSString *backing;
}

- (id)init
{
    self = track([super init]);
    if (self)
    {
        backing = @"asdfasdfasdf";
    }
    return self;
}

- (NSUInteger)length
{
    return track([backing length]);
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    return track([backing characterAtIndex:index]);
}

- (NSRange)rangeOfString:(NSString *)aString
{
    return track([super rangeOfString:aString]);
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask
{
    return track([super rangeOfString:str options:mask]);
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange
{
    return track([super rangeOfString:str options:mask range:searchRange]);
}

- (NSRange)rangeOfString:(NSString *)str options:(NSStringCompareOptions)mask range:(NSRange)searchRange locale:(NSLocale *)locale
{
    return track([super rangeOfString:str options:mask range:searchRange locale:locale]);
}

- (id)copy
{
    return track([super copy]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return track([super copyWithZone:zone]);
}

@end

@interface NSStringInternalsSubclass : NSString
{
    NSString       *_backing;
@public
    char                               *_bytes;
    NSUInteger                          _maxLength;
    NSUInteger                         *_usedLength;
    NSStringEncoding                    _encoding;
    NSStringEncodingConversionOptions   _options;
    NSRange                             _range;
    NSRangePointer                      _leftoverRange;
    BOOL                                _result;
}
@end

@implementation NSStringInternalsSubclass

- (id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self)
    {
        _backing = track([[NSString alloc] initWithString:aString]);
    }
    return self;
}

- (void)dealloc
{
    [_backing release];
    
    [super dealloc];
}

- (NSUInteger)length
{
    return track([_backing length]);
}

- (void)getCString:(char *)bytes
{
    track([super getCString:bytes]);
}

- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength
{
    track([super getCString:bytes maxLength:maxLength]);
}

- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount filledLength:(NSUInteger *)filledLength encoding:(NSStringEncoding)encoding allowLossyConversion:(BOOL)lossy range:(NSRange)range remainingRange:(NSRangePointer)leftover
{
    return track([super getBytes:buffer maxLength:maxBufferCount filledLength:filledLength encoding:encoding allowLossyConversion:lossy range:range remainingRange:leftover]);
}

- (void)getCString:(char *)bytes maxLength:(NSUInteger)maxLength range:(NSRange)range remainingRange:(NSRangePointer)leftoverRange
{
    return track([super getCString:bytes maxLength:maxLength range:range remainingRange:leftoverRange]);
}

- (BOOL)getCString:(char *)buffer maxLength:(NSUInteger)maxBufferCount encoding:(NSStringEncoding)encoding
{
    return track([super getCString:buffer maxLength:maxBufferCount encoding:encoding]);
}

- (BOOL)getBytes:(void *)buffer maxLength:(NSUInteger)maxBufferCount usedLength:(NSUInteger *)usedBufferCount encoding:(NSStringEncoding)encoding options:(NSStringEncodingConversionOptions)options range:(NSRange)range remainingRange:(NSRangePointer)leftover
{
    _bytes         = buffer;
    _maxLength     = maxBufferCount;
    _usedLength    = usedBufferCount;
    _encoding      = encoding;
    _options       = options;
    _range         = range;
    _leftoverRange = leftover;
    
    _result = track([_backing getBytes:buffer maxLength:maxBufferCount usedLength:usedBufferCount encoding:encoding options:options range:range remainingRange:leftover]);
    
    return _result;
}

- (__strong const char *)cStringUsingEncoding:(NSStringEncoding)encoding NS_RETURNS_INNER_POINTER
{
    return track([super cStringUsingEncoding:encoding]);
}

- (__strong const char *)UTF8String
{
    return track([super UTF8String]);
}

- (const char *)cString
{
    return track([super cString]);
}

 - (const char *)lossyCString
{
    return track([super lossyCString]);
}

@end

@testcase(NSStringSubclass)

test(RangeOfStringCallPattern)
{
    NSStringSubclass *target = [[NSStringSubclass alloc] init];
    testassert(target != nil);
    [target rangeOfString:@"fasd"];
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(init), @selector(rangeOfString:), @selector(length), @selector(rangeOfString:options:range:locale:), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [target release];
    return YES;
}

test(Copy)
{
    NSStringSubclass *target = [[NSStringSubclass alloc] init];
    testassert(target != nil);
    NSString *str = [target copy];
    testassert(str != nil);
    testassert(target != str);
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(init), @selector(copy), @selector(copyWithZone:), @selector(length), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [str release];
    [target release];
    return YES;
}

test(CFStringCopy)
{
    NSStringSubclass *target = [[NSStringSubclass alloc] init];
    testassert(target != nil);
    NSString *str = (NSString *)CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)target);
    testassert(str != nil);
    testassert(target != str);
//    [SubclassTracker dumpVerification:target]
    BOOL verified = [SubclassTracker verify:target commands:@selector(init), @selector(copy), @selector(copyWithZone:), @selector(length), @selector(length), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), @selector(characterAtIndex:), nil];
    testassert(verified);
    [str release];
    [target release];
    return YES;
}

test(GetCString)
{
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:@"Hello, world!"];
    
    char buffer[0x10] = {0};
    [target getCString:buffer];
    
    testassert(!strcmp(buffer, "Hello, world!"));
    testassert(target->_result == YES);
    testassert(target->_bytes == buffer);
    NSUInteger expectedLength = MIN((uintptr_t)buffer ^ -1, NSMaximumStringLength);
    testassert(target->_maxLength == expectedLength);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSDefaultCStringEncoding());
    testassert(target->_options == (NSStringEncodingConversionOptions)6);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 13)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(getCString:), @selector(length), @selector(getCString:maxLength:range:remainingRange:), @selector(getBytes:maxLength:filledLength:encoding:allowLossyConversion:range:remainingRange:), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

test(GetCStringMaxLength)
{
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:@"Hello, world!"];
    
    char buffer[0x10] = {0};
    NSUInteger maxLength = sizeof(buffer) - 1;
    [target getCString:buffer maxLength:maxLength];
    
    testassert(!strcmp(buffer, "Hello, world!"));
    testassert(target->_result == YES);
    testassert(target->_bytes == buffer);
    testassert(target->_maxLength == maxLength);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSDefaultCStringEncoding());
    testassert(target->_options == (NSStringEncodingConversionOptions)6);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 13)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(getCString:maxLength:), @selector(length), @selector(getCString:maxLength:range:remainingRange:), @selector(getBytes:maxLength:filledLength:encoding:allowLossyConversion:range:remainingRange:), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

test(GetCStringMaxLengthEncoding)
{
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:@"Hello √∫ world!"];
    
    char buffer[0x40] = {0};
    NSUInteger maxLength = sizeof(buffer);
    BOOL result = [target getCString:buffer maxLength:maxLength encoding:NSASCIIStringEncoding];
    
    testassert(result == NO);
    testassert(!strcmp(buffer, "Hello "));
    testassert(target->_result == NO);
    testassert(target->_bytes == buffer);
    testassert(target->_maxLength == maxLength - 1);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSASCIIStringEncoding);
    testassert(target->_options == (NSStringEncodingConversionOptions)4);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 15)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(getCString:maxLength:encoding:), @selector(length), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

test(CStringUsingEncoding)
{
    // 165 characters - longest length where getBytes is only called once
    const char* goldilocks = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient monte";
    
    NSString *string = [NSString stringWithCString:goldilocks encoding:NSASCIIStringEncoding];
    
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:string];
    
    const char* result = [target cStringUsingEncoding:NSUTF8StringEncoding];
    
    testassert(result && !strcmp(result, goldilocks));
    testassert(target->_result == YES);
    testassert(target->_bytes != NULL);
    testassert(target->_maxLength == 1000);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSUTF8StringEncoding);
    testassert(target->_options == (NSStringEncodingConversionOptions)4);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 165)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(cStringUsingEncoding:), @selector(length), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

test(UTF8String)
{
    // 166 characters - shortest length where getBytes is called twice
    const char* tooLong = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes";
    
    NSString *string = [NSString stringWithCString:tooLong encoding:NSASCIIStringEncoding];
    
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:string];
    
    const char* result = [target UTF8String];
    
    testassert(result && !strcmp(result, tooLong));
    testassert(target->_result == YES);
    testassert(target->_bytes != NULL);
    testassert(target->_maxLength == 166);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSUTF8StringEncoding);
    testassert(target->_options == (NSStringEncodingConversionOptions)4);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 166)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(UTF8String), @selector(length), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

test(CString)
{
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:@"Hello, world!"];
    
    const char* result = [target cString];
    
    testassert(result && !strcmp(result, "Hello, world!"));
    testassert(target->_result == YES);
    testassert(target->_bytes != NULL);
    testassert(target->_maxLength == 1000);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSDefaultCStringEncoding());
    testassert(target->_options == (NSStringEncodingConversionOptions)6);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 13)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(cString), @selector(length), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

test(LossyCString)
{
    NSStringInternalsSubclass *target = [[NSStringInternalsSubclass alloc] initWithString:@"Hello √∫ world!"];
    
    const char* result = [target lossyCString];
    
    testassert(result && !strcmp(result, "Hello \xc3\xba world!"));
    testassert(target->_result == YES);
    testassert(target->_bytes != NULL);
    testassert(target->_maxLength == 1000);
    testassert(target->_usedLength != NULL);
    testassert(target->_encoding == NSDefaultCStringEncoding());
    testassert(target->_options == (NSStringEncodingConversionOptions)5);
    testassert(NSEqualRanges(target->_range, NSMakeRange(0, 15)));
    testassert(target->_leftoverRange == NULL);
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(initWithString:), @selector(lossyCString), @selector(length), @selector(getBytes:maxLength:usedLength:encoding:options:range:remainingRange:), nil];
    testassert(verified);
    
    [target release];
    
    return YES;
}

@end
