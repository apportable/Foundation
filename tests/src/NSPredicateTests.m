//
//  NSPredicateTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface Person : NSObject
@property (copy) NSString *firstName;
@property (copy) NSString *lastName;
@property (retain) NSNumber *age;
@property (retain) NSString *like;
@end

@implementation Person

+(Person*)personWithAge:(int)age
{
    Person *person = [[Person new] autorelease];
    person.age = @(age);
    return person;
}

-(BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[Person class]])
        return NO;
    
    Person *other = (Person*)object;
 
    return
        ((!self.firstName && !other.firstName) || [self.firstName isEqualToString:other.firstName]) &&
        ((!self.lastName && !other.lastName) || [self.lastName isEqualToString:other.lastName]) &&
        ((!self.age && !other.age) || [self.age isEqualToNumber:other.age]) &&
        ((!self.like && !other.like) || [self.like isEqualToString:other.like]);
}

- (NSUInteger)hash
{
    return self.firstName.hash ^ self.lastName.hash ^ self.age.hash ^ self.like.hash;
}

-(void)dealloc
{
    self.firstName = nil;
    self.lastName = nil;
    self.age = nil;
    self.like = nil;
    
    [super dealloc];
}

@end

@testcase(NSPredicate)

test(BlockPredicateEvaluation)
{
    __block BOOL blockExecuted = NO;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"foo", @"bar", nil];
    Class cls = [dict class];
    NSPredicate *blockPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        testassert(bindings == dict);
        testassert([bindings class] == cls);
        [(NSMutableDictionary *)bindings setObject:@"test" forKey:@"test"];
        blockExecuted = YES;
        return YES;
    }];
    testassert(blockPredicate != nil);
    
    BOOL evaluated = [blockPredicate evaluateWithObject:@"foo" substitutionVariables:dict];
    testassert(evaluated);
    testassert(blockExecuted);
    testassert([dict count] == 2);
    return YES;
}

test(EqualsPredicate)
{
    NSPredicate *singleEquals = [NSPredicate predicateWithFormat:@"self = 'Hello'"];
    testassert([singleEquals evaluateWithObject:@"Hello"]);
    testassert(![singleEquals evaluateWithObject:@"He"]);
    
    NSPredicate *doubleEquals = [NSPredicate predicateWithFormat:@"self == \"Goodbye\""];
    testassert([doubleEquals evaluateWithObject:@"Goodbye"]);
    testassert(![doubleEquals evaluateWithObject:@"goodbye"]);
    
    return YES;
}

test(LessThanOrEqualsPredicate)
{
    NSPredicate *lessThanOrEqual = [NSPredicate predicateWithFormat:@"self <= 123"];
    testassert([lessThanOrEqual evaluateWithObject:@(123)]);
    testassert([lessThanOrEqual evaluateWithObject:@(-123)]);
    testassert(![lessThanOrEqual evaluateWithObject:@(123.00001)]);
    
    NSPredicate *equalOrLessThan = [NSPredicate predicateWithFormat:@"self =< 'abc'"];
    testassert([equalOrLessThan evaluateWithObject:@""]);
    testassert([equalOrLessThan evaluateWithObject:@"abc"]);
    testassert([equalOrLessThan evaluateWithObject:@"ABC"]);
    testassert([equalOrLessThan evaluateWithObject:@"XYZ"]);
    testassert([equalOrLessThan evaluateWithObject:@"123"]);
    testassert([equalOrLessThan evaluateWithObject:@"aabbcc"]);
    testassert(![equalOrLessThan evaluateWithObject:@"abcd"]);
    testassert(![equalOrLessThan evaluateWithObject:@"acb"]);
    testassert(![equalOrLessThan evaluateWithObject:@"b"]);
    
    return YES;
}

