//
//  NSJSONSerializationTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSJSONSerialization)

test(CreatingDataFromJSONObject1)
{
    NSData *someData = [NSJSONSerialization dataWithJSONObject:@{@"someKey": @"someValue"} options:0 error:nil];
    testassert(someData != nil);
    return YES;
}

test(CreatingDataFromJSONObject2)
{
    NSDictionary* msg = @{
                          @"type" : @"STATEBROADCAST",
                          @"currentState" : @"LoadingJson",
                          @"context" : [NSNull null],
                          @"fullURI" : @"stack://LoadingJson",
                          @"source"  : @"pushState",
                          };
    NSError *error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:&error];
    testassert(error == nil);
    testassert(data != nil);
    
    return YES;
}

test(EscapedCharacters)
{
    NSString *str = @"{\"jsonData\": \"{\\\"stuff\\\": [{\\\"id\\\": 1234}],}\"}";
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    testassert(json != nil);
    return YES;
}

test(FailingAtCreatingAJSONObjectAndPassingANilError1)
{
    NSData *someData = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:nil];
    testassert(json == nil);
    return YES;
}

test(FailingAtCreatingAJSONObjectAndPassingAnError)
{
    NSError *error = nil;
    NSData *someData = [@"true" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:&error];
    testassert(json == nil);
    testassert(error != nil);
    testassert(error.domain == NSCocoaErrorDomain);
    return YES;
}

test(SuccessAtCreatingASimpleJSONObject)
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *someData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:nil];
    testassert(json != nil);
    NSArray *keys = [json allKeys];
    testassert([keys containsObject:@"decimals"]);
    testassert([keys containsObject:@"number"]);
    testassert([keys containsObject:@"hello"]);
    testassert([keys containsObject:@"dictionary"]);
    testassert([keys containsObject:@"key"]);
    
    return YES;
}

test(SuccessAtCreatingJSONWithCrazyCharacters)
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"SpecialCharactersJSONTest" ofType:@"json"];
    NSData *someData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:someData options:0 error:nil];
    testassert(json != nil);
    NSArray *keys = [json allKeys];
    testassert([keys containsObject:@"crazyCharacters"]);
    NSString *theString = [json objectForKey:@"crazyCharacters"];
    testassert([theString isEqualToString:@"Hello,\n“foo bar.”\n"]);
    
    return YES;
}

test(DictionaryWithStringWithEscaptedCharacters)
{
    NSString *theKey = @"source";
    NSString *theValue = @"\u0040<a href=\"http://google.com/something\" rel=\"nofollow\">Hello</a>";
    NSDictionary *theDict = @{theKey : theValue};
    NSData *data = [NSJSONSerialization dataWithJSONObject:theDict options:0 error:nil];
    testassert(data != nil);
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *resultValue = [result objectForKey:theKey];
    
    testassert(result != nil);
    testassert([resultValue isEqualToString:theValue]);
    return YES;
}

test(DictionaryWithStringWithEscaptedCharacters2)
{
    NSString *theKey = @"source";
    NSString *theValue = @"\u0040hello \n world \r Hello \b world \f Hello \t";
    NSDictionary *theDict = @{theKey : theValue};
    NSData *data = [NSJSONSerialization dataWithJSONObject:theDict options:0 error:nil];
    testassert(data != nil);
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *resultValue = [result objectForKey:theKey];
    
    testassert(result != nil);
    testassert([resultValue isEqualToString:theValue]);
    return YES;
}

test(EscapedUnicodeCharacter)
{
    unsigned char expectedArchiveBytes[] = {
        0x7b, 0x22, 0x65, 0x6d, 0x61, 0x69, 0x6c, 0x22, 0x3a, 0x22, 0x65, 0x6d, 0x61, 0x69, 0x6c, 0x5c,
        0x75, 0x30, 0x30, 0x34, 0x30, 0x67, 0x6d, 0x61, 0x69, 0x6c, 0x2e, 0x63, 0x6f, 0x6d, 0x22, 0x7d
    };
    NSData *data = [NSData dataWithBytes:expectedArchiveBytes length:sizeof(expectedArchiveBytes)];
    testassert(data != nil);
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    testassert(json != nil);
    return YES;
}

