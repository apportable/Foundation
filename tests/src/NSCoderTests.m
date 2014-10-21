//
//  NSCoderTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface SimpleClass : NSObject <NSCoding>
@property int a;
@property BOOL didEncode;
@property BOOL didDecode;
@end
@implementation SimpleClass
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _a = [aDecoder decodeIntForKey:@"ABC"];
        _didDecode = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    _a = 123;
    [aCoder encodeInt:_a forKey:@"ABC"];
    _didEncode = YES;
}

@end

@interface SimpleClassWithString : SimpleClass
@property (assign) NSString *myString;
@end

@implementation SimpleClassWithString
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _myString = [aDecoder decodeObjectForKey:@"string"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_myString forKey:@"string"];
}
@end

@interface SimpleClassWithCString : SimpleClass
@property char *myString;
@end

@implementation SimpleClassWithCString

- (id) initWithCString:(char *)str
{
    self = [super init];
    if (self)
    {
        if (str)
        {
            _myString = malloc(strlen(str) + 1);
            strcpy(_myString, str);
        }
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        NSUInteger len;
        _myString = (char *)[aDecoder decodeBytesForKey:@"string" returnedLength:&len];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    if (_myString)
    {
        [aCoder encodeBytes:(const uint8_t *)_myString length:strlen(_myString) + 1 forKey:@"string"];
    }
    else
    {
        [aCoder encodeBytes:nil length:0 forKey:@"string"];
    }
}
@end

#define kBestScore  @"bestScore"
#define kBestStars  @"bestStars"
#define kDetail1    @"detail1"
#define kDetail2    @"detail2"
#define kDetail3    @"detail3"

@interface FooBar : NSObject <NSCoding>
@property (nonatomic, readwrite) float bestScore;
- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;
@end

@implementation FooBar
@synthesize bestScore;
- (id)init {
    if ((self = [super init])) {
        self.bestScore = 100.0f;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        self.bestScore = [coder decodeFloatForKey:kBestScore];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeFloat:self.bestScore forKey:kBestScore];
}

@end

@interface FoundationTestKeyedCoderTest : NSObject <NSCoding>
@property (strong, nonatomic) NSString* objectString;
@property (strong, nonatomic) NSArray* objectArray;
@property (strong, nonatomic) NSValue* objectValue;
@property (strong, nonatomic) NSDictionary* objectDictionary;
@property (assign, nonatomic) void*     memory;
@property (assign, nonatomic) char*     cString;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) BOOL boolean;
@property (assign, nonatomic) short shortNumber;
@property (assign, nonatomic) NSUInteger memorySize;
@property (assign, nonatomic) NSInteger integerSigned;
@property (assign, nonatomic) float floatNumber;
@property (assign, nonatomic) double doubleNumber;
@end

@implementation FoundationTestKeyedCoderTest

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (nil != self) {
        self.objectString = [aDecoder decodeObjectForKey:@"objectString"];
        self.objectValue = [aDecoder decodeObjectForKey:@"objectValue"];
        self.objectArray = [aDecoder decodeObjectForKey:@"objectArray"];

        self.objectDictionary = [aDecoder decodeObjectForKey:@"objectDictionary"];
        self.memorySize = [aDecoder decodeIntegerForKey:@"memorySize"];
        self.integerSigned = [aDecoder decodeIntegerForKey:@"integerSigned"];
        self.shortNumber = [aDecoder decodeIntegerForKey:@"shortNumber"];

#if 0
        decodeCGRectForKey is in UIKit
        self.rect = [aDecoder decodeCGRectForKey:@"rect"];
#endif
        self.boolean = [aDecoder decodeBoolForKey:@"boolean"];
        self.memory = (void*)[aDecoder decodeBytesForKey:@"memory" returnedLength:&_memorySize];
        NSUInteger cStringSize = 0;
        self.cString = (char*)[aDecoder decodeBytesForKey:@"cString" returnedLength:&cStringSize];

        self.floatNumber = [aDecoder decodeFloatForKey:@"floatNumber"];
        self.doubleNumber = [aDecoder decodeDoubleForKey:@"doubleNumber"];
    }
    return self;
}

- (BOOL)isEqual:(FoundationTestKeyedCoderTest*)object
{
    if (self.objectString && ![self.objectString isEqual:object.objectString])
    {
        return NO;
    }
    if (self.objectValue && ![self.objectValue isEqual:object.objectValue])
    {
        return NO;
    }
    if (self.objectArray && ![self.objectArray isEqual:object.objectArray])
    {
        return NO;
    }
    if (self.memory && memcmp(self.memory, object.memory, self.memorySize) != 0)
    {
        return NO;
    }
    if (self.cString && strcmp(self.cString, object.cString) != 0)
    {
        return NO;
    }
    if (!(self.rect.origin.x == object.rect.origin.x && self.rect.origin.y == object.rect.origin.y &&
          self.rect.size.width == object.rect.size.width && self.rect.size.height == object.rect.size.height))
    {
        return NO;
    }
    if (self.boolean != object.boolean)
    {
        return NO;
    }
    if (self.shortNumber != object.shortNumber)
    {
        return NO;
    }
    if (self.memorySize != object.memorySize)
    {
        return NO;
    }
    if (self.integerSigned != object.integerSigned)
    {
        return NO;
    }
    if (self.floatNumber != object.floatNumber)
    {
        return NO;
    }
    if (self.doubleNumber != object.doubleNumber)
    {
        return NO;
    }

    return YES;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.objectString forKey:@"objectString"];
    [aCoder encodeObject:self.objectValue forKey:@"objectValue"];
    [aCoder encodeObject:self.objectArray forKey:@"objectArray"];
    [aCoder encodeObject:self.objectDictionary forKey:@"objectDictionary"];

    [aCoder encodeInteger:self.memorySize forKey:@"memorySize"];
    [aCoder encodeInteger:self.integerSigned forKey:@"integerSigned"];

    [aCoder encodeBytes:self.memory length:self.memorySize forKey:@"memory"];
    if (self.cString) [aCoder encodeBytes:(void*)self.cString length:strlen(self.cString) + 1 forKey:@"cString"];

