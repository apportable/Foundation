//
//  NSFastEnumerationEnumerator.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSFastEnumerationEnumerator.h"

#import "CFString.h"
#import <Foundation/NSException.h>

@implementation __NSFastEnumerationEnumerator

+ (id)allocWithZone:(NSZone *)zone
{
    return ___CFAllocateObject2(self, sizeof(NSFastEnumerationState));
}

- (void)dealloc
{
    [(NSObject *)_obj release];
    [(NSObject *)_origObj release];
    [super dealloc];
}

- (id)nextObject
{
    NSFastEnumerationState *state = object_getIndexedIvars(self);
    if (_count == 0)
    {
        id obj = nil;
        _count = [_obj countByEnumeratingWithState:state objects:&obj count:1];

        if (_count == 0)
        {
            return nil;
        }

        _mut = _count;
        state->extra[0] = *state->mutationsPtr;
    }

    if (state->mutationsPtr == NULL || *state->mutationsPtr != state->extra[0])
    {
        [NSException raise:NSGenericException format:@"*** Collection <%s: 0x%x> was mutated while being enumerated", object_getClassName(_obj), _obj];
        return nil;
    }

    NSUInteger idx = _mut - _count;
    _count--;
    return state->itemsPtr[idx];
}

- (id)initWithObject:(id)object
{
    self = [super init];

    if (self)
    {
        _obj = (id<NSFastEnumeration>)[(NSObject *)object retain];
        _origObj = (id<NSFastEnumeration>)[(NSObject *)object retain];
        _count = 0;
        _mut = 0;
    }
    
    return self;
}

@end
