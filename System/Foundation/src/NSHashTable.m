//
//  NSHashTable.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSHashTable.h>

#import <Foundation/NSException.h>
#import "NSFastEnumerationEnumerator.h"
#import "NSObjectInternal.h"
#import "NSPointerFunctionsInternal.h"
#import <Foundation/NSSet.h>

#define NSHashTableZeroingWeakMemory NSPointerFunctionsZeroingWeakMemory

CF_PRIVATE
@interface NSConcreteHashTable : NSHashTable
@end

@implementation NSHashTable

+ (id)hashTableWithOptions:(NSPointerFunctionsOptions)options
{
    return [[[NSConcreteHashTable alloc] initWithOptions:options capacity:0] autorelease];
}

+ (id)weakObjectsHashTable
{
    return [[[NSConcreteHashTable alloc] initWithOptions:NSHashTableZeroingWeakMemory capacity:0] autorelease];
}

+ (id)hashTableWithWeakObjects
{
    return [[[NSConcreteHashTable alloc] initWithOptions:NSHashTableZeroingWeakMemory capacity:0] autorelease];
}

+ (id)allocWithZone:(NSZone *)zone
{
    return NSAllocateObject([NSConcreteHashTable self], 0, NULL);
}

+ (id)alloc
{
    return NSAllocateObject([NSConcreteHashTable self], 0, NULL);
}

- (id)init
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithOptions:(NSPointerFunctionsOptions)options capacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithPointerFunctions:(NSPointerFunctions *)pointerFunctions capacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copy];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

- (NSSet *)setRepresentation
{
    NSMutableSet *set = [NSMutableSet set];

    for (id obj in self)
    {
        [set addObject:obj];
    }

    return set;
}

- (NSMutableSet *)mutableSet
{
    NSMutableSet *set = [NSMutableSet set];

    for (id obj in self)
    {
        [set addObject:obj];
    }

    return set;
}

- (void)minusHashTable:(NSHashTable *)hashTable
{
    if (self == hashTable)
    {
        [self removeAllObjects];
        return;
    }

    for (id obj in hashTable)
    {
        [self removeObject:obj];
    }
}

- (void)unionHashTable:(NSHashTable *)hashTable
{
    if (self == hashTable)
    {
        return;
    }

    for (id obj in hashTable)
    {
        [self addObject:obj];
    }
}

- (void)intersectHashTable:(NSHashTable *)hashTable
{
    if (self == hashTable)
    {
        return;
    }

    NSUInteger count = [self count];

    id *objects = malloc(count * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    NSUInteger removeIdx = 0;

    for (id obj in self)
    {
        id member = [hashTable member:obj];
        if (member == nil)
        {
            objects[removeIdx++] = obj;
        }
    }

    for (NSUInteger idx = 0; idx < removeIdx; idx++)
    {
        [self removeObject:objects[idx]];
    }

    free(objects);
}

- (BOOL)isSubsetOfHashTable:(NSHashTable *)hashTable
{
    for (id obj in self)
    {
        if ([hashTable member:obj] == nil)
        {
            return NO;
        }
    }

    return YES;
}

- (BOOL)isEqualToHashTable:(NSHashTable *)hashTable
{
    if (self == hashTable)
    {
        return YES;
    }

    if ([self count] != [hashTable count])
    {
        return NO;
    }

    for (id obj in self)
    {
        if ([hashTable member:obj] == nil)
        {
            return NO;
        }
    }

    for (id obj in hashTable)
    {
        if ([self member:obj] == nil)
        {
            return NO;
        }
    }

    return YES;
}

- (BOOL)intersectsHashTable:(NSHashTable *)hashTable
{
    for (id obj in self)
    {
        if ([hashTable member:obj] != nil)
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL)containsObject:(id)object
{
    return [self getItem:object] ? YES : NO;
}

- (id)anyObject
{
    for (id object in self)
    {
        return object;
    }
    return nil;
}

- (void)removeAllObjects
{
    [self removeAllItems];
}

- (void)removeObject:(id)object
{
    [self removeItem:object];
}

- (id)member:(id)object
{
    return (id)[self getItem:object];
}

- (NSPointerFunctions *)pointerFunctions
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)getKeys:(const void **)keys count:(NSUInteger *)count
{
    NSRequestConcreteImplementation();
}

- (void)removeAllItems
{
    NSRequestConcreteImplementation();
}

- (id)copy
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)removeItem:(const void *)item
{
    NSRequestConcreteImplementation();
}

