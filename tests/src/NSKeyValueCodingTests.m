//
//  NSKeyValueCodingTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface RetainTestObject : NSObject
@end

@implementation RetainTestObject {
    BOOL wasRetained;
    BOOL wasReleased;
    BOOL wasAutoreleased;
}

- (id)retain
{
    wasRetained = YES;
    return [super retain];
}

- (oneway void)release
{
    wasReleased = YES;
    [super release];
}

- (id)autorelease
{
    wasAutoreleased = YES;
    return [super autorelease];
}

- (BOOL)wasReleased
{
    return wasReleased;
}

- (BOOL)wasRetained
{
    return wasRetained;
}

- (BOOL)wasAutoreleased
{
    return wasAutoreleased;
}

@end

@interface Direct : NSObject {
    BOOL interfaceIvar;
    BOOL _underscorePrefix;
    BOOL __doubleUnderscorePrefix;
    BOOL underscorePostfix_;
    BOOL isPrefixed;
    BOOL _isUnderscoredPrefix;
    BOOL property;
    id object;
    __weak id weakObject;
    __strong id strongObject;

    BOOL isFoo1;
    BOOL foo1;
    BOOL _isFoo1;
    BOOL _foo1;

    BOOL foo2;
    BOOL isFoo2;
    BOOL _isFoo2;

    BOOL foo3;
    BOOL isFoo3;
}
@property (nonatomic) BOOL property;
@end

@implementation Direct {
    BOOL implementationIvar;
}

@synthesize property=property;

+ (BOOL)accessInstanceVariablesDirectly
{
    return YES;
}

- (BOOL)interfaceIsSet
{
    return interfaceIvar;
}

- (BOOL)implementationIsSet
{
    return implementationIvar;
}

- (BOOL)underscorePrefixIsSet
{
    return _underscorePrefix;
}

- (BOOL)doubleUnderscorePrefixIsSet
{
    return __doubleUnderscorePrefix;
}

- (BOOL)underscorePostfixIsSet
{
    return underscorePostfix_;
}

- (BOOL)isPrefixedIsSet
{
    return isPrefixed;
}

- (BOOL)isUnderscoredPrefixedIsSet
{
    return _isUnderscoredPrefix;
}

- (NSArray *)foo1IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (_foo1)
    {
        [ivars addObject:@"_foo1"];
    }
    if (_isFoo1)
    {
        [ivars addObject:@"_isFoo1"];
    }
    if (foo1)
    {
        [ivars addObject:@"foo1"];
    }
    if (isFoo1)
    {
        [ivars addObject:@"isFoo1"];
    }
    return [ivars autorelease];
}

- (NSArray *)foo2IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (_isFoo2)
    {
        [ivars addObject:@"_isFoo2"];
    }
    if (foo2)
    {
        [ivars addObject:@"foo2"];
    }
    if (isFoo2)
    {
        [ivars addObject:@"isFoo2"];
    }
    return [ivars autorelease];
}

- (NSArray *)foo3IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (foo3)
    {
        [ivars addObject:@"foo3"];
    }
    if (isFoo3)
    {
        [ivars addObject:@"isFoo3"];
    }
    return [ivars autorelease];
}

@end

@interface Indirect : NSObject
@property BOOL interfaceIvar;
@property BOOL _underscorePrefix;
@property BOOL __doubleUnderscorePrefix;
@property BOOL underscorePostfix_;
@property BOOL isPrefixed;
@property BOOL _isUnderscoredPrefix;
@property BOOL property;
@property (retain) id object;
@property (assign) id weakObject;
@property (retain) id strongObject;
@property BOOL isFoo1;
@property BOOL foo1;
@property BOOL _isFoo1;
@property BOOL _foo1;
@property BOOL foo2;
@property BOOL isFoo2;
@property BOOL _isFoo2;
@property BOOL foo3;
@property BOOL isFoo3;
@end

@implementation Indirect
{
    BOOL implementationIvar;
}

+ (BOOL)accessInstanceVariablesDirectly
{
    return NO;
}

- (BOOL)implementationIvar
{
    return implementationIvar;
}

- (void)setImplementationIvar:(BOOL)b
{
    implementationIvar = b;
}

- (BOOL)interfaceIsSet
{
    return self.interfaceIvar;
}

- (BOOL)implementationIsSet
{
    return implementationIvar;
}

- (BOOL)underscorePrefixIsSet
{
    return self._underscorePrefix;
}

- (void)setUnderscorePrefix:(BOOL)b
{
    self._underscorePrefix = b;
}

- (BOOL)doubleUnderscorePrefixIsSet
{
    return self.__doubleUnderscorePrefix;
}

- (void)setDoubleUnderscorePrefix:(BOOL)b
{
    self.__doubleUnderscorePrefix = b;
}

- (BOOL)underscorePostfixIsSet
{
    return self.underscorePostfix_;
}

- (BOOL)isPrefixedIsSet
{
    return self.isPrefixed;
}

- (BOOL)isUnderscoredPrefixedIsSet
{
    return self._isUnderscoredPrefix;
}

- (NSArray *)foo1IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (_foo1)
    {
        [ivars addObject:@"_foo1"];
    }
    if (_isFoo1)
    {
        [ivars addObject:@"_isFoo1"];
    }
    if (self.foo1)
    {
        [ivars addObject:@"foo1"];
    }
    if (self.isFoo1)
    {
        [ivars addObject:@"isFoo1"];
    }
    return [ivars autorelease];
}

- (NSArray *)foo2IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (_isFoo2)
    {
        [ivars addObject:@"_isFoo2"];
    }
    if (self.foo2)
    {
        [ivars addObject:@"foo2"];
    }
    if (self.isFoo2)
    {
        [ivars addObject:@"isFoo2"];
    }
    return [ivars autorelease];
}

- (NSArray *)foo3IvarsSet
{
    NSMutableArray *ivars = [[NSMutableArray alloc] init];
    if (self.foo3)
    {
        [ivars addObject:@"foo3"];
    }
    if (self.isFoo3)
    {
        [ivars addObject:@"isFoo3"];
    }
    return [ivars autorelease];
}

@end


@interface SomeObjectWithCGPoint : NSObject {
    CGPoint point;
}
- (BOOL)verifyPoint:(CGPoint)pt;
@end

@implementation SomeObjectWithCGPoint
- (BOOL)verifyPoint:(CGPoint)pt;
{
    return point.x == pt.x && point.y == pt.y;
}
@end

@interface SomeObjectWithCGSize : NSObject {
    CGSize size;
}
- (BOOL)verifySize:(CGSize)pt;
@end

@implementation SomeObjectWithCGSize
- (BOOL)verifySize:(CGSize)aSize
{
    return size.height == aSize.height && size.width == aSize.width;
}
@end

@interface SomeObjectWithCGRect : NSObject {
    CGRect rect;
}
- (BOOL)verifyRect:(CGRect)aRect;
@end

