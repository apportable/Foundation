//
//  NSPointerArray.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSPointerArray.h>
#import <Foundation/NSCoder.h>
#import "NSPointerFunctionsInternal.h"

CF_PRIVATE
@interface NSConcretePointerArray : NSPointerArray
@end

#define NSPointerArraySubclassResponsibility() [NSException raise:@"NSPointerFunctionsAbstractImplementationError" format:@"%s is a subclass responsibility", sel_getName(_cmd)];

@implementation NSPointerArray

+ (id)allocWithZone:(NSZone *)zone
{
    return NSAllocateObject([NSConcretePointerArray class], 0, NSDefaultMallocZone());
}

+ (id)pointerArrayWithOptions:(NSPointerFunctionsOptions)options
{
    return [[[self alloc] initWithOptions:options] autorelease];
}

+ (id)pointerArrayWithPointerFunctions:(NSPointerFunctions *)functions
{
    return [[[self alloc] initWithPointerFunctions:functions] autorelease];
}

+ (id)pointerArrayWithStrongObjects
{
    return [[[NSConcretePointerArray alloc] init] autorelease];
}

+ (id)pointerArrayWithWeakObjects
{
    return [[[NSConcretePointerArray alloc] initWithOptions:NSPointerFunctionsZeroingWeakMemory] autorelease];
}

- (id)initWithOptions:(NSPointerFunctionsOptions)options
{
    [self release];
    NSPointerArraySubclassResponsibility();
    return nil;
}

- (id)init
{
    [self release];
    NSPointerArraySubclassResponsibility();
    return nil;
}

- (id)initWithPointerFunctions:(NSPointerFunctions *)functions
{
    [self release];
    NSPointerArraySubclassResponsibility();
    return nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
    [self release];
    return [[NSConcretePointerArray alloc] initWithCoder:coder];
}

- (NSPointerFunctions *)pointerFunctions
{
    NSPointerArraySubclassResponsibility();
    return nil;
}

- (void *)pointerAtIndex:(NSUInteger)index
{
    NSPointerArraySubclassResponsibility();
    return NULL;
}

- (void)addPointer:(void *)pointer
{
    NSPointerArraySubclassResponsibility();
}

- (void)removePointerAtIndex:(NSUInteger)index
{
    NSPointerArraySubclassResponsibility();
}

- (void)insertPointer:(void *)item atIndex:(NSUInteger)index
{
    NSPointerArraySubclassResponsibility();
}

- (void)replacePointerAtIndex:(NSUInteger)index withPointer:(void *)item
{
    NSPointerArraySubclassResponsibility();
}

- (void)compact
{
    NSPointerArraySubclassResponsibility();
}

- (NSUInteger)count
{
    NSPointerArraySubclassResponsibility();
    return 0;
}

- (void)setCount:(NSUInteger)count
{
    NSPointerArraySubclassResponsibility();
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPointerArraySubclassResponsibility();
    return nil;
}

@end

@implementation NSPointerArray (NSPointerArrayConveniences)

+ (id)strongObjectsPointerArray
{
    return [[[NSConcretePointerArray alloc] init] autorelease];
}

+ (id)weakObjectsPointerArray
{
    return [[[NSConcretePointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory] autorelease];
}

- (NSArray *)allObjects
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for (id object in self)
    {
        if (object != nil)
        {
            [objects addObject:object];
        }
    }
    return [objects autorelease];
}

@end

@implementation NSConcretePointerArray {
    struct NSSlice slice;
    NSUInteger count;
    NSUInteger capacity;
    NSUInteger options;
    NSUInteger mutations;
    BOOL needsCompaction;
}

static inline BOOL NSPointerArrayRangeCheck(NSUInteger index, NSUInteger count, NSString * const exceptionName)
{
    if (index >= count)
    {
        [NSException raise:exceptionName format:@"%d is out of range of array", index];
        return NO;
    }
    return YES;
}

