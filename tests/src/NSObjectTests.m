//
//  NSObjectTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface NSObject (NSCFType)
- (NSString *)_copyDescription;
- (CFTypeID)_cfTypeID;
@end

@interface NSObject (NSZombie)
- (void)__dealloc_zombie;
@end

@interface NSObject (__NSIsKinds)
- (BOOL)isNSValue__;
- (BOOL)isNSTimeZone__;
- (BOOL)isNSString__;
- (BOOL)isNSSet__;
- (BOOL)isNSOrderedSet__;
- (BOOL)isNSNumber__;
- (BOOL)isNSDictionary__;
- (BOOL)isNSDate__;
- (BOOL)isNSData__;
- (BOOL)isNSArray__;
@end

@interface NSObject (Internal)
+ (BOOL)implementsSelector:(SEL)selector;
- (BOOL)implementsSelector:(SEL)selector;
+ (BOOL)instancesImplementSelector:(SEL)selector;
@end

@interface NSObject (NSCoder)
- (BOOL)_allowsDirectEncoding;
@end

extern CFTypeID CFTypeGetTypeID();

@testcase(NSObject)

test(copyDescription)
{
    NSObject *obj = [[NSObject alloc] init];
    NSString *desc = [obj _copyDescription];
    testassert(desc != NULL);
    testassert([desc retainCount] >= 1);
    [desc release];
    [obj release];
    return YES;
}

test(cfGetTypeID)
{
    NSObject *obj = [[NSObject alloc] init];
    CFTypeID expected = CFTypeGetTypeID();
    testassert([obj _cfTypeID] == expected);
    return YES;
}

test(dealloc_zombie)
{
    Class NSObjectClass = objc_getClass("NSObject");
    Method m = class_getInstanceMethod(NSObjectClass, @selector(__dealloc_zombie));
    testassert(m != NULL);
    return YES;
}

test(IsNSValue__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSValue__] == NO);
    return YES;
}

test(IsNSTimeZone__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSTimeZone__] == NO);
    return YES;
}

test(IsNSString__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSString__] == NO);
    return YES;
}

test(IsNSSet__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSSet__] == NO);
    return YES;
}

test(IsNSOrderedSet__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSOrderedSet__] == NO);
    return YES;
}

test(IsNSNumber__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSNumber__] == NO);
    return YES;
}

test(IsNSDictionary__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSDictionary__] == NO);
    return YES;
}

test(IsNSDate__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSDate__] == NO);
    return YES;
}

test(IsNSData__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSData__] == NO);
    return YES;
}

test(IsNSArray__)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj isNSArray__] == NO);
    return YES;
}

test(InstanceMethodSignatureForSelector)
{
    NSMethodSignature *sig = [NSObject instanceMethodSignatureForSelector:@selector(init)];
    testassert(sig != NULL);
    return YES;
}

test(MethodSignatureForSelector1)
{
    NSMethodSignature *sig = [NSObject methodSignatureForSelector:@selector(alloc)];
    testassert(sig != NULL);
    return YES;
}

test(MethodSignatureForSelector2)
{
    NSObject *obj = [[NSObject alloc] init];
    NSMethodSignature *sig = [obj methodSignatureForSelector:@selector(init)];
    testassert(sig != NULL);
    [obj release];
    return YES;
}

test(Description1)
{
    NSString *str = [NSObject description];
    testassert([str isEqualToString:@"NSObject"]);
    return YES;
}

test(Description2)
{
    NSObject *obj = [[NSObject alloc] init];
    NSString *desc = [obj description];
    testassert(desc != NULL);
    NSString *expected = [NSString stringWithFormat:@"<%s: %p>", object_getClassName(obj), obj];
    testassert([desc isEqualToString:expected]);
    [obj release];
    return YES;
}

test(Description3)
{
    NSString *str = (NSString *)CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@"), self);
    testassert([[self description] isEqualToString:str]);
    [str release];
    return YES;
}