#if 0
    // need UIKit
    [aCoder encodeCGRect:self.rect forKey:@"rect"];
#endif
    [aCoder encodeBool:self.boolean forKey:@"boolean"];

    [aCoder encodeInteger:self.shortNumber forKey:@"shortNumber"];
    [aCoder encodeFloat:self.floatNumber forKey:@"floatNumber"];
    [aCoder encodeDouble:self.doubleNumber forKey:@"doubleNumber"];
}

- (void)dealloc
{
    self.objectString = nil;
    self.objectArray = nil;
    self.objectDictionary = nil;
    self.objectValue = nil;

    [super dealloc];
}

@end

@interface GraphObject : NSObject <NSCoding> {
    NSMutableArray *children;
    GraphObject *parent;
}

@property (nonatomic, readonly) NSArray *children;

- (void)addChild:(GraphObject *)object;

@end

@implementation GraphObject

- (id)init
{
    self = [super init];
    if (self)
    {
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        children = [[coder decodeObjectForKey:@"children"] retain];
        parent = [coder decodeObjectForKey:@"parent"];
    }
    return self;
}

- (void)dealloc
{
    [children release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:children forKey:@"children"];
    [coder encodeObject:parent forKey:@"parent"];
}

- (void)addChild:(GraphObject *)object
{
    [children addObject:object];
    object->parent = self;
}

- (NSArray *)children
{
    return [[children copy] autorelease];
}

@end

@testcase(NSCoder)

#pragma mark - Class for coder

test(CoderVersion)
{
    NSCoder *coder = [[NSCoder alloc] init];
    testassert([coder systemVersion] == 1000);
    [coder release];
    return YES;
}

test(KeyedArchiverVersion)
{
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:[NSMutableData data]];
    testassert([archiver systemVersion] == 2000);
    [archiver release];
    return YES;
}

test(InternalClassForCoder)
{
    // These are the classes that will actually create some internal
    // subclass, and thus different class and classForCoder.
    NSArray *classes = @[
        [NSArray self],
        [NSAttributedString self],
        [NSCharacterSet self],
        [NSData self],
        [NSDate self],
        [NSDictionary self],
        [NSMutableArray self],
        [NSMutableData self],
        [NSMutableDictionary self],
        [NSMutableOrderedSet self],
        [NSMutableSet self],
        [NSMutableString self],
        [NSOrderedSet self],
        [NSSet self],
        [NSString self],
        [NSUUID self],
    ];

    for (Class class in classes)
    {
        id obj = [[[class alloc] init] autorelease];
        Class actualClass = [obj class];
        Class classForCoder = [obj classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    return YES;
}

test(ActualClassForCoder)
{
    // These are the classes that have the same class and classForCoder.
    NSArray *classes = @[
        [NSCountedSet self],
        [NSError self],
        [NSIndexSet self],
        [NSMutableIndexSet self],
        [NSObject self],
    ];

    for (Class class in classes)
    {
        id obj = [[[class alloc] init] autorelease];
        Class actualClass = [obj class];
        Class classForCoder = [obj classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder == actualClass);
    }

    return YES;
}

test(OtherClassForCoder)
{
    // These classes cannot be directly inited, and so are tested separately.

    {
        NSDecimalNumber *decimalNumber = [NSDecimalNumber one];

        Class class = [NSDecimalNumber self];
        Class actualClass = [decimalNumber class];
        Class classForCoder = [decimalNumber classForCoder];

        testassert(classForCoder != class);
        testassert(classForCoder != actualClass);
    }

    {
        NSLocale *locale = [NSLocale systemLocale];

        Class class = [NSLocale self];
        Class actualClass = [locale class];
        Class classForCoder = [locale classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSNotification *notification = [NSNotification notificationWithName:@"foo" object:@"bar"];

        Class class = [NSNotification self];
        Class actualClass = [notification class];
        Class classForCoder = [notification classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSNumber *number = [NSNumber numberWithInt:42];

        Class class = [NSNumber self];
        Class actualClass = [number class];
        Class classForCoder = [number classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSPort *port = [NSPort port];

        Class class = [NSPort self];
        Class actualClass = [port class];

        BOOL raised = NO;

        @try {
            [port classForCoder];
        }
        @catch (NSException *e) {
            raised = YES;
            testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        }

        testassert(raised);

        testassert(actualClass != class);
    }

    {
        NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];

        Class class = [NSTimeZone self];
        Class actualClass = [timeZone class];
        Class classForCoder = [timeZone classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    {
        NSValue *value = [NSValue valueWithRange:NSMakeRange(23, 42)];

        Class class = [NSValue self];
        Class actualClass = [value class];
        Class classForCoder = [value classForCoder];

        testassert(classForCoder == class);
        testassert(classForCoder != actualClass);
    }

    return YES;
}


#pragma mark - Supported classes

- (NSArray *)NSCodingSupportedClassesWithoutCGPoint
{
    return @[
             [^(){ return [NSDictionary new]; } copy],
             [^(){ return [NSArray new]; } copy],
             [^(){ return [NSNull new]; } copy],
             [^(){ return [[NSNumber numberWithInt:1337] retain]; } copy],
             [^(){ return [NSString new]; } copy],
             [^(){ return [[NSDate date] retain]; } copy],
             ];
}

- (NSArray *)NSCodingSupportedClasses
{
    return @[
        [^(){ return [NSDictionary new]; } copy],
        [^(){ return [NSArray new]; } copy],
#if 0
        // need UIKit
        [^(){ return [[NSValue valueWithCGPoint:CGPointMake(13, 37)] retain]; } copy],
#endif
        [^(){ return [NSNull new]; } copy],
        [^(){ return [[NSNumber numberWithInt:1337] retain]; } copy],
        [^(){ return [NSString new]; } copy],
        [^(){ return [[NSDate date] retain]; } copy],
    ];
}

#pragma mark - Basic stuff

// Uncomment this to test decoding a mom file that's added to the main bundle.

//test(MomDecode)
//{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"DotsDataModel" ofType:@"bin"];
//    NSURL                *url = [NSURL fileURLWithPath:path];
//    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
//    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    testassert([unarchiver decodeObjectForKey:@"root"] != nil);
//
//    return YES;
//}

test(InitForWritingWithNil)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:nil forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 136);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id nil2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert(nil2 == nil);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNilXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:nil forKey:@"myKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id nil2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert(nil2 == nil);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNilXMLLength)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:nil forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 474);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id nil2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert(nil2 == nil);
    [unarchive finishDecoding];
    
    return YES;
}

test(EmptyArchive)
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:nil];
    testassert([objectEncoded length] == 135);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    return YES;
}

test(BasicObjectsNScodingIsImplemented)
{
    for (id (^c)(void) in [self NSCodingSupportedClasses])
    {
        id object = c();
        testassert([object respondsToSelector:@selector(initWithCoder:)]);
        testassert([object respondsToSelector:@selector(encodeWithCoder:)]);
        [object release];
    }
    return YES;
}

test(EmptyArchiveDecoded)
{
    NSData *objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:nil];
    NSKeyedUnarchiver *unarchive = [NSKeyedUnarchiver unarchiveObjectWithData:objectEncoded];
    testassert([unarchive decodeObjectForKey:@"alsfdj"] == nil);

    return YES;
}

test(InitForWritingWithMutableDataEmpty)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive finishEncoding];
    testassert([data length] == 124);
    const char *bytes = [data bytes];
