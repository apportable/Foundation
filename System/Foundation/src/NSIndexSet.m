//
//  NSIndexSet.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <stdlib.h>
#import <Foundation/NSString.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSException.h>
#import <CoreFoundation/CFArray.h>
#import <libv/utlist.h>

typedef struct RangeList {
    NSRange range;
    struct RangeList *next;
    struct RangeList *prev;
} RangeList;

typedef struct {
    CFArrayRef ranges;
    NSUInteger count;
    NSUInteger rangeCount;
} NSIndexSetCache;

static BOOL NSContainsRange(NSRange haystack, NSRange needle)
{
    return haystack.location <= needle.location && NSMaxRange(needle) <= NSMaxRange(haystack);
}

#define FLAGS(set) (set->_indexSetFlags)
#define INTERNAL(set) (set->_internal)
#define MULTIPLE_RANGES(set) INTERNAL(set)._multipleRanges

#define IS_EMPTY(set) (FLAGS(set)._isEmpty)
#define SET_EMPTY(set, val) (FLAGS(set)._isEmpty = val)

#define HAS_SINGLE_RANGE(set) (FLAGS(set)._hasSingleRange)
#define SET_HAS_SINGLE_RANGE(set, val) (FLAGS(set)._hasSingleRange = val)

#define CACHE_VALID(set) (FLAGS(set)._cacheValid)
#define SET_CACHE_VALID(set, val) (FLAGS(set)._cacheValid = val)

#define CACHE(set) (MULTIPLE_RANGES(set)._cache)
#define SET_CACHE(set, value) MULTIPLE_RANGES(set)._cache = value

#define MULTIPLE_RANGE_DATA(set) MULTIPLE_RANGES(set)._data
#define SET_MULTIPLE_RANGE_DATA(set, val) MULTIPLE_RANGES(set)._data = val

#define SINGLE_RANGE(set) (INTERNAL(set)._singleRange._range)

#define SET_SINGLE_RANGE(set, range) SINGLE_RANGE(set) = range

#define RESET_CACHE(set) \
SET_CACHE_VALID(set, NO); \
SET_CACHE(set, NULL)

#define CLEAR_CACHE(set) if (!HAS_SINGLE_RANGE(set) && CACHE_VALID(set)) { \
    NSIndexSetPurgeCache((NSIndexSetCache *)CACHE(set)); \
    RESET_CACHE(set); \
}

#define CLEAR_RANGES(set) if (!IS_EMPTY(set)) { \
    if (HAS_SINGLE_RANGE(set)) { \
        SET_HAS_SINGLE_RANGE(set, NO); \
    } else { \
        CLEAR_CACHE(set); \
    } \
    SET_EMPTY(set, YES); \
}

#define BUILD_CACHE(set) ({ \
    if (!HAS_SINGLE_RANGE(set) && !CACHE_VALID(set)) { \
        NSIndexSetBuildCache(&CACHE(set), MULTIPLE_RANGE_DATA(set)); \
    } \
    BOOL __valid = !HAS_SINGLE_RANGE(set) && CACHE_VALID(set); \
    __valid; \
})


@implementation NSIndexSet {
@package
    struct {
        unsigned int _isEmpty:1;
        unsigned int _hasSingleRange:1;
        unsigned int _cacheValid:1;
        unsigned int _arrayBinderController:29;
    } _indexSetFlags;
    
    union {
        struct {
            NSRange _range;
        } _singleRange;
        struct {
            RangeList *_data;
            NSIndexSetCache *_cache;
        } _multipleRanges;
    } _internal;
}

static inline void NSIndexSetPurgeCache(NSIndexSetCache *cache)
{
    if (cache == NULL)
    {
        return;
    }
    
    CFRelease(cache->ranges);
    
    free(cache);
}

static inline void NSIndexSetBuildCache(NSIndexSetCache **cache, RangeList *ranges)
{
    *cache = malloc(sizeof(NSIndexSetCache));
    if (*cache == NULL)
    {
        return;
    }
    
#define STACK_SIZE 32
    
    RangeList *stack_values[STACK_SIZE] = {0};
    RangeList **values = &stack_values[0];
    RangeList *entry = NULL;
    NSUInteger rangeCount = 0;
    NSUInteger count = 0;
    NSUInteger capacity = 0;
    
    DL_FOREACH(ranges, entry)
    {
        if (rangeCount > STACK_SIZE && values == &stack_values[0])
        {
            values = malloc(capacity * sizeof(RangeList *));
            if (values == NULL)
            {
                free(*cache);
                *cache = NULL;
                return;
            }
        }
        else if (rangeCount > STACK_SIZE && rangeCount + 1 > capacity)
        {
            capacity *= 2;
            values = reallocf(values, capacity * sizeof(RangeList *));
            if (values == NULL) // prev values cleaned up by reallocf
            {
                free(*cache);
                *cache = NULL;
                return;
            }
        }
        
        values[rangeCount] = entry;
        count += entry->range.length;
        
        rangeCount++;
    }
    
    static const CFArrayCallBacks callbacks = {
        .retain = NULL,
        .release = NULL,
    };
    
    (*cache)->ranges = CFArrayCreate(kCFAllocatorDefault, (const void **)values, rangeCount, &callbacks);
    (*cache)->rangeCount = rangeCount;
    
    if (values != &stack_values[0] && values != NULL)
    {
        free(values);
    }
}

