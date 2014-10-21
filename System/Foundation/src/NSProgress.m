//
//  NSProgress.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSProgress.h>

@implementation NSProgress

+ (id)currentProgress
{
    return nil;
}

+ (id)progressWithTotalUnitCount:(int64_t)unitCount
{
    return nil;
}

- (BOOL)isCancelled
{
    return NO;
}

- (void)setCompletedUnitCount:(int64_t)count
{
}

- (int64_t)completedUnitCount
{
    return 0;
}

@end