test(GreaterThanOrEqualsPredicate)
{
    NSPredicate *greatherThanOrEqual = [NSPredicate predicateWithFormat:@"self >= 0"];
    testassert([greatherThanOrEqual evaluateWithObject:@(NO)]);
    testassert([greatherThanOrEqual evaluateWithObject:@(YES)]);
    testassert([greatherThanOrEqual evaluateWithObject:@(1)]);
    testassert(![greatherThanOrEqual evaluateWithObject:@(-1)]);
    
    NSPredicate *equalOrGreaterThan = [NSPredicate predicateWithFormat:@"self => 'x z'"];
    testassert([equalOrGreaterThan evaluateWithObject:@"x z"]);
    testassert([equalOrGreaterThan evaluateWithObject:@"xyz"]);
    testassert([equalOrGreaterThan evaluateWithObject:@"xz"]);
    testassert(![equalOrGreaterThan evaluateWithObject:@""]);
    testassert(![equalOrGreaterThan evaluateWithObject:@"x Z"]);
    
    return YES;
}

test(LessThanPredicate)
{
    NSPredicate *lessThanFloat = [NSPredicate predicateWithFormat:@"SeLf < 1.0"];
    testassert([lessThanFloat evaluateWithObject:@(0.9999)]);
    testassert(![lessThanFloat evaluateWithObject:@(1)]);
    
    NSPredicate *lessThanString = [NSPredicate predicateWithFormat:@"SELF < %@", @"1"];
    testassert([lessThanString evaluateWithObject:@"01"]);
    testassert(![lessThanString evaluateWithObject:@"2"]);
    
    return YES;
}

test(GreaterThanPredicate)
{
    NSPredicate *greaterThanMinusOne = [NSPredicate predicateWithFormat:@"self>-1"];
    testassert([greaterThanMinusOne evaluateWithObject:@(0)]);
    testassert(![greaterThanMinusOne evaluateWithObject:0]);
    
    NSPredicate *greaterThanEmptyString = [NSPredicate predicateWithFormat:@"self > ''"];
    testassert([greaterThanEmptyString evaluateWithObject:@" "]);
    testassert(![greaterThanEmptyString evaluateWithObject:@""]);
    testassert(![greaterThanEmptyString evaluateWithObject:nil]);
    
    return YES;
}

test(NotEqualPredicate)
{
    NSPredicate *notEqual = [NSPredicate predicateWithFormat:@"self != NO"];
    testassert([notEqual evaluateWithObject:@(YES)]);
    testassert([notEqual evaluateWithObject:@""]);
    testassert(![notEqual evaluateWithObject:@(0)]);
    
    NSPredicate *lessThanAndGreaterThan = [NSPredicate predicateWithFormat:@"self <> 42"];
    testassert([lessThanAndGreaterThan evaluateWithObject:@"42"]);
    testassert(![lessThanAndGreaterThan evaluateWithObject:@(42)]);
    
    return YES;
}

test(QuestionMark)
{
    BOOL thrown = NO;
    @try {
        [NSPredicate predicateWithFormat:@"? = 'ABC'"];
    } @catch (NSException *e) {
        thrown = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }
    testassert(thrown);
    return YES;
}

test(Whitespace)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"\tself =\n123\n"];
    testassert([predicate evaluateWithObject:@(123)]);
    
    return YES;
}

test(NilObject)
{
    NSPredicate *matchNil = [NSPredicate predicateWithFormat:@"self == NiL"];
    testassert([matchNil evaluateWithObject:nil]);
    
    NSPredicate *evaluateNil = [NSPredicate predicateWithFormat:@"self like 'nil'"];
    testassert(![evaluateNil evaluateWithObject:nil]);
    
    return YES;
}

test(QuotedSubstitution)
{
    NSPredicate *doubleQuotedLiteral = [NSPredicate predicateWithFormat:@"self = \"%@\"", @"G'day mate"];
    testassert(![doubleQuotedLiteral evaluateWithObject:@"G'day mate"]);
    
    NSPredicate *singleQuotedLiteral = [NSPredicate predicateWithFormat:@"self == '%@'", @"Toodle pip!"];
    testassert([singleQuotedLiteral evaluateWithObject:@"%@"]);
    
    return YES;
}