@implementation SomeObjectWithCGRect
- (BOOL)verifyRect:(CGRect)aRect
{
    return rect.origin.x == aRect.origin.x && rect.origin.y == aRect.origin.y && rect.size.width == aRect.size.width && rect.size.height == aRect.size.height;
}
@end

@interface SomeObjectWithNSRange : NSObject {
    NSRange range;
}
- (BOOL)verifyRange:(NSRange)aRange;
@end

@implementation SomeObjectWithNSRange
- (BOOL)verifyRange:(NSRange)aRange
{
    return range.length == aRange.length && range.location == aRange.location;
}
@end

typedef struct SomeSmallishStruct {
    uint32_t aUint;
} SomeSmallishStruct;

@interface SomeObjectWithSmallishInnerStruct : NSObject {
    SomeSmallishStruct aSmallishStruct;
}
- (BOOL)verifyInnerStruct:(SomeSmallishStruct)s;
@end

@implementation SomeObjectWithSmallishInnerStruct
- (BOOL)verifyInnerStruct:(SomeSmallishStruct)s
{
    return s.aUint == aSmallishStruct.aUint;
}
@end

#define SOME_LARGE_STRUCT_DATASZ 256
typedef struct SomeLargeStruct {
    uint8_t data[SOME_LARGE_STRUCT_DATASZ];
} SomeLargeStruct;

@interface SomeObjectWithLargeInnerStruct : NSObject {
    SomeLargeStruct aLargeStruct;
}
- (BOOL)verifyInnerStruct:(SomeLargeStruct)l;
@end

@implementation SomeObjectWithLargeInnerStruct
- (BOOL)verifyInnerStruct:(SomeLargeStruct)l
{
    for (unsigned int i=0; i<SOME_LARGE_STRUCT_DATASZ; i++)
    {
        if (l.data[i] != aLargeStruct.data[i])
        {
            return NO;
        }
    }
    return YES;
}
@end

@interface SomePropertyObject : NSObject
@property (nonatomic, retain) NSObject* objectProperty;
@property char charProperty;
@property unsigned char unsignedCharProperty;
@property short shortProperty;
@property unsigned short unsignedShortProperty;
@property int intProperty;
@property unsigned int unsignedIntProperty;
@property long longProperty;
@property unsigned long unsignedLongProperty;
@property long long longLongProperty;
@property unsigned long long unsignedLongLongProperty;
@property float floatProperty;
@property double doubleProperty;
@property BOOL boolProperty;
@end

@implementation SomePropertyObject
@end

@interface SomeIvarObject : NSObject
{
@public
    NSObject* _objectIvar;
    char _charIvar;
    char _unsignedCharIvar;
    short _shortIvar;
    unsigned short _unsignedShortIvar;
    int _intIvar;
    unsigned int _unsignedIntIvar;
    long _longIvar;
    unsigned long _unsignedLongIvar;
    long long _longLongIvar;
    unsigned long long _unsignedLongLongIvar;
    float _floatIvar;
    double _doubleIvar;
    BOOL _boolIvar;
}
@end

@implementation SomeIvarObject
@end

@interface NSValue (Internal)
- (CGRect)rectValue;
- (CGSize)sizeValue;
- (CGPoint)pointValue;
@end


@testcase(NSKeyValueCoding)

test(DefaultAccessor)
{
    BOOL accessor = [NSObject accessInstanceVariablesDirectly];
    testassert(accessor == YES);
    return YES;
}

test(DirectInterfaceIvar)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"interfaceIvar"];
    testassert([d interfaceIsSet]);
    [d release];
    return YES;
}

test(DirectImplementationIvar)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"implementationIvar"];
    testassert([d implementationIsSet]);
    [d release];
    return YES;
}

test(DirectUnknown)
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"unknownIvar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }

    testassert(thrown);
    [d release];
    return YES;
}

test(DirectProperty)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"property"];
    testassert(d.property == YES);
    [d release];
    return YES;
}

test(DirectUnderscorePrefix)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"underscorePrefix"];
    testassert([d underscorePrefixIsSet]);
    [d release];
    return YES;
}

test(DirectUnderscorePrefix2)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"_underscorePrefix"];
    testassert([d underscorePrefixIsSet]);
    [d release];
    return YES;
}

test(DirectDoubleUnderscorePrefix)
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"doubleUnderscorePrefix"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d doubleUnderscorePrefixIsSet]);
    [d release];
    return YES;
}

test(DirectDoubleUnderscorePrefix2)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"_doubleUnderscorePrefix"];
    testassert([d doubleUnderscorePrefixIsSet]);
    [d release];
    return YES;
}

test(DirectUnderscorePostfix)
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"underscorePostfix"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d underscorePostfixIsSet]);
    [d release];
    return YES;
}

test(DirectIsPrefix)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"prefixed"];
    testassert([d isPrefixedIsSet]);
    [d release];
    return YES;
}

test(DirectIsUnderscorePrefix)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"underscoredPrefix"];
    testassert([d isUnderscoredPrefixedIsSet]);
    [d release];
    return YES;
}

test(DirectIncorrectFirstLetterCaseSetter)
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"InterfaceIvar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d interfaceIsSet]);
    [d release];
    return YES;
}

test(DirectIncorrectCaseSetter)
{
    Direct *d = [[Direct alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"interfaceivar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d interfaceIsSet]);
    [d release];
    return YES;
}

test(DirectObjectSetter)
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"object"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

test(DirectWeakObjectSetter)
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"weakObject"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

test(DirectStrongObjectSetter)
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"strongObject"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

test(DirectReassignObjectSetter)
{
    Direct *d = [[Direct alloc] init];
    RetainTestObject *retainTest1 = [[RetainTestObject alloc] init];
    RetainTestObject *retainTest2 = [[RetainTestObject alloc] init];
    [d setValue:retainTest1 forKey:@"object"];
    [d setValue:retainTest2 forKey:@"object"];
    testassert(![retainTest1 wasReleased]);
    testassert([retainTest1 wasAutoreleased]);
    [retainTest1 release];
    [retainTest2 release];
    [d release];
    return YES;
}

test(DirectOrder1)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"foo1"];
    NSArray *ivars = [d foo1IvarsSet];
    testassert([ivars isEqualToArray:@[@"_foo1"]]);
    return YES;
}

test(DirectOrder2)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"foo2"];
    NSArray *ivars = [d foo2IvarsSet];
    testassert([ivars isEqualToArray:@[@"_isFoo2"]]);
    return YES;
}

test(DirectOrder3)
{
    Direct *d = [[Direct alloc] init];
    [d setValue:@YES forKey:@"foo3"];
    NSArray *ivars = [d foo3IvarsSet];
    testassert([ivars isEqualToArray:@[@"foo3"]]);
    return YES;
}

test(IndirectInterfaceIvar)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"interfaceIvar"];
    testassert([d interfaceIsSet]);
    [d release];
    return YES;
}

test(IndirectImplementationIvar)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"implementationIvar"];
    testassert([d implementationIsSet]);
    [d release];
    return YES;
}

test(IndirectUnknown)
{
    Indirect *d = [[Indirect alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"unknownIvar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }

    testassert(thrown);
    [d release];
    return YES;
}

test(IndirectProperty)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"property"];
    testassert(d.property == YES);
    [d release];
    return YES;
}