//    0x08c45210: "bplist00\xffffffd4\x01\x02\x03\x04\x05\x06\b\tT$topX$objectsX$versionY$archiver\xffffffd0\xffffffa1\aU$null\x12"
//    0x08c4524d: "\x01\xffffff86\xffffffa0_\x10\x0fNSKeyedArchiver\b\x11\x16\x1f(235;@"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[15], "\b\tT$topX$objectsX$versionY$archiver", 35) == 0);
    testassert(strncmp(&bytes[67], "NSKeyedArchiver", 15) == 0);
    
    return YES;
}


test(InitForWritingWithMutableDataInt)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:123 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 136);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x10{\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 123);
    
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:123 forKey:@"myKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntBigger)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:30000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 137);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 30000);
    [unarchive finishDecoding];

    return YES;
}

test(InitForWritingWithMutableDataIntBiggerXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:30000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 437);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == 30000);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntMax)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:INT_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 139);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntMaxXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:INT_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 442);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntNegative)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:-5 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == -5);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntNegativeXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:-5 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 434);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == -5);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntMin)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt:INT_MIN forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MIN);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataIntMinXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt:INT_MIN forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 443);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeIntForKey:@"myKey"] == INT_MIN);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataBool)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBool:YES forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 135);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\t\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[59] == 9);
    testassert(strncmp(&bytes[76], "NSKeyedArchiver", 15) == 0);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeBoolForKey:@"myKey"]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataBoolXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBool:YES forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 420);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeBoolForKey:@"myKey"]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataBytes)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:10 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 145);
    const char *bytes = [data bytes];
//  "bplist00\xffffffd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xffffffd1\x06\aUmyKeyJabcdefghij\xffffffa1\tU$null\x12"
//  "\x01\xffffff86\xffffffa0_\x10\x0fNSKeyedArchiver\b
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKeyJabcdefghij", 18) == 0);
    testassert(strncmp(&bytes[86], "NSKeyedArchiver", 15) == 0);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 10);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataBytesXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:10 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 448);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 10);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithMutableDataBytes15)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:15 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 152);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 15);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];

    return YES;
}