test(FormatWithValue)
{
    NSPredicate *truthy = [NSPredicate predicateWithFormat:@"truePredicate"];
    testassert([truthy evaluateWithObject:@"ABC"]);
    testassert([truthy evaluateWithObject:nil]);
    testassert(truthy == [NSPredicate predicateWithValue:YES]);
    
    NSPredicate *falsy = [NSPredicate predicateWithFormat:@"FALSEpredicate"];
    testassert(![falsy evaluateWithObject:@"XYZ"]);
    testassert(![falsy evaluateWithObject:falsy]);
    testassert(falsy == [NSPredicate predicateWithValue:NO]);
    
    return YES;
}

test(PredicateWithValue)
{
    NSPredicate *truthy = [NSPredicate predicateWithValue:YES];
    testassert([truthy evaluateWithObject:@(YES)]);
    testassert([truthy class] == NSClassFromString(@"NSTruePredicate"));
    
    NSPredicate *falsy = [NSPredicate predicateWithValue:NO];
    testassert([truthy evaluateWithObject:@(NO)]);
    testassert([falsy class] == NSClassFromString(@"NSFalsePredicate"));
    
    return YES;
}

test(BinaryOperatorPredicate)
{
    NSPredicate *add = [NSPredicate predicateWithFormat:@"self + %d = 42", 2];
    testassert([add evaluateWithObject:@(40.0)]);
    testassert(![add evaluateWithObject:@(-2)]);
    
    NSPredicate *minus = [NSPredicate predicateWithFormat:@"self == 70 - 28"];
    testassert([minus evaluateWithObject:@(42)]);
    testassert(![minus evaluateWithObject:@(70)]);
    
    NSPredicate *divide = [NSPredicate predicateWithFormat:@"(self + 21) / 42.0 > 1"];
    testassert([divide evaluateWithObject:@(42)]);
    testassert(![divide evaluateWithObject:@(21)]);
    
    NSPredicate *multiply = [NSPredicate predicateWithFormat:@"(self / 2) * 2 <> self"];
    testassert([multiply evaluateWithObject:@(41)]);
    testassert(![multiply evaluateWithObject:@(42)]);
    
    NSPredicate *power = [NSPredicate predicateWithFormat:@"(self) ** 2 * 2 = 72"];
    testassert([power evaluateWithObject:@(6)]);
    testassert(![power evaluateWithObject:@(pow(72, 0.25))]);
    
    return YES;
}

test(AndOperatorPredicate)
{
    NSPredicate *and = [NSPredicate predicateWithFormat:@"%d < 42 aNd 42 < self", 0];
    testassert([and evaluateWithObject:@(69)]);
    testassert(![and evaluateWithObject:nil]);
    
    NSPredicate *doubleAmp = [NSPredicate predicateWithFormat:@"'abc' =< self && self <= 'xyz'"];
    testassert([doubleAmp evaluateWithObject:@"sbj"]);
    testassert(![doubleAmp evaluateWithObject:@"abC"]);
    
    return YES;
}

test(OrOperatorPredicate)
{
    NSPredicate *or = [NSPredicate predicateWithFormat:@"self == 'cat' or self != 'dog'"];
    testassert([or evaluateWithObject:@"fish"]);
    testassert(![or evaluateWithObject:@"dog"]);
    
    NSPredicate *doublePipe = [NSPredicate predicateWithFormat:@"self == nil or (self <> 'S' and self <> 'L')"];
    testassert([doublePipe evaluateWithObject:@"M"]);
    testassert([doublePipe evaluateWithObject:nil]);
    testassert(![doublePipe evaluateWithObject:@"S"]);
    
    return YES;
}