test(IndirectUnderscorePrefix)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"underscorePrefix"];
    testassert([d underscorePrefixIsSet]);
    [d release];
    return YES;
}

test(IndirectUnderscorePrefix2)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"_underscorePrefix"];
    testassert([d underscorePrefixIsSet]);
    [d release];
    return YES;
}

test(IndirectDoubleUnderscorePrefix)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"doubleUnderscorePrefix"];
    testassert([d doubleUnderscorePrefixIsSet]);
    [d release];
    return YES;
}

test(IndirectDoubleUnderscorePrefix2)
{
    Indirect *d = [[Indirect alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"_doubleUnderscorePrefix"];
    }
    @catch (NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d doubleUnderscorePrefixIsSet]);
    [d release];
    return YES;
}

test(IndirectUnderscorePostfix)
{
    Indirect *d = [[Indirect alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"underscorePostfix"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d underscorePostfixIsSet]);
    [d release];
    return YES;
}

test(IndirectIsPrefix)
{
    Indirect *d = [[Indirect alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"prefixed"];
    }
    @catch (NSException *e)
    {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d isPrefixedIsSet]);
    [d release];
    return YES;
}

test(IndirectIsUnderscorePrefix)
{
    Indirect *d = [[Indirect alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"underscoredPrefix"];
    }
    @catch (NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d isUnderscoredPrefixedIsSet]);
    [d release];
    return YES;
}

test(IndirectIncorrectFirstLetterCaseSetter)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"InterfaceIvar"];
    testassert([d interfaceIsSet]);
    [d release];
    return YES;
}

test(IndirectIncorrectCaseSetter)
{
    Indirect *d = [[Indirect alloc] init];
    BOOL thrown = NO;
    @try {
        [d setValue:@YES forKey:@"interfaceivar"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    testassert(![d interfaceIsSet]);
    [d release];
    return YES;
}

test(IndirectObjectSetter)
{
    Indirect *d = [[Indirect alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"object"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

test(IndirectWeakObjectSetter)
{
    Indirect *d = [[Indirect alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"weakObject"];
    testassert(![retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

test(IndirectStrongObjectSetter)
{
    Indirect *d = [[Indirect alloc] init];
    RetainTestObject *retainTest = [[RetainTestObject alloc] init];
    [d setValue:retainTest forKey:@"strongObject"];
    testassert([retainTest wasRetained]);
    [retainTest release];
    [d release];
    return YES;
}

test(IndirectReassignObjectSetter)
{
    Indirect *d = [[Indirect alloc] init];
    RetainTestObject *retainTest1 = [[RetainTestObject alloc] init];
    RetainTestObject *retainTest2 = [[RetainTestObject alloc] init];
    [d setValue:retainTest1 forKey:@"object"];
    [d setValue:retainTest2 forKey:@"object"];
    testassert([retainTest1 wasReleased]);
    testassert(![retainTest1 wasAutoreleased]);
    [retainTest1 release];
    [retainTest2 release];
    [d release];
    return YES;
}

test(IndirectOrder1)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"foo1"];
    NSArray *ivars = [d foo1IvarsSet];
    testassert([ivars isEqualToArray:@[@"_foo1", @"foo1"]]);
    return YES;
}

test(IndirectOrder2)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"foo2"];
    NSArray *ivars = [d foo2IvarsSet];
    testassert([ivars isEqualToArray:@[@"foo2"]]);
    return YES;
}

test(IndirectOrder3)
{
    Indirect *d = [[Indirect alloc] init];
    [d setValue:@YES forKey:@"foo3"];
    NSArray *ivars = [d foo3IvarsSet];
    testassert([ivars isEqualToArray:@[@"foo3"]]);
    return YES;
}

test(SetNilValueOnNSMutableDictionaryForKey1)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:nil forKey:@"foo"];
    testassert([dict count] == 0);
    return YES;
}

test(SetValueOnNSMutableDictionaryForNilKey)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    BOOL exception = NO;
    @try {
        [dict setValue:@"foo" forKey:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    testassert([dict count] == 0);
    testassert(exception);
    return YES;
}

test(SetNilValueOnNSMutableDictionaryForKey2)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSArray array] forKey:@"foo"];
    NSArray *anArray = [dict valueForKey:@"foo"];
    testassert(anArray != nil);
    return YES;
}

test(SetNilValueOnNSMutableDictionaryForKey3)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"hello" forKey:@"foo"];
    NSString *hello = [dict valueForKey:@"foo"];
    testassert(hello != nil);
    [dict setValue:nil forKey:@"foo"];
    hello = [dict valueForKey:@"foo"];
    testassert(hello == nil);
    return YES;
}

test(SetNilValueOnNSMutableDictionaryForKey4)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"hello" forKey:@"foo"];
    NSString *hello = [dict valueForKey:@"foo"];
    testassert(hello != nil);
    [dict setValue:nil forKey:@"foo"];
    hello = [dict valueForKey:@"foo"];
    testassert(hello == nil);
    return YES;
}

// [NSMutableDictionary setValue:forKeyPath:] silent FAIL cases ...

test(setValueForKeyPath_onNSMutableDictionary_PathWithAtSymbols)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *aPathWithAts = @"a@.@path@with.at@symbols@.";
    [dict setValue:@"foo" forKeyPath:aPathWithAts];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:aPathWithAts];
    testassert(anObj == nil);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_ValidYetNonexistentASCIIKeyPath)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *validYetNonexistentKeyPath = @"a.valid.yet.nonexistent.key.path";
    [dict setValue:@"foo" forKeyPath:validYetNonexistentKeyPath];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:validYetNonexistentKeyPath];
    testassert(anObj == nil);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_ValidYetNonexistentKeyPathWithSomeUnicodeSymbols)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *validYetNonexistentKeyPath = @"a.väl|d.yét.n0nEx1$t3nt.kéy´.p@th!";
    [dict setValue:@"foo" forKeyPath:validYetNonexistentKeyPath];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:validYetNonexistentKeyPath];
    testassert(anObj == nil);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_AnotherWhackyKeyPathWithMoarUnicodeSymbols)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *anotherWhackyKeyPath = @"!#$@aasdf}.\\[-$uiå∑œΩ≈©†®´√ˆ¨∆äopio`~/?.,<>><.<;:'\"{#$@#$l.k@rqADF|+_w^ier.23]]]48&*(*&()";
    [dict setValue:@"foo" forKeyPath:anotherWhackyKeyPath];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:anotherWhackyKeyPath];
    testassert(anObj == nil);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_LeadingDot)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *beginDot = @".self.subdict";
    [dict setValue:@"foo" forKeyPath:beginDot];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:beginDot];
    testassert(anObj == nil);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_UnaryDot)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *unaryDot = @".";
    [dict setValue:@"foo" forKeyPath:unaryDot];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:unaryDot];
    testassert(anObj == nil);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_DotsBros)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *dotsBros = @"........................................................................................";
    [dict setValue:@"foo" forKeyPath:dotsBros];
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:dotsBros];
    testassert(anObj == nil);

    return YES;
}