static inline void *acquire(void *ptr, struct NSSlice *slice)
{
    if (slice->acquireFunction != NULL)
    {
        return slice->acquireFunction(ptr, slice->sizeFunction, slice->shouldCopyIn);
    }
    else
    {
        return ptr;
    }
}

static inline void emptyAtIndex(struct NSSlice *slice, NSUInteger index)
{
    void **ptr = slice->items + index;
    void *item = slice->readAt(ptr, NULL);
    if (item != NULL && slice->relinquishFunction != NULL)
    {
        slice->relinquishFunction(item, slice->sizeFunction);
    }
    slice->clearAt(ptr);
}

static inline BOOL allocate(struct NSSlice *slice, size_t count)
{
    slice->items = slice->allocateFunction(count);
    if (slice->items == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer in NSPointerArray"];
        return NO;
    }
    return YES;
}

static inline NSConcretePointerArray *sharedInitialization(NSConcretePointerArray *pa)
{
    pa->capacity = 16;
    pa->mutations = 0;
    pa->needsCompaction = NO;

    [NSConcretePointerFunctions initializeBackingStore:&pa->slice sentinel:NO compactable:YES];

    if (!allocate(&pa->slice, pa->capacity))
    {
        [pa release];
        return nil;
    }

    return pa;
}

- (Class)classForCoder
{
    return [NSPointerArray self];
}

- (id)init
{
    return [self initWithOptions:NSPointerFunctionsStrongMemory];
}

- (id)initWithOptions:(NSPointerFunctionsOptions)opts
{
    options = opts;

    if (![NSConcretePointerFunctions initializeSlice:&slice withOptions:options])
    {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Invalid set of options to initialize an NSPointerArray: %x", options];
        [self release];
        return nil;
    }

    return sharedInitialization(self);
}

- (id)initWithPointerFunctions:(NSPointerFunctions *)pointerFunctions
{
    options = -1;

    slice = ((NSConcretePointerFunctions *)pointerFunctions)->slice;

    return sharedInitialization(self);
}

- (void)dealloc
{
    for (NSUInteger index = 0; index < count; index++)
    {
        emptyAtIndex(&slice, index);
    }
    slice.freeFunction(slice.items, capacity);
    [super dealloc];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }

    if (![other isKindOfClass:[NSPointerArray class]])
    {
        return NO;
    }

    if (count != [other count])
    {
        return NO;
    }

    for (NSUInteger index = 0; index < count; index++)
    {
        if (!slice.isEqualFunction(slice.readAt(slice.items + index, NULL), [other pointerAtIndex:index], slice.sizeFunction))
        {
            return NO;
        }
    }

    return YES;
}

- (NSUInteger)hash
{
    if (slice.usesWeak)
    {
        return (NSUInteger)self;
    }
    else
    {
        return count;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    NSConcretePointerArray *array = [[NSConcretePointerArray alloc] initWithPointerFunctions:[self pointerFunctions]];
    for (NSUInteger index = 0; index < count; index++)
    {
        [array addPointer:slice.readAt(slice.items + index, NULL)];
    }
    return array;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeValueOfObjCType:"i" at:&options];
    [coder encodeValueOfObjCType:"i" at:&count];
    for (id obj in self)
    {
        [coder encodeObject:obj];
    }
    [coder encodeObject:nil];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSPointerFunctionsOptions opts = -1;
    [decoder decodeValueOfObjCType:"i" at:&opts];
    self = [self initWithOptions:opts];
    if (self != nil)
    {
        NSUInteger num = -1;
        [decoder decodeValueOfObjCType:"i" at:&num];
        [self setCount:num];

        for (NSUInteger idx = 0; idx < num; idx++)
        {
            id obj = [decoder decodeObject];
            [self addPointer:obj];
        }
    }
    return self;
}

- (void)setCount:(NSUInteger)num
{
    if (num > capacity)
    {
        NSUInteger oldCount = count;
        bzero(&slice.items[oldCount], num - count);
        count = num;
        needsCompaction = YES;
    }
    else
    {
        for (NSUInteger index = count; index < num; index++)
        {
            emptyAtIndex(&slice, index);
        }
        count = num;
    }
    mutations++;
}

