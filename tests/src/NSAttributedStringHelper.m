//
//  NSAttributedStringHelper.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSAttributedStringHelper.h"


// Avoid including UIKit to test Foundation

@implementation UIColorish

+(id)yellowColor
{
    return @1;
}

+(id)blueColor
{
    return @2;
}

+(id)redColor
{
    return @3;
}

+(id)greenColor
{
    return @4;
}

+(id)orangeColor
{
    return @4;
}

+ (id)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    if (red == 1 && green == 0 && blue == 0 && alpha == 1)
    {
        return @3;
    }
    return @5;
}

@end

NSString *const NSFontAttributeName = @"NSFont";
NSString *const NSBackgroundColorAttributeName = @"NSBackground";
NSString *const NSForegroundColorAttributeName = @"NSForeground";