// [NSMutableDictionary setValue:forKeyPath:] success cases ...

test(setValueForKeyPath_onNSMutableDictionary_EmptyPath)
{
    id anObj = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];
    NSUInteger dictCount = [dict count];

    NSString *emptyPath = @"";
    [dict setValue:@"foo" forKeyPath:emptyPath];
    ++dictCount;
    testassert([dict count] == dictCount);
    anObj = [dict valueForKeyPath:emptyPath];
    testassert([anObj isEqualToString:@"foo"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_LastDot)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *lastDot = @"self.subdict.parent.subdict.";
    [dict setValue:@"foo" forKeyPath:lastDot];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:lastDot];
    testassert([anObj isEqualToString:@"foo"]);
    testassert([anObj isEqualToString:@"foo"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_SelfReferentialPath)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *fooKeyPath = @"self.self.subdict.parent.fooKey";
    [dict setValue:@"bar" forKeyPath:fooKeyPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:fooKeyPath];
    testassert([anObj isEqualToString:@"bar"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_LongerSelfReferentialPath)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *bazKeyPath = @"subdict.bazKey";
    NSString *aLongRecursiveBazKeyPath = @"self.self.subdict.parent.self.self.self.subdict.parent.subdict.bazKey";
    [dict setValue:@"foo" forKeyPath:aLongRecursiveBazKeyPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:bazKeyPath];
    testassert([anObj isEqualToString:@"foo"]);

    [dict setValue:@"bazVal" forKeyPath:bazKeyPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aLongRecursiveBazKeyPath];
    testassert([anObj isEqualToString:@"bazVal"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_AddingNewSubKey)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *aNewKeyPath = @"subdict.aNewKey";
    [dict setValue:@"aNewKeyVal" forKeyPath:aNewKeyPath];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aNewKeyPath];
    testassert([anObj isEqualToString:@"aNewKeyVal"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_RediculouslyLongRecursiveKeyPath)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *aSomewhatRidiculouslyLongRecursivePath = @"self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.self.subdict.parent.self.self.fooKey";
    [dict setValue:@"bazz" forKeyPath:aSomewhatRidiculouslyLongRecursivePath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aSomewhatRidiculouslyLongRecursivePath];
    testassert([anObj isEqualToString:@"bazz"]);

    return YES;
}

// [NSMutableDictionary setValue:forKeyPath:] special operators tests ...

test(setValueForKeyPath_onNSMutableDictionary_MaxOperator)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *maxValuePath = @"subdict.@max";
    [dict setValue:@"altMax" forKeyPath:maxValuePath];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    // valueForKey{,Path} should prolly be tested here and elsewhere
    anObj = [subdict objectForKey:@"@max"];
    testassert([anObj isEqualToString:@"altMax"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_CountOperator)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *aPathWithCountOperator = @"@count";
    [dict setValue:@"hmm" forKeyPath:aPathWithCountOperator];
    ++dictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:aPathWithCountOperator];
    testassert([anObj intValue] == 4);
    anObj = [dict valueForKey:aPathWithCountOperator];
    testassert([anObj intValue] == 4);
    anObj = [dict objectForKey:aPathWithCountOperator];
    testassert([anObj isEqualToString:@"hmm"]);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_SubPathCountOperator)
{
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *anotherPathWithCountOperator = @"subdict.@count";
    [dict setValue:@"yea" forKeyPath:anotherPathWithCountOperator];
    ++subdictCount;
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:anotherPathWithCountOperator];
    testassert([anObj intValue] == 6);
    anObj = [dict valueForKey:anotherPathWithCountOperator];
    testassert(anObj == nil);
    anObj = [dict objectForKey:anotherPathWithCountOperator];
    testassert(anObj == nil);
    anObj = [subdict objectForKey:@"@count"];
    testassert([anObj isEqualToString:@"yea"]);

    return YES;
}

// TODO : More @operator tests ...

// [NSMutableDictionary setValue:forKeyPath:] assertion cases ...

test(setValueForKeyPath_onNSMutableDictionary_Assertion1)
{
    BOOL exception = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];

    @try {
        exception = NO;
        [dict setValue:@"foo" forKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_Assertion2)
{
    BOOL exception = NO;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"barVal", @"barKey", @"fooVal", @"fooKey", nil];
    [dict setObject:dict forKey:@"self"];

    NSString *atDotPath = @"@.";
    @try {
        exception = NO;
        [dict setValue:@"foo" forKeyPath:atDotPath];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(setValueForKeyPath_onNSMutableDictionary_Assertion3)
{
    BOOL exception = NO;
    id anObj = nil;

    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subarray, @"subarray", [NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", @"fooVal", @"fooKey", nil];

    [subdict setObject:dict forKey:@"parent"];
    [dict setObject:dict forKey:@"self"];

    NSUInteger dictCount = [dict count];
    NSUInteger subdictCount = [subdict count];

    NSString *setValueOutFromUnderItselfPath = @"subdict.parent.subdict";
    [dict setValue:@"gone" forKeyPath:setValueOutFromUnderItselfPath];
    testassert([dict count] == dictCount);
    testassert([subdict count] == subdictCount);
    anObj = [dict valueForKeyPath:@"subdict"];
    testassert([anObj isEqualToString:@"gone"]);
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:setValueOutFromUnderItselfPath];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);
    [dict setObject:subdict forKey:@"subdict"];// reset

    return YES;
}

// TODO : NSMutableArray , NSMutableSet setValue:forKeyPath: tests ...

#pragma mark -
#pragma mark NSDictionary KVC tests

test(NSDictionary_valueForKeyPath_NilPath)
{
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", nil];

    anObj = [dict valueForKeyPath:nil];
    testassert(anObj == nil);

    return YES;
}

test(NSDictionary_valueForKeyPath_EmptyPath)
{
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"empty", @"", nil];

    anObj = [dict valueForKeyPath:@""];
    testassert([anObj isEqualToString:@"empty"]);

    return YES;
}

test(NSDictionary_valueForKeyPath_ValidShortPath)
{
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    anObj = [dict valueForKeyPath:@"subdict.subarray"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableArray class]]);
    testassert([anObj isEqual:subarray]);

    return YES;
}

test(NSDictionary_valueForKeyPath_LeadingDot)
{
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    anObj = [dict valueForKeyPath:@".subdict.subarray"];
    testassert(anObj == nil);

    return YES;
}

test(NSDictionary_valueForKeyPath_TrailingDot)
{
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    anObj = [dict valueForKeyPath:@"subdict."];
    testassert(anObj == nil);

    return YES;
}

test(NSDictionary_valueForKeyPath_TrailingDot2)
{
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    [subdict setObject:@"foo" forKey:@""];
    anObj = [dict valueForKeyPath:@"subdict."];
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([anObj isEqualToString:@"foo"]);

    return YES;
}

