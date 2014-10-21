//
//  NSAttributedStringSubclassSubclassTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//


#import "FoundationTests.h"
#import "NSAttributedStringHelper.h"

@interface NSMutableAttributedStringSubclass : NSMutableAttributedString

@end

@implementation NSMutableAttributedStringSubclass {
    NSMutableAttributedString *backing;
}

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs
{
    self = [super init];
    if (self)
    {
        self->backing = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
    }
    return self;
}

- (id)initWithString:(NSString *)str
{
    return [self initWithString:str attributes:nil];
}

- (id)initWithAttributedString:(NSAttributedString *)str
{
    NSMutableAttributedStringSubclass *retVal = [[NSMutableAttributedStringSubclass alloc] initWithString:@""];
    if (retVal)
    {
        [retVal setAttributedString:str];
    }
    return retVal;
}

- (NSString *)string
{
    return [backing string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range
{
    return [backing attributesAtIndex:index effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [backing replaceCharactersInRange:range withString:str];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [backing setAttributes:attrs range:range];
}

@end


@interface NSAttributedStringSubclass : NSAttributedString

@end

@implementation NSAttributedStringSubclass {
    NSAttributedString *backing;
}

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs
{
    self = [super init];
    if (self)
    {
        self->backing = [[NSAttributedString alloc] initWithString:str attributes:attrs];
    }
    return self;
}

- (id)initWithString:(NSString *)str
{
    return [self initWithString:str attributes:nil];
}

- (id)initWithAttributedString:(NSAttributedString *)str
{
    NSMutableAttributedStringSubclass *retVal = [[NSMutableAttributedStringSubclass alloc] initWithString:@""];
    if (retVal)
    {
        [retVal setAttributedString:str];
    }
    return (NSAttributedStringSubclass *)retVal;
}

- (NSString *)string
{
    return [backing string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range
{
    return [backing attributesAtIndex:index effectiveRange:range];
}

@end

@testcase(NSAttributedStringSubclass)

#ifndef IM_A_MAC_TARGET

test(NSAttributedStringSubclassString)
{
    NSAttributedStringSubclass *str = [[NSAttributedStringSubclass alloc] initWithString:@"My string."];
    testassert([[str string] isEqualToString:@"My string."]);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassLength)
{
    NSAttributedStringSubclass *str = [[NSAttributedStringSubclass alloc] initWithString:@"My string."];
    testassert([str length] == 10);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributed)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedStringSubclass *preAttrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                        attributes:attrsDictionary];
    
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithAttributedString:preAttrString];
    [preAttrString release];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedEffective)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedEffectiveAttributesEmpty)
{
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy"];
    NSRange range;
    NSDictionary *d = [attrString attributesAtIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    testassert([d count] == 0);
    
    id obj = [attrString attribute:@"foo" atIndex:5 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    testassert(obj == nil);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedEffectiveAttributesEmptyMutable)
{
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"];
    NSRange range;
    [attrString attributesAtIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,2)];
    [attrString attributesAtIndex:1 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    
    [attrString attributesAtIndex:6 effectiveRange:&range];
    testassert(range.location == 5 && range.length == 2);
    
    NSDictionary *d = [attrString attributesAtIndex:0 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    testassert([d count] == 0);
    
    id obj = [attrString attribute:@"foo" atIndex:5 effectiveRange:&range];
    testassert(range.location == 5 && range.length == 2);
    testassert(obj == nil);
    [attrString release];
    return YES;
}


test(NSAttributedStringSubclassStringMutable)
{
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    testassert([[str string] isEqualToString:@"My string."]);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassLengthMutable)
{
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    testassert([str length] == 10);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedEffectiveMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    [attrString release];
    return YES;
}


test(NSAttributedStringSubclassInitWithStringAttributedEffectiveMutable2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,2)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 2);
    
    [attrString attribute:NSFontAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    
    UIColorish *color2 = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    testassert(color2 == nil);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 2);
    testassert(color2 == nil);
    
    [attrString attribute:NSFontAttributeName atIndex:6 effectiveRange:&range];
    testassert(range.location == 5 && range.length == 2);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedOverlap)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:yellow range:NSMakeRange(3,2)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:blue range:NSMakeRange(3,3)];
    
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:5 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:6 effectiveRange:nil] == nil);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedOverlap2)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:yellow range:NSMakeRange(3,2)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:blue range:NSMakeRange(2,2)];
    
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:1 effectiveRange:nil] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil] == blue);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:nil] == yellow);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:5 effectiveRange:nil] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:6 effectiveRange:nil] == nil);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributes)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"];
    [attrString addAttribute:NSFontAttributeName value:yellow range:NSMakeRange(2,3)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:yellow range:NSMakeRange(3,3)];
    [attrString addAttribute:NSBackgroundColorAttributeName value:blue range:NSMakeRange(4,2)];
    
    NSDictionary *d = [attrString attributesAtIndex:1 effectiveRange:nil];
    testassert([d count] == 0);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 0);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:6 effectiveRange:nil] count] == 0);
    [attrString release];
    return YES;
}