test(InitForWritingWithMutableDataBytes15XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmop" length:15 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 452);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 15);
    testassert(strncmp((const char *)decodeBytes,  "abcdefghijklmop", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithMutableDataBytesLong)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 162);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithMutableDataBytesLongXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 468);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataDouble)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeDouble:-91.73 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey#\xc0V\xee\xb8Q\xeb\x85\x1f\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[59] == 35);
    testassert(bytes[61] == 86);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == -91.73);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataDoubleXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeDouble:-91.73 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 445);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == -91.73);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataFloat)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeFloat:3.14159f forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 139);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey"@I\x0f\xd0\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 64);
    testassert(bytes[62] == 15);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeFloatForKey:@"myKey"] == 3.14159f);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataFloatXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeFloat:3.14159f forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 444);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeFloatForKey:@"myKey"] == 3.14159f);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataInt32)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt32:-65000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x10{\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt32ForKey:@"myKey"] == -65000);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataInt32XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt32:-65000 forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 438);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt32ForKey:@"myKey"] == -65000);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataInt64)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeInt64:LONG_LONG_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 143);
    const char *bytes = [data bytes];
    // "bplist00\xd4\x01\x02\x03\x04\x05\b\n\vT$topX$objectsX$versionY$archiver\xd1\x06\aUmyKey\x13\x7f\xff\xff\xff\xff\xff\xff\xff\xa1\tU$null\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\n\vT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aUmyKey", 7) == 0);
    testassert(bytes[60] == 127);
    for (int i = 61; i <= 67; i++)
    {
        testassert((unsigned char)bytes[i] == 0xff);
    }

    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt64ForKey:@"myKey"] == LONG_LONG_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataInt64XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeInt64:LONG_LONG_MAX forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 451);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeInt64ForKey:@"myKey"] == LONG_LONG_MAX);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableMultiple)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeFloat:-30.5 forKey:@"floatKey"];
    [archive encodeInteger:987 forKey:@"integerKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == 0.0);
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 3.14);
    testassert([unarchive decodeFloatForKey:@"floatKey"] == -30.5);
    testassert([unarchive decodeIntegerForKey:@"integerKey"] == 987);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableMultipleXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeFloat:-30.5 forKey:@"floatKey"];
    [archive encodeInteger:987 forKey:@"integerKey"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"myKey"] == 0.0);
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 3.14);
    testassert([unarchive decodeFloatForKey:@"floatKey"] == -30.5);
    testassert([unarchive decodeIntegerForKey:@"integerKey"] == 987);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableOverwrite)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeDouble:9.5 forKey:@"doubleKey"];  // Should generate warning in log like
    // 2013-11-06 11:44:51.622 FoundationTests[98844:a0b] *** NSKeyedArchiver warning: replacing existing value for key 'doubleKey'; probable duplication of encoding keys in class hierarchy
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 9.5);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableOverwriteXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeDouble:3.14 forKey:@"doubleKey"];
    [archive encodeDouble:9.5 forKey:@"doubleKey"];  // Should generate warning in log like
    // 2013-11-06 11:44:51.622 FoundationTests[98844:a0b] *** NSKeyedArchiver warning: replacing existing value for key 'doubleKey'; probable duplication of encoding keys in class hierarchy
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive decodeDoubleForKey:@"doubleKey"] == 9.5);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataBytesTwiceLong)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 201);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    
    const uint8_t *decodeBytes2 = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes2, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);

    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithMutableDataBytesTwiceLongXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey"];
    [archive encodeBytes:(const uint8_t *)"abcdefghijklmopqrstuvwzyz" length:25 forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 546);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSUInteger returnedLength;
    const uint8_t *decodeBytes = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    
    const uint8_t *decodeBytes2 = [unarchive decodeBytesForKey:@"myKey" returnedLength:&returnedLength];
    testassert(returnedLength == 25);
    testassert(strncmp((const char *)decodeBytes2, "abcdefghijklmopqrstuvwzyz", returnedLength) == 0);
    
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithString)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSString *s = @"myString";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 147);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithStringXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSString *s = @"myString";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 502);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSpecialStringDollarNull)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSString *s = @"$null";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 235);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSpecialStringDollarNullXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSString *s = @"$null";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 235);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(EncodeValueOfCFBooleanType)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    [archive encodeObject:(id)kCFBooleanTrue forKey:@"boolTrue"];
    [archive encodeObject:(id)kCFBooleanFalse forKey:@"boolFalse"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    id boolTrue = [unarchive decodeObjectForKey:@"boolTrue"];
    id boolFalse = [unarchive decodeObjectForKey:@"boolFalse"];
    testassert([boolTrue isKindOfClass:objc_getClass("__NSCFBoolean")]);
    testassert([boolFalse isKindOfClass:objc_getClass("__NSCFBoolean")]);
    
    testassert(CFBooleanGetValue((CFBooleanRef)boolTrue));
    testassert(!CFBooleanGetValue((CFBooleanRef)boolFalse));
    return YES;
    
}

test(EncodeValueOfCFBooleanTypeXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:(id)kCFBooleanTrue forKey:@"boolTrue"];
    [archive encodeObject:(id)kCFBooleanFalse forKey:@"boolFalse"];
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    id boolTrue = [unarchive decodeObjectForKey:@"boolTrue"];
    id boolFalse = [unarchive decodeObjectForKey:@"boolFalse"];
    testassert([boolTrue isKindOfClass:objc_getClass("__NSCFBoolean")]);
    testassert([boolFalse isKindOfClass:objc_getClass("__NSCFBoolean")]);
    
    testassert(CFBooleanGetValue((CFBooleanRef)boolTrue));
    testassert(!CFBooleanGetValue((CFBooleanRef)boolFalse));
    return YES;
    
}

test(EncodeValueOfObjType1)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    char *s = "i";
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive finishEncoding];
    testassert([data length] == 137);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    testassert(strcmp(s, s2) == 0);
    [unarchive finishDecoding];
    
    return YES;
}

test(EncodeValueOfObjType1XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    char *s = "i";
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive finishEncoding];
    testassert([data length] == 492);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    testassert(strcmp(s, s2) == 0);
    [unarchive finishDecoding];
    
    return YES;
}


test(EncodeValueOfObjType2)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 133);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}