static inline void addIndexesInRange(NSIndexSet *self, NSRange range)
{
    NSUInteger start = range.location;
    NSUInteger end = start + range.length;
    
    if (range.length == 0)
    {
        return;
    }
    else if (IS_EMPTY(self))
    {
        SET_HAS_SINGLE_RANGE(self, YES);
        SET_EMPTY(self, NO);
        SET_SINGLE_RANGE(self, range);
        return;
    }
    else if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger rangeStart = SINGLE_RANGE(self).location;
        NSUInteger rangeEnd = rangeStart + SINGLE_RANGE(self).length;
        
        if (rangeEnd == start) //adjoining, merge and extend
        {
            SET_SINGLE_RANGE(self, NSMakeRange(SINGLE_RANGE(self).location, SINGLE_RANGE(self).length + range.length));
            return;
        }
        if ((start <= rangeStart && rangeEnd <= end) ||
            (rangeStart <= start && start <= rangeEnd && rangeEnd <= end) ||
            (start <= rangeStart && rangeStart <= end && end <= rangeEnd))
        {
            SET_SINGLE_RANGE(self, NSMakeRange(MIN(start, rangeStart), MAX(end, rangeEnd) - MIN(start, rangeStart)));
            return;
        }
        RangeList *oldRange = malloc(sizeof(RangeList));
        oldRange->range = SINGLE_RANGE(self);
        
        RangeList *newRange = malloc(sizeof(RangeList));
        newRange->range = range;
        
        SET_HAS_SINGLE_RANGE(self, NO);
        MULTIPLE_RANGE_DATA(self) = NULL;
        
        // set the cache to NULL so that it does not have junk data from the union
        RESET_CACHE(self);
        
        if (oldRange->range.location < newRange->range.location)
        {
            DL_APPEND(MULTIPLE_RANGE_DATA(self), oldRange);
            DL_APPEND(MULTIPLE_RANGE_DATA(self), newRange);
        }
        else
        {
            DL_APPEND(MULTIPLE_RANGE_DATA(self), newRange);
            DL_APPEND(MULTIPLE_RANGE_DATA(self), oldRange);
        }
    }
    else
    {
        // clear the cache
        CLEAR_CACHE(self);
        
        RangeList *newRange = malloc(sizeof(RangeList));
        newRange->range = range;
        
        RangeList *ptr = [self _pointerToRangeBeforeOrContainingIndex:range.location];
        if (ptr == NULL)
        {
            DL_PREPEND(MULTIPLE_RANGE_DATA(self), newRange);
        }
        else if (NSContainsRange(ptr->range, range))
        {
            return;
        }
        else
        {
            DL_INSERT(MULTIPLE_RANGE_DATA(self), ptr, newRange);
        }
        
        [self _mergeOverlappingRangesStartingAtIndex:(ptr ?: MULTIPLE_RANGE_DATA(self))];
    }
}

static inline CFComparisonResult NSIndexSetCompareEntry(RangeList *r1, RangeList *r2, RangeList *search)
{
    RangeList *needle = NULL;
    RangeList *haystack = NULL;
    
    if (r1 == search)
    {
        needle = r1;
        haystack = r2;
    }
    else if (r2 == search)
    {
        needle = r2;
        haystack = r1;
    }
    else
    {
        if (r1->range.location < r2->range.location)
        {
            return kCFCompareLessThan;
        }
        else if (r1->range.location > r2->range.location)
        {
            return kCFCompareGreaterThan;
        }
        else
        {
            return kCFCompareEqualTo;
        }
    }
    
    if (haystack->range.location <= needle->range.location + needle->range.length && needle->range.location + needle->range.length <= haystack->range.location + haystack->range.length)
    {
        return kCFCompareEqualTo;
    }
    else if (needle->range.location < haystack->range.location)
    {
        if (needle == r1)
        {
            return kCFCompareLessThan;
        }
        else
        {
            return kCFCompareGreaterThan;
        }
    }
    else if (needle->range.location > haystack->range.location)
    {
        if (needle == r1)
        {
            return kCFCompareGreaterThan;
        }
        else
        {
            return kCFCompareLessThan;
        }
    }
    
    NSCAssert(0, @"Incorrect searching logic");
    return kCFCompareEqualTo; // error in logic if we get to here?
}

- (BOOL)_isEmpty
{
    return IS_EMPTY(self);
}

- (BOOL)_hasSingleRange
{
    return HAS_SINGLE_RANGE(self);
}

- (NSRange)_singleRange
{
    return SINGLE_RANGE(self);
}

- (RangeList *)_multipleRangeData
{
    return MULTIPLE_RANGE_DATA(self);
}

+ (id)indexSet
{
    return [[[self alloc] init] autorelease];
}

+ (id)indexSetWithIndex:(NSUInteger)value
{
    return [[[self alloc] initWithIndexesInRange:NSMakeRange(value,1)] autorelease];
}

+ (id)indexSetWithIndexesInRange:(NSRange)range
{
    return [[[self alloc] initWithIndexesInRange:range] autorelease];
}

- (id)init
{
    return [self initWithIndexesInRange:NSMakeRange(0,0)];
}

- (id)_init
{
    self = [super init];
    if (self)
    {
        CLEAR_RANGES(self);
    }
    return self;
}

- (id)initWithIndex:(NSUInteger)value
{
    return [self initWithIndexesInRange:NSMakeRange(value, 1)];
}

- (id)initWithIndexSet:(NSIndexSet *)indexSet
{
    [self _init];
    if (self)
    {
        [self _setContentToContentFromIndexSet:indexSet];
    }
    return self;
}

- (id)initWithIndexesInRange:(NSRange)range
{
    [self _init];
    if (self)
    {
        if (range.length > 0)
        {
            addIndexesInRange(self, range);
        }
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSIndexSet class]])
    {
        return NO;
    }
    return [self isEqualToIndexSet:other];
}

- (BOOL)isEqualToIndexSet:(NSIndexSet *)indexSet
{
   
    NSUInteger idx1 = [self firstIndex];
    NSUInteger idx2 = [indexSet firstIndex];
    
    do {
        if (idx1 != idx2)
        {
            return NO;
        }
        idx1 = [self indexGreaterThanIndex:idx1];
        idx2 = [indexSet indexGreaterThanIndex:idx2];
    } while (idx1 != NSNotFound && idx2 != NSNotFound);
    
    return idx1 == idx2;
}

- (NSUInteger)count
{
    if (IS_EMPTY(self))
    {
        return 0;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        return SINGLE_RANGE(self).length;
    }
    else if (!BUILD_CACHE(self))
    {
        RangeList *ptr = NULL;
        NSUInteger count = 0;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            count += ptr->range.length;
        }
        return count;
    }
    else
    {
        return CACHE(self)->count;
    }
}

- (NSUInteger)rangeCount
{
    if (IS_EMPTY(self))
    {
        return 0;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        return 1;
    }
    else if (!BUILD_CACHE(self))
    {
        NSUInteger sum = 0;
        RangeList *ptr = NULL;
        DL_COUNT(MULTIPLE_RANGE_DATA(self), ptr, sum);
        return sum;
    }
    else
    {
        return CACHE(self)->rangeCount;
    }
}

- (NSUInteger)firstIndex
{
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        return SINGLE_RANGE(self).location;
    }
    
    return MULTIPLE_RANGE_DATA(self)->range.location;
}

