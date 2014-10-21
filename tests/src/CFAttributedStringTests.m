//
//  CFAttributedString.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//


#import "FoundationTests.h"
#import <CoreFoundation/CFAttributedString.h>
#import "NSAttributedStringHelper.h"

@testcase(CFAttributedString)

test(CFAttributedStringString)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("My string."), NULL);
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"My string."]);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringLength)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("My string"), NULL);
    testassert(CFAttributedStringGetLength(str) == 9);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithStringAttributed)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("stringy"), (CFDictionaryRef)attrsDictionary);
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"stringy"]);
    CFAttributedStringRef color2 = CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSFontAttributeName, NULL);
    testassert([color isEqual:(UIColorish *)color2]);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithAttributedString)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    CFAttributedStringRef preAttrString = CFAttributedStringCreate(NULL, CFSTR("stringy 123"), (CFDictionaryRef)attrsDictionary);
    
    CFAttributedStringRef attrString = CFAttributedStringCreateCopy(kCFAllocatorDefault, preAttrString);
    CFRelease(preAttrString);
    testassert([(NSString *)CFAttributedStringGetString(attrString) isEqualToString:@"stringy 123"]);
    CFAttributedStringRef color2 = CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSFontAttributeName, NULL);
    testassert([color isEqual:(UIColorish *)color2]);
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedEffective)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, CFSTR("stringy"), (CFDictionaryRef)attrsDictionary);
    
    CFRange range;
    CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 0 && range.length == 7);
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedEffectiveAttributesEmpty)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("stringy"), NULL);
    CFRange range;
    CFDictionaryRef d = CFAttributedStringGetAttributes(str, 2, &range);
    testassert(range.location == 0 && range.length == 7);
    testassert([(NSDictionary *)d count] == 0);
    
    d = CFAttributedStringGetAttributes(str, 5, &range);
    testassert(range.location == 0 && range.length == 7);
    testassert([(NSDictionary *)d count] == 0);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedEffectiveAttributesEmptyMutable)
{
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringy"), NULL);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 0, s);
    CFRelease(s);
    CFRange range;
    CFAttributedStringGetAttributes(str, 5, &range);
    testassert(range.location == 0 && range.length == 7);
    
    range = __CFRangeMake( 3, 2 );
    CFAttributedStringSetAttribute(str, range, CFSTR("abc"), [UIColorish yellowColor] );

    CFAttributedStringGetAttributes(str, 1, &range);
    testassert(range.location == 0 && range.length == 3);
    
    CFAttributedStringGetAttributes(str, 6, &range);
    testassert(range.location == 5 && range.length == 2);
    
    CFDictionaryRef d = CFAttributedStringGetAttributes(str, 0, &range);
    testassert(range.location == 0 && range.length == 3);
    testassert([(NSDictionary *)d count] == 0);
    
    id obj = CFAttributedStringGetAttribute(str, 5, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 5 && range.length == 2);
    testassert(obj == NULL);
    
    CFRelease(str);
    return YES;
}


test(CFAttributedStringStringMutable)
{
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("My string."), NULL);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"My string."]);
    testassert(CFAttributedStringGetLength(str) == 10);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedMutable)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringy"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    
    CFRange range;
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"stringy"]);
    CFAttributedStringRef color2 = CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSFontAttributeName, &range);
    testassert([color isEqual:(UIColorish *)color2]);
    testassert(range.location == 0 && range.length == 7);
    CFRelease(str);
    return YES;
}


