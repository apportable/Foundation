//
//  NSAttributedStringHelper.h
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//


// Avoid including UIKit to test Foundation

@interface UIColorish : NSObject
+(id)yellowColor;
+(id)blueColor;
+(id)redColor;
+(id)greenColor;
+(id)orangeColor;
+(id)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
@end

extern NSString *const NSFontAttributeName;
extern NSString *const NSBackgroundColorAttributeName;
extern NSString *const NSForegroundColorAttributeName;