- (NSUInteger)lastIndex
{
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        return SINGLE_RANGE(self).location + SINGLE_RANGE(self).length - 1;
    }
    
    RangeList *last = DL_TAIL(MULTIPLE_RANGE_DATA(self));
    return last->range.location + last->range.length - 1;
}

- (NSUInteger)indexGreaterThanIndex:(NSUInteger)value
{
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        if (value >= end)
        {
            return NSNotFound;
        }
        else if (value < start)
        {
            return start;
        }
        else
        {
            return value + 1;
        }
    }
    else if (!BUILD_CACHE(self))
    {
        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            NSUInteger start = ptr->range.location;
            NSUInteger end = start + ptr->range.length - 1;
            if (value < end)
            {
                if (value < start)
                {
                    return start;
                }
                else
                {
                    return value + 1;
                }
            }
        }
        return NSNotFound;
    }
    else
    {
        RangeList search = {
            .range = {
                .location = value,
                .length = 0,
            },
        };
        
        CFIndex found = CFArrayBSearchValues(CACHE(self)->ranges, CFRangeMake(0, CACHE(self)->rangeCount), &search, (CFComparatorFunction)&NSIndexSetCompareEntry, &search);
        if (found != kCFNotFound)
        {
            return value + 1;
        }
        
        return NSNotFound;
    }
}

- (NSUInteger)indexGreaterThanOrEqualToIndex:(NSUInteger)value
{
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        if (value > end)
        {
            return NSNotFound;
        }
        else if (value <= start)
        {
            return start;
        }
        else
        {
            return value;
        }
    }
    else if (!BUILD_CACHE(self))
    {
        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            NSUInteger start = ptr->range.location;
            NSUInteger end = start + ptr->range.length - 1;
            if (value < end)
            {
                if (value <= start)
                {
                    return start;
                }
                else
                {
                    return value;
                }
            }
        }
        return NSNotFound;
    }
    else
    {
        RangeList search = {
            .range = {
                .location = value,
                .length = 0,
            },
        };
        
        CFIndex found = CFArrayBSearchValues(CACHE(self)->ranges, CFRangeMake(0, CACHE(self)->rangeCount), &search, (CFComparatorFunction)&NSIndexSetCompareEntry, &search);
        if (found != kCFNotFound)
        {
            return value;
        }
        
        return NSNotFound;
    }
}

- (NSUInteger)indexLessThanIndex:(NSUInteger)value
{
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        if (value <= start)
        {
            return NSNotFound;
        }
        else if (value <= end)
        {
            return value - 1;
        }
        else
        {
            return end;
        }
    }
    else if (!BUILD_CACHE(self))
    {
        RangeList *ptr = MULTIPLE_RANGE_DATA(self);
        if (value <= ptr->range.location)
        {
            return NSNotFound;
        }
        for (;; ptr = ptr->next)
        {
            NSUInteger start = ptr->range.location;
            NSUInteger end = start + ptr->range.length - 1;
            if (value <= end)
            {
                return value - 1;
            }
            if (ptr->next == NULL || value <= ptr->next->range.location)
            {
                return end;
            }
        }
    }
    else
    {
        RangeList search = {
            .range = {
                .location = value,
                .length = 1,
            },
        };
        
        CFIndex found = CFArrayBSearchValues(CACHE(self)->ranges, CFRangeMake(0, CACHE(self)->rangeCount), &search, (CFComparatorFunction)&NSIndexSetCompareEntry, &search);
        if (found != kCFNotFound)
        {
            return value - 1;
        }
        
        return NSNotFound;
    }
    
}

- (NSUInteger)indexLessThanOrEqualToIndex:(NSUInteger)value
{
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        if (value < start)
        {
            return NSNotFound;
        }
        else if (value <= end)
        {
            return value;
        }
        else
        {
            return end;
        }
    }
    else if (!BUILD_CACHE(self))
    {
        RangeList *ptr = MULTIPLE_RANGE_DATA(self);
        if (value < ptr->range.location)
        {
            return NSNotFound;
        }
        for (;; ptr = ptr->next)
        {
            NSUInteger start = ptr->range.location;
            NSUInteger end = start + ptr->range.length - 1;
            if (value <= end)
            {
                return value;
            }
            if (ptr->next == NULL || value < ptr->next->range.location)
            {
                return end;
            }
        }
    }
    else
    {
        RangeList search = {
            .range = {
                .location = value,
                .length = 1,
            },
        };
        
        CFIndex found = CFArrayBSearchValues(CACHE(self)->ranges, CFRangeMake(0, CACHE(self)->rangeCount), &search, (CFComparatorFunction)&NSIndexSetCompareEntry, &search);
        if (found != kCFNotFound)
        {
            return value;
        }
        
        return NSNotFound;
    }
}

- (NSUInteger)getIndexes:(NSUInteger *)indexBuffer maxCount:(NSUInteger)bufferSize inIndexRange:(NSRangePointer)range
{
    if (IS_EMPTY(self) || bufferSize == 0)
    {
        return 0;
    }
    
    NSUInteger count = 0;
    NSUInteger startRange = range ? range->location : 0;
    NSUInteger endRange = range ? (startRange + range->length - 1) : NSUIntegerMax;
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        
        if (endRange < start || startRange > end)
        {
            return 0;
        }
        NSUInteger first = MAX(start, startRange);
        NSUInteger last = MIN(end, endRange);
        for (NSUInteger i = first; i <= last; i++)
        {
            indexBuffer[count++] = i;
            if (count == bufferSize)
            {
                break;
            }
        }
        return count;
    }
    
    RangeList *ptr = NULL;
    DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
    {
        NSUInteger start = ptr->range.location;
        NSUInteger end = start + ptr->range.length - 1;
        
        if (endRange < start)
        {
            return count;
        }
        if (startRange > end)
        {
            continue;
        }
        NSUInteger first = MAX(start, startRange);
        NSUInteger last = MIN(end, endRange);
        for (NSUInteger i = first; i <= last; i++)
        {
            indexBuffer[count++] = i;
            if (count == bufferSize)
            {
                return count;
            }
        }
    }
    return count;
}