- (void)insertKnownAbsentItem:(const void *)item
{
    NSRequestConcreteImplementation();
}

- (void)addObject:(id)object
{
    NSRequestConcreteImplementation();
}

- (void *)getItem:(const void *)item
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (NSUInteger)weakCount
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSArray *)allObjects
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)objects count:(NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSRequestConcreteImplementation();
}

- (id)initWithCoder:(NSCoder *)decoder
{
    [super dealloc];
    return [[NSConcreteHashTable alloc] initWithCoder:decoder];
}

- (NSEnumerator *)objectEnumerator
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)description
{
    NSRequestConcreteImplementation();
    return nil;
}

@end

@implementation NSConcreteHashTable
{
    struct NSSlice slice;
    NSUInteger count;
    NSUInteger capacity;
    NSPointerFunctionsOptions options;
    NSUInteger mutations;
}

// NSConcreteHashTable preserves the following invariants:

// If hash(X) points to nothing, X is not in the table.

// If hash(X) points to something, X may be in the table. If so, it is
// found by iterating through the items at hash(X), hash(X) + 1, etc.
// until either X is found or nothing is found.

// This means that adding X to the table means computing hash(X),
// and putting it in the first available slot.

// This also implies that removing X from the table means restoring
// the invariant. This is the purpose of the rehashAround: method.

// In particular, if hash(X) == hash(Y) == idx, and X was put in the
// table before Y, the layout before removal will be something like:
// ... | idx - 1 | idx + 0 | idx + 1 | idx + 2 | ...
// ... | NOTHING |    X    |    Y    | NOTHING | ...

// The layout after removing X is then:
// ... | idx - 1 | idx + 0 | idx + 1 | idx + 2 | ...
// ... | NOTHING | NOTHING |    Y    | NOTHING | ...
// which breaks the invariant above, as hash(Y) points to nothing.

// Thus we must rehashAround: and move Y back to idx:
// ... | idx - 1 | idx + 0 | idx + 1 | idx + 2 | ...
// ... | NOTHING |    Y    | NOTHING | NOTHING | ...


#define NSDefaultHashTableCapacity 16

static inline BOOL decrementCount(NSConcreteHashTable *ht)
{
    if (ht->count > 0)
    {
        ht->count--;
        return YES;
    }
    else
    {
        [ht raiseCountUnderflowException];
        return NO;
    }
}

static inline void incrementIndex(NSConcreteHashTable *ht, NSUInteger *idx)
{
    (*idx)++;
    if (*idx == ht->capacity)
    {
        *idx = 0;
    }
}

static inline void decrementIndex(NSConcreteHashTable *ht, NSUInteger *idx)
{
    if (*idx == 0)
    {
        *idx = ht->capacity;
    }
    (*idx)--;
}