test(CFAttributedStringInitWithStringAttributedEffectiveMutable2)
{
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringy"), NULL);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 0, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake( 3, 2 );
    CFAttributedStringSetAttribute(str, range, CFSTR("abc"), [UIColorish yellowColor] );
    
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"stringy"]);
    
    CFAttributedStringGetAttribute(str, 3, CFSTR("abc"), &range);
    testassert(range.location == 3 && range.length == 2);
    
    CFAttributedStringGetAttribute(str, 2, CFSTR("abc"), &range);
    testassert(range.location == 0 && range.length == 3);
    
    CFAttributedStringRef color2 = CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 0 && range.length == 3);
    testassert(color2 == nil);
    
    color2 = CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 3 && range.length == 2);
    testassert(color2 == nil);
    
    CFAttributedStringGetAttribute(str, 6, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 5 && range.length == 2);
    
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedOverlap)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake( 3, 2 );
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake( 4, 4 );
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    
    
    testassert(CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSBackgroundColorAttributeName, &range) == NULL);
    testassert(CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range) == yellow);
    testassert(range.location == 3 && range.length == 1);
    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSBackgroundColorAttributeName, &range) == blue);
    testassert(CFAttributedStringGetAttribute(str, 5, (CFStringRef)NSBackgroundColorAttributeName, &range) == blue);
    testassert(CFAttributedStringGetAttribute(str, 6, (CFStringRef)NSBackgroundColorAttributeName, &range) == blue);
    testassert(CFAttributedStringGetAttribute(str, 7, (CFStringRef)NSBackgroundColorAttributeName, &range) == blue);
    testassert(CFAttributedStringGetAttribute(str, 8, (CFStringRef)NSBackgroundColorAttributeName, &range) == NULL);

    range = __CFRangeMake( 5, 2 );
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    testassert(CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSBackgroundColorAttributeName, &range) == NULL);
    testassert(CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range) == yellow);
    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSBackgroundColorAttributeName, &range) == blue);
    testassert(CFAttributedStringGetAttribute(str, 5, (CFStringRef)NSBackgroundColorAttributeName, &range) == yellow);
    testassert(CFAttributedStringGetAttribute(str, 6, (CFStringRef)NSBackgroundColorAttributeName, &range) == yellow);
    testassert(CFAttributedStringGetAttribute(str, 7, (CFStringRef)NSBackgroundColorAttributeName, &range) == blue);
    
    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSFontAttributeName, &range) == yellow);
    
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithStringAttributes)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), NULL);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    
    NSDictionary *d = (NSDictionary *)CFAttributedStringGetAttributes(str, 0, NULL);
    testassert([d count] == 0);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 1, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 3, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 5, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 6, NULL) count] == 0);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringRemoveAttribute)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    
    testassert(CFAttributedStringGetAttribute(str, 1, (CFStringRef)NSBackgroundColorAttributeName, NULL) == blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 1, (CFStringRef)NSBackgroundColorAttributeName, NULL) == NULL);
    testassert(CFAttributedStringGetAttribute(str, 1, (CFStringRef)NSForegroundColorAttributeName, NULL) == orange);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 0, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 2, NULL) count] == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 3, NULL) count] == 3);

    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSFontAttributeName, NULL) == yellow);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(3,5), (CFStringRef)NSFontAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSFontAttributeName, NULL) == NULL);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 2, NULL) count] == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 3, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 5, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 6, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 7, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 8, NULL) count] == 2);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringRemoveAttributeImmutable)  // Only typing keeps immutable - immutable!
{
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = (CFMutableAttributedStringRef)s;
    
    testassert(CFAttributedStringGetAttribute(str, 1, (CFStringRef)NSBackgroundColorAttributeName, NULL) == blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 1, (CFStringRef)NSBackgroundColorAttributeName, NULL) == NULL);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringReplaceAttributedStringEmpty)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 3);
    s = CFAttributedStringCreate(NULL, CFSTR(""), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str2 = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 3);
    CFRelease(s);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 3);
    CFAttributedStringReplaceAttributedString(str2, __CFRangeMake(0,0), str);
   
    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSFontAttributeName, NULL) == yellow);
    testassert(CFAttributedStringGetAttribute(str2, 4, (CFStringRef)NSFontAttributeName, NULL) == yellow);
    CFAttributedStringRemoveAttribute(str2, __CFRangeMake(3,5), (CFStringRef)NSFontAttributeName);
    testassert(CFAttributedStringGetAttribute(str2, 4, (CFStringRef)NSFontAttributeName, NULL) == NULL);
    testassert(CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSFontAttributeName, NULL) == yellow);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 2, NULL) count] == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 3, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 3);
    CFRelease(str);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 4, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 5, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 6, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 7, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 8, NULL) count] == 2);
    CFRelease(str2);
    return YES;
}

test(CFAttributedStringReplaceAttributedStringEnd)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    
    s = CFAttributedStringCreate(NULL, CFSTR("ABC"), NULL);
    CFMutableAttributedStringRef str2 = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFAttributedStringReplaceAttributedString(str2, __CFRangeMake(3,0), str);
    
    testassert([(NSString *)CFAttributedStringGetString(str2) isEqualToString:@"ABCstringyabc"]);
    
    testassert(CFAttributedStringGetAttribute(str2, 7, (CFStringRef)NSFontAttributeName, NULL) == yellow);
    CFAttributedStringRemoveAttribute(str2, __CFRangeMake(6,5), (CFStringRef)NSFontAttributeName);
    testassert(CFAttributedStringGetAttribute(str2, 7, (CFStringRef)NSFontAttributeName, NULL) == NULL);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 1, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 4, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 5, NULL) count] == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 6, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 7, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 8, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 9, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 10, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 11, NULL) count] == 2);
    CFRelease(str);
    return YES;
}