test(GeneralDataSerialization)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSDictionary *dict2 = @{@"obj1" : @"value1", @"obj2" : @"value2"};
    NSArray *arr1 = @[@"obj1value1", @"obj2value2", @"obj3value3"];
    BOOL boolYes = YES;
    int16_t int16 = 12345;
    int32_t int32 = 2134567890;
    uint32_t uint32 = 3124141341;
    unsigned long long ull = 312414134131241413ull;
    double dlrep = 1.5;
    double dlmayrep = 1.123456789101112;
    float fl = 3124134134678.13;
    double dl = 13421331.72348729 * 1000000000000000000000000000000000000000000000000000.0;
    long long negLong = -632414314135135234;
    unsigned long long unrepresentable = 10765432100123457789ull;

    dict[@"dict"] = dict2;
    dict[@"arr"] = arr1;
    dict[@"bool"] = @(boolYes);
    dict[@"int16"] = @(int16);
    dict[@"int32"] = @(int32);
    dict[@"dlrep"] = @(dlrep);
    dict[@"dlmayrep"] = @(dlmayrep);
    dict[@"fl"] = @(fl);
    dict[@"dl"] = @(dl);
    dict[@"uint32"] = @(uint32);
    dict[@"ull"] = @(ull);
    dict[@"negLong"] = @(negLong);
    dict[@"unrepresentable"] = @(unrepresentable);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    testassert(data != nil);
    
    NSDictionary *dict_back = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:nil];
    
    testassert(dict_back != nil);
    testassert(![dict_back isEqualToDictionary:dict]);
    testassert(([(NSNumber *)dict_back[@"bool"] boolValue] == boolYes));
    testassert(([[(NSNumber *)dict_back[@"bool"] stringValue] isEqualToString:@"1"]));
    testassert(([(NSNumber *)dict_back[@"int16"] intValue] == int16));
    testassert(([(NSNumber *)dict_back[@"int32"] intValue] == int32));
    testassert(([(NSNumber *)dict_back[@"uint32"] intValue] == uint32));
    testassert(([(NSNumber *)dict_back[@"ull"] unsignedLongLongValue] == ull));
    testassert(abs([(NSNumber *)dict_back[@"fl"] floatValue] - fl) < (fl/100000.0));
    testassert(abs([(NSNumber *)dict_back[@"dl"] doubleValue] - dl) < (dl/1000000000.0));
    testassert([(NSNumber *)dict_back[@"dlrep"] doubleValue] == dlrep);
    testassert([(NSNumber *)dict_back[@"dlmayrep"] doubleValue] == dlmayrep);
    testassert(([(NSNumber *)dict_back[@"negLong"] longLongValue] == negLong));
#if defined(__IPHONE_8_0)
    testassert([(NSNumber *)dict_back[@"unrepresentable"] unsignedLongLongValue] == unrepresentable);
#else
    testassert([(NSNumber *)dict_back[@"unrepresentable"] unsignedLongLongValue] != unrepresentable);
#endif
    return YES;
}

test(EmptyArray)
{
    NSString *str = @"{\"test\":[]}";
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    testassert([dict objectForKey:@"test"] != nil);
    testassert([[dict objectForKey:@"test"] count] == 0);
    return YES;
}

test(EmptyDict)
{
    NSString *str = @"{\"test\":{}}";
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    testassert([dict objectForKey:@"test"] != nil);
    testassert([[dict objectForKey:@"test"] count] == 0);
    return YES;
}

test(NumberParsing)
{
#ifdef APPORTABLE
#warning Remove this when NSDecimalNumber doubleValue is more accurate
#endif
#define EPSILON 0.000000001
    NSString *str = @"{ \"values\" : [42, 3.14, 1.23456 ]}";
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSArray *numbers = dict[@"values"];
    testassert(abs([numbers[0] doubleValue] - 42.0) < EPSILON);
    testassert(abs([numbers[1] doubleValue] - 3.14) < EPSILON);
    testassert(abs([numbers[2] doubleValue] - 1.23456) < EPSILON);
    return YES;
}

test(TrueRootObject)
{
    NSString *str = @"true";
    NSError *error = nil;
    NSNumber *t = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    testassert(t == nil);
    testassert(error != nil);
    return YES;
}

test(TrueRootFragment)
{
    NSString *str = @"true";
    NSError *error = nil;
    NSNumber *t = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    testassert(t != nil);
    testassert(error == nil);
    testassert([t isEqualToNumber:@YES]);
    testassert(t == (id)kCFBooleanTrue);
    return YES;
}

@end