// The following is taken from objc-weak.mm
static inline uintptr_t hash_pointer(const void *key) {
    uintptr_t k = (uintptr_t)key;

    // Code from CFSet.c
#if __LP64__
    uintptr_t a = 0x4368726973746F70ULL;
    uintptr_t b = 0x686572204B616E65ULL;
#else
    uintptr_t a = 0x4B616E65UL;
    uintptr_t b = 0x4B616E65UL;
#endif
    uintptr_t c = 1;
    a += k;
#if __LP64__
    a -= b; a -= c; a ^= (c >> 43);
    b -= c; b -= a; b ^= (a << 9);
    c -= a; c -= b; c ^= (b >> 8);
    a -= b; a -= c; a ^= (c >> 38);
    b -= c; b -= a; b ^= (a << 23);
    c -= a; c -= b; c ^= (b >> 5);
    a -= b; a -= c; a ^= (c >> 35);
    b -= c; b -= a; b ^= (a << 49);
    c -= a; c -= b; c ^= (b >> 11);
    a -= b; a -= c; a ^= (c >> 12);
    b -= c; b -= a; b ^= (a << 18);
    c -= a; c -= b; c ^= (b >> 22);
#else
    a -= b; a -= c; a ^= (c >> 13);
    b -= c; b -= a; b ^= (a << 8);
    c -= a; c -= b; c ^= (b >> 13);
    a -= b; a -= c; a ^= (c >> 12);
    b -= c; b -= a; b ^= (a << 16);
    c -= a; c -= b; c ^= (b >> 5);
    a -= b; a -= c; a ^= (c >> 3);
    b -= c; b -= a; b ^= (a << 10);
    c -= a; c -= b; c ^= (b >> 15);
#endif
    return c;
}

static inline NSUInteger hash(NSConcreteHashTable *ht, const void *item)
{
    return hash_pointer(item) % ht->capacity;
}

// Returns the index of the first entry in the hash table which is
// equal to the sought item or is nothing.
static NSUInteger searchHashTable(NSConcreteHashTable *ht, const void *searchItem, const void **gotItem, BOOL preserveSentinels)
{
    NSUInteger startingIdx = hash(ht, searchItem);
    NSUInteger idx = startingIdx;

    do {
        BOOL wasSentinel = YES;
        void *item = ht->slice.readAt(ht->slice.items + idx, &wasSentinel);

        if (item != NULL)
        {
            if (ht->slice.isEqualFunction(item, searchItem, ht->slice.sizeFunction))
            {
                if (gotItem != NULL)
                {
                    *gotItem = item;
                }
                return idx;
            }
        }
        else if (wasSentinel)
        {
            if (gotItem != NULL)
            {
                *gotItem = NULL;
            }
            return idx;
        }
        else if (!preserveSentinels)
        {
            ht->slice.clearAt(ht->slice.items + idx);
            if (!decrementCount(ht))
            {
                return NSNotFound;
            }
            [ht rehashAround:idx];
        }

        incrementIndex(ht, &idx);
    } while (idx != startingIdx);

    if (gotItem != NULL)
    {
        *gotItem = NULL;
    }
    return NSNotFound;
}

static void empty(struct NSSlice *slice, NSUInteger capacity)
{
    for (NSUInteger idx = 0; idx < capacity; idx++)
    {
        void *item = slice->readAt(slice->items + idx, NULL);
        if (item != NULL && slice->relinquishFunction != NULL)
        {
            slice->relinquishFunction(item, slice->sizeFunction);
        }
        slice->clearAt(slice->items + idx);
    }
}

static NSUInteger roundCapacityToPowerOfTwo(NSUInteger n)
{
    if (n == 0)
    {
        return NSDefaultHashTableCapacity;
    }

    if ((n & (n - 1)) == 0)
    {
        return n;
    }

    NSUInteger ret = 1;
    while (n != 0)
    {
        ret <<= 1;
        n >>= 1;
    }

    return ret;
}

static void NSConcreteHashTableAllocationFailure(void)
{
    [NSException raise:NSMallocException format:@"Unable to allocate backing store for hash table"];
}

static BOOL initBackingStore(struct NSSlice *slice, NSUInteger capacity)
{
    [NSConcretePointerFunctions initializeBackingStore:slice sentinel:YES compactable:NO];
    slice->items = slice->allocateFunction(capacity);

    if (slice->items == NULL)
    {
        NSConcreteHashTableAllocationFailure();
        return NO;
    }

    return YES;
}