test(NSDictionary_valueForKeyPath_TrailingDot3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.subarray."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_InvalidKey)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    anObj = [dict valueForKeyPath:@"subdict.bazKey"];
    testassert([anObj isEqualToString:@"bazVal"]);

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.bazKey.invalid"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_RecursivePaths)
{
    id anObj;
    NSMutableArray *subarray = [NSMutableArray arrayWithObjects:@0, [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0f], [NSNumber numberWithInt:101], [NSNumber numberWithFloat:4], [NSNumber numberWithLong:-2], nil];
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", subarray, @"subarray", loop, @"loop", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    // inf loop ...
    [loop setObject:dict forKey:@"dict"];
    [loop setObject:loop forKey:@"loop"];

    anObj = [dict valueForKeyPath:@"subdict.loop"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:loop]);

    anObj = [dict valueForKeyPath:@"subdict.loop.loop"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:loop]);

    anObj = [dict valueForKeyPath:@"subdict.loop.dict"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableDictionary class]]);
    testassert([anObj isEqual:dict]);

    anObj = [dict valueForKeyPath:@"subdict.loop.loop.loop.dict.subdict.loop.dict.subdict.subarray"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSMutableArray class]]);
    testassert([anObj isEqual:subarray]);

    return YES;
}

test(NSDictionary_valueForKeyPath_InvalidPaths)
{
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", nil];

    anObj = [dict valueForKeyPath:@"a.completely.wrong.path.that.is.syntactically.correct"];
    testassert(anObj == nil);

    anObj = [dict valueForKeyPath:@"#!/bin/sh -c 'echo hello.world'"];
    testassert(anObj == nil);

    return YES;
}

// @count

test(NSDictionary_valueForKeyPath_CountOperator1)
{
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", @"barVal", @"barKey", nil];

    anObj = [dict valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 2);

    return YES;
}

test(NSDictionary_valueForKeyPath_CountOperator2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", @"barVal", @"barKey", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@count.subdict"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_CountOperator3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", @"barVal", @"barKey", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@count.invalid.righthand.path"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_CountOperator4)
{
    id anObj;
    NSMutableDictionary *loop = [NSMutableDictionary dictionary];
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    [loop setObject:dict forKey:@"dict"];
    [loop setObject:subdict forKey:@"subdict"];
    [loop setObject:loop forKey:@"loop"];
    [dict setObject:loop forKey:@"loop"];

    anObj = [dict valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 2);

    anObj = [dict valueForKeyPath:@"subdict.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 3);

    anObj = [dict valueForKeyPath:@"loop.loop.@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 3);

    return YES;
}

// -

test(NSDictionary_valueForKeyPath_InvalidOperatorWithRemainderPath)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator.with.a.remainder.path"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_InvalidOperator)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@anInvalidOperator"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_InvalidOperatorWithDot)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @avg

test(NSDictionary_valueForKeyPath_AvgOperator1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@avg"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_AvgOperator2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@avg"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_AvgOperator3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@avg.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @max

test(NSDictionary_valueForKeyPath_MaxOperator1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@max"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_MaxOperator2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@max"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_MaxOperator3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@max.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @min

test(NSDictionary_valueForKeyPath_MinOperator1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@min"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_MinOperator2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@min"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_MinOperator3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@min.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @sum

test(NSDictionary_valueForKeyPath_SumOperator1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@sum"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}
test(NSDictionary_valueForKeyPath_SumOperator2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@sum"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_SumOperator3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@sum.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @unionOfObjects

test(NSDictionary_valueForKeyPath_unionOfObjects1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_unionOfObjects2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfObjects

test(NSDictionary_valueForKeyPath_distinctUnionOfObjects1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_distinctUnionOfObjects2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @unionOfArrays

test(NSDictionary_valueForKeyPath_unionOfArrays1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_unionOfArrays2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfArrays

test(NSDictionary_valueForKeyPath_distinctUnionOfArrays1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_distinctUnionOfArrays2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];
    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfSets

test(NSDictionary_valueForKeyPath_distinctUnionOfSets1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"subdict.@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSDictionary_valueForKeyPath_distinctUnionOfSets2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableDictionary *subdict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:3.14], @"piApproxKey", @"bazVal", @"bazKey", [NSNull null], @"nsNullKey", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:subdict, @"subdict", nil];

    @try {
        exception = NO;
        anObj = [dict valueForKeyPath:@"@distinctUnionOfSets"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

#pragma mark -
#pragma mark NSArray KVC tests

test(NSArray_valueForKeyPath_NilPath)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_InvalidPath)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_EmptyPath)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_DotPath)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_UnaryAt)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_One)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_AtOne)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Ats)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@@@@@@@@@@@@@@@@@@@@@@@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @count

test(NSArray_valueForKeyPath_CountOperator)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 10);

    return YES;
}

test(NSArray_valueForKeyPath_CountOperatorIgnoreRighthandPath)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@count.should.ignore.right.hand.path"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 10);

    return YES;
}

test(NSArray_valueForKeyPath_CountOperatorPrefix)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@count"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Recursion)
{
    NSMutableArray *recursiveArray = [NSMutableArray array];
    [recursiveArray addObject:recursiveArray];
    [recursiveArray addObject:@[@"foo", @"bar"]];
    [recursiveArray addObject:@[@"foo", @"bar"]];

    //anObj = [recursiveArray valueForKeyPath:@"@max.count"]; -- stack overflow in iOS simulator
    //anObj = [recursiveArray valueForKeyPath:@"@min.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@avg.count"]; -- ditto
    //anObj = [recursiveArray valueForKeyPath:@"@sum.count"]; -- ditto

    return YES;
}

// @max

test(NSArray_valueForKeyPath_Max1)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@max.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@127 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Max2)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@max.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@127 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Max3)
{
    id anObj;

    NSMutableArray *anotherArray = [NSMutableArray array];
    anObj = [anotherArray valueForKeyPath:@"@max.count"];
    testassert(anObj == nil);

    return YES;
}

test(NSArray_valueForKeyPath_Max4)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@max.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([[anObj description] isEqualToString:@"another constant NSString with a long description"]);

    return YES;
}

test(NSArray_valueForKeyPath_Max5)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@max.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Max6)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@max"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Max7)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@max.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @min

test(NSArray_valueForKeyPath_Min1)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@min.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@-127 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Min2)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@min.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@-127 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Min3)
{
    id anObj;

    NSMutableArray *anotherArray = [NSMutableArray array];
    anObj = [anotherArray valueForKeyPath:@"@min.count"];
    testassert(anObj == nil);

    return YES;
}

test(NSArray_valueForKeyPath_Min4)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@min.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([[anObj description] isEqualToString:@""]);

    return YES;
}

test(NSArray_valueForKeyPath_Min5)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@min.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Min6)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@min"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Min7)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@min.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @avg

test(NSArray_valueForKeyPath_Avg1)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@avg.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@8 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Avg2)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@avg.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@8 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Avg3)
{
    id anObj;

    NSMutableArray *anotherArray = [NSMutableArray array];
    anObj = [anotherArray valueForKeyPath:@"@avg.count"];
    testassert(anObj == nil);

    return YES;
}

