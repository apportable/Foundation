//
//  NSObject+Apportable.m
//
//
//  Created by Philippe Hausler on 12/27/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#import "Apportable/NSObject+Apportable.h"

@implementation NSObject (Apportable)

- (void)performSelectorInBackground:(SEL)selector withObject:(id)object
{
    [NSThread detachNewThreadSelector:selector toTarget:self withObject:object];
}

@end