- (void)dealloc
{
    empty(&slice, capacity);
    slice.freeFunction(slice.items, capacity);
    slice.items = NULL;
    [super dealloc];
}

- (id)initWithPointerFunctions:(NSPointerFunctions *)pointerFunctions capacity:(NSUInteger)cap
{
    if (pointerFunctions == nil)
    {
        [self release];
        [NSException raise:NSInternalInconsistencyException format:@"Cannot init hash table with nil pointer functions"];
        return nil;
    }

    if ([pointerFunctions class] != [NSConcretePointerFunctions self])
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot use unknown subclass of NSPointerFunctions to init hash table"];
        return nil;
    }

    NSConcretePointerFunctions *cpf = (NSConcretePointerFunctions *)pointerFunctions;

    memcpy(&slice, &cpf->slice, sizeof(struct NSSlice));
    slice.items = NULL;

    capacity = roundCapacityToPowerOfTwo(cap);
    count = 0;
    mutations = 0;
    options = NSPointerFunctionsOptionsInvalid;

    [self _initBlock];

    if (!initBackingStore(&slice, capacity))
    {
        [self release];
        return nil;
    }

    return self;
}

- (id)initWithOptions:(NSPointerFunctionsOptions)opts capacity:(NSUInteger)cap
{
    options = opts;
    capacity = roundCapacityToPowerOfTwo(cap);
    count = 0;
    mutations = 0;

    [self _initBlock];
    if (![NSConcretePointerFunctions initializeSlice:&slice withOptions:options])
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Bad options to init hash table"];
        return nil;
    }

    if (!initBackingStore(&slice, capacity))
    {
        [self release];
        return nil;
    }

    return self;
}

- (id)init
{
    return [self initWithOptions:0 capacity:NSDefaultHashTableCapacity];
}

- (void)_initBlock
{
    slice.callback = nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSUInteger memoryType = options & NSPointerFunctionsMemoryTypeMask;
    if (memoryType != NSPointerFunctionsStrongMemory &&
        memoryType != NSPointerFunctionsOpaqueMemory)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot encode hash table with weak references"];
        return;
    }

    NSUInteger personality = options & NSPointerFunctionsPersonalityMask;
    if (personality != NSPointerFunctionsObjectPersonality &&
        personality != NSPointerFunctionsOpaquePersonality &&
        personality != NSPointerFunctionsStructPersonality &&
        personality != NSPointerFunctionsIntegerPersonality)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot encode hash table with object pointer or c string personality"];
        return;
    }

    if ((options & NSPointerFunctionsCopyIn) != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot encode hash table created with copy-in option"];
        return;
    }

    [coder encodeValueOfObjCType:@encode(NSPointerFunctionsOptions) at:&options];

    for (id obj in self)
    {
        if (obj == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot encode nil"];
            return;
        }
        [coder encodeObject:obj];
    }

    [coder encodeObject:nil];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSPointerFunctionsOptions decodedOptions = 0;
    [decoder decodeValueOfObjCType:@encode(NSPointerFunctionsOptions) at:&decodedOptions];

    self = [self initWithOptions:decodedOptions capacity:capacity];
    if (self != nil)
    {
        for (id obj = nil; obj != nil; obj = [decoder decodeObject])
        {
            [self addObject:obj];
        }
    }
    return self;
}

- (Class)classForCoder
{
    return [NSHashTable self];
}

- (id)copy
{
    NSConcreteHashTable *copy = [NSConcreteHashTable alloc];

    copy->count = 0;
    copy->mutations = 0;
    copy->options = options;
    copy->capacity = capacity;

    memcpy(&copy->slice, &slice, sizeof(struct NSSlice));
    copy->slice.items = NULL;

    [copy _initBlock];

    copy->slice.items = copy->slice.allocateFunction(copy->capacity);
    if (copy->slice.items == NULL)
    {
        [self release];
        [NSException raise:NSMallocException format:@"Unable to allocate backing store for hash table"];
        return nil;
    }

    for (id item in self)
    {
        [copy insertItem:item];
    }

    return copy;
}

