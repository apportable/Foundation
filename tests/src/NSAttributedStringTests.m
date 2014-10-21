//
//  NSAttributedStringTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <Foundation/NSAttributedString.h>
#import "NSAttributedStringHelper.h"
@testcase(NSAttributedString)

#ifndef IM_A_MAC_TARGET

test(NSAttributedStringColorTest)
{
    UIColorish *one = [UIColorish colorWithRed:1 green:0 blue:0 alpha:1];
    UIColorish *two = [UIColorish redColor];
    testassert([one isEqual:two]);
    return YES;
}

test(NSAttributedStringString)
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"My string."];
    testassert([[str string] isEqualToString:@"My string."]);
    [str release];
    return YES;
}

test(NSAttributedStringLength)
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"My string."];
    testassert([str length] == 10);
    [str release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributed)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                    attributes:attrsDictionary];

    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *preAttrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];

    NSAttributedString *attrString = [[NSAttributedString alloc] initWithAttributedString:preAttrString];
    [preAttrString release];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedEffective)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];

    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedEffectiveAttributesEmpty)
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy"];
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

test(NSAttributedStringInitWithStringAttributedEffectiveAttributesEmptyMutable)
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"];
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


test(NSAttributedStringStringMutable)
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    testassert([[str string] isEqualToString:@"My string."]);
    [str release];
    return YES;
}

test(NSAttributedStringLengthMutable)
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    testassert([str length] == 10);
    [str release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];

    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedEffectiveMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                     attributes:attrsDictionary];

    testassert([[attrString string] isEqualToString:@"stringy"]);
    NSRange range;
    [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 0 && range.length == 7);
    [attrString release];
    return YES;
}

test(NSMutableAttributedStringInit)
{
    NSAttributedString *orig = [[NSAttributedString alloc] initWithString:@"Hello!" attributes:[NSDictionary dictionaryWithObject:[UIColorish orangeColor] forKey:NSFontAttributeName]];
    NSMutableAttributedString *str_m = [[NSMutableAttributedString alloc] init];
    [str_m beginEditing];
    [str_m appendAttributedString:orig];
    [str_m endEditing];
    testassert([str_m length] == [orig length]);
    [str_m release];
    [orig release];
    return YES;
}

test(NSAttributedStringInitWithNilAtttributes)
{
    NSString *str = @"Hello!";
    NSAttributedString *mas = [[NSAttributedString alloc] initWithString:str attributes:nil];
    testassert([mas length] == str.length);
    [mas release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedEffectiveMutable2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedOverlap)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedOverlap2)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributes)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"];
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

// ios failure will go away if UIKit is linked in. By spec, NSAttributedString merging is undefined

test(NSAttributedStringInitWithStringAttributedEffectiveMutableMerge1)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedEffectiveMutableMerge2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithAttributedStringAttributedEffectiveMutableMerge2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *preAttrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [preAttrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];

    testassert([[preAttrString string] isEqualToString:@"stringy"]);

    NSRange range;
    [preAttrString attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:&range];
    testassert(range.location == 3 && range.length == 1);

    [preAttrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(4,2)];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:preAttrString];
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

test(NSAttributedStringInitWithAttributedStringAttributedEffectiveMutableMergeFromImmutable)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    NSAttributedString *preAttrString = [[NSAttributedString alloc] initWithString:@"stringy"
                                                                                      attributes:attrsDictionary];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:preAttrString];

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

test(NSAttributedStringInitWithStringAttributedLongestEffectiveMutableMiss0)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedLongestEffectiveMutableMissLow)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedLongestEffectiveMutableMissHigh)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedLongestEffectiveAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy" attributes:attrsDictionary];

    NSRange range = NSMakeRange(1,2);
    NSDictionary *val = [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 4 && range.length == 2);
    testassert([val count] == 1);

    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedLongestEffectiveAttribute)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"stringy" attributes:attrsDictionary];

    NSRange range = NSMakeRange(1,2);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:5 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 4 && range.length == 2);
    testassert(color2 == color);

    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedLongestEffectiveMutableMissAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,1)];

    NSRange range = NSMakeRange(1,2);
    NSDictionary *val = [attrString attributesAtIndex:3 longestEffectiveRange:&range inRange:NSMakeRange(4, 2)];
    testassert(range.location == 0 && range.length == 0);
    testassert([val count] == 2);

    [attrString release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedLongestEffectiveMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringInitWithStringAttributedLongestEffectiveMutableAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringAttributeNil)
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,5)];
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:2 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:8 effectiveRange:nil] == nil);
    testassert([str attribute:NSBackgroundColorAttributeName atIndex:9 effectiveRange:nil] == nil);
    [str release];
    return YES;
}