test(CFAttributedStringReplaceAttributedStringMiddle)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    
    s = CFAttributedStringCreate(NULL, CFSTR("ABC"), NULL);
    CFMutableAttributedStringRef str2 = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFAttributedStringReplaceAttributedString(str2, __CFRangeMake(1,1), str);
    
    testassert([(NSString *)CFAttributedStringGetString(str2) isEqualToString:@"AstringyabcC"]);
    
    testassert(CFAttributedStringGetAttribute(str2, 5, (CFStringRef)NSFontAttributeName, NULL) == yellow);
    CFAttributedStringRemoveAttribute(str2, __CFRangeMake(4,5), (CFStringRef)NSFontAttributeName);
    testassert(CFAttributedStringGetAttribute(str2, 5, (CFStringRef)NSFontAttributeName, NULL) == NULL);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 3, NULL) count] == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 4, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 5, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 6, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 7, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 8, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str2, 9, NULL) count] == 2);
    CFRelease(str);
    return YES;
}


test(CFAttributedStringReplaceAttributedStringSmaller)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    
    s = CFAttributedStringCreate(NULL, CFSTR("ABC"), NULL);
    CFMutableAttributedStringRef str2 = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFAttributedStringReplaceAttributedString(str, __CFRangeMake(1,7), str2);
    
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"sABCbc"]);
    
    range = __CFRangeMake(2, 1);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, orange);
    
    testassert(CFAttributedStringGetAttribute(str, 5, (CFStringRef)NSBackgroundColorAttributeName, NULL) == blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(5,1), (CFStringRef)NSBackgroundColorAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 5, (CFStringRef)NSBackgroundColorAttributeName, NULL) == NULL);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 0, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 1, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 3, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 4, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 5, NULL) count] == 1);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringReplaceAttributedStringSelfMutableCopy)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 0, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    
    CFAttributedStringRef str2 = CFAttributedStringCreateMutableCopy(NULL, 0, str);
    
    CFAttributedStringReplaceAttributedString(str, __CFRangeMake(3,1), str2);
    CFRelease(str2);
    
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"strstringyabcngyabc"]);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 0, &range) count] == 2);
    testassert(range.location == 0 && range.length == 1);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 9, &range) count] == 2);
    testassert(range.location == 8 && range.length == 5);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, &range) count] == 3);
    testassert(range.location == 13 && range.length == 1);
    
    testassert(CFAttributedStringGetAttribute(str, 15, (CFStringRef)NSForegroundColorAttributeName, NULL) == orange);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(11,5), (CFStringRef)NSForegroundColorAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 15, (CFStringRef)NSForegroundColorAttributeName, NULL) == NULL);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 14, &range) count] == 1);
    testassert(range.location == 14 && range.length == 2);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 10, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 11, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 12, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 14, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 15, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 16, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 17, NULL) count] == 2);
    CFRelease(str);
    
    return YES;
}

test(CFAttributedStringReplaceAttributedStringSelfMutableCopyMergingAfterInsert)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 0, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    
    CFAttributedStringRef str2 = CFAttributedStringCreateMutableCopy(NULL, 0, str);
    
    CFAttributedStringReplaceAttributedString(str, __CFRangeMake(1,2), str2);
    CFRelease(str2);
    
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"sstringyabcingyabc"]);
    
    // Check beginning and end merges
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 0, &range) count] == 2);
    testassert(range.location == 0 && range.length == 2);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 9, &range) count] == 2);
    testassert(range.location == 6 && range.length == 5);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, &range) count] == 2);
    testassert(range.location == 13 && range.length >= 1);  // iOS doesn't merge at end in this case
    
    testassert(CFAttributedStringGetAttribute(str, 15, (CFStringRef)NSForegroundColorAttributeName, NULL) == orange);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(11,5), (CFStringRef)NSForegroundColorAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 15, (CFStringRef)NSForegroundColorAttributeName, NULL) == NULL);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, &range) count] == 1);
    testassert(range.location == 13 && range.length == 3);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 10, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 11, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 12, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 14, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 15, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 16, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 17, NULL) count] == 2);
    CFRelease(str);
    
    testassert(CFGetRetainCount(dict) == 1);
    return YES;
}