test(EncodeValueOfObjType2XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 432);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}

test(EncodeValueOfObjType3)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 146);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(strcmp(s, s2) == 0);
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}

test(EncodeValueOfObjType3XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    char *s = "i";
    int a = 0xdd;
    [archive encodeValueOfObjCType:"*" at:&s];
    [archive encodeValueOfObjCType:s at:&a];
    [archive finishEncoding];
    testassert([data length] == 533);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    char *s2;
    [unarchive decodeValueOfObjCType:"*" at:&s2];
    int a2;
    [unarchive decodeValueOfObjCType:s at:&a2];
    testassert(strcmp(s, s2) == 0);
    testassert(a2 == 0xdd);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithValue)
{
    static uint8_t bytes[] = {
        0x62, 0x70, 0x6c, 0x69, 0x73, 0x74, 0x30, 0x30,
        0xd4, 0x01, 0x02, 0x03, 0x04, 0x05, 0x08, 0x19,
        0x1a, 0x54, 0x24, 0x74, 0x6f, 0x70, 0x58, 0x24,
        0x6f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x73, 0x58,
        0x24, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e,
        0x59, 0x24, 0x61, 0x72, 0x63, 0x68, 0x69, 0x76,
        0x65, 0x72, 0xd1, 0x06, 0x07, 0x55, 0x6d, 0x79,
        0x4b, 0x65, 0x79, 0x80, 0x01, 0xa4, 0x09, 0x0a,
        0x11, 0x12, 0x55, 0x24, 0x6e, 0x75, 0x6c, 0x6c,
        0xd3, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x52,
        0x24, 0x31, 0x52, 0x24, 0x30, 0x56, 0x24, 0x63,
        0x6c, 0x61, 0x73, 0x73, 0x10, 0xee, 0x80, 0x02,
        0x80, 0x03, 0x51, 0x69, 0xd2, 0x13, 0x14, 0x15,
        0x18, 0x58, 0x24, 0x63, 0x6c, 0x61, 0x73, 0x73,
        0x65, 0x73, 0x5a, 0x24, 0x63, 0x6c, 0x61, 0x73,
        0x73, 0x6e, 0x61, 0x6d, 0x65, 0xa2, 0x16, 0x17,
        0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75, 0x65,
        0x58, 0x4e, 0x53, 0x4f, 0x62, 0x6a, 0x65, 0x63,
        0x74, 0x57, 0x4e, 0x53, 0x56, 0x61, 0x6c, 0x75,
        0x65, 0x12, 0x00, 0x01, 0x86, 0xa0, 0x5f, 0x10,
        0x0f, 0x4e, 0x53, 0x4b, 0x65, 0x79, 0x65, 0x64,
        0x41, 0x72, 0x63, 0x68, 0x69, 0x76, 0x65, 0x72,
        0x08, 0x11, 0x16, 0x1f, 0x28, 0x32, 0x35, 0x3b,
        0x3d, 0x42, 0x48, 0x4f, 0x52, 0x55, 0x5c, 0x5e,
        0x60, 0x62, 0x64, 0x69, 0x72, 0x7d, 0x80, 0x88,
        0x91, 0x99, 0x9e, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x1b, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xb0
    };

    static int foo = 0xee;
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSValue *v = [NSValue value:(const void *)&foo withObjCType:@encode(int)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 235);
    NSData *expectedData = [NSData dataWithBytes:bytes length:235];
    testassert([data isEqualToData:expectedData]);
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithValueXML)
{
    static int foo = 0xee;
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSValue *v = [NSValue value:(const void *)&foo withObjCType:@encode(int)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 908);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClass)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 231);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassXML)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 811);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}


test(SimpleClassContainsValueForKeyXML)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive containsValueForKey:@"myKey"]);
    testassert(![unarchive containsValueForKey:@"yourKey"]);
    
    return YES;
}

test(SimpleClassContainsValueForKey)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    testassert([unarchive containsValueForKey:@"myKey"]);
    testassert(![unarchive containsValueForKey:@"yourKey"]);
    
    return YES;
}