test(NSArray_valueForKeyPath_Avg4)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Avg5)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Avg6)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@avg"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Avg7)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@avg.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @sum

test(NSArray_valueForKeyPath_Sum1)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@sum.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@82 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Sum2)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@sum.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@81 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Sum3)
{
    id anObj;

    NSMutableArray *anotherArray = [NSMutableArray array];
    anObj = [anotherArray valueForKeyPath:@"@sum.count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@0 intValue]);

    return YES;
}

test(NSArray_valueForKeyPath_Sum4)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@sum.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([[anObj description] isEqualToString:@"NaN"]);

    return YES;
}

test(NSArray_valueForKeyPath_Sum5)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    // throw exception with invalid prefix --
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"foo@sum.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Sum6)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    // throw exception for no suffix --
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@sum"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_Sum7)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    // throw exception for invalid suffix --
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@sum.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @unionOfObjects

test(NSArray_valueForKeyPath_unionOfObjects1)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@unionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 10);

    return YES;
}

test(NSArray_valueForKeyPath_unionOfObjects2)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@unionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 10);

    return YES;
}

test(NSArray_valueForKeyPath_unionOfObjects3)
{
    id anObj;

    NSMutableArray *anotherArray = [NSMutableArray array];
    anObj = [anotherArray valueForKeyPath:@"@unionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 0);

    return YES;
}

test(NSArray_valueForKeyPath_unionOfObjects4)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfObjects

test(NSArray_valueForKeyPath_distinctUnionOfObjects1)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 7);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfObjects2)
{
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    anObj = [anArray valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 9);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfObjects3)
{
    id anObj;

    NSMutableArray *anotherArray = [NSMutableArray array];
    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 0);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfObjects4)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    // @operator as last element in path ...
    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @unionOfArrays

test(NSArray_valueForKeyPath_unionOfArrays1)
{
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];

    anObj = [anotherArray valueForKeyPath:@"@unionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 7);
    id subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSArray class]]);
    testassert([subObj count] == 3);

    return YES;
}

test(NSArray_valueForKeyPath_unionOfArrays2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];

    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_unionOfArrays3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfArrays

test(NSArray_valueForKeyPath_distinctUnionOfArrays1)
{
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];

    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 5);
    id subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSNumber class]]);
    testassert([subObj intValue] == 0);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfArrays2)
{
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];

    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);
    id subObj = [anObj objectAtIndex:0];
    testassert([subObj isKindOfClass:[NSArray class]]);
    testassert([subObj count] == 3);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfArrays3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSArray arrayWithObjects:@[@1, @2, @42], @[@1, @2, @42], @3.3, @[@1, @2, @3], nil]];
    [anotherArray addObject:[NSArray arrayWithObjects:@"hello", @"world", @"-23", nil]];

    @try {
        exception = NO;
        anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfArrays4)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfSets

test(NSArray_valueForKeyPath_distinctUnionOfSets1)
{
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSSet setWithObjects:[NSSet setWithObjects:@1, @2, @42, nil], [NSSet setWithObjects:@1, @2, @42, nil], @3.3, [NSSet setWithObjects:@1, @2, @3, nil], nil]];
    [anotherArray addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", nil]];

    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 6);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfSets2)
{
    id anObj;
    NSMutableArray *anotherArray = [NSMutableArray array];
    [anotherArray addObject:[NSSet setWithObjects:[NSSet setWithObjects:@1, @2, @42, nil], [NSSet setWithObjects:@1, @2, @42, nil], @3.3, [NSSet setWithObjects:@1, @2, @3, nil], nil]];
    [anotherArray addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", nil]];

    anObj = [anotherArray valueForKeyPath:@"@distinctUnionOfSets.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSArray class]]);
    testassert([anObj count] == 5);

    return YES;
}

test(NSArray_valueForKeyPath_distinctUnionOfSets3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableArray *anArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"a NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [anArray valueForKeyPath:@"@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

#pragma mark -
#pragma mark NSSet KVC Tests

test(NSSet_valueForKeyPath_NilPath)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_InvalidPath)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"lastObject"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_EmptyPath)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@""];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_UnaryDot)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"."];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_UnaryAt)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_One)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_AtOne)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@1"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Ats)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@@@@@@@"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_CountOperator)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 9);

    return YES;
}

test(NSSet_valueForKeyPath_CountOperatorIgnoreRighthandPath)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@count.should.ignore.right.hand.path"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == 9);

    return YES;
}

test(NSSet_valueForKeyPath_CountOperatorInvalidPrefix)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@count"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_recursion)
{
    NSMutableSet *recursiveSet = [NSMutableSet set];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:@[@"foo", @"bar"]];
    [recursiveSet addObject:recursiveSet];
    //anObj = [recursiveSet valueForKeyPath:@"@max.count"]; //-- stack overflow in iOS simulator
    //anObj = [recursiveSet valueForKeyPath:@"@min.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@avg.count"]; //-- ditto
    //anObj = [recursiveSet valueForKeyPath:@"@sum.count"]; //-- ditto

    return YES;
}

// @max

test(NSSet_valueForKeyPath_Max1)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@max.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@127 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Max2)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@max.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@127 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Max3)
{
    id anObj;

    NSMutableSet *anotherSet = [NSMutableSet set];
    anObj = [anotherSet valueForKeyPath:@"@max.count"];
    testassert(anObj == nil);

    return YES;
}

test(NSSet_valueForKeyPath_Max4)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@max.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([[anObj description] isEqualToString:@"another constant NSString with a long description"]);

    return YES;
}

test(NSSet_valueForKeyPath_Max5)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@max.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Max6)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@max"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Max7)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@max.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @min

test(NSSet_valueForKeyPath_Min1)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@min.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@-127 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Min2)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@min.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@-127 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Min3)
{
    id anObj;

    NSMutableSet *anotherSet = [NSMutableSet set];
    anObj = [anotherSet valueForKeyPath:@"@min.count"];
    testassert(anObj == nil);

    return YES;
}

test(NSSet_valueForKeyPath_Min4)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@min.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSString class]]);
    testassert([[anObj description] isEqualToString:@""]);

    return YES;
}

test(NSSet_valueForKeyPath_Min5)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@min.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Min6)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@min"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Min7)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@min.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @avg

test(NSSet_valueForKeyPath_Avg1)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@avg.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@4 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Avg2)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@avg.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@4 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Avg3)
{
    id anObj;

    NSMutableSet *anotherSet = [NSMutableSet set];
    anObj = [anotherSet valueForKeyPath:@"@avg.count"];
    testassert(anObj == nil);

    return YES;
}

test(NSSet_valueForKeyPath_Avg4)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Avg5)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Avg6)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@avg"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Avg7)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@avg.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @sum

test(NSSet_valueForKeyPath_Sum1)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@sum.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@40 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Sum2)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@sum.floatValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@39 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Sum3)
{
    id anObj;

    NSMutableSet *anotherSet = [NSMutableSet set];
    anObj = [anotherSet valueForKeyPath:@"@sum.count"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert([anObj intValue] == [@0 intValue]);

    return YES;
}

test(NSSet_valueForKeyPath_Sum4)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@sum.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSNumber class]]);
    testassert(isnan([anObj doubleValue]));

    return YES;
}