test(CFAttributedStringReplaceAttributedStringSelfImmutable)
{
    UIColorish *yellow = [UIColorish yellowColor];
    UIColorish *blue = [UIColorish blueColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 0, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(2, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, yellow);
    range = __CFRangeMake(3, 3);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, blue);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(1,1), (CFStringRef)NSBackgroundColorAttributeName);
    
    CFAttributedStringRef str2 = CFAttributedStringCreateCopy(NULL, str);

    CFAttributedStringReplaceAttributedString(str, __CFRangeMake(1,2), str2);
    CFRelease(str2);
    
    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"sstringyabcingyabc"]);
    
    // Check beginning and end merges
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 0, &range) count] == 2);
    testassert(range.location == 0 && range.length == 2);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 9, &range) count] == 2);
    testassert(range.location == 6 && range.length == 5);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, &range) count] == 2);
    testassert(range.location == 13 && range.length >= 1); // iOS doesn't merge at end in this case
    
    testassert(CFAttributedStringGetAttribute(str, 15, (CFStringRef)NSForegroundColorAttributeName, NULL) == orange);
    CFAttributedStringRemoveAttribute(str, __CFRangeMake(11,5), (CFStringRef)NSForegroundColorAttributeName);
    testassert(CFAttributedStringGetAttribute(str, 15, (CFStringRef)NSForegroundColorAttributeName, NULL) == NULL);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, &range) count] == 1);
    testassert(range.location == 13 && range.length == 3);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 10, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 11, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 12, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 13, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 14, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 15, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 16, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(str, 17, NULL) count] == 2);
    CFRelease(str);
    return YES;
}


test(CFAttributedStringInitWithStringAttributedEffectiveMutableMerge1)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];

    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    CFRange range = __CFRangeMake(3, 1);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, color);
    
    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    range = __CFRangeMake(2, 1);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, color);

    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 2 && range.length == 2);
    
    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert((range.location == 2 || range.location == 3) && range.length >= 1);
    
    CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 2 && range.length == 2);
    
    range = __CFRangeMake(2, 1);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, [UIColorish blueColor]);
    
    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 2 && range.length == 1);
    
    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedEffectiveMutableMerge2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3, 1);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, color);

    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    range = __CFRangeMake(4, 2);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSBackgroundColorAttributeName, color);
    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 3);
    
    id foo = CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    range = __CFRangeMake(4,1);
    CFAttributedStringSetAttribute(str, range, (CFStringRef)NSFontAttributeName, [UIColorish blueColor]);
    
    CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    CFAttributedStringGetAttribute(str, 4, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 4 && range.length == 1);

    CFRelease(str);
    return YES;
}

test(CFAttributedStringInitWithAttributedStringAttributedEffectiveMutableMerge2)
{
    UIColorish *color = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:color forKey:NSFontAttributeName];
    
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef preStr = CFAttributedStringCreateMutableCopy(NULL, 19, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3, 1);
    CFAttributedStringSetAttribute(preStr, range, (CFStringRef)NSBackgroundColorAttributeName, color);
    
    CFAttributedStringGetAttribute(preStr, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);

    range = __CFRangeMake(4, 2);
    CFAttributedStringSetAttribute(preStr, range, (CFStringRef)NSBackgroundColorAttributeName, color);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, preStr);
    CFRelease(preStr);
    
    CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 3);
    
    id foo = CFAttributedStringGetAttribute(attrString, 2, (CFStringRef)NSBackgroundColorAttributeName, &range);;
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    range = __CFRangeMake(4,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSFontAttributeName, [UIColorish blueColor]);
    
    CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    CFAttributedStringGetAttribute(attrString, 4, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 4 && range.length == 1);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithAttributedStringAttributedEffectiveMutableMergeFromImmutable)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    
    CFRange range;
    UIColorish *color = CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSFontAttributeName, &range);
    testassert(color == yellow);
    
    range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    testassert([(NSString *)CFAttributedStringGetString(attrString) isEqualToString:@"stringyabc"]);
    
    CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    range = __CFRangeMake(4,2);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 3);
    
    CFAttributedStringGetAttribute(s, 3, (CFStringRef)NSFontAttributeName, &range);
    testassert(range.location == 0 && range.length == 10);
    CFRelease(s);
    
    id foo = CFAttributedStringGetAttribute(attrString, 2, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(foo == nil);
    testassert(range.location == 0 && range.length == 3);
    
    range = __CFRangeMake(4,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSFontAttributeName, [UIColorish blueColor]);
    
    CFAttributedStringGetAttribute(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 3 && range.length == 1);
    
    CFAttributedStringGetAttribute(attrString, 4, (CFStringRef)NSBackgroundColorAttributeName, &range);
    testassert(range.location == 4 && range.length == 1);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveAttribute)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake(1, 3);
    CFRange effRange = __CFRangeMake(1,2);
    id val = CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(range.location == 1 && range.length == 3);
    testassert(effRange.location == 3 && effRange.length == 1);
    testassert(val == yellow);
    
    CFRelease(attrString);
    return YES;
}