- (NSUInteger)countOfIndexesInRange:(NSRange)range
{
    if (IS_EMPTY(self))
    {
        return 0;
    }
    
    NSUInteger startRange = range.location;
    NSUInteger endRange = startRange + range.length - 1;
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        
        if (endRange < start || startRange > end)
        {
            return 0;
        }
        
        NSUInteger first = MAX(start, startRange);
        NSUInteger last = MIN(end, endRange);
        return last - first + 1;
    }
    
    NSUInteger count = 0;
    
    RangeList *ptr = NULL;
    DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
    {
        NSUInteger start = ptr->range.location;
        NSUInteger end = start + ptr->range.length - 1;
        
        if (endRange < start)
        {
            return count;
        }
        if (startRange > end)
        {
            continue;
        }
        NSUInteger first = MAX(start, startRange);
        NSUInteger last = MIN(end, endRange);
        count += last - first + 1;
    }
    
    return count;
}

- (BOOL)containsIndex:(NSUInteger)value
{
    if (IS_EMPTY(self))
    {
        return NO;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        return value >= start && value <= end;
    }
    
    RangeList *ptr = NULL;
    DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
    {
        NSUInteger start = ptr->range.location;
        NSUInteger end = start + ptr->range.length - 1;
        
        if (value < start)
        {
            return NO;
        }
        if (value <= end)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsIndexesInRange:(NSRange)range
{
    if (IS_EMPTY(self) || range.length == 0)
    {
        return NO;
    }
    
    NSUInteger startRange = range.location;
    NSUInteger endRange = startRange + range.length - 1;
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        return startRange >= start && endRange <= end;
    }
    
    RangeList *ptr = NULL;
    
    DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
    {
        NSUInteger start = ptr->range.location;
        NSUInteger end = start + ptr->range.length - 1;
        
        if (start > endRange)
        {
            break;
        }
        if (startRange >= start && endRange <= end)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsIndexes:(NSIndexSet *)indexSet
{
    if (indexSet == nil)
    {
        return YES;
    }
    
    if (IS_EMPTY(self))
    {
        return NO;
    }
    
    if ([indexSet _hasSingleRange])
    {
        return [self containsIndexesInRange:[indexSet _singleRange]];
    }
    
    for (RangeList *ptr = [indexSet _multipleRangeData]; ptr != NULL; ptr = ptr->next)
    {
        if (![self containsIndexesInRange:ptr->range])
        {
            return NO;
        }
    }
    
    return YES;
}
- (BOOL)intersectsIndexesInRange:(NSRange)range
{
    if (IS_EMPTY(self))
    {
        return NO;
    }
    
    NSUInteger startRange = range.location;
    NSUInteger endRange = startRange + range.length - 1;
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSUInteger start = SINGLE_RANGE(self).location;
        NSUInteger end = start + SINGLE_RANGE(self).length - 1;
        return (startRange <= end && endRange >= start);
    }
    
    RangeList *ptr = NULL;
    DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
    {
        NSUInteger start = ptr->range.location;
        NSUInteger end = start + ptr->range.length - 1;
        
        if (start > endRange)
        {
            break;
        }
        if (startRange <= end)
        {
            if (endRange >= start)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (id)description
{
    if (IS_EMPTY(self))
    {
        return @"Empty NSIndexSet";
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        if (SINGLE_RANGE(self).length == 1)
        {
            return  [NSString stringWithFormat:@"index %lu", (unsigned long)SINGLE_RANGE(self).location];
        }
        else
        {
            return  [NSString stringWithFormat:@"index range %lu through %lu", (unsigned long)SINGLE_RANGE(self).location, (unsigned long)(SINGLE_RANGE(self).location + SINGLE_RANGE(self).length - 1)];
        }
    }
    else
    {
        NSMutableString *description = [@"" mutableCopy];

        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            if (ptr->range.length == 1)
            {
                [description appendFormat:@"index %lu -- ", (unsigned long)ptr->range.location];
            }
            else
            {
                [description appendFormat:@"index range %lu through %lu -- ", (unsigned long)ptr->range.location, (unsigned long)(ptr->range.location + ptr->range.length - 1)];
            }
        }
        return [description autorelease];
    }
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    NSMutableIndexSet *copy = [NSMutableIndexSet allocWithZone:zone];
    return [copy initWithIndexSet:self];
}

- (id)copyWithZone:(NSZone*)zone
{
    NSIndexSet *copy = [NSIndexSet allocWithZone:zone];
    return [copy initWithIndexSet:self];
}

- (void)dealloc
{
    CLEAR_CACHE(self);
    
    if (!IS_EMPTY(self) && !HAS_SINGLE_RANGE(self))
    {
        RangeList *ptr = NULL;
        RangeList *tmp = NULL;
        
        DL_FOREACH_SAFE(MULTIPLE_RANGE_DATA(self), ptr, tmp)
        {
            free(ptr);
        }
        
        MULTIPLE_RANGE_DATA(self) = NULL;
    }
    
    [super dealloc];
}

typedef void (^IndexCallback)(NSUInteger, BOOL *);

static void __NSEnumerateSingleIndexRange(NSRange range, NSEnumerationOptions options, IndexCallback block)
{
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply(range.length, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                block(iter + range.location, &stop);
            }
        });
    }
    else if (options & NSEnumerationReverse)
    {
        BOOL stop = NO;
        
        NSUInteger i = range.location + range.length;
        while (i > range.location && !stop)
        {
            block(i - 1, &stop);
            i--;
        }
    }
    else
    {
        BOOL stop = NO;
        
        for (NSUInteger i = range.location; i < range.location + range.length; i++)
        {
            block(i, &stop);
            if (stop)
            {
                return;
            }
        }
    }
}

static void __NSEnumerateMultipleIndexRangesWithNonZeroOptions(NSIndexSet *self, NSRange *range, NSEnumerationOptions options, IndexCallback block)
{
    NSUInteger count = [self count];
    NSUInteger *indexes = (NSUInteger *)malloc(count * sizeof(NSUInteger));
    NSUInteger actualCount = [self getIndexes:indexes maxCount:count inIndexRange:range];
    
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply(actualCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                block(indexes[iter], &stop);
            }
        });
    }
    else // NSEnumerationReverse
    {
        BOOL stop = NO;
        
        for (NSInteger i = actualCount - 1; i >= 0; i--)
        {
            block(indexes[i], &stop);
            
            if (stop)
            {
                break;
            }
        }
    }
    free(indexes);
}

- (void)enumerateIndexesUsingBlock:(void (^)(NSUInteger idx, BOOL *stop))block
{
    [self enumerateIndexesWithOptions:0 usingBlock:block];
}

