//
//  NSInvocation.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSInvocation)

- (NSRange)methodReturningRange
{
    return NSMakeRange(500, 50);
}

- (NSRange *)referenceToNewRange
{
    NSRange *rangePtr = (NSRange *)malloc(sizeof(NSRange));
    if (rangePtr != NULL)
    {
        *rangePtr = NSMakeRange(123, 321);
    }
    return rangePtr;
}

- (NSString *)substringFromString:(NSString *)str withRange:(NSRange)range
{
    return [str substringWithRange:range];
}

test(IncorrectAllocInit)
{
    NSInvocation *inv = [[NSInvocation alloc] init]; // should not throw

    testassert(inv == nil);
    return YES;
}

test(InvocationWithMethodSiganture)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    testassert(inv != nil);
    return YES;
}

test(SelectorUnset)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    SEL bad = [inv selector];
    testassert(bad == nil);
    return YES;
}

test(SelectorSet)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    SEL good = [inv selector];
    testassert(good == @selector(objectForKey:));
    return YES;
}

test(TargetUnset)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    id target = [inv target];
    testassert(target == nil);
    return YES;
}

test(TargetSet)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    id target = [inv target];
    testassert(target == nil);
    [inv setTarget:dict];
    target = [inv target];
    testassert(target == dict);
    [inv setTarget:nil];
    target = [inv target];
    testassert(target == nil);
    return YES;
}

test(MethodSignature)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSMethodSignature *ms = [inv methodSignature];
    testassert(ms != nil);
    return YES;
}

test(ArgumentsSetOutOfOrder)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSString *foo = [NSString stringWithUTF8String:"Foo"];
    [inv setArgument:&foo atIndex:2]; // odd that &@"Foo" doesn't work...
    id fooFrom;
    [inv getArgument:&fooFrom atIndex:2];
    testassert([fooFrom isEqual:foo]);

    return YES;
}

test(ArgumentsRetainedUnretained)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    testassert([inv argumentsRetained] == NO);
    NSUInteger rc = [dict retainCount];
    [inv setTarget:dict];
    testassert(rc == [dict retainCount]); // target is not retained by the invocation except if the arguments are.

    return YES;
}

test(ArgumentsRetainedRetained)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv retainArguments];
    NSUInteger rc = [dict retainCount];
    testassert([inv argumentsRetained] == YES);
    [inv setTarget:dict];
    testassert(rc < [dict retainCount]);


    return YES;
}

test(SetArgumentAtIndexBeyondBounds)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    NSString *foo = [NSString string];
    void (^block)(void) = ^{
        [inv setArgument:(void *)&foo atIndex:6];
    };
    BOOL raised = NO;
    @try
    {
        block();
    }
    @catch (NSException *e)
    {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]); // why is this not an NSRangeException anyway?
        raised = YES;
    }
    testassert(raised == YES);

    return YES;
}

test(GetReturnValueUninvoked)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    return YES;
}

test(GetReturnValueInvoked)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"bar"]);
    return YES;
}

test(SetReturnValueUninvoked)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    NSString *str2 = [dict objectForKey:@"Foo"];
    [inv setReturnValue:&str2];
    [inv getReturnValue:&result];
    testassert(result == str2);
    return YES;
}

test(SetReturnValueInvoked)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    NSString *str2 = [dict objectForKey:@"Foo"];
    [inv setReturnValue:&str2];
    [inv getReturnValue:&result];
    testassert(result == str2);
    NSString *fake = @"qux";
    [inv setReturnValue:&fake];
    result = nil;
    [inv getReturnValue:&result];
    testassert(fake == result);
    return YES;
}