test(CFAttributedStringInitWithStringAttributedLongestEffectiveAttributes)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake(1, 3);
    CFRange effRange = __CFRangeMake(1,2);
    NSDictionary *dict = (NSDictionary *)CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 3, range, &effRange);
    testassert(range.location == 1 && range.length == 3);
    testassert(effRange.location == 3 && effRange.length == 1);
    testassert([dict count] == 2);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveMutableMiss)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake(4, 2);
    CFRange effRange = __CFRangeMake(1,2);
    id val = CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(range.location == 4 && range.length == 2);
    testassert(effRange.location == 4 && effRange.length == 0);
    testassert(val == yellow);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveMutableMissHigh)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake(5, 2);
    CFRange effRange = __CFRangeMake(1,2);
    id val = CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(range.location == 5 && range.length == 2);
    testassert(effRange.location == 5 && effRange.length == -1);
    testassert(val == yellow);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveMutableMissLow)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake(0, 1);
    CFRange effRange = __CFRangeMake(1,2);
    id val = CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(range.location == 0 && range.length == 1);
    testassert(effRange.location == 3 && effRange.length == -2);
    testassert(val == yellow);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveAttributes2)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange range = __CFRangeMake(3,1);
    CFAttributedStringSetAttribute(attrString, range, (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    range = __CFRangeMake(4, 2);
    CFRange effRange = __CFRangeMake(1,2);
    NSDictionary *dict = (NSDictionary *)CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 3, range, &effRange);
    testassert(range.location == 4 && range.length == 2);
    testassert(effRange.location == 4 && effRange.length == 0);
    testassert([dict count] == 2);
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveMutable)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange effRange;
    CFRange range = __CFRangeMake(0, 6);
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(3,1), (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(effRange.location == 3 && effRange.length == 1);
    
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(2,1), (CFStringRef)NSBackgroundColorAttributeName, yellow);
    CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 3, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    
    CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 2, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(2,1), (CFStringRef)@"foo", yellow);
    CFAttributedStringGetAttributeAndLongestEffectiveRange(attrString, 2, (CFStringRef)NSBackgroundColorAttributeName, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringInitWithStringAttributedLongestEffectiveMutableAttributes)
{
    UIColorish *yellow = [UIColorish yellowColor];
    NSDictionary *attrsDictionary =  [NSDictionary dictionaryWithObject:yellow forKey:NSFontAttributeName];
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), (CFDictionaryRef)attrsDictionary);
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    
    CFRange effRange;
    CFRange range = __CFRangeMake(0, 6);
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(3,1), (CFStringRef)NSBackgroundColorAttributeName, yellow);
    
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 3, range, &effRange);
    testassert(effRange.location == 3 && effRange.length == 1);
    
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(2,1), (CFStringRef)NSBackgroundColorAttributeName, yellow);
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 3, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 2, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(2,1), (CFStringRef)@"foo", [UIColorish redColor]);
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 2, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 1);
    
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 3, range, &effRange);
    testassert(effRange.location == 3 && effRange.length == 1);
    
    CFAttributedStringSetAttribute(attrString, __CFRangeMake(3,1), (CFStringRef)@"foo", [UIColorish redColor]);
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 2, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    
    CFAttributedStringGetAttributesAndLongestEffectiveRange(attrString, 3, range, &effRange);
    testassert(effRange.location == 2 && effRange.length == 2);
    
    CFRelease(attrString);
    return YES;
}