- (void)enumerateIndexesInRange:(NSRange)range options:(NSEnumerationOptions)options usingBlock:(void (^)(NSUInteger idx, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return;
    }
    
    if (IS_EMPTY(self))
    {
        return;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSRange intersectRange = NSIntersectionRange(range, SINGLE_RANGE(self));
        if (intersectRange.length == 0)
        {
            return;
        }
        __NSEnumerateSingleIndexRange(intersectRange, options, block);
    }
    else if (options != 0)
    {
        __NSEnumerateMultipleIndexRangesWithNonZeroOptions(self, &range, options, block);
    }
    else // multiple ranges, zero options
    {
        BOOL stop = NO;
        
        for (RangeList *ptr = MULTIPLE_RANGE_DATA(self); ptr != NULL; ptr = ptr->next)
        {
            if (range.location >= ptr->range.location + ptr->range.length)
            {
                continue;
            }
            
            if (ptr->range.location >= range.location + range.length)
            {
                break;
            }
            
            NSRange iRange = NSIntersectionRange(range, ptr->range);
            
            for (NSUInteger i = iRange.location; i < iRange.location + iRange.length; i++)
            {
                block(i, &stop);
                
                if (stop)
                {
                    return;
                }
            }
        }
    }
}

- (void)enumerateIndexesWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(NSUInteger idx, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return;
    }
    
    if (IS_EMPTY(self))
    {
        return;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        __NSEnumerateSingleIndexRange(SINGLE_RANGE(self), options, block);
    }
    else if (options != 0)
    {
        __NSEnumerateMultipleIndexRangesWithNonZeroOptions(self, nil, options, block);
    }
    else // multiple ranges, zero options
    {
        BOOL stop = NO;
        
        for (RangeList *ptr = MULTIPLE_RANGE_DATA(self); ptr != NULL; ptr = ptr->next)
        {
            for (NSUInteger i = ptr->range.location; i < ptr->range.location + ptr->range.length; i++)
            {
                block(i, &stop);
                
                if (stop)
                {
                    return;
                }
            }
        }
    }
}

typedef void (^RangeCallback)(NSRange, BOOL *);

static void __NSEnumerateMultipleRangesWithNonZeroOptions(NSIndexSet *self, NSRange *range, NSEnumerationOptions options, RangeCallback block)
{
    NSUInteger count = [self rangeCount];
    
    if (count == 0)
    {
        return;
    }
    
    NSUInteger actualCount = 0;
    NSRange *ranges = (NSRange *)malloc(count * sizeof(NSRange));
    RangeList *ptr = MULTIPLE_RANGE_DATA(self);
    
    for (NSUInteger i = 0; i < count; i++, ptr = ptr->next)
    {
        if (range)
        {
            if (range->location >= ptr->range.location + ptr->range.length)
            {
                continue;
            }
            if (ptr->range.location >= range->location + range->length)
            {
                break;
            }
        }
        ranges[actualCount++] = ptr->range;
    }
    
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply(actualCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                block(ranges[iter], &stop);
            }
        });
    }
    else // NSEnumerationReverse
    {
        BOOL stop = NO;
        for (NSInteger i = actualCount - 1; i >= 0; i--)
        {
            block(ranges[i], &stop);
            
            if (stop)
            {
                break;
            }
        }
    }
    free(ranges);
}

- (void)enumerateRangesUsingBlock:(void (^)(NSRange range, BOOL *stop))block
{
    [self enumerateRangesWithOptions:0 usingBlock:block];
}

- (void)enumerateRangesInRange:(NSRange)range options:(NSEnumerationOptions)options usingBlock:(void (^)(NSRange range, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return;
    }
    
    if (IS_EMPTY(self))
    {
        return;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        BOOL stop = NO;
        NSRange intersectRange = NSIntersectionRange(range, SINGLE_RANGE(self));
        if (intersectRange.length == 0)
        {
            return;
        }
        block(intersectRange, &stop);
    }
    else if (options != 0)
    {
        __NSEnumerateMultipleRangesWithNonZeroOptions(self, &range, options, block);
    }
    else // multiple ranges, zero options
    {
        BOOL stop = NO;
        RangeList *ptr = NULL;
        RangeList *tmp = NULL;
        DL_FOREACH_SAFE(MULTIPLE_RANGE_DATA(self), ptr, tmp)
        {
            if (range.location >= ptr->range.location + ptr->range.length)
            {
                continue;
            }
            if (ptr->range.location >= range.location + range.length)
            {
                break;
            }
            NSRange iRange = NSIntersectionRange(range, ptr->range); // only really necessary on first and last iteration
            block(iRange, &stop);
            if (stop)
            {
                return;
            }
        }
    }
}

- (void)enumerateRangesWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(NSRange range, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return;
    }
    
    if (IS_EMPTY(self))
    {
        return;
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        BOOL stop = NO;
        block(SINGLE_RANGE(self), &stop);
    }
    else if (options != 0)
    {
        __NSEnumerateMultipleRangesWithNonZeroOptions(self, nil, options, block);
    }
    else // multiple ranges, zero options
    {
        BOOL stop = NO;
        RangeList *ptr = NULL;
        RangeList *tmp = NULL;
        DL_FOREACH_SAFE(MULTIPLE_RANGE_DATA(self), ptr, tmp)
        {
            block(ptr->range, &stop);
            if (stop)
            {
                return;
            }
        }
    }
}

typedef BOOL (^IndexTest)(NSUInteger, BOOL *);

static NSUInteger __NSEnumerateIndexSingleIndexRange(NSRange range, NSEnumerationOptions options, IndexTest block)
{
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        __block NSUInteger found = NSNotFound;
        dispatch_apply(range.length, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                if (block(iter + range.location, &stop))
                {
                    found = iter + range.location;
                    stop = YES;
                }
            }
        });
        return found;
    }
    else if (options & NSEnumerationReverse)
    {
        BOOL stop = NO;
        for (NSInteger i = range.location + range.length - 1 ; i >= range.location; i--)
        {
            if (block(i, &stop))
            {
                return i;
            }
            if (stop)
            {
                break;
            }
        }
        return NSNotFound;
    }
    else
    {
        BOOL stop = NO;
        for (NSUInteger i = range.location; i < range.location + range.length; i++)
        {
            if (block(i, &stop))
            {
                return i;
            }
            if (stop)
            {
                break;
            }
        }
        return NSNotFound;
    }
}