test(GetArgumentAtIndex)
{
    NSString *unintedString = [NSString alloc];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[unintedString methodSignatureForSelector:@selector(initWithBytes:length:encoding:)]];
    char *bytesArg = "This is the dawning of the age of Aquarius!";
    [inv setTarget:unintedString];
    [inv setSelector:@selector(initWithBytes:length:encoding:)];
    [inv setArgument:&bytesArg atIndex:2];
    NSUInteger length = strlen(bytesArg);
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [inv setArgument:&length atIndex:3];
    [inv setArgument:&encoding atIndex:4];
    NSUInteger outLen;
    [inv getArgument:&outLen atIndex:3];
    NSStringEncoding outEnc;
    [inv getArgument:&outEnc atIndex:4];
    testassert(outLen == length);
    testassert(outEnc == encoding);
    [inv invoke]; // should still work after invocation
    [inv getArgument:&outLen atIndex:3];
    [inv getArgument:&outEnc atIndex:4];
    testassert(outLen == length);
    testassert(outEnc == encoding);

    id result;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    result = nil;
    [inv getArgument:&result atIndex:-1];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    [unintedString release];
    return YES;
}

test(CharStarBehaviorWithUnretainedArguments)
{
    NSString *unintedString = [NSString alloc];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[unintedString methodSignatureForSelector:@selector(initWithCString:encoding:)]];
    const char *bytes = "This is the dawning of the age of Aquarius!";
    char *bytesArg = malloc(strlen(bytes) + 1);
    strcpy(bytesArg, bytes);
    [inv setTarget:unintedString];
    [inv setSelector:@selector(initWithCString:encoding:)];
    [inv setArgument:&bytesArg atIndex:2];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [inv setArgument:&encoding atIndex:3];
    testassert([inv target] == unintedString);
    testassert([inv selector] == @selector(initWithCString:encoding:));
    bytesArg[2] = 'a';
    bytesArg[3] = 't';
    [inv invoke];
    id result;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"That is the dawning of the age of Aquarius!"]);
    [unintedString release];
    free(bytesArg);
    return YES;
}
test(CharStarBehaviorWithRetainedArguments)
{
    NSString *unintedString = [NSString alloc];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[unintedString methodSignatureForSelector:@selector(initWithCString:encoding:)]];
    const char *bytes = "This is the dawning of the age of Aquarius!";
    char *bytesArg = malloc(strlen(bytes) + 1);
    strcpy(bytesArg, bytes);
    [inv setTarget:unintedString];
    [inv setSelector:@selector(initWithCString:encoding:)];
    [inv setArgument:&bytesArg atIndex:2];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [inv setArgument:&encoding atIndex:3];
    testassert([inv target] == unintedString);
    testassert([inv selector] == @selector(initWithCString:encoding:));
    [inv retainArguments];
    char *foo;
    [inv getArgument:&foo atIndex:2];
    bytesArg[34] = 'C';
    bytesArg[35] = 'a';
    bytesArg[36] = 'p';
    bytesArg[37] = 'r';
    bytesArg[38] = 'i';
    bytesArg[39] = 'c';
    bytesArg[40] = 'o';
    bytesArg[41] = 'r';
    bytesArg[42] = 'n';
    free(bytesArg);
    for (int i = 0; i < 1000; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%d %d %d", i, i+1, i+2]; // do some nonesense allocations to clear out bytesArg
        (void)str;
    }
    [inv invoke];
    [inv getArgument:&foo atIndex:2];
    id result;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"This is the dawning of the age of Aquarius!"]);
    [unintedString release];
    return YES;
}

test(InvokeAllUnset)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv invoke]; // doesn't crash or throw an exception, just silently fails.
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);

    return YES;
}
test(InvokeSelAndArgsUnset)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setTarget:dict];
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    return YES;

}
test(InvokeArgsUnset)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    [inv setTarget:dict];
    id result = nil;
    [inv getReturnValue:&result];
    testassert(result == nil);
    return YES;

}
test(InvokeWithTarget)
{
    NSDictionary *dict = @{@"Foo": @"bar"};
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dict methodSignatureForSelector:@selector(objectForKey:)]];
    [inv setSelector:@selector(objectForKey:)];
    NSString *str = @"Foo";
    [inv setArgument:&str atIndex:2];
    id result = nil;
    [inv invokeWithTarget:dict];
    NSString *str2 = [dict objectForKey:@"Foo"];
    [inv getReturnValue:&result];
    testassert([result isEqualToString:str2]);
    return YES;
}

