//
//  NSKeyValueContainerClass.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueContainerClass.h"
#import <Foundation/NSString.h>
#import <objc/runtime.h>

@implementation NSKeyValueContainerClass

- (instancetype)initWithOriginalClass:(Class)cls
{
    self = [super init];
    if (self != nil)
    {
        self.originalClass = cls;
        self.cachedObservationInfoImplementation = class_getMethodImplementation(self.originalClass, @selector(observationInfo));
        Method setObservationInfoMethod = class_getInstanceMethod(self.originalClass, @selector(setObservationInfo:));
        self.cachedSetObservationInfoImplementation = method_getImplementation(setObservationInfoMethod);
        char buf = 0;
        method_getArgumentType(setObservationInfoMethod, 2, &buf, 1);
        if (buf == '@')
        {
            self.cachedSetObservationInfoTakesAnObject = YES;
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ containing: %@, cached observationInfo IMP: %p, cached setObservationInfo: IMP: %p, cached setObservationInfo: does %@take an object>",
                     [super description],
                     self.originalClass,
                     self.cachedObservationInfoImplementation,
                     self.cachedSetObservationInfoImplementation,
                     self.cachedSetObservationInfoTakesAnObject ? @"" : @"NOT "];
}
@end
