//
//  NSProgress.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSProgress.h>

@implementation NSProgress

+ (NSProgress *)currentProgress
{
    return nil;
}

+ (NSProgress *)progressWithTotalUnitCount:(int64_t)unitCount
{
    return nil;
}

- (instancetype)initWithParent:(NSProgress *)parentProgressOrNil userInfo:(NSDictionary *)userInfoOrNil
{
    return nil;
}

- (void)becomeCurrentWithPendingUnitCount:(int64_t)unitCount
{
}

- (void)resignCurrent
{
}

- (void)setTotalUnitCount:(int64_t)count
{
}

- (int64_t)totalUnitCount
{
    return 0;
}

- (void)setCompletedUnitCount:(int64_t)count
{
}

- (int64_t)completedUnitCount
{
    return 0;
}

- (void)setLocalizedDescription:(NSString *)localizedDescription
{
}

- (NSString *)localizedDescription
{
    return nil;
}

- (void)setLocalizedAdditionalDescription:(NSString *)localizedAdditionalDescription
{
}

- (NSString *)localizedAdditionalDescription
{
    return nil;
}

- (void)setCancellable:(BOOL)cancellable
{
}

- (BOOL)isCancellable
{
    return NO;
}

- (void)setPausable:(BOOL)pausable
{
}

- (BOOL)isPausable
{
    return NO;
}

- (BOOL)isCancelled
{
    return NO;
}

- (BOOL)isPaused
{
    return NO;
}

#if NS_BLOCKS_AVAILABLE
- (void)setCancellationHandler:(void (^)(void))cancellationHandler
{
}

- (void (^)(void))cancellationHandler
{
    return nil;
}

- (void)setPausingHandler:(void (^)(void))pausingHandler
{
}

- (void (^)(void))pausingHandler
{
    return nil;
}
#endif

- (void)setUserInfoObject:(id)objectOrNil forKey:(NSString *)key
{
}

- (BOOL)isIndeterminate
{
    return NO;
}

- (double)fractionCompleted
{
    return 0.0;
}

- (void)cancel
{
}

- (void)pause
{
}

- (NSDictionary *)userInfo
{
    return nil;
}

- (void)setKind:(NSString *)kind
{
}

- (NSString *)kind
{
    return nil;
}

@end