test(StructParameter)
{
    NSString *str = @"Foobarbazqux";
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[str methodSignatureForSelector:@selector(substringWithRange:)]];
    [inv setSelector:@selector(substringWithRange:)];
    NSRange range = NSMakeRange(3, 6);
    [inv setTarget:str];
    [inv setArgument:&range atIndex:2];
    id result = nil;
    [inv invoke];
    NSString *expected = @"barbaz";
    [inv getReturnValue:&result];
    testassert([result isEqualToString:expected]);

    return YES;
}

test(MixedParameters)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(substringFromString:withRange:)]];
    [inv setSelector:@selector(substringFromString:withRange:)];
    [inv setTarget:self];
    NSRange range = NSMakeRange(6, 3);
    NSString *str = @"Foobarbazqux";
    [inv setArgument:&str atIndex:2];
    [inv setArgument:&range atIndex:3];
    [inv invoke];
    NSString *result = nil;
    [inv getReturnValue:&result];
    testassert([result isEqualToString:@"baz"]);

    return YES;
}

- (id)newObjectReturn
{
    return [[NSObject alloc] init];
}

test(UnretainedArgsRetainsReturnValue)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(newObjectReturn)]];
    [inv setTarget:self];
    [inv setSelector:@selector(newObjectReturn)];
    id result;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert([result retainCount] == [[self newObjectReturn] retainCount]); // Leaks out of necessity. Result is not retained.

    return YES;

}
test(RetainedArgsRetainsReturnValue)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(newObjectReturn)]];
    [inv setTarget:self];
    [inv setSelector:@selector(newObjectReturn)];
    [inv retainArguments]; // This probably causes a retain cycle, come to think of it.
    id result;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert([result retainCount] > [[self newObjectReturn] retainCount]);
    // Leaky out of necessity. The out param is retained and
    // autoreleased.  We can't prove that within this test, though, as
    // we would need to check the retain count immediately before and
    // after the autoreleasepool drains in a debugger.
    return YES;
}

#warning TODO: fix NSInvocation trying to autorelease result (NSRange) below.
test(StructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(methodReturningRange)]];
    [inv setSelector:@selector(methodReturningRange)];
    [inv setTarget:self];
    NSRange result;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.length = 50);
    testassert(result.location = 500);
    return YES;
}

test(StructPtrReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(referenceToNewRange)]];
    [inv setTarget:self];
    [inv setSelector:@selector(referenceToNewRange)];
    NSRange *result;
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result->length = 321);
    testassert(result->location = 123);
    free(result);

    return YES;
}


struct charStruct {
    char a;
};

- (struct charStruct)charStructRetMethod
{
    struct charStruct ret = { 'a' };
    return ret;
}

test(CharStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(charStructRetMethod)]];
    [inv setSelector:@selector(charStructRetMethod)];
    [inv setTarget:self];
    struct charStruct result = { 'b' };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 'a');

    return YES;
}

struct shortStruct {
    short a;
};

- (struct shortStruct)shortStructRetMethod
{
    struct shortStruct ret = { 12345 };
    return ret;
}

test(ShortStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(shortStructRetMethod)]];
    [inv setSelector:@selector(shortStructRetMethod)];
    [inv setTarget:self];
    struct shortStruct result = { 23147 };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 12345);

    return YES;
}

struct shortCharStruct {
    short a;
    char b;
};

- (struct shortCharStruct)shortCharStructRetMethod
{
    struct shortCharStruct ret = { 12345, 'a' };
    return ret;
}

test(ShortCharStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(shortCharStructRetMethod)]];
    [inv setSelector:@selector(shortCharStructRetMethod)];
    [inv setTarget:self];
    struct shortCharStruct result = { 23147, 'c' };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 12345);
    testassert(result.b == 'a');

    return YES;
}

struct intStruct {
    int a;
};

