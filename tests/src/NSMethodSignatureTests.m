//
//  NSMethodSignatureTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#import <objc/message.h>
#import <objc/runtime.h>

@testcase(NSMethodSignature)

- (void (^)(void))fakeCompletionBlock
{
    return [^{} copy];
}
- (id)ridiculousMethod:(int)foo :(int)bar :(int)baz :(struct foo { int a; int b; int c; int d; int e;})qux :(int)quux :(int)quuux :(int)quuuux :(int)im :(int)running :(int)outof :meta :variables :but :i :need :to :get :too :two :hundred :twenty :four :bytes :of :arguments :got :a :few :more :tto :go :this :should :be :enough
{
    return nil;
}
- (void)setter:(int)value
{
}

test(FrameLength)
{
    NSString *obj = [[NSString alloc] init];

    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(initWithBytesNoCopy:length:encoding:freeWhenDone:)];
    // This would be 24 on iOS, but we need a 64-bit runtime on Mac.
#ifdef __LP64__
    testassert([methodSignature frameLength] == 224); // logical 44, actual 224 on x86_64
#else
    testassert([methodSignature frameLength] == 24);
#endif

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
#ifdef __LP64__
    testassert([methodSignature frameLength] == 224); // logical 16, actual 224.
#else
    testassert([methodSignature frameLength] >= 8);
#endif

    methodSignature = [self methodSignatureForSelector:@selector(ridiculousMethod:::::::::::::::::::::::::::::::::::)];
#ifdef __LP64__
    testassert([methodSignature frameLength] == 488);
#else
    testassert([methodSignature frameLength] == 164);
#endif

    [obj release];
    return YES;
}

test(OneWay)
{
    NSObject *obj = [[NSObject alloc] init];

    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(release)];
    testassert([methodSignature isOneway] == YES);

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
    testassert([methodSignature isOneway] == NO);
    [obj release];
    return YES;
}

test(MethodReturnLength)
{
    NSObject *obj = [[NSObject alloc] init];
    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(release)];
    testassert([methodSignature methodReturnLength] == 0);

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
    testassert([methodSignature methodReturnLength] == sizeof(id));

    methodSignature = [obj methodSignatureForSelector:@selector(class)];
    testassert([methodSignature methodReturnLength] == sizeof(Class));

    methodSignature = [obj methodSignatureForSelector:@selector(methodForSelector:)];
    testassert([methodSignature methodReturnLength] == sizeof(IMP));

    methodSignature = [obj methodSignatureForSelector:@selector(conformsToProtocol:)];
    testassert([methodSignature methodReturnLength] == sizeof(BOOL));

    methodSignature = [obj methodSignatureForSelector:@selector(hash)];
    testassert([methodSignature methodReturnLength] == sizeof(NSUInteger));
    [obj release];

    NSNumber *num = [[NSNumber alloc] initWithFloat:3.141f];
    methodSignature = [num methodSignatureForSelector:@selector(floatValue)];
    testassert([methodSignature methodReturnLength] == sizeof(float));
    [num release];

    num = [[NSNumber alloc] initWithDouble:M_PI];
    methodSignature = [num methodSignatureForSelector:@selector(doubleValue)];
    testassert([methodSignature methodReturnLength] == sizeof(double));
    [num release];

    num = [[NSNumber alloc] initWithChar:'d'];
    methodSignature = [num methodSignatureForSelector:@selector(charValue)];
    testassert([methodSignature methodReturnLength] == sizeof(char));
    [num release];

    num = [[NSNumber alloc] initWithShort:22222];
    methodSignature = [num methodSignatureForSelector:@selector(shortValue)];
    testassert([methodSignature methodReturnLength] == sizeof(short));
    [num release];

    num = [[NSNumber alloc] initWithInt:22222];
    methodSignature = [num methodSignatureForSelector:@selector(intValue)];
    testassert([methodSignature methodReturnLength] == sizeof(int));
    [num release];

    num = [[NSNumber alloc] initWithInteger:22222];
    methodSignature = [num methodSignatureForSelector:@selector(integerValue)];
    testassert([methodSignature methodReturnLength] == sizeof(NSInteger));
    [num release];

    NSRange r = NSMakeRange(0, 0);
    NSValue *val = [NSValue valueWithRange:r];
    methodSignature = [val methodSignatureForSelector:@selector(rangeValue)];
    testassert([methodSignature methodReturnLength] == sizeof(NSRange));

    NSSortDescriptor *des = [[NSSortDescriptor alloc] init];
    methodSignature = [des methodSignatureForSelector:@selector(selector)];
    testassert([methodSignature methodReturnLength] == sizeof(SEL));
    [des release];

    methodSignature = [self methodSignatureForSelector:@selector(fakeCompletionBlock)];
    testassert([methodSignature methodReturnLength] == sizeof(void (^)(void)));

    return YES;
}