test(NSAttributedStringSubclassInitWithStringAttributedEffectiveMutableMerge1)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(2,1)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColorish blueColor] range:NSMakeRange(2,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 1);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedEffectiveMutableMerge2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(4,2)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 3);
    
    id foo = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColorish blueColor] range:NSMakeRange(4,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 1);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithAttributedStringAttributedEffectiveMutableMerge2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *preAttrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                      attributes:attrsDictionary];
    [preAttrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[preAttrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [preAttrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [preAttrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(4,2)];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithAttributedString:preAttrString];
    [preAttrString release];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 3);
    
    id foo = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColorish blueColor] range:NSMakeRange(4,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 1);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithAttributedStringAttributedEffectiveMutableMergeFromImmutable)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSAttributedStringSubclass *preAttrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                        attributes:attrsDictionary];
    
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithAttributedString:preAttrString];
    
    UIColorish *color = [attrString attribute:NSFontAttributeName atIndex:2 effectiveRange:nil];
    testassert(color == yellow);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(4,2)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 3);
    
    [preAttrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    [preAttrString release];
    testassert(range.location == 0 && range.length == 7);
    
    id foo = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    [attrString addAttribute:NSFontAttributeName value:[UIColorish blueColor] range:NSMakeRange(4,1)];
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 1);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveMutableMiss0)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range = NSMakeRange(1,2);
    id val = [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 0 && range.length == 0);
    testassert(val == color);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveMutableMissLow)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range = NSMakeRange(1,2);
    id val = [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 1)];
    testassert(range.location == 0 && range.length == 0);
    testassert(val == color);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveMutableMissHigh)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range = NSMakeRange(1,2);
    id val = [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(5, 2)];
    testassert(range.location == 0 && range.length == 0);
    testassert(val == color);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy" attributes:attrsDictionary];
    
    NSRange range = NSMakeRange(1,2);
    NSDictionary *val = [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 4 && range.length == 2);
    testassert([val count] == 1);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveAttribute)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"stringy" attributes:attrsDictionary];
    
    NSRange range = NSMakeRange(1,2);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:5 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 4 && range.length == 2);
    testassert(color2 == color);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveMutableMissAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    NSRange range = NSMakeRange(1,2);
    NSDictionary *val = [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 0 && range.length == 0);
    testassert([val count] == 2);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    
    NSRange range;
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(2,1)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString addAttribute:@"foo" value:[UIColorish redColor] range:NSMakeRange(2,1)];
    [attrString attribute:NSBackgroundColorAttributeName atIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedLongestEffectiveMutableAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];
    
    NSRange range;
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(2,1)];
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attributesAtIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString addAttribute:@"foo" value:[UIColorish redColor] range:NSMakeRange(2,1)];
    [attrString attributesAtIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 1);
    
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 3 && range.length == 1);
    
    [attrString addAttribute:@"foo" value:[UIColorish redColor] range:NSMakeRange(3,1)];
    [attrString attributesAtIndex:2 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(0, 6)];
    testassert(range.location == 2 && range.length == 2);
    
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassAttributeNil)
{
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,5)];
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:8 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:9 effectiveRange:nil] == nil);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassInitWithStringAttributedMutable2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(0,6)];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassAttribute)
{
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,5)];
    UIColorish *color = [str attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color != nil);
    testassert([color isEqual:[UIColorish yellowColor]]);
    [str release];
    return YES;
}