- (struct intStruct)intStructRetMethod
{
    struct intStruct ret = { 678910 };
    return ret;
}

test(IntStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(intStructRetMethod)]];
    [inv setSelector:@selector(intStructRetMethod)];
    [inv setTarget:self];
    struct intStruct result = { 109876 };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 678910);

    return YES;
}

struct charIntStruct {
    char a;
    int b;
};

- (struct charIntStruct)charIntStructRetMethod
{
    struct charIntStruct ret = { 'a', 678910 };
    return ret;
}

test(CharIntStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(charIntStructRetMethod)]];
    [inv setSelector:@selector(charIntStructRetMethod)];
    [inv setTarget:self];
    struct charIntStruct result = { 'c', 109876 };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.b == 678910);
    testassert(result.a == 'a');

    return YES;
}

struct intCharStruct {
    int a;
    char b;
};

- (struct intCharStruct)intCharStructRetMethod
{
    struct intCharStruct ret = { 678910, 'a' };
    return ret;
}

test(IntCharStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(intCharStructRetMethod)]];
    [inv setSelector:@selector(intCharStructRetMethod)];
    [inv setTarget:self];
    struct intCharStruct result = { 109876, 'c' };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 678910);
    testassert(result.b == 'a');

    return YES;
}

struct longLongStruct {
    long long a;
};

- (struct longLongStruct)longLongStructRetMethod
{
    struct longLongStruct ret = { 678910111213 };
    return ret;
}

test(LongLongStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(longLongStructRetMethod)]];
    [inv setSelector:@selector(longLongStructRetMethod)];
    [inv setTarget:self];
    struct longLongStruct result = { 10987654321 };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 678910111213);

    return YES;
}

struct longLongCharStruct {
    long long a;
    char b;
};

- (struct longLongCharStruct)longLongCharStructRetMethod
{
    struct longLongCharStruct ret = { 678910111213, 'a' };
    return ret;
}

test(LongLongCharStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(longLongCharStructRetMethod)]];
    [inv setSelector:@selector(longLongCharStructRetMethod)];
    [inv setTarget:self];
    struct longLongCharStruct result = { 10987654321, 'c' };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == 678910111213);
    testassert(result.b == 'a');

    return YES;
}

struct charLongLongStruct {
    char a;
    long long b;
};

- (struct charLongLongStruct)charLongLongStructRetMethod
{
    struct charLongLongStruct ret = { 'a', 678910111213 };
    return ret;
}

test(CharLongLongStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(charLongLongStructRetMethod)]];
    [inv setSelector:@selector(charLongLongStructRetMethod)];
    [inv setTarget:self];
    struct charLongLongStruct result = { 'c', 10987654321 };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.b == 678910111213);
    testassert(result.a == 'a');

    return YES;
}

struct doubleStruct {
    double a;
};

- (struct doubleStruct)doubleStructRetMethod
{
    struct doubleStruct ret = { M_PI };
    return ret;
}

test(DoubleStructReturn)
{
#if !__LP64__
    IOS_SIMULATOR_BUG_FAILURE();
#endif

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(doubleStructRetMethod)]];
    [inv setSelector:@selector(doubleStructRetMethod)];
    [inv setTarget:self];
    struct doubleStruct result = { M_E };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == M_PI);

    return YES;
}

struct doubleCharStruct {
    double a;
    char b;
};

- (struct doubleCharStruct)doubleCharStructRetMethod
{
    struct doubleCharStruct ret = { M_PI, 'a' };
    return ret;
}

test(DoubleCharStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(doubleCharStructRetMethod)]];
    [inv setSelector:@selector(doubleCharStructRetMethod)];
    [inv setTarget:self];
    struct doubleCharStruct result = { M_E, 'c' };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == M_PI);
    testassert(result.b == 'a');

    return YES;
}

struct charDoubleStruct {
    char a;
    double b;
};

- (struct charDoubleStruct)charDoubleStructRetMethod
{
    struct charDoubleStruct ret = { 'a', M_PI };
    return ret;
}