test(CFAttributedStringAttribute)
{
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringyabc"), NULL);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, 33, s);
    CFRelease(s);
    CFAttributedStringSetAttribute(str, __CFRangeMake(3,5), (CFStringRef)NSBackgroundColorAttributeName, [UIColorish yellowColor]);
    CFRange effRange;
    testassert(CFAttributedStringGetAttribute(str, 0, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == nil);
    testassert(CFAttributedStringGetAttribute(str, 2, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == nil);
    testassert(CFAttributedStringGetAttribute(str, 3, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == [UIColorish yellowColor]);
    testassert(CFAttributedStringGetAttribute(str, 5, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == [UIColorish yellowColor]);
    testassert(CFAttributedStringGetAttribute(str, 7, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == [UIColorish yellowColor]);
    testassert(CFAttributedStringGetAttribute(str, 8, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == nil);
    testassert(CFAttributedStringGetAttribute(str, 9, (CFStringRef)NSBackgroundColorAttributeName, &effRange) == nil);
    CFRelease(str);
    return YES;
}


test(CFAttributedStringCopy)
{
    UIColorish *red = [UIColorish redColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName: red};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), (CFDictionaryRef)dict);
    CFAttributedStringRef attributedString = CFAttributedStringCreateCopy(NULL, preCopy);
    CFRelease(preCopy);
    
    CFRange effRange;
    UIColorish *color = CFAttributedStringGetAttribute(attributedString, 3, (CFStringRef)NSForegroundColorAttributeName, &effRange);
    testassert(color == red);
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My string."]);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringMutableCopy)
{
    UIColorish *red = [UIColorish redColor];
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    
    CFRange effRange;
    UIColorish *color = CFAttributedStringGetAttribute(attributedString, 3, (CFStringRef)NSForegroundColorAttributeName, &effRange);
    testassert(color == orange);
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My string."]);
    
    CFAttributedStringSetAttribute(attributedString, __CFRangeMake(2,2), (CFStringRef)NSBackgroundColorAttributeName, red);
    CFAttributedStringRef selectedString = CFAttributedStringCreateWithSubstring(kCFAllocatorDefault, attributedString,__CFRangeMake(1,4));
    CFRelease(attributedString);
    
    color = CFAttributedStringGetAttribute(selectedString, 2, (CFStringRef)NSBackgroundColorAttributeName, NULL);
    testassert(color == red);
    
    color = CFAttributedStringGetAttribute(selectedString, 2, (CFStringRef)NSForegroundColorAttributeName, NULL);
    testassert(color == orange);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 0, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 1, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 2, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 3, NULL) count] == 1);

    CFRelease(selectedString);
    return YES;
}

test(CFAttributedStringMutable)
{
    UIColorish *red = [UIColorish redColor];
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutable(NULL, 0);
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(0,0), CFSTR("My string."));
    testassert(CFAttributedStringGetLength(attributedString) == 10);

    CFRange effRange;
    UIColorish *color = CFAttributedStringGetAttribute(attributedString, 3, (CFStringRef)NSForegroundColorAttributeName, &effRange);
    testassert(color == NULL);
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My string."]);
    
    CFAttributedStringSetAttribute(attributedString, __CFRangeMake(2,2), (CFStringRef)NSBackgroundColorAttributeName, red);
    
    CFAttributedStringRef selectedString = CFAttributedStringCreateWithSubstring(kCFAllocatorDefault, attributedString,__CFRangeMake(1,4));
    CFRelease(attributedString);
    
    color = CFAttributedStringGetAttribute(selectedString, 2, (CFStringRef)NSBackgroundColorAttributeName, NULL);
    testassert(color == red);
    
    color = CFAttributedStringGetAttribute(selectedString, 2, (CFStringRef)NSForegroundColorAttributeName, NULL);
    testassert(color == NULL);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 3, NULL) count] == 0);
    
    CFRelease(selectedString);
    return YES;
}

test(CFAttributedStringCreateMutableLimit) // Despite the docs saying otherwise iOS seems to ignore the limit param
{
    UIColorish *red = [UIColorish redColor];
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutable(NULL, 1);
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(0,0), CFSTR("My string."));
    testassert(CFAttributedStringGetLength(attributedString) == 10);
    
    CFRange effRange;
    UIColorish *color = CFAttributedStringGetAttribute(attributedString, 3, (CFStringRef)NSForegroundColorAttributeName, &effRange);
    testassert(color == NULL);
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My string."]);
    
    CFAttributedStringSetAttribute(attributedString, __CFRangeMake(2,2), (CFStringRef)NSBackgroundColorAttributeName, red);
    
    CFAttributedStringRef selectedString = CFAttributedStringCreateWithSubstring(kCFAllocatorDefault, attributedString, __CFRangeMake(1,4));
    CFRelease(attributedString);
    
    color = CFAttributedStringGetAttribute(selectedString, 2, (CFStringRef)NSBackgroundColorAttributeName, NULL);
    testassert(color == red);
    
    color = CFAttributedStringGetAttribute(selectedString, 2, (CFStringRef)NSForegroundColorAttributeName, NULL);
    testassert(color == NULL);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(selectedString, 3, NULL) count] == 0);
    CFRelease(selectedString);
    
    return YES;
}