- (NSEnumerator *)objectEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }

    if (other == nil)
    {
        return NO;
    }

    if (![other isKindOfClass:[NSConcreteHashTable self]])
    {
        return NO;
    }

    NSConcreteHashTable *hashTable = (NSConcreteHashTable *)other;

    if (count != hashTable->count)
    {
        return NO;
    }

    if (slice.isEqualFunction != hashTable->slice.isEqualFunction)
    {
        return NO;
    }

    if (slice.sizeFunction != hashTable->slice.sizeFunction)
    {
        return NO;
    }

    for (NSUInteger idx = 0; idx < capacity; idx++)
    {
        void *item = slice.readAt(slice.items + idx, NULL);
        if (item == NULL)
        {
            break;
        }

        void *otherItem = [hashTable getItem:item];

        if (!slice.isEqualFunction(item, otherItem, slice.sizeFunction))
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

- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"NSHashTable {\n"];

    for (NSUInteger idx = 0; idx < capacity; idx++)
    {
        id obj = slice.readAt(slice.items + idx, NULL);
        if (obj != nil)
        {
            [desc appendFormat:@"[%llu] %@\n", (unsigned long long)idx, slice.describeFunction(obj)];
        }
    }

    [desc appendString:@"}\n"];

    return desc;
}

- (void)getKeys:(const void **)keys count:(NSUInteger *)outCount
{
    NSUInteger nonNilIdx = 0;

    for (NSUInteger idx = 0; idx < capacity; idx++)
    {
        void *item = slice.readAt(slice.items + idx, NULL);
        if (item != NULL)
        {
            keys[nonNilIdx++] = item;
        }
    }

    if (outCount != NULL)
    {
        *outCount = nonNilIdx;
    }
}

- (NSArray *)allObjects
{
    NSMutableArray *array = [NSMutableArray array];

    for (id obj in self)
    {
        [array addObject:obj];
    }

    return array;
}

- (void)removeAllItems
{
    empty(&slice, capacity);
    mutations++;
    count = 0;
}

- (void)removeItem:(const void *)item
{
    if (item == NULL)
    {
        return;
    }

    const void *gotItem = NULL;
    NSUInteger idx = searchHashTable(self, item, &gotItem, YES);

    if (gotItem == NULL)
    {
        return;
    }

    if (slice.relinquishFunction != NULL)
    {
        slice.relinquishFunction(gotItem, slice.sizeFunction);
    }

    slice.clearAt(slice.items + idx);

    if (!decrementCount(self))
    {
        return;
    }

    mutations++;

    [self rehashAround:idx];
}

- (void)insertKnownAbsentItem:(const void *)item
{
    if (item == NULL)
    {
        return;
    }

    void *gotItem = NULL;
    NSUInteger idx = searchHashTable(self, item, (const void **)&gotItem, YES);

    if (gotItem != NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"Item was not absent from hash table"];
        return;
    }

    [self assign:idx key:item];

    count++;
    if (count * 2 > capacity)
    {
        [self hashGrow];
    }
}

- (void)addObject:(id)object
{
    if (object == nil)
    {
        return;
    }

    id gotObject = nil;
    NSUInteger idx = searchHashTable(self, object, (const void **)&gotObject, YES);

    if (gotObject != nil)
    {
        return;
    }

    [self assign:idx key:object];

    count++;
    if (count * 2 > capacity)
    {
        [self hashGrow];
    }
}

- (void)insertItem:(const void *)item
{
    if (item == NULL)
    {
        return;
    }

    void *gotItem = NULL;
    NSUInteger idx = searchHashTable(self, item, (const void **)&gotItem, YES);

    [self assign:idx key:item];

    if (gotItem == NULL)
    {
        count++;
        if (count * 2 > capacity)
        {
            [self hashGrow];
        }
    }
}