test(InitForWritingWithSimpleClassWithString)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is hereer";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 307);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is hereer"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithStringXML)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is hereer";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    //testassert([data length] == 307);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is hereer"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCString)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 290);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringXML)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    //testassert([data length] == 290);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringAutorelease)
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 290);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringAutoreleaseXML)
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:"abcdef"];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 924);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "abcdef") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringAutoreleaseEmpty)
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:""];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 284);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringAutoreleaseEmptyXML)
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:""];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 916);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(strcmp(obj2.myString, "") == 0);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringAutoreleaseNULL)
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:NULL];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 281);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(obj2.myString == NULL);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithCStringAutoreleaseNULLXML)
{
    NSMutableData *data = [NSMutableData data];
    @autoreleasepool {
        SimpleClassWithCString *obj = [[SimpleClassWithCString alloc] initWithCString:NULL];
        NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archive encodeObject:obj forKey:@"myKey"];
        testassert([obj didEncode]);
        [archive finishEncoding];
    }
    testassert([data length] == 913);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClassWithCString *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj2 a] == 123);
    testassert(obj2.myString == NULL);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassToFile)
{
    SimpleClass *obj = [[SimpleClass alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *saveFile = [documentsDirectory stringByAppendingPathComponent:@"testKeyedArchiver.bin"];
    
    [NSKeyedArchiver archiveRootObject:obj toFile:saveFile];
    
    SimpleClass *obj2 = [NSKeyedUnarchiver unarchiveObjectWithFile:saveFile];
    
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    
    return YES;
}

test(InitForWritingWithSameNSNumber)
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:num forKey:@"myKey"];
    [archive encodeObject:num forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 153);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    NSNumber *num3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([num2 intValue] == 123);
    testassert([num3 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithSameNSNumberXML)
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:num forKey:@"myKey"];
    [archive encodeObject:num forKey:@"myKey2"];
    [archive finishEncoding];
    testassert([data length] == 583);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    NSNumber *num3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([num2 intValue] == 123);
    testassert([num3 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithSimpleClassSame)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:obj forKey:@"myKey"];
    [archive encodeObject:obj forKey:@"myKey2"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 244);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    SimpleClass *obj3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    testassert([obj3 a] == 123);
    testassert([obj3 didDecode] == YES);
    testassert([obj3 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithSimpleClassSameXML)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClass *obj = [[SimpleClass alloc] init];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:obj forKey:@"myKey"];
    [archive encodeObject:obj forKey:@"myKey2"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 895);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    SimpleClass *obj2 = [unarchive decodeObjectForKey:@"myKey"];
    SimpleClass *obj3 = [unarchive decodeObjectForKey:@"myKey2"];
    testassert([obj2 a] == 123);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    testassert([obj3 a] == 123);
    testassert([obj3 didDecode] == YES);
    testassert([obj3 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithDictionary)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = @{};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 252);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithDictionaryXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = @{};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 840);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleDictionary3)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = @{@"myDictKey" : @"myValue", @"keyTwo" : @"valueTwo", @"keyThree" : @"valueThree"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 380);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleDictionary3XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = @{@"myDictKey" : @"myValue", @"keyTwo" : @"valueTwo", @"keyThree" : @"valueThree"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1462);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithSimpleDictionary)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = @{@"myDictKey" : @"myValue"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 282);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleDictionaryXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = @{@"myDictKey" : @"myValue"};
    [archive encodeObject:dict forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1062);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([dict isEqualToDictionary:dict2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithStringInDictionary)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is hereer";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:obj forKey:@"myDictKey"];
    [archive encodeObject:dict forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 455);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 =[unarchive decodeObjectForKey:@"myKey"];
    SimpleClassWithString *obj2 = [dict2 objectForKey:@"myDictKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is hereer"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleClassWithStringInDictionaryXML)
{
    NSMutableData *data = [NSMutableData data];
    SimpleClassWithString *obj = [[SimpleClassWithString alloc] init];
    obj.myString = @"apportable is hereer";
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:obj forKey:@"myDictKey"];
    [archive encodeObject:dict forKey:@"myKey"];
    testassert([obj didEncode]);
    [archive finishEncoding];
    testassert([data length] == 1554);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict2 =[unarchive decodeObjectForKey:@"myKey"];
    SimpleClassWithString *obj2 = [dict2 objectForKey:@"myDictKey"];
    testassert([obj2 a] == 123);
    testassert([obj2.myString isEqualToString:@"apportable is hereer"]);
    testassert([obj2 didDecode] == YES);
    testassert([obj2 didEncode] == NO);
    [unarchive finishDecoding];
    
    return YES;
}
#if 0
// need UIKit
test(InitForWritingWithValueCGSize)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSValue *v = [NSValue valueWithCGSize:CGSizeMake(1.1f, 2.2f)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 260);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithValueCGSizeXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSValue *v = [NSValue valueWithCGSize:CGSizeMake(1.1f, 2.2f)];
    [archive encodeObject:v forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 931);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *v2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([v2 isEqualToValue:v]);
    [unarchive finishDecoding];
    
    return YES;
}
#endif

test(InitForWritingWithArray)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSArray *a = @[@"one", @"two", @"three"];
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 261);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithArrayXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSArray *a = @[@"one", @"two", @"three"];
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1094);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSNull)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:[NSNull null] forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 211);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchive decodeObjectForKey:@"myKey"];
    testassert(obj == [NSNull null]);
    testassert(obj == [NSNull new]);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithNSNullXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:[NSNull null] forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 757);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id obj = [unarchive decodeObjectForKey:@"myKey"];
    testassert(obj == [NSNull null]);
    testassert(obj == [NSNull new]);
    [unarchive finishDecoding];
    
    return YES;
}

test(SimpleArchiveNumber)
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@123];
    testassert([objectEncoded length] == 139);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$null\x10{\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\v\fT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(bytes[70] == 123);
    return YES;
}

test(SimpleArchiveString)
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@"abcdefg"];
    testassert([objectEncoded length] == 145);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$nullWabcdefg\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\v\fT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(strncmp(&bytes[70], "abcdefg", 7) == 0);
    return YES;
}

