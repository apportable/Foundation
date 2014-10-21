//
//  NSEnumerator.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSEnumerator.h>
#import <Foundation/NSArray.h>
#import "NSObjectInternal.h"

@implementation NSEnumerator

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    if (state->state == -1) {
        return 0;
    }
    state->itemsPtr = buffer;
    state->mutationsPtr = &state->extra[0];
    // should this adjust mutations?
    buffer[0] = [self nextObject];
    if (buffer[0] == nil) {
        state->state = -1;
        return 0;
    }
    else {
        ++state->state;
        return 1;
    }
}

- (id)nextObject
{
    NSRequestConcreteImplementation();
    return nil;
}

@end

@implementation NSEnumerator (NSExtendedEnumerator)

- (NSArray *)allObjects
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    for (id object in self)
    {
        [objects addObject:object];
    }
    
    NSArray *array = [objects copy];
    [objects release];
    return [array autorelease];
}

@end