static NSUInteger __NSEnumerateIndexMultipleIndexRangesWithNonZeroOptions(NSIndexSet *self, NSRange *range, NSEnumerationOptions options, IndexTest block)
{
    NSUInteger count = [self count];
    NSUInteger *indexes = (NSUInteger *)malloc(count * sizeof(NSUInteger));
    NSUInteger actualCount = [self getIndexes:indexes maxCount:count inIndexRange:range];
    __block NSUInteger found = NSNotFound;
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply(actualCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                if (block(indexes[iter], &stop))
                {
                    found = indexes[iter];
                    stop = YES;
                }
            }
        });
    }
    else // NSEnumerationReverse
    {
        BOOL stop = NO;
        for (NSInteger i = actualCount - 1; i >= 0; i--)
        {
            if (block(indexes[i], &stop))
            {
                found = indexes[i];
                break;
            }
            if (stop)
            {
                break;
            }
        }
    }
    free(indexes);
    return found;
}


- (NSUInteger)indexPassingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    return [self indexWithOptions:0 passingTest:predicate];
}


- (NSUInteger)indexInRange:(NSRange)range options:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return NSNotFound;
    }
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    if (HAS_SINGLE_RANGE(self))
    {
        NSRange intersectRange = NSIntersectionRange(range, SINGLE_RANGE(self));
        if (intersectRange.length == 0)
        {
            return NSNotFound;
        }
        return __NSEnumerateIndexSingleIndexRange(intersectRange, options, predicate);
    }
    else if (options != 0)
    {
        return __NSEnumerateIndexMultipleIndexRangesWithNonZeroOptions(self, &range, options, predicate);
    }
    else // multiple ranges, zero options
    {
        BOOL stop = NO;
        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            if (range.location >= ptr->range.location + ptr->range.length)
            {
                continue;
            }
            if (ptr->range.location >= range.location + range.length)
            {
                break;
            }
            NSRange iRange = NSIntersectionRange(range, ptr->range);
            for (NSUInteger i = iRange.location; i < iRange.location + iRange.length; i++)
            {
                if (predicate(i, &stop))
                {
                    return i;
                }
                if (stop)
                {
                    break;
                }
            }
        }
        return NSNotFound;
    }
}

- (NSUInteger)indexWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return NSNotFound;
    }
    if (IS_EMPTY(self))
    {
        return NSNotFound;
    }
    if (HAS_SINGLE_RANGE(self))
    {
        return __NSEnumerateIndexSingleIndexRange(SINGLE_RANGE(self), options, predicate);
    }
    else if (options != 0)
    {
        return __NSEnumerateIndexMultipleIndexRangesWithNonZeroOptions(self, nil, options, predicate);
    }
    else // multiple ranges, zero options
    {
        BOOL stop = NO;
        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            for (NSUInteger i = ptr->range.location; i < ptr->range.location + ptr->range.length; i++)
            {
                if (predicate(i, &stop))
                {
                    return i;
                }
                if (stop)
                {
                    break;
                }
            }
        }
        return NSNotFound;
    }
}

static NSIndexSet *__NSEnumerateIndexesSingleIndexRange(NSRange range, NSEnumerationOptions options, IndexTest block)
{
    __block NSMutableIndexSet *indexSet = [[NSIndexSet indexSet] mutableCopy];
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply(range.length, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                if (block(iter + range.location, &stop))
                {
                    [indexSet addIndex:iter + range.location];
                }
            }
        });
    }
    else if (options & NSEnumerationReverse)
    {
        BOOL stop = NO;
        for (NSInteger i = range.location + range.length - 1 ; i >= range.location; i--)
        {
            if (block(i, &stop))
            {
                [indexSet addIndex:i];
            }
            if (stop)
            {
                break;
            }
        }
    }
    else
    {
        BOOL stop = NO;
        for (NSUInteger i = range.location; i < range.location + range.length; i++)
        {
            if (block(i, &stop))
            {
                [indexSet addIndex:i];
            }
            if (stop)
            {
                break;
            }
        }
    }
    return [indexSet autorelease];
}

static NSIndexSet *__NSEnumerateIndexesMultipleIndexRangesWithNonZeroOptions(NSIndexSet *self, NSRange *range, NSEnumerationOptions options, IndexTest block)
{
    NSUInteger count = [self count];
    if (count == 0)
    {
        return [NSIndexSet indexSet];
    }
    NSUInteger *indexes = (NSUInteger *)malloc(count * sizeof(NSUInteger));
    NSUInteger actualCount = [self getIndexes:indexes maxCount:count inIndexRange:range];
    __block NSMutableIndexSet *indexSet = [[NSIndexSet indexSet] mutableCopy];
    if (options & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply(actualCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                if (block(indexes[iter], &stop))
                {
                    [indexSet addIndex:indexes[iter]];
                }
            }
        });
    }
    else // NSEnumerationReverse
    {
        BOOL stop = NO;
        for (NSInteger i = actualCount - 1; i >= 0; i--)
        {
            if (block(indexes[i], &stop))
            {
                [indexSet addIndex:indexes[i]];
            }
            if (stop)
            {
                break;
            }
        }
    }
    free(indexes);
    return [indexSet autorelease];
}

- (NSIndexSet *)indexesPassingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    return [self indexesWithOptions:0 passingTest:predicate];
}

- (NSIndexSet *)indexesInRange:(NSRange)range options:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return nil;
    }
    
    if (IS_EMPTY(self))
    {
        return [NSIndexSet indexSet];
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        NSRange intersectRange = NSIntersectionRange(range, SINGLE_RANGE(self));
        if (intersectRange.length == 0)
        {
            return [NSIndexSet indexSet];
        }
        return __NSEnumerateIndexesSingleIndexRange(intersectRange, options, predicate);
    }
    else if (options != 0)
    {
        return __NSEnumerateIndexesMultipleIndexRangesWithNonZeroOptions(self, &range, options, predicate);
    }
    else // multiple ranges, zero options
    {
        NSMutableIndexSet *indexSet = [[NSIndexSet indexSet] mutableCopy];
        BOOL stop = NO;
        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            if (range.location >= ptr->range.location + ptr->range.length)
            {
                continue;
            }
            if (ptr->range.location >= range.location + range.length)
            {
                break;
            }
            NSRange iRange = NSIntersectionRange(range, ptr->range);
            for (NSUInteger i = iRange.location; i < iRange.location + iRange.length; i++)
            {
                if (predicate(i, &stop))
                {
                    [indexSet addIndex:i];
                }
                if (stop)
                {
                    break;
                }
            }
        }
        return [indexSet autorelease];
    }
}