test(CFAttributedStringReplaceString)
{
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(2, 2), CFSTR(" BIG S"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My BIG String."]);
    testassert(CFAttributedStringGetLength(attributedString) == 14);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringEnd)
{
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(10, 0), CFSTR("ABCD"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My string.ABCD"]);
    testassert(CFAttributedStringGetLength(attributedString) == 14);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 9, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 10, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 11, NULL) count] == 1);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringAttributesCheck)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *red = [UIColorish redColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    CFAttributedStringSetAttribute(attributedString, __CFRangeMake(5,2), (CFStringRef)NSBackgroundColorAttributeName, red);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(2, 2), CFSTR(" BIG S"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My BIG String."]);
    testassert(CFAttributedStringGetLength(attributedString) == 14);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 3, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 4, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 5, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 6, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 7, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 8, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 9, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 10, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 11, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 12, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 13, NULL) count] == 1);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringAttributesAtZero)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR(""), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(0, 0), CFSTR("ABC"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"ABC"]);
    testassert(CFAttributedStringGetLength(attributedString) == 3);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 0);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringAttributesAtZero2)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("Z"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(0, 0), CFSTR("ABC"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"ABCZ"]);
    testassert(CFAttributedStringGetLength(attributedString) == 4);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 3, NULL) count] == 2);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringAttributesWithZeroLen)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("Z"), NULL);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(0, 1), CFSTR(""));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@""]);
    testassert(CFAttributedStringGetLength(attributedString) == 0);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(0, 0), CFSTR("ABC"));
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"ABC"]);
    testassert(CFAttributedStringGetLength(attributedString) == 3);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 0);
    CFAttributedStringSetAttributes(attributedString, __CFRangeMake(1,1), (CFDictionaryRef)dict, false);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 0);
    CFRelease(attributedString);
    return YES;
}


test(CFAttributedStringReplaceStringAttributesZeroLen)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("XYZ"), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(1, 0), CFSTR("ABC"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"XABCYZ"]);
    testassert(CFAttributedStringGetLength(attributedString) == 6);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 3, NULL) count] == 2);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringSmaller)
{
    UIColorish *orange = [UIColorish orangeColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), (CFDictionaryRef)dict);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(2, 5), CFSTR("ab"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"Myabng."]);
    testassert(CFAttributedStringGetLength(attributedString) == 7);
    CFRelease(attributedString);
    return YES;
}


test(CFAttributedStringReplaceStringAttributesCheckMix)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *red = [UIColorish redColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), NULL);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    CFAttributedStringSetAttribute(attributedString, __CFRangeMake(1,2), (CFStringRef)NSBackgroundColorAttributeName, red);
    CFAttributedStringSetAttributes(attributedString, __CFRangeMake(3,2), (CFDictionaryRef)dict, false);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(2, 2), CFSTR(" BIG S"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My BIG String."]);
    testassert(CFAttributedStringGetLength(attributedString) == 14);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 3, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 4, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 5, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 6, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 7, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 8, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 9, NULL) count] == 0);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringReplaceStringAttributesCheckMixWithDeleteRun)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *red = [UIColorish redColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef preCopy = CFAttributedStringCreate(NULL, CFSTR("My string."), NULL);
    CFMutableAttributedStringRef attributedString = CFAttributedStringCreateMutableCopy(NULL, 0, preCopy);
    CFRelease(preCopy);
    CFAttributedStringSetAttribute(attributedString, __CFRangeMake(1,2), (CFStringRef)NSBackgroundColorAttributeName, red);
    CFAttributedStringSetAttributes(attributedString, __CFRangeMake(3,2), (CFDictionaryRef)dict, false);
    CFAttributedStringSetAttributes(attributedString, __CFRangeMake(8,2), (CFDictionaryRef)dict, false);
    
    CFAttributedStringReplaceString(attributedString, __CFRangeMake(2, 5), CFSTR(" BIG S"));
    
    testassert([(NSString *)CFAttributedStringGetString(attributedString) isEqualToString:@"My BIG Sng."]);
    testassert(CFAttributedStringGetLength(attributedString) == 11);
    
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 0, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 1, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 2, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 3, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 4, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 5, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 6, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 7, NULL) count] == 1);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 8, NULL) count] == 0);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 9, NULL) count] == 2);
    testassert([(NSDictionary *)CFAttributedStringGetAttributes(attributedString, 10, NULL) count] == 2);
    CFRelease(attributedString);
    return YES;
}