test(NotOperatorPrediate)
{
    NSPredicate *not = [NSPredicate predicateWithFormat:@"NOT self != 42"];
    testassert([not evaluateWithObject:@(42)]);
    testassert(![not evaluateWithObject:nil]);
    
    NSPredicate *exclamation = [NSPredicate predicateWithFormat:@"!(YES == self or \"YES\" == self or 42 == self)"];
    testassert([exclamation evaluateWithObject:@(FALSE)]);
    testassert([exclamation evaluateWithObject:@"TRUE"]);
    testassert(![exclamation evaluateWithObject:@(1)]);
    
    return YES;
}

test(MultipleOperatorPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self = 'abc' or not self = 'xyz' and self != '123'"];
    testassert([predicate evaluateWithObject:@"abc"]);
    testassert([predicate evaluateWithObject:@(123)]);
    testassert([predicate evaluateWithObject:@(42)]);
    testassert(![predicate evaluateWithObject:@"xyz"]);
    
    return YES;
}

test(ContainsPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS 'abc'"];
    testassert([predicate evaluateWithObject:@"abc"]);
    testassert([predicate evaluateWithObject:@"XYZabc"]);
    testassert(![predicate evaluateWithObject:@"bca"]);
    
    return YES;
}

test(BeginsWithPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"'aBcDeF' beginswith self"];
    testassert([predicate evaluateWithObject:@"aBc"]);
    testassert([predicate evaluateWithObject:@"aBcDeF"]);
    testassert(![predicate evaluateWithObject:@"aa"]);
    testassert(![predicate evaluateWithObject:@""]);
    
    return YES;
}

test(EndsWithPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith %@", @"XXY"];
    testassert([predicate evaluateWithObject:@"XXY"]);
    testassert([predicate evaluateWithObject:@"XYXXY"]);
    testassert(![predicate evaluateWithObject:@"XXYY"]);
    testassert(![predicate evaluateWithObject:@""]);
    
    return YES;
}

test(LikeWildcardPredicate)
{
    NSPredicate *match = [NSPredicate predicateWithFormat:@"self like 'abc'"];
    testassert([match evaluateWithObject:@"abc"]);
    testassert(![match evaluateWithObject:@"ABC"]);
    
    NSPredicate *star = [NSPredicate predicateWithFormat:@"self like 'a*c'"];
    testassert([star evaluateWithObject:@"abc"]);
    testassert([star evaluateWithObject:@"ac"]);
    testassert([star evaluateWithObject:@"acc"]);
    testassert([star evaluateWithObject:@"abcdefc"]);
    testassert(![star evaluateWithObject:@"ab"]);
    
    NSPredicate *question = [NSPredicate predicateWithFormat:@"self like 'a?c'"];
    testassert([question evaluateWithObject:@"abc"]);
    testassert(![question evaluateWithObject:@"ac"]);
    testassert(![question evaluateWithObject:@"abbc"]);
    
    NSPredicate *starQuestion = [NSPredicate predicateWithFormat:@"self like '*?'"];
    testassert([starQuestion evaluateWithObject:@"a"]);
    testassert(![starQuestion evaluateWithObject:@""]);
    
    NSPredicate *multiStar = [NSPredicate predicateWithFormat:@"self like 'a*b*c?e'"];
    testassert([multiStar evaluateWithObject:@"abcde"]);
    testassert([multiStar evaluateWithObject:@"abcfebbcce"]);
    testassert([multiStar evaluateWithObject:@"aaabbbcccdddeeebbbccce"]);
    testassert([multiStar evaluateWithObject:@"abcccccccde"]);
    testassert(![multiStar evaluateWithObject:@"aaabbbcccc"]);
    testassert(![multiStar evaluateWithObject:@"acde"]);
    testassert(![multiStar evaluateWithObject:@"acbe"]);
    
    NSPredicate *multiQuestion = [NSPredicate predicateWithFormat:@"self like '?a*z?\\?'"];
    testassert([multiQuestion evaluateWithObject:@"aazz?"]);
    testassert([multiQuestion evaluateWithObject:@"aabbcczzeeffzZ?"]);
    testassert(![multiQuestion evaluateWithObject:@"Aabcz?"]);
    testassert(![multiQuestion evaluateWithObject:@"aabbccz???"]);
    
    return YES;
}