test(MethodReturnType)
{
    NSObject *obj = [[NSObject alloc] init];
    NSMethodSignature *methodSignature = [obj methodSignatureForSelector:@selector(release)];
    testassert(strcmp([methodSignature methodReturnType], "Vv") == 0); //not @encode(void), which is v

    methodSignature = [obj methodSignatureForSelector:@selector(init)];
    testassert(strcmp([methodSignature methodReturnType], @encode(id)) == 0);

    methodSignature = [obj methodSignatureForSelector:@selector(class)];
    testassert(strcmp([methodSignature methodReturnType], @encode(Class)) == 0);

    methodSignature = [obj methodSignatureForSelector:@selector(methodForSelector:)];
    testassert(strcmp([methodSignature methodReturnType], @encode(IMP)) == 0);

    methodSignature = [obj methodSignatureForSelector:@selector(conformsToProtocol:)];
    testassert(strcmp([methodSignature methodReturnType], @encode(BOOL)) == 0);

    methodSignature = [obj methodSignatureForSelector:@selector(hash)];
    testassert(strcmp([methodSignature methodReturnType], @encode(NSUInteger)) == 0);
    [obj release];

    NSNumber *num = [[NSNumber alloc] initWithFloat:3.141f];
    methodSignature = [num methodSignatureForSelector:@selector(floatValue)];
    testassert(strcmp([methodSignature methodReturnType], @encode(float)) == 0);
    [num release];

    num = [[NSNumber alloc] initWithDouble:M_PI];
    methodSignature = [num methodSignatureForSelector:@selector(doubleValue)];
    testassert(strcmp([methodSignature methodReturnType], @encode(double)) == 0);
    [num release];

    num = [[NSNumber alloc] initWithChar:'d'];
    methodSignature = [num methodSignatureForSelector:@selector(charValue)];
    testassert(strcmp([methodSignature methodReturnType], @encode(char)) == 0);
    [num release];

    num = [[NSNumber alloc] initWithShort:22222];
    methodSignature = [num methodSignatureForSelector:@selector(shortValue)];
    testassert(strcmp([methodSignature methodReturnType], @encode(short)) == 0);
    [num release];

    num = [[NSNumber alloc] initWithInt:22222];
    methodSignature = [num methodSignatureForSelector:@selector(intValue)];
    testassert(strcmp([methodSignature methodReturnType], @encode(int)) == 0);
    [num release];

    num = [[NSNumber alloc] initWithInteger:22222];
    methodSignature = [num methodSignatureForSelector:@selector(integerValue)];
    testassert(strcmp([methodSignature methodReturnType], @encode(NSInteger)) == 0);
    [num release];

    NSRange r = NSMakeRange(0, 0);
    NSValue *val = [NSValue valueWithRange:r];
    methodSignature = [val methodSignatureForSelector:@selector(rangeValue)];
    testassert(val != nil && strcmp([methodSignature methodReturnType], @encode(NSRange)) == 0);

    NSSortDescriptor *des = [[NSSortDescriptor alloc] init];
    methodSignature = [des methodSignatureForSelector:@selector(selector)];
    testassert(strcmp([methodSignature methodReturnType], @encode(SEL)) == 0);
    [des release];

    methodSignature = [self methodSignatureForSelector:@selector(fakeCompletionBlock)];
    testassert(strcmp([methodSignature methodReturnType], @encode(void (^)(void))) == 0);

    methodSignature = [self methodSignatureForSelector:@selector(setter:)];
    testassert(strcmp([methodSignature methodReturnType], @encode(void)) == 0);

    return YES;

}

@end