test(CharDoubleStructReturn)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(charDoubleStructRetMethod)]];
    [inv setSelector:@selector(charDoubleStructRetMethod)];
    [inv setTarget:self];
    struct charDoubleStruct result = { 'c', M_E };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.b == M_PI);
    testassert(result.a == 'a');

    return YES;
}
union floatInt {
    int a;
    float b;
};
struct hugeStruct {
    double a;
    char b;
    int c;
    short d;
    long long e;
    char *f;
    SEL g;
    id h;
    NSRange i;
    NSObject *j;
    int *k;
    void (^l)(void);
    int *(*m)(int *);
    struct charDoubleStruct n;
//    union floatInt o;
    IMP q;
    Class r;
    int s[5];
//    char t:1;
//    char u:3;
//    char v:4;
    volatile int x;
    float y;


};

int *foo(int *bar) { return bar; };
int *baz(int *qux) { return NULL;};

- (struct hugeStruct)hugeStructRetMethod
{
    int *k = NULL;
    struct hugeStruct ret = {
        M_PI,
        'b',
        1234567,
        -1234,
        1234567891011,
        (char *)NULL,
        _cmd,
        @protocol(NSCoding),
        NSMakeRange(123, 321),
        @"Foo",
        k,
        [^{} copy],
        foo,
        { 'a', M_E },
//        9001,
        [self methodForSelector:_cmd],
        [self class],
        { 4321, 1234, 5678, 8765, 9101112},
//        1,
//        3,
//        6,
        70,
        4.42f
    };
    return ret;
}

test(HugeStruct)
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(hugeStructRetMethod)]];
    [inv setSelector:@selector(hugeStructRetMethod)];
    [inv setTarget:self];
    int k = 51;
    char f = 'x';
    struct hugeStruct result = {
        M_PI_2,
        'f',
        7654321,
        4321,
        1110987654321,
        &f,
        _cmd,
        @protocol(NSCopying),
        NSMakeRange(500, 50),
        @"Bar",
        &k,
        nil,
        baz,
        { 'b', M_LN2 },
//        90.5f,
        [self methodForSelector:_cmd],
        [NSInvocation class],
        { 42, 0, -1, INT_MIN, INT_MAX},
//        0,
//        0,
//        0,
        77,
        41147.7
    };
    [inv invoke];
    [inv getReturnValue:&result];
    testassert(result.a == M_PI);
    testassert(result.b == 'b');
    testassert(result.c == 1234567);
    testassert(result.d == -1234);
    testassert(result.e == 1234567891011);
    testassert(result.f == NULL);
    testassert(result.g == @selector(hugeStructRetMethod));
    testassert(result.h == @protocol(NSCoding));
    testassert(result.i.length == 321);
    testassert(result.i.location == 123);
    testassert([(id)result.j isEqualToString:@"Foo"]);
    testassert(result.k == NULL);
    testassert(result.l != nil);
    testassert(result.m == foo);
    testassert(result.n.a == 'a');
    testassert(result.n.b == M_E);
//    testassert(result.o.a == 9001);
    testassert(result.q == [self methodForSelector:@selector(hugeStructRetMethod)]);
    testassert(result.r == [self class]);
    testassert(result.s[0] == 4321);
    testassert(result.s[1] == 1234);
    testassert(result.s[2] == 5678);
    testassert(result.s[3] == 8765);
    testassert(result.s[4] == 9101112);
//    testassert(result.t == 1);
//    testassert(result.u == 3);
//    testassert(result.v == 6);
    testassert(result.x == 70);
    testassert(result.y == 4.42f);

    return YES;
}

#pragma mark - Other return types and their helpers
#define IL(...) __VA_ARGS__
#define TYPERETURN(type, nospaceType, testValues) \
- (type)nospaceType##Return \
{ \
    static int rotationCount = 0; \
    type testVals[] = testValues; \
    return testVals[rotationCount++/2%sizeof(testVals)/sizeof(testVals[0])]; \
}