test(InAggregatePredicate)
{
    NSPredicate *inArray = [NSPredicate predicateWithFormat:@"self in %@", @[@"a", @"b", @(1), @(2)]];
    testassert([inArray evaluateWithObject:@"a"]);
    testassert([inArray evaluateWithObject:@(1)]);
    testassert(![inArray evaluateWithObject:@"1"]);
    testassert(![inArray evaluateWithObject:nil]);
    
    NSPredicate *contains = [NSPredicate predicateWithFormat:@"self contains 42"];
    testassert([contains evaluateWithObject:@[@(42)]]);
    testassert([contains evaluateWithObject:@[@"a", @(42)]]);
    testassert(![contains evaluateWithObject:@[@"42"]]);
    testassert(![contains evaluateWithObject:nil]);
    
    return YES;
}

test(ReservedWordPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"#like like 'like'"];
    Person *person = [Person new];
    person.like = @"like";
    
    testassert([predicate evaluateWithObject:person]);
    
    [person release];
    
    return YES;
}

test(ValueSubstitutionPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age == %f", 42.];
    Person *person = [Person new];
    person.age = @(42);
    
    testassert([predicate evaluateWithObject:person]);
    
    [person release];
    
    return YES;
}

test(ObjectSubstitutionPredicate)
{
    Person *person = [Person new];
    person.firstName = @"Joe";
    person.lastName = @"Bloggs";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", person];
    
    Person *testPerson = [Person new];
    NSArray *names = [@"Joe Bloggs" componentsSeparatedByString:@" "];
    testPerson.firstName = names[0];
    testPerson.lastName = names[1];
    
    testassert([predicate evaluateWithObject:testPerson]);
    
    [testPerson release];
    [person release];
    
    return YES;
}

test(KeyPathPredicate)
{
    Person *person = [Person new];
    person.firstName = @"Stephen";
    person.lastName = @"Smith";
    person.age = @(42);
    
    NSPredicate *equals = [NSPredicate predicateWithFormat:@"age == %@", @(42)];
    testassert([equals evaluateWithObject:person]);
    
    NSPredicate *like = [NSPredicate predicateWithFormat:@"firstName like 'Ste*en'"];
    testassert([like evaluateWithObject:person]);
    
    NSPredicate *keyPathIn = [NSPredicate predicateWithFormat:@"lastName in %@", @[@"Tinker", @"Tailor", @"Smith", @"Sailer"]];
    testassert([keyPathIn evaluateWithObject:person]);
    
    [person release];
    
    return YES;
}

test(KeyPathSubstitutionPredicate)
{
    Person *person = [Person new];
    person.firstName = @"Stephen";
    person.lastName = @"Smith";
    person.age = @(42);
    
    NSPredicate *equals = [NSPredicate predicateWithFormat:@"%K == %@", @"age", @(42)];
    testassert([equals evaluateWithObject:person]);
    
    NSPredicate *like = [NSPredicate predicateWithFormat:@"%K like 'Ste*en'", @"firstName"];
    testassert([like evaluateWithObject:person]);
    
    NSPredicate *keyPathIn = [NSPredicate predicateWithFormat:@"%K in %@", @"lastName", @[@"Tinker", @"Tailor", @"Smith", @"Sailer"]];
    testassert([keyPathIn evaluateWithObject:person]);
    
    [person release];
    
    return YES;
}

test(VariablePredicate)
{
    Person *person = [Person new];
    person.firstName = @"James";
    person.lastName = @"Bond";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName == $FIRST_NAME and lastName == $LAST_NAME"];
    testassert([predicate evaluateWithObject:person substitutionVariables:@{@"FIRST_NAME": @"James", @"LAST_NAME": @"Bond"}]);
    
    [person release];
    
    return YES;
}

