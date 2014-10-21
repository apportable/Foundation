//
//  NSPointerFunctions.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPointerFunctionsInternal.h"
#import "ForFoundationOnly.h"
#import <mach/mach.h>

extern id objc_loadWeakRetained(id *location);
extern void objc_destroyWeak(id *addr);

void * const _NSPointerFunctionsSentinel = (void *)1;

@implementation NSPointerFunctions

+ (id)pointerFunctionsWithOptions:(NSPointerFunctionsOptions)options
{
    return [[[self alloc] initWithOptions:options] autorelease];
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSPointerFunctions class])
    {
        return [NSConcretePointerFunctions allocWithZone:zone];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (BOOL)usesWeakReadAndWriteBarriers
{
    NSRequestConcreteImplementation();
    return NO;
}

- (void)setUsesWeakReadAndWriteBarriers:(BOOL)flag
{
    NSRequestConcreteImplementation();
}

- (BOOL)usesStrongWriteBarrier
{
    NSRequestConcreteImplementation();
    return NO;
}

- (void)setUsesStrongWriteBarrier:(BOOL)flag
{
    NSRequestConcreteImplementation();
}

- (void (*)(const void *item, NSUInteger (*size)(const void *item)))relinquishFunction
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setRelinquishFunction:(void (*)(const void *item, NSUInteger (*size)(const void *item)))fn
{
    NSRequestConcreteImplementation();
}

- (void *(*)(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy))acquireFunction
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setAcquireFunction:(void *(*)(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy))fn
{
    NSRequestConcreteImplementation();
}

- (NSString *(*)(const void *item))descriptionFunction
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setDescriptionFunction:(NSString *(*)(const void *item))fn
{
    NSRequestConcreteImplementation();
}

- (BOOL (*)(const void *item1, const void*item2, NSUInteger (*size)(const void *item)))isEqualFunction
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setIsEqualFunction:(BOOL (*)(const void *item1, const void*item2, NSUInteger (*size)(const void *item)))fn
{
    NSRequestConcreteImplementation();
}

- (NSUInteger (*)(const void *item, NSUInteger (*size)(const void *item)))hashFunction
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setHashFunction:(NSUInteger (*)(const void *item, NSUInteger (*size)(const void *item)))fn
{
    NSRequestConcreteImplementation();
}

- (NSUInteger (*)(const void *item))sizeFunction
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setSizeFunction:(NSUInteger (*)(const void *item))fn
{
    NSRequestConcreteImplementation();
}

- (id)copyWithZone:(NSZone *)zone
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithOptions:(NSPointerFunctionsOptions)options
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

@end

@implementation NSConcretePointerFunctions

- (BOOL)usesWeakReadAndWriteBarriers
{
    return slice.usesWeak;
}

- (void)setUsesWeakReadAndWriteBarriers:(BOOL)flag
{
    slice.usesWeak = flag;
}

- (BOOL)usesStrongWriteBarrier
{
    return slice.usesStrong;
}

- (void)setUsesStrongWriteBarrier:(BOOL)flag
{
    slice.usesStrong = flag;
}

- (void (*)(const void *item, NSUInteger (*size)(const void *item)))relinquishFunction
{
    return slice.relinquishFunction;
}

- (void)setRelinquishFunction:(void (*)(const void *item, NSUInteger (*size)(const void *item)))fn
{
    slice.relinquishFunction = fn;
}

- (void *(*)(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy))acquireFunction
{
    return slice.acquireFunction;
}

- (void)setAcquireFunction:(void *(*)(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy))fn
{
    slice.acquireFunction = fn;
}

- (NSString *(*)(const void *item))descriptionFunction
{
    return slice.describeFunction;
}

- (void)setDescriptionFunction:(NSString *(*)(const void *item))fn
{
    slice.describeFunction = fn;
}

- (BOOL (*)(const void *item1, const void*item2, NSUInteger (*size)(const void *item)))isEqualFunction
{
    return slice.isEqualFunction;
}

- (void)setIsEqualFunction:(BOOL (*)(const void *item1, const void*item2, NSUInteger (*size)(const void *item)))fn
{
    slice.isEqualFunction = fn;
}

- (NSUInteger (*)(const void *item, NSUInteger (*size)(const void *item)))hashFunction
{
    return slice.hashFunction;
}

- (void)setHashFunction:(NSUInteger (*)(const void *item, NSUInteger (*size)(const void *item)))fn
{
    slice.hashFunction = fn;
}

- (NSUInteger (*)(const void *item))sizeFunction
{
    return slice.sizeFunction;
}

- (void)setSizeFunction:(NSUInteger (*)(const void *item))fn
{
    slice.sizeFunction = fn;
}

static NSUInteger NSCStringHash(const void *item, NSUInteger (*size)(const void *item))
{
    return CFStringHashISOLatin1CString(item, size(item));
}

static NSUInteger NSCStringSize(const void *item)
{
    return strlen(item) + 1;
}

static BOOL NSDirectEquality(const void *item1, const void *item2, NSUInteger (*size)(const void *item))
{
    return item1 == item2;
}

static NSString *NSIntegerDescription(const void *item)
{
    return [NSString stringWithFormat:@"%d", (int)item];
}

static NSUInteger NSIntegerHash(const void *item, NSUInteger (*size)(const void *item))
{
    return (NSUInteger)item;
}

static void *NSObjectAcquire(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy)
{
     if (shouldCopy)
     {
        return [(id)src copy];
     }
     else
     {
        return [(id)src retain];
     }
}

static NSString *NSObjectDescription(const void *item)
{
    return [(id)item description];
}

static BOOL NSObjectEquality(const void *item1, const void *item2, NSUInteger (*size)(const void *item))
{
    return [(id)item1 isEqual:(id)item2];
}

static NSUInteger NSObjectHash(const void *item, NSUInteger (*size)(const void *item))
{
    return [(id)item hash];
}

static void NSObjectRelinquish(const void *item, NSUInteger (*size)(const void *item))
{
    [(id)item release];
}

static void *NSPointerAcquire(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy)
{
    NSUInteger sz = size(src);
    void *dst = calloc(sz, 1);
    memcpy(dst, src, sz);
    return dst;
}

static NSString *NSPointerDescription(const void *item)
{
    return [NSString stringWithFormat:@"%p", item];
}

static NSUInteger NSPointerHash(const void *item, NSUInteger (*size)(const void *item))
{
    return (((uintptr_t)item >> 4) ^ ((uintptr_t)item >> 9));
}

static void NSPointerRelinquish(const void *item, NSUInteger (*size)(const void *item))
{
    free((void *)item);
}

static void *NSMachAcquire(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy)
{
    if (!shouldCopy)
    {
        return (void *)src;
    }

    NSUInteger len = size(src);

    vm_address_t copy;

    kern_return_t ret = vm_allocate(mach_task_self(), &copy, len, 1);
    if (ret != KERN_SUCCESS)
    {
        return NULL;
    }

    ret = vm_copy(mach_task_self(), (vm_address_t)src, len, copy);
    if (ret != KERN_SUCCESS)
    {
        vm_deallocate(mach_task_self(), copy, len);
        return NULL;
    }

    return (void *)copy;
}

static void NSMachRelinquish(const void *item, NSUInteger (*size)(const void *item))
{
    vm_deallocate(mach_task_self(), (vm_address_t)item, size(item));
}

static BOOL NSMemoryEquality(const void *item1, const void *item2, NSUInteger (*size)(const void *item))
{
    NSUInteger size1 = size(item1);
    NSUInteger size2 = size(item2);

    if (size1 != size2)
    {
        return NO;
    }

    return memcmp(item1, item2, size1) == 0;
}

static NSUInteger NSMemoryHash(const void *item, NSUInteger (*size)(const void *item))
{
    const uint8_t *bytes = item;
    NSUInteger len = size(item);
    NSUInteger hash = len;

    for (NSUInteger idx = 0; idx < len; idx++)
    {
        hash += bytes[idx];
    }

    return hash;
}

static NSString *NSCStringDescription(const void *item)
{
    return [NSString stringWithUTF8String:(const char *)item];
}

static void *NSSliceAlloc(size_t count)
{
    return calloc(count, sizeof(id));
}

static void *NSARCSliceAlloc(size_t count)
{
    return calloc(count, sizeof(id));
}

static void *NSARCSentinelSliceAlloc(size_t count)
{
    size_t size = count * sizeof(id);
    void *buffer = malloc(size);
    if (buffer != NULL)
    {
        memset_pattern4(buffer, &_NSPointerFunctionsSentinel, size);
    }

    return buffer;
}

static void NSSliceFree(void **ptr, NSUInteger size)
{
    free(ptr);
}

static void NSARCSliceFree(void **buffer, NSUInteger size)
{
    for (NSUInteger idx = 0; idx < size; idx++)
    {
        if (buffer[idx] != NULL && buffer[idx] != _NSPointerFunctionsSentinel)
        {
            objc_storeWeak((id *)buffer + idx, nil);
        }
    }

    free(buffer);
}

static void *NSSliceReadAt(void **ptr, BOOL *wasSentinel)
{
    void *item = *ptr;
    if (wasSentinel != NULL)
    {
        *wasSentinel = item == NULL;
    }
    return item;
}

static void *NSARCSliceReadAt(void **ptr, BOOL *wasSentinel)
{
    void *item = NULL;
    if (*ptr != NULL)
    {
        item = objc_loadWeak((id *)ptr);
    }
    if (wasSentinel != NULL)
    {
        *wasSentinel = item == NULL;
    }
    return item;
}

static void *NSARCSentinelSliceReadAt(void **ptr, BOOL *wasSentinel)
{
    if (wasSentinel != NULL)
    {
        *wasSentinel = *ptr == _NSPointerFunctionsSentinel;
    }
    if (*ptr == NULL || *ptr == _NSPointerFunctionsSentinel)
    {
        return NULL;
    }
    return objc_loadWeak((id *)ptr);
}

static void NSSliceClearAt(void **ptr)
{
    *ptr = NULL;
}

static void NSARCSliceClearAt(void **ptr)
{
    if (*ptr != NULL)
    {
        objc_storeWeak((id *)ptr, nil);
    }
    *ptr = NULL;
}

static void NSARCSentinelSliceClearAt(void **ptr)
{
    if (*ptr != NULL && *ptr != _NSPointerFunctionsSentinel)
    {
        objc_storeWeak((id *)ptr, nil);
    }
    *ptr = _NSPointerFunctionsSentinel;
}

static void NSSliceStoreAt(void **buffer, void *item, NSUInteger index)
{
    buffer[index] = item;
}

static void NSARCSliceStoreAt(void **buffer, void *item, NSUInteger index)
{
    if (buffer[index] == _NSPointerFunctionsSentinel)
    {
        buffer[index] = NULL;
    }
    objc_storeWeak((id *)buffer + index, (id)item);
}

static inline void sliceInitializeError(NSPointerFunctionsOptions options)
{
    NSPointerFunctionsOptions memory = NSPointerFunctionsMemoryType(options);
    NSPointerFunctionsOptions personality = NSPointerFunctionsPersonality(options);
    NSPointerFunctionsOptions copyIn = (options & NSPointerFunctionsCopyIn) == NSPointerFunctionsCopyIn;

    NSLog(@"Invalid combination of NSPointerFunctionsOptions in %x (memory type %d, personality %d, copy in %d)",
          options, memory, personality, copyIn);
}

#define INIT_ERROR() ({ sliceInitializeError(options); return NO; })

+ (BOOL)initializeSlice:(struct NSSlice *)aSlice withOptions:(NSPointerFunctionsOptions)options
{
    *aSlice = (struct NSSlice){ .items = aSlice->items };

    aSlice->shouldCopyIn = (options & NSPointerFunctionsCopyIn) == NSPointerFunctionsCopyIn;

    if (aSlice->shouldCopyIn)
    {
        switch (NSPointerFunctionsMemoryType(options))
        {
            case NSPointerFunctionsStrongMemory:
                switch (NSPointerFunctionsPersonality(options))
                {
                    case NSPointerFunctionsObjectPersonality:
                    case NSPointerFunctionsObjectPointerPersonality:
                        break;
                    default:
                        INIT_ERROR();
                        break;
                }
                break;
            case NSPointerFunctionsMallocMemory:
                switch (NSPointerFunctionsPersonality(options))
                {
                    case NSPointerFunctionsCStringPersonality:
                    case NSPointerFunctionsStructPersonality:
                        break;
                    default:
                        INIT_ERROR();
                        break;
                }
                break;
            case NSPointerFunctionsMachVirtualMemory:
                switch (NSPointerFunctionsPersonality(options))
                {
                    case NSPointerFunctionsCStringPersonality:
                    case NSPointerFunctionsStructPersonality:
                        break;
                    default:
                        INIT_ERROR();
                        break;
                }
                break;
            default:
                INIT_ERROR();
                break;
        }
    }
    else
    {
        switch (NSPointerFunctionsPersonality(options))
        {
            case NSPointerFunctionsObjectPersonality:
            case NSPointerFunctionsObjectPointerPersonality:
                switch (NSPointerFunctionsMemoryType(options))
                {
                    case NSPointerFunctionsMallocMemory:
                    case NSPointerFunctionsMachVirtualMemory:
                        INIT_ERROR();
                        break;
                    default:
                        break;
                }
                break;
            case NSPointerFunctionsIntegerPersonality:
                switch (NSPointerFunctionsMemoryType(options))
                {
                    case NSPointerFunctionsOpaqueMemory:
                        break;
                    default:
                        INIT_ERROR();
                        break;
                }
                break;
            default:
                break;
        }
    }

    switch (NSPointerFunctionsMemoryType(options))
    {
        case NSPointerFunctionsStrongMemory:
            aSlice->wantsStrong = YES;
            switch (NSPointerFunctionsPersonality(options))
            {
                case NSPointerFunctionsObjectPersonality:
                case NSPointerFunctionsObjectPointerPersonality:
                    aSlice->acquireFunction = &NSObjectAcquire;
                    aSlice->relinquishFunction = &NSObjectRelinquish;
                    break;
                default:
                    break;
            }
            break;
        case NSPointerFunctionsZeroingWeakMemory:
            aSlice->wantsWeak = YES;
            break;
        case NSPointerFunctionsOpaqueMemory:
            break;
        case NSPointerFunctionsMallocMemory:
            aSlice->acquireFunction = &NSPointerAcquire;
            aSlice->relinquishFunction = &NSPointerRelinquish;
            break;
        case NSPointerFunctionsMachVirtualMemory:
            aSlice->acquireFunction = &NSMachAcquire;
            aSlice->relinquishFunction = &NSMachRelinquish;
            break;
        case NSPointerFunctionsWeakMemory:
            aSlice->wantsWeak = YES;
            aSlice->wantsARC = YES;
            break;
    }

    switch (NSPointerFunctionsPersonality(options))
    {
        case NSPointerFunctionsObjectPersonality:
            aSlice->hashFunction = &NSObjectHash;
            aSlice->isEqualFunction = &NSObjectEquality;
            aSlice->describeFunction = &NSObjectDescription;
            break;
        case NSPointerFunctionsOpaquePersonality:
            aSlice->pointerPersonality = YES;
            aSlice->hashFunction = &NSPointerHash;
            aSlice->isEqualFunction = &NSDirectEquality;
            aSlice->describeFunction = &NSPointerDescription;
            break;
        case NSPointerFunctionsObjectPointerPersonality:
            aSlice->pointerPersonality = YES;
            aSlice->hashFunction = &NSPointerHash;
            aSlice->isEqualFunction = &NSDirectEquality;
            aSlice->describeFunction = &NSObjectDescription;
            break;
        case NSPointerFunctionsCStringPersonality:
            aSlice->sizeFunction = &NSCStringSize;
            aSlice->hashFunction = &NSCStringHash;
            aSlice->isEqualFunction = &NSMemoryEquality;
            aSlice->describeFunction = &NSCStringDescription;
            break;
        case NSPointerFunctionsStructPersonality:
            aSlice->hashFunction = &NSMemoryHash;
            aSlice->isEqualFunction = &NSMemoryEquality;
            break;
        case NSPointerFunctionsIntegerPersonality:
            aSlice->integerPersonality = YES;
            aSlice->hashFunction = &NSIntegerHash;
            aSlice->isEqualFunction = &NSDirectEquality;
            aSlice->describeFunction = &NSIntegerDescription;
            break;
    }

    return YES;
}

+ (void)initializeBackingStore:(struct NSSlice *)aSlice sentinel:(BOOL)sentinel compactable:(BOOL)compactable
{
    if (aSlice->wantsWeak && aSlice->wantsARC)
    {
        aSlice->usesStrong = NO;
        aSlice->usesWeak = YES;
        aSlice->usesARC = YES;
        aSlice->simpleReadClear = NO;
        aSlice->usesSentinel = sentinel;

        aSlice->storeAt = &NSARCSliceStoreAt;
        aSlice->freeFunction = &NSARCSliceFree;
        if (sentinel)
        {
            aSlice->allocateFunction = &NSARCSentinelSliceAlloc;
            aSlice->readAt = &NSARCSentinelSliceReadAt;
            aSlice->clearAt = &NSARCSentinelSliceClearAt;
        }
        else
        {
            aSlice->allocateFunction = &NSARCSliceAlloc;
            aSlice->readAt = &NSARCSliceReadAt;
            aSlice->clearAt = &NSARCSliceClearAt;
        }
    }
    else
    {
        aSlice->usesStrong = YES;
        aSlice->simpleReadClear = YES;
        aSlice->usesSentinel = NO;

        aSlice->storeAt = &NSSliceStoreAt;
        aSlice->freeFunction = &NSSliceFree;
        aSlice->allocateFunction = &NSSliceAlloc;
        aSlice->readAt = &NSSliceReadAt;
        aSlice->clearAt = &NSSliceClearAt;
    }
}

- (id)initWithOptions:(NSPointerFunctionsOptions)options
{
    self = [super init];
    if (self)
    {
        if (![NSConcretePointerFunctions initializeSlice:&slice withOptions:options])
        {
            [self release];
            return nil;
        }
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (self != other)
    {
        struct NSSlice *s1 = &self->slice;
        struct NSSlice *s2 = &((NSConcretePointerFunctions *)other)->slice;

        if (s1->wantsStrong != s2->wantsStrong)
        {
            return NO;
        }
        if (s1->wantsWeak != s2->wantsWeak)
        {
            return NO;
        }
        if (s1->wantsARC != s2->wantsARC)
        {
            return NO;
        }
        if (s1->shouldCopyIn != s2->shouldCopyIn)
        {
            return NO;
        }
        if (s1->usesStrong != s2->usesStrong)
        {
            return NO;
        }
        if (s1->usesWeak != s2->usesWeak)
        {
            return NO;
        }
        if (s1->usesARC != s2->usesARC)
        {
            return NO;
        }
        if (s1->usesSentinel != s2->usesSentinel)
        {
            return NO;
        }
        if (s1->pointerPersonality != s2->pointerPersonality)
        {
            return NO;
        }
        if (s1->integerPersonality != s2->integerPersonality)
        {
            return NO;
        }
        if (s1->simpleReadClear != s2->simpleReadClear)
        {
            return NO;
        }
        if (s1->sizeFunction != s2->sizeFunction)
        {
            return NO;
        }
        if (s1->hashFunction != s2->hashFunction)
        {
            return NO;
        }
        if (s1->isEqualFunction != s2->isEqualFunction)
        {
            return NO;
        }
        if (s1->describeFunction != s2->describeFunction)
        {
            return NO;
        }
        if (s1->acquireFunction != s2->acquireFunction)
        {
            return NO;
        }
        if (s1->relinquishFunction != s2->relinquishFunction)
        {
            return NO;
        }
        if (s1->allocateFunction != s2->allocateFunction)
        {
            return NO;
        }
        if (s1->freeFunction != s2->freeFunction)
        {
            return NO;
        }
        if (s1->readAt != s2->readAt)
        {
            return NO;
        }
        if (s1->clearAt != s2->clearAt)
        {
            return NO;
        }
        if (s1->storeAt != s2->storeAt)
        {
            return NO;
        }
    }
    return YES;
}

- (NSUInteger)hash
{
    return (uintptr_t)slice.wantsStrong ^
           (uintptr_t)slice.wantsWeak ^
           (uintptr_t)slice.wantsARC ^
           (uintptr_t)slice.shouldCopyIn ^
           (uintptr_t)slice.usesStrong ^
           (uintptr_t)slice.usesWeak ^
           (uintptr_t)slice.usesARC ^
           (uintptr_t)slice.usesSentinel ^
           (uintptr_t)slice.pointerPersonality ^
           (uintptr_t)slice.integerPersonality ^
           (uintptr_t)slice.simpleReadClear ^
           (uintptr_t)slice.sizeFunction ^
           (uintptr_t)slice.hashFunction ^
           (uintptr_t)slice.isEqualFunction ^
           (uintptr_t)slice.describeFunction ^
           (uintptr_t)slice.acquireFunction ^
           (uintptr_t)slice.relinquishFunction ^
           (uintptr_t)slice.allocateFunction ^
           (uintptr_t)slice.freeFunction ^
           (uintptr_t)slice.readAt ^
           (uintptr_t)slice.clearAt ^
           (uintptr_t)slice.storeAt;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSConcretePointerFunctions *obj = [[NSConcretePointerFunctions alloc] init];

    obj->slice.wantsStrong = slice.wantsStrong;
    obj->slice.wantsWeak = slice.wantsWeak;
    obj->slice.wantsARC = slice.wantsARC;
    obj->slice.shouldCopyIn = slice.shouldCopyIn;
    obj->slice.usesStrong = slice.usesStrong;
    obj->slice.usesWeak = slice.usesWeak;
    obj->slice.usesARC = slice.usesARC;
    obj->slice.usesSentinel = slice.usesSentinel;
    obj->slice.pointerPersonality = slice.pointerPersonality;
    obj->slice.integerPersonality = slice.integerPersonality;
    obj->slice.simpleReadClear = slice.simpleReadClear;
    obj->slice.sizeFunction = slice.sizeFunction;
    obj->slice.hashFunction = slice.hashFunction;
    obj->slice.isEqualFunction = slice.isEqualFunction;
    obj->slice.describeFunction = slice.describeFunction;
    obj->slice.acquireFunction = slice.acquireFunction;
    obj->slice.relinquishFunction = slice.relinquishFunction;
    obj->slice.allocateFunction = slice.allocateFunction;
    obj->slice.freeFunction = slice.freeFunction;
    obj->slice.readAt = slice.readAt;
    obj->slice.clearAt = slice.clearAt;
    obj->slice.storeAt = slice.storeAt;

    return obj;
}

@end

