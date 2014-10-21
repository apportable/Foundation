//
//  NSKeyValueObservationInfo.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueObservationInfo.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import "NSKeyValueObservance.h"

@implementation NSKeyValueObservationInfo
{
    NSMutableArray *_observances;
}
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _observances = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [_observances release];
    [super dealloc];
}

- (void)addObservance:(NSKeyValueObservance *)observance
{
    [_observances addObject:observance];
}
- (void)removeObservance:(NSKeyValueObservance *)observance
{
    [_observances removeObject:observance];
}
- (NSArray *)observances
{
    return _observances;
}
- (NSString *)description
{
    NSMutableString *desc = [[super description] mutableCopy];
    [desc appendString:@" (\n"];
    for (NSKeyValueObservance *observance in _observances)
    {
        [desc appendString:[observance description]];
    }
    [desc appendString:@")"];
    return [desc autorelease];
}
@end