test(FunctionPredicate)
{
    Person *person = [Person new];
    person.age = @(21);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age == min(%@)", @[@(21), @(42)]];
    testassert([predicate evaluateWithObject:person]);
    
    [person release];
    
    return YES;
}

test(FilteredArrayUsingPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self >= 2"];
    NSArray *values = [@[@(0), @(1), @(2), @(3)] filteredArrayUsingPredicate:predicate];
    
    testassert([values isEqualToArray:@[@(2), @(3)]]);
    
    return YES;
}

test(FilterUsingPredicateArray)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self like 'a*z'"];
    NSMutableArray *values = [NSMutableArray arrayWithArray:@[@"abc", @"abcz", @"aaaazzz"]];
    [values filterUsingPredicate:predicate];
    
    testassert([values isEqualToArray:@[@"abcz", @"aaaazzz"]]);
    
    return YES;
}

test(FilteredSetUsingPredicate)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age > 21"];
    NSArray *persons = @[
        [Person personWithAge:17],
        [Person personWithAge:42],
        [Person personWithAge:99]
    ];
    NSSet *values = [[NSSet setWithArray:persons] filteredSetUsingPredicate:predicate];
    
    testassert([values isEqualToSet:[NSSet setWithArray:@[persons[1], persons[2]]]]);
    
    return YES;
}

test(FilterUsingPredicateSet)
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > 21", @"age"];
    NSArray *persons = @[
        [Person personWithAge:17],
        [Person personWithAge:42],
        [Person personWithAge:99]
    ];
    NSMutableSet *values = [NSMutableSet setWithArray:persons];
    [values filterUsingPredicate:predicate];
    
    testassert([values isEqualToSet:[NSSet setWithArray:@[[Person personWithAge:42], [Person personWithAge:99]]]]);
    
    return YES;
}

test(AggregateLiteral)
{
    NSPredicate *aggregate = [NSPredicate predicateWithFormat:@"{1, 2,3} = $arr"];

    testassert([aggregate evaluateWithObject:nil substitutionVariables:@{@"arr": @[@1, @2, @3]}]);
    testassert(![aggregate evaluateWithObject:nil substitutionVariables:@{@"arr": @[@1, @2, @3, @4]}]);

    testassert([[[(NSComparisonPredicate *)aggregate leftExpression] expressionValueWithObject:nil context:nil] isKindOfClass:[NSArray class]]);

    return YES;
}

test(SizeOperator)
{
    NSPredicate *sizeOp = [NSPredicate predicateWithFormat:@"{1, 2, 3}[SIZE] = 3"];
    testassert([sizeOp evaluateWithObject:nil]);

    sizeOp = [NSPredicate predicateWithFormat:@"{}[SIZE] = 0"];
    testassert([sizeOp evaluateWithObject:nil]);

    sizeOp = [NSPredicate predicateWithFormat:@"{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}[SIZE] = 1"];
    testassert([sizeOp evaluateWithObject:nil]);
    return YES;
}

test(FirstOperator)
{
    NSPredicate *first = [NSPredicate predicateWithFormat:@"{1, 2, 3}[FIRST] = 1"];
    testassert([first evaluateWithObject:nil]);

    first = [NSPredicate predicateWithFormat:@"{}[FIRST] = 1"];
    testassert(![first evaluateWithObject:nil]);

    return YES;
}

test(LastOperator)
{
    NSPredicate *last = [NSPredicate predicateWithFormat:@"{1, 2, {3}}[LAST] = {3}"];
    testassert([last evaluateWithObject:nil]);

    last = [NSPredicate predicateWithFormat:@"{}[LAST] = {3}"];
    testassert(![last evaluateWithObject:nil]);

    return YES;
}