test(ImplementsSelector1)
{
    testassert([NSObject implementsSelector:@selector(alloc)]);
    return YES;
}

test(ImplementsSelector2)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj implementsSelector:@selector(init)]);
    [obj release];
    return YES;
}

test(InstancesImplementSelector)
{
    testassert([NSObject instancesImplementSelector:@selector(init)]);
    return YES;
}

test(Version)
{
    NSInteger ver = [NSObject version];
    testassert(ver == 0);
    [NSObject setVersion:ver + 1];
    testassert([NSObject version] == ver + 1);
    return YES;
}

test(InitWithCoder)
{
    Class NSObjectClass = objc_getClass("NSObject");
    Method m = class_getInstanceMethod(NSObjectClass, @selector(initWithCoder:));
    testassert(m == NULL);
    return YES;
}

test(AllowsDirectEncoding)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj _allowsDirectEncoding] == NO);
    [obj release];
    return YES;
}

test(ClassForCoder)
{
    NSObject *obj = [[NSObject alloc] init];
    testassert([obj classForCoder] == [NSObject class]);
    [obj release];
    return YES;
}

test(ReplacementObjectForCoder)
{
    NSObject *obj = [[NSObject alloc] init];
    id replacement = [obj replacementObjectForCoder:nil];
    testassert(obj == replacement);
    [obj release];
    return YES;
}

test(AwakeAfterUsingCoder)
{
    NSObject *obj = [[NSObject alloc] init];
    id replacement = [obj awakeAfterUsingCoder:nil];
    testassert(obj == replacement);
    [obj release];
    return YES;
}

test(MissingForwarding)
{
    BOOL raised = NO;
    @try {
        [self thisSelectorIsNotImplemented];
    } @catch(NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    return YES;
}

static BOOL performed = NO;
static BOOL objectRecieved = NO;

- (void)recipient
{
    performed = YES;
}

- (void)recipientObject:(NSString *)obj
{
    performed = YES;
    objectRecieved = [obj isEqualToString:@"foo"];
}


test(DelayedPerformer)
{
    performed = NO;
    [self performSelector:@selector(recipient) withObject:nil afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == YES);
    return YES;
}

test(DelayedPerformerExtraObject)
{
    performed = NO;
    [self performSelector:@selector(recipient) withObject:@"foo" afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == YES);
    return YES;
}

test(DelayedPerformerObject)
{
    performed = NO;
    objectRecieved = NO;
    [self performSelector:@selector(recipientObject:) withObject:@"foo" afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == YES);
    testassert(objectRecieved == YES);
    return YES;
}

test(DelayedPerformerCancelation)
{
    performed = NO;
    [self performSelector:@selector(recipient) withObject:nil afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == NO);
    return YES;
}

test(DelayedPerformerCancelation1)
{
    performed = NO;
    [self performSelector:@selector(recipient) withObject:nil afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recipient) object:nil];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == NO);
    return YES;
}

test(DelayedPerformerObjectCancellation)
{
    performed = NO;
    objectRecieved = NO;
    [self performSelector:@selector(recipientObject:) withObject:@"foo" afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recipientObject:) object:nil];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == YES);
    testassert(objectRecieved == YES);
    return YES;
}

test(DelayedPerformerObjectCancellation2)
{
    performed = NO;
    objectRecieved = NO;
    [self performSelector:@selector(recipientObject:) withObject:@"foo" afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recipientObject:) object:@"foo"];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == NO);
    testassert(objectRecieved == NO);
    return YES;
}

test(DelayedPerformerObjectCancellation3)
{
    performed = NO;
    objectRecieved = NO;
    [self performSelector:@selector(recipientObject:) withObject:@"foo" afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recipientObject:) object:[NSString stringWithUTF8String:"foo"]];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    testassert(performed == NO);
    testassert(objectRecieved == NO);
    return YES;
}

@end