test(NSAttributedStringSubclassException)
{
    BOOL gotException = NO;
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    @try
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColorish greenColor] range:NSMakeRange(10,7)];
    }
    @catch (NSException *caught) {
        testassert([caught.name isEqualToString:@"NSRangeException"]);
        gotException = YES;  //  po caught.reason --- NSMutableRLEArray objectAtIndex:effectiveRange:: Out of bounds
    }
    testassert(gotException);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassExceptionOverlap)
{
    BOOL gotException = NO;
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    @try
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColorish greenColor] range:NSMakeRange(4,7)];
    }
    @catch (NSException *caught) {
        testassert([caught.name isEqualToString:@"NSRangeException"]);
        gotException = YES;  //  po caught.reason --- NSMutableRLEArray objectAtIndex:effectiveRange:: Out of bounds
    }
    testassert(gotException);
    [str release];
    return YES;
}

test(NSAttributedStringSubclassUseCase)
{
    NSMutableAttributedStringSubclass *str = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string.abcdefghijklmnopqrstuvwxyz"];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,5)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColorish greenColor] range:NSMakeRange(10,7)];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(20,10)];
    [str release];
    return YES;
}

test(NSAttributedStringSubclassCopy)
{
    UIColorish *red = [UIColorish redColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName: red};
    NSAttributedStringSubclass *preCopy = [[NSAttributedStringSubclass alloc] initWithString:@"My string." attributes:dict];
    NSAttributedStringSubclass *attributedString = [preCopy copy];
    [preCopy release];
    
    UIColorish *color = [attributedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == red);
    
    testassert([[attributedString string] isEqualToString:@"My string."]);
    [attributedString release];
    return YES;
}

test(NSAttributedStringSubclassMutableCopy)
{
    UIColorish *red = [UIColorish redColor];
    NSAttributedStringSubclass *preCopy = [[NSAttributedStringSubclass alloc] initWithString:@"My string."];
    NSMutableAttributedStringSubclass *attributedString = [preCopy mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(2,2)];
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    [attributedString release];
    
    UIColorish *color = [selectedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == nil);
    
    color = [selectedString attribute:NSForegroundColorAttributeName atIndex:2 effectiveRange:nil];
    testassert(color == red);
    
    testassert([[selectedString attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[selectedString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:3 effectiveRange:nil] count] == 0);
    return YES;
}

test(NSAttributedStringSubclassAttributedSubstringFromRange)
{
    UIColorish *red = [UIColorish redColor];
    NSMutableAttributedStringSubclass *attributedString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:red range:NSMakeRange(2,2)];
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    [attributedString release];
    
    UIColorish *color = [selectedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == nil);
    
    color = [selectedString attribute:NSForegroundColorAttributeName atIndex:2 effectiveRange:nil];
    testassert(color == red);
    
    testassert([[selectedString attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[selectedString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[selectedString attributesAtIndex:3 effectiveRange:nil] count] == 0);
    return YES;
}

test(NSAttributedStringSubclassAttributedSubstringFromRange2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    NSMutableAttributedStringSubclass *as2 = [attrString mutableCopy];
    [as2 setAttributes:attrsDictionary range:NSMakeRange(3, 5)];
    
    NSAttributedString *substr = [as2 attributedSubstringFromRange:NSMakeRange(2,4)];
    [as2 release];
    testassert([attrString length] == 10);
    [attrString release];
    testassert([substr length] == 4);
    
    NSRange range;
    UIColorish *color2 = [substr attribute:NSFontAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 1 && range.length == 3);
    testassert([color isEqual:color2]);
    
    color2 = [substr attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 1);
    testassert([color2 isEqual:[UIColorish blueColor]]);
    
    testassert([[substr attributesAtIndex:0 effectiveRange:nil] count] == 1);
    testassert([[substr attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[substr attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[substr attributesAtIndex:3 effectiveRange:nil] count] == 1);
    
    return YES;
}

test(NSAttributedStringSubclassEnumerateAttributesInRange)
{
    __block NSUInteger found = NO;
    __block NSUInteger count = 0;
    NSMutableAttributedStringSubclass *attributedString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColorish redColor] range:NSMakeRange(1,4)];
    
    [attributedString enumerateAttributesInRange:NSMakeRange(0, 6)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColorish colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
         count++;
     }];
    testassert(count == 3);
    testassert(found == 1);
    
    count = 0;
    found = 0;
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    [attributedString release];
    
    [selectedString enumerateAttributesInRange:NSMakeRange(0, [selectedString length])
                                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                    usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColorish colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
         count++;
     }];
    testassert(count == 1);
    testassert(found == 1);
    
    return YES;
}