test(NSSet_valueForKeyPath_Sum5)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"foo@sum.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Sum6)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@sum"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_Sum7)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@sum.foobar"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_extraMinMaxAvgSum)
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"fooVal", @"fooKey", @"barVal", @"barKey", @101, @"101Key", nil];
    NSMutableSet *set = [NSMutableSet setWithObject:dict];

    id aValue = [set valueForKeyPath:@"@max.intValue"];
    testassert(aValue == nil);

    aValue = [set valueForKeyPath:@"@min.intValue"];
    testassert(aValue == nil);

    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 0);

    aValue = [set valueForKeyPath:@"@sum.intValue"];
    testassert([aValue intValue] == 0);

    [set addObject:[NSNumber numberWithInt:42]];

    aValue = [set valueForKeyPath:@"@max.intValue"];
    testassert([aValue intValue] == 42);

    aValue = [set valueForKeyPath:@"@min.intValue"];
    testassert([aValue intValue] == 42);

    aValue = [set valueForKeyPath:@"@sum.intValue"];
    testassert([aValue intValue] == 42);

    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 21);

    [set addObject:[NSNumber numberWithInt:-10]];

    aValue = [set valueForKeyPath:@"@avg.intValue"];
    testassert([aValue intValue] == 10);

    return YES;
}

// @unionOfObjects

test(NSSet_valueForKeyPath_unionOfObjects1)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@unionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfObjects2)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfObjects3)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@unionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfObjects4)
{
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
    testassert([anotherSet count] == 3);
    BOOL exception = NO;
    id anObj;

    @try {
        anObj = [anotherSet valueForKeyPath:@"@unionOfObjects.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfObjects5)
{
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
    testassert([anotherSet count] == 3);
    BOOL exception = NO;
    id anObj;

    @try {
        anObj = [anotherSet valueForKeyPath:@"@unionOfObjects.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfObjects

test(NSSet_valueForKeyPath_distinctUnionOfObjects1)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 7);

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfObjects2)
{
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 9);

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfObjects3)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfObjects"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfObjects4)
{
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
    testassert([anotherSet count] == 3);

    id anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfObjects.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 3);
    testassert([anObj isEqual:anotherSet]);

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfObjects5)
{
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];
    testassert([anotherSet count] == 3);

    id anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfObjects.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 3);

    return YES;
}

// @unionOfArrays

test(NSSet_valueForKeyPath_unionOfArrays1)
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfArrays2)
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays.intValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfArrays3)
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    @try {
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(NSSet_valueForKeyPath_unionOfArrays4)
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    @try {
        anObj = [anotherSet valueForKeyPath:@"@unionOfArrays.doubleValue"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfArrays

test(NSSet_valueForKeyPath_distinctUnionOfArrays1)
{
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.intValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 5);
#warning TODO: iterate/verify subobjects

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfArrays2)
{
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 9);
#warning TODO: iterate/verify subobjects

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfArrays3)
{
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays.doubleValue"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 5);
#warning TODO: iterate/verify subobjects

    return YES;
}

test(NSSet_valueForKeyPath_distinctUnionOfArrays4)
{
    BOOL exception = NO;
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    NSArray *subAry = [NSArray arrayWithObjects:@[ @"helloset", @"helloset" ], @"helloset", @"helloset", @"arrayobj", nil];
    [anotherSet addObject:subAry];

    @try {
        exception = NO;
        anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfArrays"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSUnknownKeyException"]);
    }
    testassert(exception);

    return YES;
}

// @distinctUnionOfSets