test(SimpleArchiveNSDate)
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1387931403.0];
    NSData *objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:date];
    testassert([objectEncoded length] == 231);
    const char *bytes = [objectEncoded bytes];
    testassert(strncmp(bytes, "bplist00\xd4\x01\x02\x03\x04\x05", 14) == 0);
    testassert(strncmp(&bytes[14], "\x08\x16\x17T$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[50], "\xd1\x06\x07Troot\x80\x01\xa3\x09\x0a\x0fU$null", 20) == 0);
    testassert(strncmp(&bytes[70], "\xd2\x0b\x0c\x0d\x0eV$classWNS.time", 20) == 0);
    return YES;
}

test(InitForWritingWithStringNonAscii)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSString *s = @"myStß©∆¬ååœ∑ring";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 173);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithStringNonAsciiXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSString *s = @"myStß©∆¬ååœ∑ring";
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 173);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqualToString:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSNumber)
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 140);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSDate)
{
    NSMutableData *data = [NSMutableData data];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:131180400.0];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:date forKey:@"myDate"];
    [archive finishEncoding];
    testassert([data length] == 233);

    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDate *date2 = [unarchive decodeObjectForKey:@"myDate"];
    testassert([date2 timeIntervalSince1970] == 131180400.0);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSNumberXML)
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithInt:123];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 140);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 intValue] == 123);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSNumberReal)
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithDouble:1234567.5];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 147);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 doubleValue] == 1234567.5);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSNumberRealXML)
{
    NSMutableData *data = [NSMutableData data];
    NSNumber *num = [NSNumber numberWithDouble:1234567.5];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:num forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 147);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSNumber *num2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([num2 doubleValue] == 1234567.5);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSData)
{
    NSMutableData *data = [NSMutableData data];
    NSData *d = [NSData dataWithBytes:"abc" length:3];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive encodeObject:d forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 142);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSData *d2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([d isEqualToData:d2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNSDataXML)
{
    NSMutableData *data = [NSMutableData data];
    NSData *d = [NSData dataWithBytes:"abc" length:3];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archive encodeObject:d forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 500);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSData *d2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([d isEqualToData:d2]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithNestedArray)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSArray *a = [NSArray arrayWithObjects:@[@170, @187], nil];  // 0xaa 0xbb
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 261);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}


test(InitForWritingWithNestedArrayXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSArray *a = [NSArray arrayWithObjects:@[@170, @187], nil];  // 0xaa 0xbb
    [archive encodeObject:a forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1229);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *a2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([a2 isEqualToArray:a]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleSet)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSSet *s = [NSSet setWithObjects:@"abc", @"xyz", nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 245);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSimpleSetXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSSet *s = [NSSet setWithObjects:@"abc", @"xyz", nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 993);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSet)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSSet *s = [NSSet setWithObjects:@1, @"abc", @[@3, @4], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 314);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSetXML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSSet *s = [NSSet setWithObjects:@1, @"abc", @[@3, @4], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 1588);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSValue *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSet2)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    NSSet *s = [NSSet setWithObjects:@[@7, @9], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 296);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSSet *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(InitForWritingWithSet2XML)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archive setOutputFormat:NSPropertyListXMLFormat_v1_0];
    NSSet *s = [NSSet setWithObjects:@[@7, @9], nil];
    [archive encodeObject:s forKey:@"myKey"];
    [archive finishEncoding];
    //testassert([data length] == 296);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSSet *s2 = [unarchive decodeObjectForKey:@"myKey"];
    testassert([s2 isEqual:s]);
    [unarchive finishDecoding];
    
    return YES;
}

test(SimpleArchiveArray)
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@[ @4, @5, @6]];
    testassert([objectEncoded length] == 252);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$nullWabcdefg\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[14], "\b\x1c\x1dT$topX$objectsX$versionY$archiver", 36) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(strncmp(&bytes[80], "classZNS.objects", 16) == 0);
    testassert(strncmp(&bytes[119], "X$classesZ$classname", 20) == 0);
    testassert(strncmp(&bytes[142], "WNSArrayXNSObjectWNSArray", 25) == 0);
    testassert(bytes[109] == 4);
    testassert(bytes[111] == 5);
    testassert(bytes[113] == 6);
    return YES;
}

test(SimpleArchiveDictionary)
{
    NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:@{ @"abc": @4, @"def": @9}];
    testassert([objectEncoded length] == 287);
    const char *bytes = [objectEncoded bytes];
    // should be "bplist00\xd4\x01\x02\x03\x04\x05\b\v\fT$topX$objectsX$versionY$archiver\xd1\x06\aTroot\x80\x01\xa2\t\nU$nullWabcdefg\x12"
    testassert(strncmp(bytes, "bplist00", 8) == 0);
    testassert(strncmp(&bytes[17], "T$topX$objectsX$versionY$archiver", 33) == 0);
    testassert(strncmp(&bytes[52], "\aTroot", 6) == 0);
    testassert(strncmp(&bytes[81], "ZNS.objectsV$classWNS.keys", 25) == 0);
    testassert(strncmp(&bytes[123], "SabcSdef", 8) == 0);
    testassert(strncmp(&bytes[140], "X$classesZ$classname", 20) == 0);
    testassert(strncmp(&bytes[164], "NSDictionaryXNSObject", 21) == 0);
    testassert(bytes[132] == 4);
    testassert(bytes[134] == 9);
    return YES;
}

test(BasicObjectsEncodeDecodeWithoutCGPoint)
{
    for (id (^c)(void) in [self NSCodingSupportedClassesWithoutCGPoint])
    {
        id object = c();
        NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:object];
        testassert(objectEncoded != nil);
        id objectDecoded = [NSKeyedUnarchiver unarchiveObjectWithData:objectEncoded];
        testassert(objectDecoded != nil);
        
        testassert([object isEqual:objectDecoded]);
        
        [object release];
    }
    return YES;
}

#if 0
test(BasicObjectsEncodeDecode)
{
    for (id (^c)(void) in [self NSCodingSupportedClasses])
    {
        id object = c();
        NSData* objectEncoded = [NSKeyedArchiver archivedDataWithRootObject:object];
        testassert(objectEncoded != nil);
        id objectDecoded = [NSKeyedUnarchiver unarchiveObjectWithData:objectEncoded];
        testassert(objectDecoded != nil);

        testassert([object isEqual:objectDecoded]);

        [object release];
    }
    return YES;
}