test(IndexOperator)
{
    for (int idx = 0; idx < 5; idx++)
    {
        NSPredicate *idxPred = [NSPredicate predicateWithFormat:@"{1, 2, 1, 3, 1}[%d] != 1", idx];
        testassert([idxPred evaluateWithObject:nil] == idx % 2);
    }

    NSPredicate *idxPred = [NSPredicate predicateWithFormat:@"{1, 2, 1, 3, 1}[23] != 1"];
    idxPred = [NSPredicate predicateWithFormat:@"{1, 2, 1, 3, 1}[-23] != 1"];

    return YES;
}

test(BetweenOperator)
{
    NSPredicate *between = [NSPredicate predicateWithFormat:@"42 BETWEEN {23, 50}"];
    testassert([between evaluateWithObject:nil]);

    BOOL thrown = NO;
    between = [NSPredicate predicateWithFormat:@"42 BETWEEN {23}"];
    @try {
        [between evaluateWithObject:nil];
    }
    @catch (NSException *e)
    {
        thrown = [[e name] isEqualToString:NSInvalidArgumentException];
    }
    testassert(thrown);

    thrown = NO;
    between = [NSPredicate predicateWithFormat:@"42 BETWEEN {0, 23, 50}"];
    @try {
        [between evaluateWithObject:nil];
    }
    @catch (NSException *e)
    {
        thrown = [[e name] isEqualToString:NSInvalidArgumentException];
    }
    testassert(thrown);

    return YES;
}

test(AnyModifier)
{
    NSPredicate *anyPredicate = [NSPredicate predicateWithFormat:@"ANY {0, 42, 100} BETWEEN {23, 50}"];
    testassert([anyPredicate evaluateWithObject:nil]);

    anyPredicate = [NSPredicate predicateWithFormat:@"ANY {0, 22, 100} BETWEEN {23, 50}"];
    testassert(![anyPredicate evaluateWithObject:nil]);

    anyPredicate = [NSPredicate predicateWithFormat:@"ANY {} BETWEEN {23, 50}"];
    testassert(![anyPredicate evaluateWithObject:nil]);

    return YES;
}

test(AllModifier)
{
    NSPredicate *allPredicate = [NSPredicate predicateWithFormat:@"ALL {41, 42, 43} BETWEEN {23, 50}"];
    testassert([allPredicate evaluateWithObject:nil]);

    allPredicate = [NSPredicate predicateWithFormat:@"ALL {0, 22, 100} BETWEEN {23, 50}"];
    testassert(![allPredicate evaluateWithObject:nil]);

    allPredicate = [NSPredicate predicateWithFormat:@"ALL {} BETWEEN {23, 50}"];
    testassert([allPredicate evaluateWithObject:nil]);

    return YES;
}

test(SomeModifier)
{
    NSPredicate *somePredicate = [NSPredicate predicateWithFormat:@"SOME {0, 42, 100} BETWEEN {23, 50}"];
    testassert([somePredicate evaluateWithObject:nil]);

    somePredicate = [NSPredicate predicateWithFormat:@"SOME {0, 22, 51} BETWEEN {23, 50}"];
    testassert(![somePredicate evaluateWithObject:nil]);

    somePredicate = [NSPredicate predicateWithFormat:@"SOME {} BETWEEN {23, 50}"];
    testassert(![somePredicate evaluateWithObject:nil]);

    return YES;
}

test(NoneModifier)
{
    NSPredicate *nonePredicate = [NSPredicate predicateWithFormat:@"NONE {0, 22, 100} BETWEEN {23, 50}"];
    testassert([nonePredicate evaluateWithObject:nil]);

    nonePredicate = [NSPredicate predicateWithFormat:@"NONE {0, 43, 100} BETWEEN {23, 50}"];
    testassert(![nonePredicate evaluateWithObject:nil]);

    nonePredicate = [NSPredicate predicateWithFormat:@"NONE {} BETWEEN {23, 50}"];
    testassert([nonePredicate evaluateWithObject:nil]);

    return YES;
}

@end