TYPERETURN(char, char, IL({CHAR_MIN, -'a', 0, 'a', CHAR_MAX}))
TYPERETURN(unsigned char, unsignedChar, IL({0, 'a', 200, UCHAR_MAX}))
TYPERETURN(short, short, IL({SHRT_MIN, -12345, 0, 12345, SHRT_MAX}))
TYPERETURN(unsigned short, unsignedShort, IL({0, 45678, USHRT_MAX}))
TYPERETURN(int, int, IL({INT_MIN, -1234567, 0, 2345678, INT_MAX}))
TYPERETURN(unsigned int, unsignedInt, IL({0, 2345678, 3141592654, UINT_MAX}))
TYPERETURN(long, long, IL({LONG_MIN, -42, 0, 42, LONG_MAX}))
TYPERETURN(unsigned long, unsignedLong, IL({0, 42, 3141592654, ULONG_MAX}))
TYPERETURN(long long, longLong, IL({LLONG_MIN, -654321098765, -7654321, -4321, -21, 0, 42, 12345, 12345678, 12345678910, LLONG_MAX}))
TYPERETURN(unsigned long long, unsignedLongLong, IL({0, LLONG_MAX, ULLONG_MAX}))
TYPERETURN(float, float, IL({FLT_MIN, FLT_TRUE_MIN, -4321.109f, 0.0f, 0.001f, 4321.1234f, FLT_MAX}))
TYPERETURN(double, double, IL({DBL_MIN, DBL_TRUE_MIN, -4321.9197123796, 0.0, 0.001, 0.148943280124, 4321.91971, DBL_MAX}))
TYPERETURN(long double, longDouble, IL({LDBL_MIN, LDBL_TRUE_MIN, LDBL_MIN/2.0L, -42.1234678910L, 0.0L, 42.0L, 12345.678910L, LDBL_MAX/2.0L, LDBL_MAX}))
//unichar return will be characterAtIndex:
TYPERETURN(SEL, sel, IL({@selector(self), @selector(characterAtIndex:), @selector(initFileURLWithPath:isDirectory:), @selector(fileAttributesToWriteToURL:forSaveOperation:error:), @selector(selectorThatDoesntExist)}))

#undef AL
#undef TYPERETURN

#define TESTTYPERETURN(type, nospaceType) \
test(test##nospaceType##Return) \
{ \
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(nospaceType##Return)]]; \
    [inv setTarget:self]; \
    [inv setSelector:@selector(nospaceType##Return)]; \
    type result; \
    for (int i = 0; i < 50; i++) \
    { \
        [inv invoke]; \
        [inv getReturnValue:&result]; \
        testassert(result == [self nospaceType##Return]); \
    } \
    return YES; \
}

TESTTYPERETURN(char, char)
TESTTYPERETURN(unsigned char, unsignedChar)
TESTTYPERETURN(short, short)
TESTTYPERETURN(unsigned short, unsignedShort)
TESTTYPERETURN(int, int)
TESTTYPERETURN(unsigned int, unsignedInt)
TESTTYPERETURN(long, long)
TESTTYPERETURN(unsigned long, unsignedLong)
TESTTYPERETURN(long long, longLong)
TESTTYPERETURN(unsigned long long, unsignedLongLong)
TESTTYPERETURN(float, float)
TESTTYPERETURN(double, double) // toil and trouble
TESTTYPERETURN(long double, longDouble)
TESTTYPERETURN(SEL, sel)

#undef TESTTYPERETURN

test(UnicharReturn)
{
    NSString *target = [[NSString alloc] initWithUTF8String:"Foo"];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:@selector(characterAtIndex:)]];
    [inv setTarget:target];
    NSUInteger index = 1;
    [inv setSelector:@selector(characterAtIndex:)];
    [inv setArgument:&index atIndex:2];
    [inv invoke];
    unichar result;
    [inv getReturnValue:&result];
    testassert(result == [@"There's nothing" characterAtIndex:9]);
    return YES;
}

@end
