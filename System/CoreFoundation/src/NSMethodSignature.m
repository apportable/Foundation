//
//  NSMethodSignature.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSMethodSignature.h>
#import "NSMethodSignatureInternal.h"
#import "NSObjCRuntimeInternal.h"
#import "NSObjectInternal.h"

#define ALIGN_TO(value, alignment) \
(((value) % (alignment)) ? \
((value) + (alignment) - ((value) % (alignment))) : \
(value) \
)

@implementation NSMethodSignature {
    NSMethodType *_types;
    NSUInteger _count;
    NSUInteger _frameLength;
    BOOL _isOneway;
    BOOL _stret;
}

- (instancetype)initWithObjCTypes:(const char *)types
{
    self = [super init];

    if (self == nil)
    {
        return nil;
    }

    _count = 0;
    _frameLength = 0;
    // strlen(types) is a safe overapproximation to the actual number of types.
    _types = calloc(sizeof(NSMethodType), strlen(types));

    if (UNLIKELY(_types == NULL))
    {
        [self release];
        return nil;
    }

    const char *currentType = types;
    const char *nextType = types;

    while(strlen(nextType) > 0)
    {
        NSMethodType *ms = &_types[_count];

        currentType = nextType;
        nextType = NSGetSizeAndAlignment(currentType, &ms->size, &ms->alignment);
        ms->type = calloc(nextType - currentType + 1, 1);
        if (UNLIKELY(ms->type == NULL))
        {
            [self release];
            return nil;
        }
        strncpy(ms->type, currentType, nextType - currentType);

        // Skip advisory size
        strtol(nextType, (char **)&nextType, 10);

        NSUInteger frameAlignment = MAX(ms->alignment, sizeof(int));
        NSUInteger frameSize = ALIGN_TO(ms->size, frameAlignment);

        if (_count == 0)
        {
            // Determine whether the method is stret, based on the
            // type of the return value.
            switch (*stripQualifiersAndComments(_types[0].type))
            {
                case _C_STRUCT_B:
                {
                    if (frameSize > sizeof(int))
                    {
                        // Account for the stret return pointer.
                        _frameLength += sizeof(void *);
                        _stret = YES;
                    }
                    break;
                }

                default:
                    // All other cases are non-stret.
                    break;
            }
        }
        else
        {
#if __arm__
            _frameLength = ALIGN_TO(_frameLength, frameAlignment);
#endif
            _types[_count].offset = _frameLength;
            _frameLength += frameSize;
        }

        _count++;
    }

    // Check whether the method is oneway by reading all the
    // qualifiers of the return type.
    static const char *qualifiers = "nNoOrRV";
    char *cur = _types[0].type;
    while (strchr(qualifiers, *cur)) {
        if (*cur == 'V') {
            _isOneway = YES;
            break;
        }
        cur++;
    }

    return self;
}

+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types
{
    return [[[self alloc] initWithObjCTypes:types] autorelease];
}

- (void)dealloc
{
    for (NSUInteger idx = 0; idx < _count; idx++)
    {
        if (_types[idx].type != NULL)
        {
            free(_types[idx].type);
        }
    }

    if (_types != NULL)
    {
        free(_types);
    }

    [super dealloc];
}

- (NSUInteger)numberOfArguments
{
    return _count - 1;
}

- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx
{
    return _types[idx + 1].type;
}

- (NSUInteger)frameLength
{
    return _frameLength;
}

- (BOOL)isOneway
{
    return _isOneway;
}

- (const char *)methodReturnType
{
    return _types[0].type;
}

- (NSUInteger)methodReturnLength
{
    return _types[0].size;
}

- (NSMethodType *)_argInfo:(int)index
{
    return &_types[index];
}

- (BOOL)_stret
{
    return _stret;
}

@end