- (NSIndexSet *)indexesWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(NSUInteger idx, BOOL *stop))predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return nil;
    }
    if (IS_EMPTY(self))
    {
        return [NSIndexSet indexSet];
    }
    
    if (HAS_SINGLE_RANGE(self))
    {
        return __NSEnumerateIndexesSingleIndexRange(SINGLE_RANGE(self), options, predicate);
    }
    else if (options != 0)
    {
        return __NSEnumerateIndexesMultipleIndexRangesWithNonZeroOptions(self, nil, options, predicate);
    }
    else // multiple ranges, zero options
    {
        NSMutableIndexSet *indexSet = [[NSIndexSet indexSet] mutableCopy];
        BOOL stop = NO;
        RangeList *ptr = NULL;
        DL_FOREACH(MULTIPLE_RANGE_DATA(self), ptr)
        {
            for (NSUInteger i = ptr->range.location; i < ptr->range.location + ptr->range.length; i++)
            {
                if (predicate(i, &stop))
                {
                    [indexSet addIndex:i];
                }
                if (stop)
                {
                    break;
                }
            }
        }
        return [indexSet autorelease];
    }
}

- (RangeList *)_pointerToRangeBeforeOrContainingIndex:(NSUInteger)index
{
    RangeList *ptr = MULTIPLE_RANGE_DATA(self);
    if (ptr == NULL)
    {
        return NULL;
    }
    
    if (ptr->range.location > index)
    {
        return NULL; // insert at beginning
    }
    while (ptr->next && ptr->next->range.location <= index)
    {
        ptr = ptr->next;
    }
    return ptr;
}

- (void)_mergeOverlappingRangesStartingAtIndex:(RangeList *)ptr
{
    if (ptr == NULL)
    {
        return;
    }
    NSUInteger start = ptr->range.location;
    while (YES)
    {
        RangeList *next = ptr->next;
        if (next)
        {
            NSUInteger endAnd1 = start + ptr->range.length;
            NSUInteger nextStart = next->range.location;
            if (endAnd1 >= nextStart)
            {
                NSUInteger nextEndAnd1 = nextStart + next->range.length;
                DL_DELETE(MULTIPLE_RANGE_DATA(self), next);
                ptr->range.length = MAX(endAnd1, nextEndAnd1) - start;
                free(next);
                continue;
            }
        }
        break;
    }
    if (MULTIPLE_RANGE_DATA(self)->next == NULL)
    {
        CLEAR_CACHE(self);
        SET_HAS_SINGLE_RANGE(self, YES);
        SET_EMPTY(self, NO);
        SET_SINGLE_RANGE(self, ptr->range);
        free(ptr);
    }
}

- (void)_setContentToContentFromIndexSet:(NSIndexSet *)other
{
    if ([other _isEmpty])
    {
        return;
    }
    
    SET_EMPTY(self, NO);
    
    if ([other _hasSingleRange])
    {
        SET_HAS_SINGLE_RANGE(self, YES);
        SET_SINGLE_RANGE(self, [other _singleRange]);
        return;
    }

    for (RangeList *ptr = [other _multipleRangeData]; ptr != NULL; ptr = ptr->next)
    {
        RangeList *to = (RangeList *)malloc(sizeof(RangeList));
        to->range = ptr->range;
        DL_APPEND(MULTIPLE_RANGE_DATA(self), to);
    }
}

@end

@implementation NSMutableIndexSet

- (void)addIndexes:(NSIndexSet *)indexSet
{
    if (indexSet == nil || [indexSet _isEmpty])
    {
        return;
    }
    if ([indexSet _hasSingleRange])
    {
        [self addIndexesInRange:[indexSet _singleRange]];
    }
    else
    {
        NSUInteger currentIndex = [indexSet firstIndex];
        while (currentIndex != NSNotFound)
        {
            [self addIndex:currentIndex];
            currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
        }
    }
}

- (void)removeIndexes:(NSIndexSet *)indexSet
{
    if ([indexSet _isEmpty])
    {
        return;
    }
    if ([indexSet _hasSingleRange])
    {
        [self removeIndexesInRange:[indexSet _singleRange]];
    }
    else
    {
        for (RangeList *ptr = [indexSet _multipleRangeData]; ptr != NULL; ptr = ptr->next)
        {
            [self removeIndexesInRange:ptr->range];
        }
    }
}

- (void)removeAllIndexes
{
    if (!IS_EMPTY(self) && !HAS_SINGLE_RANGE(self))
    {
        RangeList *ptr = NULL;
        RangeList *tmp = NULL;
        
        DL_FOREACH_SAFE(MULTIPLE_RANGE_DATA(self), ptr, tmp)
        {
            free(ptr);
        }
    }

    CLEAR_RANGES(self);
}

- (void)addIndex:(NSUInteger)value
{
    [self addIndexesInRange:NSMakeRange(value, 1)];
}

- (void)removeIndex:(NSUInteger)value
{
    [self removeIndexesInRange:NSMakeRange(value, 1)];
}

- (void)addIndexesInRange:(NSRange)range
{
    addIndexesInRange(self, range);
}