test(InitForWritingWithNullString)
{
    NSMutableData *data = [NSMutableData data];
    
    FoundationTestKeyedCoderTest *obj = [FoundationTestKeyedCoderTest new];
    obj.cString = "sdfgsdfg";
    
    NSKeyedArchiver *archive = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    [archive encodeObject:obj forKey:@"myKey"];
    [archive finishEncoding];
    testassert([data length] == 558);
    
    NSKeyedUnarchiver *unarchive = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    FoundationTestKeyedCoderTest *decodedObject = [unarchive decodeObjectForKey:@"myKey"];
    testassert([obj isEqual:decodedObject]);
    [unarchive finishDecoding];
    
    return YES;
}

test(EncodeDecodeOfDifferentTypes0)
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectString = @"apportable is here";
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    testassert([data length] == 557);
    FoundationTestKeyedCoderTest* decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([obj isEqual:decodedObject]);
    free(obj.memory);
    [obj release];
    return YES;
}

TODO remove UIKIt dependency

test(EncodeDecodeOfDifferentTypes1)
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectString = @"apportable is here";
    obj.objectDictionary = @{@"hello": @(12345)};
    obj.objectArray = @[@"1", @(2), @{@"hello": @(12345)}];
    obj.memorySize = 1024;
    obj.memory = malloc(obj.memorySize);
    obj.cString = "sdfgsdfg";
    obj.rect = CGRectMake(1, 2, 1024, 512);
    obj.doubleNumber = 123234534.045f;
    obj.floatNumber = 1234.12f;
    obj.integerSigned = 10000;
    obj.shortNumber = 127;
    obj.boolean = YES;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    FoundationTestKeyedCoderTest* decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    testassert([obj isEqual:decodedObject]);
    free(obj.memory);
    [obj release];
    return YES;
}

test(EncodeDecodeOfDifferentTypes2)
{
    FoundationTestKeyedCoderTest* obj = [FoundationTestKeyedCoderTest new];
    obj.objectValue = [NSValue valueWithCGSize:(CGSize){100, 500}];

    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    FoundationTestKeyedCoderTest* decodedObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    testassert([obj isEqual:decodedObject]);
    free(obj.memory);
    [obj release];
    return YES;
}
#endif

test(RoundTripChar)
{
    char val = 'A';
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(char) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    char dval = '\0';
    [decoder decodeValueOfObjCType:@encode(char) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripUnsignedChar)
{
    unsigned char val = 5;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned char) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned char dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned char) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripShort)
{
    short val = 888;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(short) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    short dval = 0;
    [decoder decodeValueOfObjCType:@encode(short) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripUnsignedShort)
{
    unsigned short val = -888;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned short) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned short dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned short) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripInt)
{
    int val = -383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(int) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    int dval = 0;
    [decoder decodeValueOfObjCType:@encode(int) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripUnsignedInt)
{
    unsigned int val = 383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned int dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned int) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripLong)
{
    long val = -383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    long dval = 0;
    [decoder decodeValueOfObjCType:@encode(long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripUnsignedLong)
{
    unsigned long val = 383838383;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned long dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripLongLong)
{
    long long val = -3838383383383838383LL;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(long long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    long long dval = 0;
    [decoder decodeValueOfObjCType:@encode(long long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(RoundTripUnsignedLongLong)
{
    unsigned long long val = 3838388383383838383ULL;
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [coder encodeValueOfObjCType:@encode(unsigned long long) at:&val];
    [coder finishEncoding];
    [coder release];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [data release];
    unsigned long long dval = 0;
    [decoder decodeValueOfObjCType:@encode(unsigned long long) at:&dval];
    [decoder finishDecoding];
    [decoder release];
    testassert(val == dval);
    return YES;
}

test(NilData)
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData:nil];
    testassert(obj == nil);
    return YES;
}

test(NilData2)
{
    NSKeyedUnarchiver *archiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:nil];
    testassert(archiver == nil);
    return YES;
}

test(NilPath)
{
    id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:nil];
    testassert(obj == nil);
    return YES;
}

test(Graph)
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    GraphObject *a = [[GraphObject alloc] init];
    GraphObject *b = [[GraphObject alloc] init];
    GraphObject *c = [[GraphObject alloc] init];
    GraphObject *d = [[GraphObject alloc] init];
    [a addChild:b];
    [a addChild:c];
    [a addChild:d];
    [b release];
    [c release];
    [d release];
    [archiver encodeObject:a forKey:@"root"];
    [a release];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GraphObject *root = [unarchiver decodeObjectForKey:@"root"];
    [unarchiver finishDecoding];
    testassert([[root children] count] == 3);
    [unarchiver release];
    [archiver release];
    return YES;
}

test(ArchiveLargeKeySize)
{
    const int iters = 253;
    NSMutableArray* foobars = [NSMutableArray arrayWithCapacity:iters];
    for (int i = 0; i < iters; i++) {
        FooBar* foobar = [[[FooBar alloc] init] autorelease];
        [foobars addObject:foobar];
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    testassert([data length] == 0); // precondition!
    [archiver encodeObject:foobars forKey:@"Archive"];
    [archiver finishEncoding];
    [archiver release];
    testassert([data length] > 0);
    [data release];
    return YES;
}

#pragma mark - Nested structures

#pragma mark - Corner cases

@end