test(NSSet_valueForKeyPath_distinctUnionOfSets1)
{
    id anObj;
    NSMutableSet *anotherSet = [NSMutableSet set];
    [anotherSet addObject:[NSSet setWithObjects:@"hello", @"world", @"-23", [NSSet setWithObjects:@"subsetobj", @"subsetobj", [NSSet setWithObjects:@"subsubsetobj", nil], nil], nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];
    [anotherSet addObject:[NSSet setWithObjects:@"helloset", @"helloset", @"helloset", @"worldset", @"-22", nil]];

    anObj = [anotherSet valueForKeyPath:@"@distinctUnionOfSets.description"];
    testassert(anObj != nil);
    testassert([anObj isKindOfClass:[NSSet class]]);
    testassert([anObj count] == 7);

    return YES;
}

#pragma mark -

test(NSSet_valueForKeyPath_distinctUnionOfSets2)
{
    BOOL exception = NO;
    id anObj;
    NSSet *aSet = [NSSet setWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithChar:0x81], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"another constant NSString with a long description", [NSMutableString stringWithString:@"an NSMutableString"], @"", nil];

    @try {
        exception = NO;
        anObj = [aSet valueForKeyPath:@"@distinctUnionOfSets.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(exception);

    return YES;
}

test(valueForKeyPath_strangeExceptions1)
{
    NSArray *anArray = [NSArray arrayWithObjects:[NSMutableString stringWithString:@"an NSMutableString"], nil];
    BOOL exception = NO;
    id aValue;

    @try {
        exception = NO;
        aValue = [anArray valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);

    return YES;
}

test(valueForKeyPath_strangeExceptions2)
{
    NSSet *aSet = [NSSet setWithObjects:[NSMutableString stringWithString:@"an NSMutableString"], nil];
    BOOL exception = NO;
    id aValue;

    @try {
        exception = NO;
        aValue = [aSet valueForKeyPath:@"@avg.description"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:@"NSDecimalNumberOverflowException"]);
    }
    testassert(exception);

    return YES;
}

test(valueForKeyPath_onEmptySet)
{
    NSMutableSet *set = [NSMutableSet set];

    id aValue = [set valueForKeyPath:@"max.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);

    aValue = [set valueForKeyPath:@"min.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);

    aValue = [set valueForKeyPath:@"avg.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);

    aValue = [set valueForKeyPath:@"sum.intValue"];
    testassert([aValue isKindOfClass:[NSSet class]]);
    testassert([aValue isEqual:set]);
    testassert([aValue count] == 0);
    return YES;
}

#if 0
CGPoint not available without UIKit

test(SetValueForKeyOnInnerCGPoint)
{
    SomeObjectWithCGPoint *obj = [[SomeObjectWithCGPoint alloc] init];
    NSValue *val = [NSValue valueWithCGPoint:CGPointFromString(@"{-42,-101}")];
    testassert([val pointValue].x == -42);
    testassert([val pointValue].y == -101);
    
    [obj setValue:val forKey:@"point"];
    testassert([obj verifyPoint:[val pointValue]]);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnInnerCGSize)
{
    SomeObjectWithCGSize *obj = [[SomeObjectWithCGSize alloc] init];
    NSValue *val = [NSValue valueWithCGSize:CGSizeMake(42,84)];
    testassert([val sizeValue].width == 42);
    testassert([val sizeValue].height == 84);
    
    [obj setValue:val forKey:@"size"];
    testassert([obj verifySize:[val sizeValue]]);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnInnerCGRect)
{
    SomeObjectWithCGRect *obj = [[SomeObjectWithCGRect alloc] init];
    NSValue *val = [NSValue valueWithCGRect:CGRectMake(-123.5f, 456, 42, 84.25f)];
    testassert([val rectValue].origin.x == -123.5f);
    testassert([val rectValue].origin.y == 456);
    testassert([val rectValue].size.width == 42);
    testassert([val rectValue].size.height == 84.25f);
    
    [obj setValue:val forKey:@"rect"];
    testassert([obj verifyRect:[val rectValue]]);
    
    [obj release];
    return YES;
}
#endif

test(SetValueForKeyOnInnerNSRange)
{
    SomeObjectWithNSRange *obj = [[SomeObjectWithNSRange alloc] init];
    NSRange range = NSMakeRange(33, 66);
    NSValue *val = [NSValue valueWithRange:range];
    
    [obj setValue:val forKey:@"range"];
    testassert([obj verifyRange:range]);
    
    [obj release];
    return YES;
}


test(SetValueForKeyOnInnerStruct)
{
    SomeObjectWithSmallishInnerStruct *obj = [[SomeObjectWithSmallishInnerStruct alloc] init];
    SomeSmallishStruct aStruct;
    aStruct.aUint = 0xabadf00;
    
    NSValue *val = [NSValue value:&aStruct withObjCType:@encode(SomeSmallishStruct)];
    
    [obj setValue:val forKey:@"aSmallishStruct"];
    testassert([obj verifyInnerStruct:aStruct]);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnLargeInnerStruct)
{
    SomeObjectWithLargeInnerStruct *obj = [[SomeObjectWithLargeInnerStruct alloc] init];
    SomeLargeStruct aStruct;
    for (unsigned int i=0; i<SOME_LARGE_STRUCT_DATASZ; i++)
    {
        aStruct.data[i] = (uint8_t)i;
    }
    
    NSValue *val = [NSValue value:&aStruct withObjCType:@encode(SomeLargeStruct)];
    
    [obj setValue:val forKey:@"aLargeStruct"];
    testassert([obj verifyInnerStruct:aStruct]);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnObjectProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"objectProperty"];
    testassert([obj.objectProperty isEqual:@(42)]);
    
    [obj setValue:@"32" forKey:@"objectProperty"];
    testassert([obj.objectProperty isEqual:@"32"]);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnCharProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"charProperty"];
    testassert(obj.charProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedCharProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedCharProperty"];
    testassert(obj.unsignedCharProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnShortProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"shortProperty"];
    testassert(obj.shortProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedShortProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedShortProperty"];
    testassert(obj.unsignedShortProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnIntProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"intProperty"];
    testassert(obj.intProperty == 42);
    
    [obj setValue:@"32" forKey:@"intProperty"];
    testassert(obj.intProperty == 32);
    
    [obj release];
    return YES;
}

#if !defined(__IPHONE_8_0)
test(SetValueForKeyOnUnsignedIntProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedIntProperty"];
    testassert(obj.unsignedIntProperty == 42);
    
    [obj setValue:@"32" forKey:@"unsignedIntProperty"];
    testassert(obj.unsignedIntProperty == 32);
    
    [obj release];
    return YES;
}
#endif

test(SetValueForKeyOnLongProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"longProperty"];
    testassert(obj.longProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedLongProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedLongProperty"];
    testassert(obj.unsignedLongProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnLongLongProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"longLongProperty"];
    testassert(obj.longLongProperty == 42);
    
    [obj setValue:@"32" forKey:@"longLongProperty"];
    testassert(obj.longLongProperty == 32);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedLongLongProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedLongLongProperty"];
    testassert(obj.unsignedLongLongProperty == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnFloatProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(128) forKey:@"floatProperty"];
    testassert(obj.floatProperty == 128.f);
    
    [obj setValue:@"256" forKey:@"floatProperty"];
    testassert(obj.floatProperty == 256.f);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnDoubleProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(128) forKey:@"doubleProperty"];
    testassert(obj.doubleProperty == 128.);
    
    [obj setValue:@"256" forKey:@"doubleProperty"];
    testassert(obj.doubleProperty == 256.);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnBoolProperty)
{
    SomePropertyObject *obj = [[SomePropertyObject alloc] init];
    
    [obj setValue:@(0) forKey:@"boolProperty"];
    testassert(obj.boolProperty == NO);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnObjectIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"objectIvar"];
    testassert([obj->_objectIvar isEqual:@(42)]);
    
    [obj setValue:@"32" forKey:@"objectIvar"];
    testassert([obj->_objectIvar isEqual:@"32"]);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnCharIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"charIvar"];
    testassert(obj->_charIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedCharIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedCharIvar"];
    testassert(obj->_unsignedCharIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnShortIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"shortIvar"];
    testassert(obj->_shortIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedShortIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedShortIvar"];
    testassert(obj->_unsignedShortIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnIntIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"intIvar"];
    testassert(obj->_intIvar == 42);
    
    [obj setValue:@"32" forKey:@"intIvar"];
    testassert(obj->_intIvar == 32);
    
    [obj release];
    return YES;
}

#if !defined(__IPHONE_8_0)
test(SetValueForKeyOnUnsignedIntIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedIntIvar"];
    testassert(obj->_unsignedIntIvar == 42);
    
    [obj setValue:@"32" forKey:@"unsignedIntIvar"];
    testassert(obj->_unsignedIntIvar == 32);
    
    [obj release];
    return YES;
}
#endif

test(SetValueForKeyOnLongIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"longIvar"];
    testassert(obj->_longIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedLongIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedLongIvar"];
    testassert(obj->_unsignedLongIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnLongLongIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"longLongIvar"];
    testassert(obj->_longLongIvar == 42);
    
    [obj setValue:@"32" forKey:@"longLongIvar"];
    testassert(obj->_longLongIvar == 32);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnUnsignedLongLongIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(42) forKey:@"unsignedLongLongIvar"];
    testassert(obj->_unsignedLongLongIvar == 42);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnFloatIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(128) forKey:@"floatIvar"];
    testassert(obj->_floatIvar == 128.f);
    
    [obj setValue:@"256" forKey:@"floatIvar"];
    testassert(obj->_floatIvar == 256.f);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnDoubleIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(128) forKey:@"doubleIvar"];
    testassert(obj->_doubleIvar == 128.);
    
    [obj setValue:@"256" forKey:@"doubleIvar"];
    testassert(obj->_doubleIvar == 256.);
    
    [obj release];
    return YES;
}

test(SetValueForKeyOnBoolIvar)
{
    SomeIvarObject *obj = [[SomeIvarObject alloc] init];
    
    [obj setValue:@(0) forKey:@"boolIvar"];
    testassert(obj->_boolIvar == NO);
    
    [obj release];
    return YES;
}

@end