test(NSAttributedStringInitWithStringAttributedMutable2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
                                                                                   attributes:attrsDictionary];

    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(0,6)];
    testassert([[attrString string] isEqualToString:@"stringy"]);
    UIColorish *color2 = [attrString attribute:NSFontAttributeName atIndex:3 effectiveRange:nil];
    testassert([color isEqual:color2]);
    [attrString release];
    return YES;
}

test(NSAttributedStringAttribute)
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,5)];
    UIColorish *color = [str attribute:NSBackgroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color != nil);
    testassert([color isEqual:[UIColorish yellowColor]]);
    [str release];
    return YES;
}


test(NSAttributedStringException)
{
    BOOL gotException = NO;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
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

test(NSAttributedStringExceptionOverlap)
{
    BOOL gotException = NO;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string."];
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

test(NSAttributedStringUseCase)
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"My string.abcdefghijklmnopqrstuvwxyz"];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(3,5)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColorish greenColor] range:NSMakeRange(10,7)];
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColorish yellowColor] range:NSMakeRange(20,10)];
    [str release];
    return YES;
}

test(NSAttributedStringCopy)
{
    UIColorish *red = [UIColorish redColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName: red};
    NSAttributedString *preCopy = [[NSAttributedString alloc] initWithString:@"My string." attributes:dict];
    NSAttributedString *attributedString = [preCopy copy];
    [preCopy release];

    UIColorish *color = [attributedString attribute:NSForegroundColorAttributeName atIndex:3 effectiveRange:nil];
    testassert(color == red);

    testassert([[attributedString string] isEqualToString:@"My string."]);
    [attributedString release];
    return YES;
}

test(NSAttributedStringMutableCopy)
{
    UIColorish *red = [UIColorish redColor];
    NSAttributedString *preCopy = [[NSAttributedString alloc] initWithString:@"My string."];
    NSMutableAttributedString *attributedString = [preCopy mutableCopy];
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

test(NSAttributedStringAttributedSubstringFromRange)
{
    UIColorish *red = [UIColorish redColor];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
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


test(NSAttributedStringAttributedSubstringFromRange2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    NSMutableAttributedString *as2 = [attrString mutableCopy];
    [as2 setAttributes:attrsDictionary range:NSMakeRange(3, 5)];
    
    NSAttributedString *substr = [as2 attributedSubstringFromRange:NSMakeRange(2,4)];
    [as2 release];
    testassert([attrString length] == 10);
    [attrString release];
    
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

test(NSAttributedStringEnumerateAttributesInRange)
{
    __block NSUInteger found = NO;
    __block NSUInteger count = 0;
    __block NSInteger previous = -1;
    __block BOOL orderOK = YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColorish redColor] range:NSMakeRange(1,4)];

    [attributedString enumerateAttributesInRange:NSMakeRange(0, 6)
                                       options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                    usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         if ((signed)range.location <= previous)
         {
             orderOK = NO;
         }
         previous = range.location;
         found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColorish colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
         count++;
     }];
    testassert(orderOK);
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

test(NSAttributedStringEnumerateAttribute)
{
    __block NSUInteger found = 0;
    __block NSUInteger count = 0;
    __block NSInteger previous = -1;
    __block BOOL orderOK = YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColorish redColor] range:NSMakeRange(1,4)];

    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, 6)
                                         options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                      usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         if ((signed)range.location <= previous)
         {
             orderOK = NO;
         }
         found |= val != nil ? 1 : 0;
         count++;
     }];
    testassert(orderOK);
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