- (void *)getItem:(const void *)item
{
    if (item == NULL)
    {
        return NULL;
    }

    void *gotItem = NULL;
    searchHashTable(self, item, (const void **)&gotItem, NO);

    return gotItem;
}

- (void)rehash
{
    if (count == 0)
    {
        return;
    }

    void * const sentinel = slice.usesSentinel ? _NSPointerFunctionsSentinel : NULL;

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        void *item = slice.items[idx];
        if (item == sentinel)
        {
            NSUInteger newIdx = [self rehashAround:idx];
            if (newIdx < idx)
            {
                return;
            }
            idx = newIdx;
        }
    }
}

- (void)assign:(NSUInteger)idx key:(const void *)key
{
    mutations++;

    if (slice.acquireFunction != NULL)
    {
        key = slice.acquireFunction(key, slice.sizeFunction, slice.shouldCopyIn);
    }

    slice.storeAt(slice.items, (void *)key, idx);
}

- (void)hashGrow
{
    NSUInteger oldCapacity = capacity;
    capacity *= 2;
    void **oldItems = slice.items;
    slice.items = slice.allocateFunction(capacity);
    if (slice.items == NULL)
    {
        NSConcreteHashTableAllocationFailure();
        return;
    }
    count = 0;


    for (NSUInteger idx = 0; idx < oldCapacity; idx++)
    {
        void *item = slice.readAt(oldItems + idx, NULL);
        if (item != NULL)
        {
            count++;
            NSUInteger newIdx = searchHashTable(self, item, NULL, NO);
            slice.storeAt(slice.items, item, newIdx);
            slice.clearAt(oldItems + idx);
        }
    }

    slice.freeFunction(oldItems, oldCapacity);
}

- (NSUInteger)rehashAround:(NSUInteger)startingIdx
{
    void * const sentinel = slice.usesSentinel ? _NSPointerFunctionsSentinel : NULL;

    // Find the first empty empty slot to the left of startingIdx
    NSUInteger idx = startingIdx;
    do {
        decrementIndex(self, &idx);
    } while (slice.items[idx] != sentinel);

    while (YES)
    {
        incrementIndex(self, &idx);
        if (idx == startingIdx)
        {
            incrementIndex(self, &idx);
        }

        BOOL wasSentinel = NO;
        void *item = slice.readAt(slice.items + idx, &wasSentinel);

        if (item == NULL)
        {
            slice.clearAt(slice.items + idx);

            if (wasSentinel)
            {
                return idx;
            }

            if (!decrementCount(self))
            {
                return NSNotFound;
            }
        }
        else
        {
            slice.clearAt(slice.items + idx);
            NSUInteger newIdx = searchHashTable(self, item, NULL, NO);
            slice.storeAt(slice.items, item, newIdx);
        }
    }
}

- (void)raiseCountUnderflowException
{
    [NSException raise:NSInternalInconsistencyException format:@"Count underflow in NSConcreteHashTable"];
}

- (NSUInteger)count
{
    return count;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)objects count:(NSUInteger)count
{
    state->mutationsPtr = (unsigned long *)&mutations;

    while (state->state < capacity)
    {
        void *item = slice.readAt(slice.items + state->state, NULL);
        state->state++;
        if (item != NULL)
        {
            state->itemsPtr = (id *)&state->extra[2];
            *state->itemsPtr = item;
            return 1;
        }
    }

    return 0;
}

- (NSPointerFunctions *)pointerFunctions
{
    NSConcretePointerFunctions *pf = [[NSConcretePointerFunctions alloc] autorelease];
    memcpy(&pf->slice, &slice, sizeof(struct NSSlice));
    pf->slice.items = NULL;
    return pf;
}

@end