test(CFAttributedStringGetMutableString)
{
    CFAttributedStringRef s = CFAttributedStringCreate(NULL, CFSTR("stringy"), NULL);
    CFMutableAttributedStringRef str = CFAttributedStringCreateMutableCopy(NULL, 0, s);
    
    CFMutableStringRef stringRef = CFAttributedStringGetMutableString(str);
    testassert(stringRef == nil);  // This is nil on iOS!

//    Add the tests below if iOS starts behaving as documented
//    CFStringReplace(stringRef, __CFRangeMake(1,1), CFSTR("AB"));
//    testassert([(NSString *)stringRef isEqualToString:@"sABringy"]);
//    testassert([(NSString *)CFAttributedStringGetString(str) isEqualToString:@"sABringy"]);
//    
//    CFRange range;
//    CFAttributedStringGetAttributes(str, 5, &range);
//    testassert(range.location == 0 && range.length == 8);
    return YES;
}

test(CFAttributedStringEmpty)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR(""), NULL);
    testassert(CFAttributedStringGetLength(str) == 0);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringCFRetain)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR(""), NULL);
    testassert(CFGetRetainCount(str) == 1);
    CFRetain(str);
    testassert(CFGetRetainCount(str) == 2);
    CFRelease(str);
    testassert(CFGetRetainCount(str) == 1);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringCFEquals)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("abc"), NULL);
    CFAttributedStringRef str2 = CFAttributedStringCreate(NULL, CFSTR("abc"), NULL);
    testassert(CFEqual(str, str2));
    CFRelease(str2);
    CFMutableAttributedStringRef str3 = CFAttributedStringCreateMutableCopy(NULL, 0, str);
    testassert(CFEqual(str, str3));
    CFAttributedStringSetAttribute(str3, __CFRangeMake(1,1), CFSTR("abcddee"), [UIColorish yellowColor] );
    testassert(CFEqual(str, str3) == false);
    CFRelease(str3);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringCFEquals2)
{
    UIColorish *orange = [UIColorish orangeColor];
    UIColorish *blue = [UIColorish blueColor];
    NSDictionary *dict = @{NSForegroundColorAttributeName:orange, NSBackgroundColorAttributeName:blue};
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("abc"), (CFDictionaryRef)dict);
    CFAttributedStringRef str2 = CFAttributedStringCreate(NULL, CFSTR("abc"), (CFDictionaryRef)dict);
    testassert(CFEqual(str, str2));
    CFRelease(str2);
    CFMutableAttributedStringRef str3 = CFAttributedStringCreateMutableCopy(NULL, 0, str);
    testassert(CFEqual(str, str3));
    CFAttributedStringSetAttribute(str3, __CFRangeMake(1,1), CFSTR("abcddee"), [UIColorish yellowColor]);
    testassert(CFEqual(str, str3) == false);
    CFRelease(str3);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringCFHash)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR("abc"), NULL);
    CFAttributedStringRef str2 = CFAttributedStringCreate(NULL, CFSTR("abc"), NULL);
    testassert(CFHash(str) == CFHash(str2));
    CFRelease(str2);
    CFMutableAttributedStringRef str3 = CFAttributedStringCreateMutableCopy(NULL, 0, str);
    testassert(CFEqual(str, str3));
    CFAttributedStringSetAttribute(str3, __CFRangeMake(1,1), CFSTR("abcddee"), [UIColorish yellowColor] );
    testassert(CFHash(str) == CFHash(str3));   // Attributes have no effect on hash
    CFAttributedStringRef str4 = CFAttributedStringCreate(NULL, CFSTR("abcd"), NULL);
    testassert(CFHash(str) != CFHash(str4));
    CFRelease(str4);
    CFRelease(str3);
    CFRelease(str);
    return YES;
}

test(CFAttributedStringCFAttributedStringCopyDescription)
{
    CFAttributedStringRef str = CFAttributedStringCreate(NULL, CFSTR(""), NULL);
    CFStringRef desc = CFCopyDescription(str);
    testassert([(NSString *)desc isEqualToString:@""]);
    return YES;
}

@end