- (void)removeIndexesInRange:(NSRange)range
{
    if (range.length == 0 || [self _isEmpty])
    {
        return;
    }
    
    NSUInteger start = range.location;
    NSUInteger end = start + range.length - 1;
    
    if (HAS_SINGLE_RANGE(self))
    {
        if (NSIntersectionRange(SINGLE_RANGE(self), range).length == 0)
        {
            return;
        }

        NSUInteger rangeStart = SINGLE_RANGE(self).location;
        NSUInteger rangeEnd = rangeStart + SINGLE_RANGE(self).length - 1;
        
        if (start <= rangeStart && (end >= rangeEnd))  // remove everything
        {
            CLEAR_RANGES(self);
            return;
        }
        else if (start <= rangeStart)
        {
            SET_SINGLE_RANGE(self, NSMakeRange(end + 1, rangeEnd - end));
            return;
        }
        else if (end >= rangeEnd)
        {
            SET_SINGLE_RANGE(self, NSMakeRange(SINGLE_RANGE(self).location, start - rangeStart));
            return;
        }
        else // Need to split
        {
            SET_HAS_SINGLE_RANGE(self, NO);
            SET_EMPTY(self, NO);
            // set the cache to NULL so that it does not have junk data from the union
            RESET_CACHE(self);
            
            RangeList *first = (RangeList *)malloc(sizeof(RangeList));
            first->range.location = rangeStart;
            first->range.length = start - rangeStart;
            
            RangeList *second = (RangeList *)malloc(sizeof(RangeList));
            second->range.location = end + 1;
            second->range.length = rangeEnd - end;
            
            MULTIPLE_RANGE_DATA(self) = NULL;
            DL_APPEND(MULTIPLE_RANGE_DATA(self), first);
            DL_APPEND(MULTIPLE_RANGE_DATA(self), second);
            return;
        }
    }
    else
    {
        CLEAR_CACHE(self);
        
        RangeList *tmp;
        RangeList *ptr = [self _pointerToRangeBeforeOrContainingIndex:start];
        if (ptr == NULL)
        {
            ptr = MULTIPLE_RANGE_DATA(self); // start at beginning
        }
        
        DL_FOREACH_SAFE(ptr, ptr, tmp)
        {
            NSUInteger rangeStart = ptr->range.location;
            NSUInteger rangeEnd = rangeStart + ptr->range.length - 1;
            if (start > rangeEnd)
            {
                continue;
            }
            else if (start <= rangeStart && (end >= rangeEnd)) // remove whole range
            {
                DL_DELETE(MULTIPLE_RANGE_DATA(self), ptr);
                free(ptr);
                continue;
            }
            else if (rangeStart > end) // passed relevant ranges
            {
                break;
            }
            else if (start <= rangeStart)
            {
                ptr->range.location = end + 1;
                ptr->range.length = rangeEnd - end;
                break;  // Cannot be any more relevant ranges
            }
            else if (end >= rangeEnd)
            {
                ptr->range.length = start - rangeStart;
                continue;
            }
            else // Need to split
            {
                ptr->range.length = start - rangeStart;
                
                RangeList *second = (RangeList *)malloc(sizeof(RangeList));
                second->range.location = end + 1;
                second->range.length = rangeEnd - end;
                
                DL_INSERT(MULTIPLE_RANGE_DATA(self), ptr, second);
                break;
            }
        }
        
        [self _mergeOverlappingRangesStartingAtIndex:ptr != NULL ? ptr->prev : MULTIPLE_RANGE_DATA(self)];
    }
}

// Shift a range, possibly truncating at 0
static inline void _shiftRange(NSRange *range, NSInteger delta)
{
    if (delta < 0 && -delta > range->location)
    {
        if (-delta > NSMaxRange(*range))
        {
            range->length = 0;
        }
        else
        {
            range->length = NSMaxRange(*range) + delta;
        }
        range->location = 0;
    }
    else
    {
        range->location += delta;
    }
}

- (void)shiftIndexesStartingAtIndex:(NSUInteger)index by:(NSInteger)delta
{
    if (IS_EMPTY(self))
    {
        return;
    }

    if (delta == 0)
    {
        return;
    }

    if (HAS_SINGLE_RANGE(self))
    {
        // Index past range results in no change
        if(NSMaxRange(SINGLE_RANGE(self)) <= index)
        {
            return;
        }

        // Overflow
        if ((delta > 0) && (NSMaxRange(SINGLE_RANGE(self)) > (NSNotFound - delta - 1)))
        {
            [NSException raise:NSRangeException format:@"shift would push range past NSNotFound - 1"];
            return;
        }

        // Overlapping negative shift results in one range
        if ((delta < 0) && -delta <= SINGLE_RANGE(self).length)
        {
            _shiftRange(&SINGLE_RANGE(self), delta);
            return;
        }

        // Index before single range results in one range (or zero if shifted left too far)
        if (index <= SINGLE_RANGE(self).location)
        {
            _shiftRange(&SINGLE_RANGE(self), delta);
            if (SINGLE_RANGE(self).length == 0)
            {
                CLEAR_RANGES(self);
            }
            return;
        }

        // Otherwise, index inside single range splits into two ranges
        RangeList *firstRange = malloc(sizeof(RangeList));
        RangeList *secondRange = malloc(sizeof(RangeList));

        NSRange currentRange = SINGLE_RANGE(self);

        CLEAR_CACHE(self);
        SET_HAS_SINGLE_RANGE(self, NO);
        MULTIPLE_RANGE_DATA(self) = NULL;

        firstRange->range = NSMakeRange(currentRange.location, index - currentRange.location);
        secondRange->range = NSMakeRange(index, NSMaxRange(currentRange) - index);

        if (delta > 0)
        {
            _shiftRange(&secondRange->range, delta);
        }
        else
        {
            _shiftRange(&firstRange->range, delta);
        }

        DL_APPEND(MULTIPLE_RANGE_DATA(self), firstRange);
        DL_APPEND(MULTIPLE_RANGE_DATA(self), secondRange);

        return;
    }
    else
    {
        CLEAR_CACHE(self);

        RangeList *ptr = [self _pointerToRangeBeforeOrContainingIndex:index];
        if (ptr == NULL)
        {
            ptr = MULTIPLE_RANGE_DATA(self); // start at beginning
        }
        if (NSLocationInRange(index, ptr->range) && ptr->range.location != index)
        {
            //Break the range up
            RangeList *second = (RangeList *)malloc(sizeof(RangeList));
            second->range.location = index;
            second->range.length = (ptr->range.location + ptr->range.length) - index;
            second->next = ptr->next;

            ptr->next = second;
            ptr->range.length = index - ptr->range.location;

            ptr = second;
        }
        for (; ptr != NULL; ptr = ptr->next)
        {
            if(NSMaxRange(ptr->range) <= index)
            {
                continue;
            }
            else if ((delta > 0) && ((ptr->range.location + ptr->range.length) > (NSNotFound - delta - 1)))
            {
                [NSException raise:NSRangeException format:@"shift would push range past NSNotFound - 1"];
                return;
            }
            else if ((delta < 0) && (ptr->range.location < -delta))
            {
                if (ptr->range.location + ptr->range.length <= -delta)
                {
                    [self removeIndexesInRange: NSMakeRange(ptr->range.location, ptr->range.length)];
                }
                else
                {
                    NSUInteger oldLocation = ptr->range.location;
                    ptr->range.location = 0;
                    ptr->range.length += (oldLocation + delta);
                }
            }
            else
            {
                ptr->range.location += delta;
            }
        }
    }
}

@end