test(NSAttributedStringEnumerateAttributesInRangeReverse)
{
    __block NSUInteger found = NO;
    __block NSUInteger count = 0;
    __block NSInteger previous = INT_MAX;
    __block BOOL orderOK = YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColorish redColor] range:NSMakeRange(1,4)];
    
    [attributedString enumerateAttributesInRange:NSMakeRange(0, 6)
                                         options:NSAttributedStringEnumerationReverse
                                      usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         if (range.location >= previous)
         {
             orderOK = NO;
         }
         previous = range.location;
         found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColorish colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
         count++;
     }];
    testassert(orderOK);
    testassert(count == 3);
    testassert(found == 1);
    
    count = 0;
    found = 0;
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    [attributedString release];
    
    [selectedString enumerateAttributesInRange:NSMakeRange(0, [selectedString length])
                                       options:NSAttributedStringEnumerationReverse
                                    usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop)
     {
         found += [[attributes objectForKey:NSForegroundColorAttributeName] isEqual:[UIColorish colorWithRed:1 green:0 blue:0 alpha:1]] ? 1 : 0;
         count++;
     }];
    testassert(count == 1);
    testassert(found == 1);
    
    return YES;
}

test(NSAttributedStringEnumerateAttributeReverse)
{
    __block NSUInteger found = 0;
    __block NSUInteger count = 0;
    __block NSInteger previous = INT_MAX;
    __block BOOL orderOK = YES;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"My string."];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColorish redColor] range:NSMakeRange(1,4)];
    
    [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, 6)
                                 options:NSAttributedStringEnumerationReverse
                              usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         if (range.location >= previous)
         {
             orderOK = NO;
         }
         found |= val != nil ? 1 : 0;
         count++;
     }];
    testassert(orderOK);
    testassert(count == 3);
    testassert(found == 1);
    
    count = 0;
    found = 0;
    
    NSAttributedString *selectedString = [attributedString attributedSubstringFromRange:NSMakeRange(1,4)];
    [attributedString release];
    
    [selectedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, [selectedString length])
                               options:NSAttributedStringEnumerationReverse
                            usingBlock:^(id val, NSRange range, BOOL *stop)
     {
         found = val != nil ? 1 : 0;
         count++;
     }];
    
    testassert(count == 1);
    testassert(found == 1);
    return YES;
}

test(NSAttributedStringEmpty)
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@""];
    int length = [str length];
    testassert(length == 0);
    [str release];
    return YES;
}


test(NSAttributedStringRemoveAttribute)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"
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

test(NSAttributedStringSetAttributeString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy"];
    
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

test(NSAttributedStringDeleteCharactersInRange)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"stringy1" attributes:attrsDictionary];
    
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


test(NSAttributedStringAppendAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abc" attributes:attrsDictionary];
    
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

test(NSAttributedStringInsertAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abc" attributes:attrsDictionary];
    
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


test(NSAttributedStringInsertAttributedString2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abcd" attributes:attrsDictionary];
    
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

test(NSAttributedStringReplaceCharactersInRange)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abc" attributes:attrsDictionary];
    
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

test(NSAttributedStringSetAttributes)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abcdefghij"];
    
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


test(NSAttributedStringSetAttributesAndCopy)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    [attrString setAttributes:attrsDictionary range:NSMakeRange(3, 5)];
    
    NSAttributedString *as2 = [attrString copy];
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


test(NSAttributedStringSetAttributesAndMutableCopy)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abcdefghij"];
    
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,4)];
    NSMutableAttributedString *as2 = [attrString mutableCopy];
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

test(NSAttributedStringEquals)
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"abc"];
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:@"abc"];
    testassert([attrString isEqual:attrString2]);
    testassert([attrString isEqualToAttributedString:attrString2]);
    [attrString2 release];
    NSAttributedString *attrString3 = [[NSMutableAttributedString alloc] initWithString:@"abcd"];
    testassert(![attrString isEqual:attrString3]);
    [attrString release];
    [attrString3 release];
    return YES;
}

test(NSAttributedStringEquals2)
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"abc"];
    NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:@"abc"];
    testassert([attrString isEqual:attrString2]);
    [attrString2 addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    testassert(![attrString isEqual:attrString2]);
    [attrString release];
    [attrString2 release];
    return YES;
}

test(NSAttributedStringGetMutableString)
{
    NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:@"ABCDEFGHIJ"] autorelease];

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

test(NSAttributedStringHash)
{
    int expectedHash = 516202353;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"abc"];
    testassert([attrString hash] == expectedHash);
    testassert([[attrString string] hash] == expectedHash);
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColorish blueColor] range:NSMakeRange(1,1)];
    testassert([attrString hash] == expectedHash);
    testassert([[attrString string] hash] == expectedHash);
    return YES;
}

#endif

@end
