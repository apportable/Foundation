//
//  NSExternals.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExternals.h"
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import <dispatch/dispatch.h>

NSString *const NS_objects =  @"NS.objects";
NSString *const NS_keys =  @"NS.keys";
NSString *const NS_special =  @"NS.special";
NSString *const NS_pointval =  @"NS.pointval";
NSString *const NS_sizeval =  @"NS.sizeval";
NSString *const NS_rectval =  @"NS.rectval";
NSString *const NS_rangeval_length =  @"NS.rangeval.length";
NSString *const NS_rangeval_location =  @"NS.rangeval.location";
NSString *const NS_atval_a =  @"NS.atval.a";
NSString *const NS_atval_b =  @"NS.atval.b";
NSString *const NS_atval_c =  @"NS.atval.c";
NSString *const NS_atval_d =  @"NS.atval.d";
NSString *const NS_atval_tx =  @"NS.atval.tx";
NSString *const NS_atval_ty =  @"NS.atval.ty";
NSString *const NS_edgeval_top =  @"NS.edgeval.top";
NSString *const NS_edgeval_left =  @"NS.edgeval.left";
NSString *const NS_edgeval_bottom =  @"NS.edgeval.bottom";
NSString *const NS_edgeval_right =  @"NS.edgeval.right";
NSString *const NS_offset_h =  @"NS.offset.h";
NSString *const NS_offset_v =  @"NS.offset.v";
NSString *const NS_time =  @"NS.time";

NSString *NSStringFromPoint(CGPoint pt)
{
    return [NSString stringWithFormat:@"{%.8g, %.8g}", pt.x, pt.y];
}

NSString *NSStringFromSize(CGSize sz)
{
    return [NSString stringWithFormat:@"{%.8g, %.8g}", sz.width, sz.height];
}

NSString *NSStringFromRect(CGRect r)
{
    return [NSString stringWithFormat:@"{{%.8g, %.8g}, {%.8g, %.8g}}", r.origin.x, r.origin.y, r.size.width, r.size.height];
}

static NSArray *CGFloatArrayFromString(NSString *string)
{
    // This should be re-worked to avoid charactersets and arrays and just use libc calls
    static NSCharacterSet *ignoredCharacters = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        ignoredCharacters = [NSCharacterSet characterSetWithCharactersInString:@"{} ,"];
        [ignoredCharacters retain];
    });
    NSArray *components = [string componentsSeparatedByCharactersInSet:ignoredCharacters];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < [components count]; i++)
    {
        NSString *component = [components objectAtIndex:i];
        if ([component length] > 0)
        {
            [result addObject:[components objectAtIndex:i]];
        }
    }
    return [result autorelease];
}

CGSize NSSizeFromString(NSString *string)
{
    CGSize sz = {0, 0};
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 2)
    {
        sz.width = [[components objectAtIndex:0] floatValue];
        sz.height = [[components objectAtIndex:1] floatValue];
    }
    return sz;
}

CGPoint NSPointFromString(NSString *string)
{
    CGPoint pt = {0, 0};
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 2)
    {
        pt.x = [[components objectAtIndex:0] floatValue];
        pt.y = [[components objectAtIndex:1] floatValue];
    }
    return pt;
}

CGRect NSRectFromString(NSString *string)
{
    CGRect r = {{0, 0}, {0, 0}};
    NSArray *components = CGFloatArrayFromString(string);
    if ([components count] == 4)
    {
        r.origin.x = [[components objectAtIndex:0] floatValue];
        r.origin.y = [[components objectAtIndex:1] floatValue];
        r.size.width = [[components objectAtIndex:2] floatValue];
        r.size.height = [[components objectAtIndex:3] floatValue];
    }
    return r;
}