test(NSAttributedStringSubclassEnumerateAttribute)
{
    __block NSUInteger found = 0;
    __block NSUInteger count = 0;
    NSMutableAttributedStringSubclass *attributedString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColorish redColor] range:NSMakeRange(1,4)];
    
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, 6)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         found |= val != nil ? 1 : 0;
         count++;
     }];
    testassert(count == 3);
    testassert(found == 1);
    
    count = 0;
    found = 0;
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    [attributedString release];
    
    [selectedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, [selectedString length])
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         found = val != nil ? 1 : 0;
         count++;
     }];
    
    testassert(count == 1);
    testassert(found == 1);
    return YES;
}

test(NSAttributedStringSubclassEmpty)
{
    NSAttributedStringSubclass *str = [[NSAttributedStringSubclass alloc] initWithString:@""];
    int length = [str length];
    testassert(length == 0);
    [str release];
    return YES;
}


test(NSAttributedStringSubclassRemoveAttribute)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(2,5)];
    [attrString removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(1,3)];
    
    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 4);
    testassert([color isEqual:color2]);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:5 effectiveRange:NULL] == [UIColorish yellowColor]);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:NULL] == nil);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassSetAttributeString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(3,3)];
    [attrString setAttributes:attrsDictionary range:NSMakeRange(2,2)];
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 2);
    testassert([color isEqual:color2]);
    
    testassert([attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:NULL] == color);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:NULL] == nil);
    testassert([attrString attribute:NSFontAttributeName atIndex:4 effectiveRange:NULL] == nil);
    testassert([attrString attribute:NSBackgroundColorAttributeName atIndex:5 effectiveRange:NULL] == [UIColorish blueColor]);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassDeleteCharactersInRange)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"stringy1" attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(3,4)];
    [attrString deleteCharactersInRange:NSMakeRange(2,2)];
    
    testassert([[attrString string] isEqualToString:@"stngy1"]);
    testassert([attrString length] == 6);
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 3);
    testassert([color isEqual:color2]);
    
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    [attrString release];
    return YES;
}


test(NSAttributedStringSubclassAppendAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abc" attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    [attrString appendAttributedString:[attrString copy]];
    
    testassert([[attrString string] isEqualToString:@"abcabc"]);
    testassert([attrString length] == 6);
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 2 && range.length == 2);
    testassert([color isEqual:color2]);
    
    testassert([[attrString attributesAtIndex:0 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassInsertAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abc" attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    [attrString insertAttributedString:[attrString copy] atIndex:2];
    
    testassert([[attrString string] isEqualToString:@"ababcc"]);
    testassert([attrString length] == 6);
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 2);
    testassert([color isEqual:color2]);
    
    testassert([[attrString attributesAtIndex:0 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    [attrString release];
    return YES;
}


test(NSAttributedStringSubclassInsertAttributedString2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abcd" attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(2,1)];
    [attrString insertAttributedString:[attrString copy] atIndex:1];
    
    testassert([[attrString string] isEqualToString:@"aabcdbcd"]);
    testassert([attrString length] == 8);
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:1 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 3);
    testassert([color isEqual:color2]);
    
    color2 = [attrString attribute:NSFontAttributeName atIndex:5 effectiveRange:&range];
    testassert(range.location == 4 && range.length == 2);
    testassert([color isEqual:color2]);
    
    testassert([[attrString attributesAtIndex:0 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:6 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:7 effectiveRange:nil] count] == 1);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassReplaceCharactersInRange)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abc" attributes:attrsDictionary];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    [attrString replaceCharactersInRange:NSMakeRange(1,1) withAttributedString:[attrString copy]];
    
    testassert([[attrString string] isEqualToString:@"aabcc"]);
    testassert([attrString length] == 5);
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:1 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 2);
    testassert([color isEqual:color2]);
    
    testassert([[attrString attributesAtIndex:0 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 2);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 1);
    [attrString release];
    return YES;
}

test(NSAttributedStringSubclassSetAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    [attrString setAttributes:attrsDictionary range:NSMakeRange(3, 5)];
    
    NSRange range;
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 5);
    testassert([color isEqual:color2]);
    
    color2 = [attrString attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 1 && range.length == 2);
    testassert([color2 isEqual:[UIColorish blueColor]]);
    
    testassert([[attrString attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[attrString attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:3 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:4 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:5 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:6 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:7 effectiveRange:nil] count] == 1);
    testassert([[attrString attributesAtIndex:8 effectiveRange:nil] count] == 0);
    [attrString release];
    return YES;
}


test(NSAttributedStringSubclassSetAttributesAndCopy)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    [attrString setAttributes:attrsDictionary range:NSMakeRange(3, 5)];
    
    NSAttributedStringSubclass *as2 = [attrString copy];
    [attrString release];
    
    NSRange range;
    UIColorish *color2 = [as2 attribute:NSFontAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 5);
    testassert([color isEqual:color2]);
    
    color2 = [as2 attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 1 && range.length == 2);
    testassert([color2 isEqual:[UIColorish blueColor]]);
    
    testassert([[as2 attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[as2 attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:3 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:4 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:5 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:6 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:7 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:8 effectiveRange:nil] count] == 0);
    [as2 release];
    return YES;
}


test(NSAttributedStringSubclassSetAttributesAndMutableCopy)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedStringSubclass *attrString = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    NSMutableAttributedStringSubclass *as2 = [attrString mutableCopy];
    [attrString release];
    [as2 setAttributes:attrsDictionary range:NSMakeRange(3, 5)];
    
    NSRange range;
    UIColorish *color2 = [as2 attribute:NSFontAttributeName atIndex:4 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 5);
    testassert([color isEqual:color2]);
    
    color2 = [as2 attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:&range];
    testassert(range.location == 1 && range.length == 2);
    testassert([color2 isEqual:[UIColorish blueColor]]);
    
    testassert([[as2 attributesAtIndex:0 effectiveRange:nil] count] == 0);
    testassert([[as2 attributesAtIndex:1 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:2 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:3 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:4 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:5 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:6 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:7 effectiveRange:nil] count] == 1);
    testassert([[as2 attributesAtIndex:8 effectiveRange:nil] count] == 0);
    [as2 release];
    return YES;
}

test(NSAttributedStringSubclassEquals)
{
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"abc"];
    NSAttributedStringSubclass *attrString2 = [[NSAttributedStringSubclass alloc] initWithString:@"abc"];
    testassert([attrString isEqual:attrString2]);
    testassert([attrString isEqualToAttributedString:attrString2]);
    [attrString2 release];
    NSAttributedStringSubclass *attrString3 = [[NSAttributedStringSubclass alloc] initWithString:@"abcd"];
    testassert(![attrString isEqual:attrString3]);
    [attrString release];
    [attrString3 release];
    return YES;
}

test(NSAttributedStringSubclassEquals2)
{
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"abc"];
    NSMutableAttributedStringSubclass *attrString2 = [[NSMutableAttributedStringSubclass alloc] initWithString:@"abc"];
    testassert([attrString isEqual:attrString2]);
    [attrString2 addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    testassert(![attrString isEqual:attrString2]);
    [attrString release];
    [attrString2 release];
    return YES;
}

test(NSAttributedStringSubclassEquals3)
{
    NSAttributedStringSubclass *attrString = [[NSAttributedStringSubclass alloc] initWithString:@"abc"];
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:@"abc"];
    testassert([attrString isEqual:attrString2]);
    testassert([attrString2 isEqual:attrString]);
    [attrString2 addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    testassert(![attrString isEqual:attrString2]);
    [attrString release];
    [attrString2 release];
    return YES;
}

test(NSAttributedStringSubclassGetMutableString)
{
    NSMutableAttributedStringSubclass *attrString = [[[NSMutableAttributedStringSubclass alloc] initWithString:@"ABCDEFGHIJ"] autorelease];
    
    NSMutableString *str = [attrString mutableString];
    testassert([str isEqualToString:@"ABCDEFGHIJ"]);
    
    [str insertString:@"xyz" atIndex:3];
    testassert([str isEqualToString:@"ABCxyzDEFGHIJ"]);
    testassert([[attrString string] isEqualToString:@"ABCxyzDEFGHIJ"]);
    
    [str replaceCharactersInRange:NSMakeRange(5,4) withString:@"foo"];
    testassert([str isEqualToString:@"ABCxyfooGHIJ"]);
    testassert([[attrString string] isEqualToString:@"ABCxyfooGHIJ"]);
    
    NSRange range;
    [attrString attributesAtIndex:5 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 12);
    return YES;
}

#endif

@end

