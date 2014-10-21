//
//  NSDate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSDate.h>

#import "NSExternals.h"
#import "NSObjectInternal.h"

#import <Foundation/NSCoder.h>

@implementation NSDate (NSDate)

- (Class)classForCoder
{
    return [NSDate self];
}

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSTimeInterval timeInterval = 0.0;
    if ([aDecoder allowsKeyedCoding])
    {
        timeInterval = [aDecoder decodeDoubleForKey:NS_time];
    }
    else
    {
        [aDecoder decodeValueOfObjCType:@encode(NSTimeInterval) at:&timeInterval];
    }
    return [self initWithTimeIntervalSinceReferenceDate:timeInterval];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSTimeInterval timeInterval = [self timeIntervalSinceReferenceDate];
    if ([aCoder allowsKeyedCoding])
    {
        [aCoder encodeDouble:timeInterval forKey:NS_time];
    }
    else
    {
        [aCoder encodeValueOfObjCType:@encode(NSTimeInterval) at:&timeInterval];
    }
}
OBJC_PROTOCOL_IMPL_POP

@end

@interface NSCalendarDate : NSDate
@end

@implementation NSCalendarDate

- (id)allocWithZone:(NSZone *)zone
{
#warning TODO implement NSCalendarDate
    DEBUG_BREAK();
    return nil;
}

@end