- (NSUInteger)count
{
    return count;
}

- (void)compact
{
    if (!needsCompaction)
    {
        return;
    }

    NSUInteger storeIdx = 0;
    for (NSUInteger readIdx = 0; readIdx < count; readIdx++)
    {
        void *item = slice.readAt(slice.items + readIdx, NULL);
        slice.clearAt(slice.items + readIdx);
        if (item != NULL)
        {
            slice.storeAt(slice.items, item, storeIdx);
            storeIdx++;
        }
    }
    count = storeIdx;
}

- (void)replacePointerAtIndex:(NSUInteger)index withPointer:(void *)ptr
{
    if (!NSPointerArrayRangeCheck(index, count, NSInvalidArgumentException))
    {
        return;
    }
    emptyAtIndex(&slice, index);
    slice.storeAt(slice.items, acquire(ptr, &slice), index);

    if (ptr == NULL)
    {
        needsCompaction = YES;
    }

    mutations++;
}

- (void)insertPointer:(void *)ptr atIndex:(NSUInteger)index
{
    if (!NSPointerArrayRangeCheck(index, count + 1, NSInvalidArgumentException))
    {
        return;
    }
    if (count + 1 > capacity)
    {
        [self arrayGrow:capacity + 1];
    }

    for (NSUInteger idx = count; idx > index; idx--)
    {
        void *item = slice.readAt(slice.items + idx - 1, NULL);
        slice.clearAt(slice.items + idx - 1);
        slice.storeAt(slice.items, item, idx);
    }
    slice.storeAt(slice.items, acquire(ptr, &slice), index);

    if (ptr == NULL)
    {
        needsCompaction = YES;
    }

    count++;
    mutations++;
}

- (void)removePointerAtIndex:(NSUInteger)index
{
    if (!NSPointerArrayRangeCheck(index, count, NSInvalidArgumentException))
    {
        return;
    }

    emptyAtIndex(&slice, index);

    for (NSUInteger idx = index; idx + 1 < count; idx++)
    {
        void *item = slice.readAt(slice.items + idx + 1, NULL);
        slice.clearAt(slice.items + idx + 1);
        slice.storeAt(slice.items, item, idx);
    }

    count--;
    mutations++;
}

- (void)addPointer:(void *)ptr
{
    if (count + 1 > capacity)
    {
        [self arrayGrow:capacity + 1];
    }
    slice.storeAt(slice.items, acquire(ptr, &slice), count);

    if (ptr == NULL)
    {
        needsCompaction = YES;
    }

    count++;
    mutations++;
}

- (void *)pointerAtIndex:(NSUInteger)index
{
    if (!NSPointerArrayRangeCheck(index, count, NSRangeException))
    {
        return NULL;
    }
    return slice.readAt(slice.items + index, NULL);
}

- (void)arrayGrow:(NSUInteger)newCapacity
{
    void **oldItems = slice.items;
    allocate(&slice, newCapacity);

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        void *item = slice.readAt(oldItems + idx, NULL);
        slice.storeAt(slice.items, item, idx);
    }

    slice.freeFunction(oldItems, capacity);

    capacity = newCapacity;
}

- (NSPointerFunctions *)pointerFunctions
{
    NSConcretePointerFunctions *funcs = [NSConcretePointerFunctions alloc];
    memcpy(&funcs->slice, &slice, sizeof(struct NSSlice));
    return [funcs autorelease];
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    if (state->state == count)
    {
        return 0;
    }

    NSUInteger num = 0;
    NSUInteger curr = state->state;
    while (num < len && curr < count)
    {
        buffer[num] = slice.readAt(slice.items + curr, NULL);
        num++;
        curr++;
    }
    state->state = curr;
    state->itemsPtr = buffer;
    if (state->mutationsPtr == NULL)
    {
        state->mutationsPtr = (unsigned long *)&mutations;
    }

    return num;
}

@end
