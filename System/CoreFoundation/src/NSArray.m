//
//  NSArray.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSArray.h>

#import <Foundation/NSData.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSIndexSet.h>

#import <objc/message.h>
#import <objc/runtime.h>

#import "NSFastEnumerationEnumerator.h"
#import "NSObjectInternal.h"
#import "NSStringInternal.h"
#import "CFInternal.h"

CF_EXPORT Boolean _CFArrayIsMutable(CFArrayRef array);
CF_EXPORT NSUInteger _CFArrayFastEnumeration(CFArrayRef array, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);
CF_EXPORT CFDataRef _CFPropertyListCreateXMLData(CFAllocatorRef allocator, CFPropertyListRef propertyList, Boolean checkValidPlist);

#define STACK_BUFFER_SIZE 256

@interface NSArray (Internal)
+ (id)newWithContentsOf:(id)pathOrURL immutable:(BOOL)immutable;
@end

CF_PRIVATE
@interface __NSPlaceholderArray : NSMutableArray
+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
@end

CF_PRIVATE
@interface __NSCFArray : NSMutableArray
@end

CF_PRIVATE
@interface __NSArrayI : NSArray
+ (id)__new:(const id *)objects :(NSUInteger)count :(BOOL)immutable;
@end

CF_PRIVATE
@interface __NSArrayReverseEnumerator : NSEnumerator
- (id)initWithObject:(NSArray *)object;
@end

@implementation NSMutableArray (Mutation)

- (void)_mutate
{
}

@end

@implementation NSArray

+ (id)allocWithZone:(NSZone *)zone
{

    NSArray *array = nil;

    if (self == [NSArray class])
    {
        array = [__NSPlaceholderArray immutablePlaceholder];
    }
    else if (self == [NSMutableArray class])
    {
        array = [__NSPlaceholderArray mutablePlaceholder];
    }
    else
    {
        array = [super allocWithZone:zone];
    }

    return array;
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)objectAtIndex:(NSUInteger)idx
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSArray allocWithZone:zone] initWithArray:self copyItems:NO];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[NSMutableArray allocWithZone:zone] initWithArray:self copyItems:NO];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    // state->state is -1 when iteration is done.

    // state->state is otherwise the index into the array to start
    // iterating at (including at the start of iteration, when it is
    // 0).

    // state->extra[0] is count.

    if (buffer == NULL && len != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot enumerate into NULL buffer of nonzero length"];
        return 0;
    }

    if (state->state == -1)
    {
        return 0;
    }

    if (state->state == 0)
    {
        state->mutationsPtr = &state->extra[0];
        state->extra[0] = [self count];
    }

    state->itemsPtr = buffer;

    NSUInteger returnedLength = MIN(state->extra[0] - state->state, len);
    if (returnedLength != 0)
    {
        [self getObjects:buffer range:NSMakeRange(state->state, returnedLength)];
    }

    if (state->state + returnedLength >= state->extra[0])
    {
        state->state = -1;
    }
    else
    {
        state->state += returnedLength;
    }

    return returnedLength;
}

- (CFTypeID)_cfTypeID
{
    return CFArrayGetTypeID();
}

- (BOOL)isNSArray__
{
    return YES;
}

- (NSUInteger)hash
{
    return [self count];
}

- (BOOL)isEqual:(NSArray *)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isNSArray__])
    {
        return NO;
    }
    return [self isEqualToArray:other];
}

@end

@implementation NSMutableArray

- (void)addObject:(id)obj
{
    [self insertObject:obj atIndex:[self count]];
}

- (void)insertObject:(id)obj atIndex:(NSUInteger)idx
{
    NSRequestConcreteImplementation();
}

- (void)removeLastObject
{
    NSUInteger count = [self count];
    if (count > 0)
    {
        [self removeObjectAtIndex:count - 1];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSRequestConcreteImplementation();
}

- (void)removeAllObjects
{
    for (int n = [self count] - 1; n >= 0; n--)
    {
        [self removeObjectAtIndex:n];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)obj
{
    NSRequestConcreteImplementation();
}

- (void)replaceObjectsInRange:(NSRange)range withObjects:(const id *)objects count:(NSUInteger)count
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of array"];
        return;
    }

    if (objects == NULL && count > 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot insert NULL objects with nonzero count into array"];
        return;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        if (objects[idx] == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot insert nil into array"];
            return;
        }
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        [objects[idx] retain];
    }

    NSUInteger index = 0;
    while (index < range.length && index < count)
    {
        [self replaceObjectAtIndex:index + range.location withObject:objects[index]];
        index++;
    }

    while (index < count)
    {
        [self insertObject:objects[index] atIndex:index + range.location];
        index++;
    }

    NSUInteger idx = index + range.location;
    while (index < range.length)
    {
        [self removeObjectAtIndex:idx];
        index++;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        [objects[idx] release];
    }
}

- (void)setArray:(NSArray *)array
{
    NSUInteger count = [array count];
    id objects[STACK_BUFFER_SIZE] = {0};
    id *objs = &objects[0];
    if (count > STACK_BUFFER_SIZE)
    {
        objs = malloc(sizeof(id) * count);
        if (objs == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d objects"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return;
        }
    }

    [array getObjects:objs range:NSMakeRange(0, count)];
    [self replaceObjectsInRange:NSMakeRange(0, [self count]) withObjects:objs count:count];

    if (objs != objects)
    {
        free(objs);
    }
}

- (void)insertObjects:(const id *)objects count:(NSUInteger)count atIndex:(NSUInteger)idx
{
    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"index %d is out of bounds of count %d for array", idx, [self count]];
        return;
    }
    NSUInteger i = 0;
    [self _mutate];
    while (count > 0)
    {
        [self insertObject:objects[i] atIndex:idx];
        idx++;
        i++;
        count--;
    }
}

@end

@implementation NSMutableArray (NSExtendedMutableArray)

- (void)addObjectsFromArray:(NSArray *)other
{
    for (id obj in other)
    {
        [self addObject:obj];
    }
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    NSUInteger count = [self count];
    if (idx1 >= count || idx2 >= count)
    {
        CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("index (%d) beyond array bounds (%d)"), MAX(idx1, idx2), count);
        @throw [NSException exceptionWithName:NSRangeException reason:(NSString *)reason userInfo:nil];
        CFRelease(reason);
        return;
    }
    if (idx1 == idx2)
    {
        return;
    }
    id obj1 = [self objectAtIndex:idx1];
    [obj1 retain];
    id obj2 = [self objectAtIndex:idx2];
    [self replaceObjectAtIndex:idx2 withObject:obj1];
    [self replaceObjectAtIndex:idx1 withObject:obj2];
    [obj1 release];
}

- (void)removeAllObjects
{
    NSUInteger count = [self count];
    while (count > 0)
    {
        [self removeObjectAtIndex:count - 1];
        count--;
    }
}

- (void)removeObject:(id)obj inRange:(NSRange)range
{
    NSUInteger count = [self count];
    if (NSMaxRange(range) > count)
    {
        CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("range {%d, %d} beyond array bounds (%d)"), range.location, range.length, count);
        @throw [NSException exceptionWithName:NSRangeException reason:(NSString *)reason userInfo:nil];
        CFRelease(reason);
        return;
    }
    obj = [obj retain];
    NSUInteger idx = [self indexOfObject:obj inRange:range];
    if (idx != NSNotFound)
    {
        [self removeObjectAtIndex:idx];
    }
    [obj release];
}

- (void)removeObject:(id)obj
{
    obj = [obj retain];
    NSUInteger idx = [self indexOfObject:obj];
    while (idx != NSNotFound)
    {
        [self removeObjectAtIndex:idx];
        idx = [self indexOfObject:obj];
    }
    [obj release];
}

- (void)removeObjectIdenticalTo:(id)obj inRange:(NSRange)range
{
    obj = [obj retain];
    NSUInteger idx = [self indexOfObjectIdenticalTo:obj inRange:range];
    while (idx != NSNotFound)
    {
        [self removeObjectAtIndex:idx];
        idx = [self indexOfObjectIdenticalTo:obj inRange:range];
    }
    [obj release];
}

- (void)removeObjectIdenticalTo:(id)obj
{
    obj = [obj retain];
    NSUInteger idx = [self indexOfObjectIdenticalTo:obj];
    while (idx != NSNotFound)
    {
        [self removeObjectAtIndex:idx];
        idx = [self indexOfObjectIdenticalTo:obj];
    }
    [obj release];
}

- (void)removeObjectsFromIndices:(NSUInteger *)indices numIndices:(NSUInteger)cnt
{
    if (cnt == 0)
    {
        return;
    }
    CFSortIndexes((CFIndex *)indices, cnt, 0, ^(CFIndex i1, CFIndex i2) {
        if (i1 < i2)
        {
            return kCFCompareLessThan;
        }
        else if (i1 > i2)
        {
            return kCFCompareGreaterThan;
        }
        else
        {
            return kCFCompareEqualTo;
        }
    });
    for (NSInteger idx = cnt - 1; idx >= 0; idx--)
    {
        [self removeObjectAtIndex:indices[idx]];
    }
}

- (void)removeObjectsInArray:(NSArray *)other
{
    NSSet *set = [[NSSet alloc] initWithArray:other];
    for (id obj in set)
    {
        [self removeObject:obj];
    }
    [set release];
}

- (void)removeObjectsInRange:(NSRange)range
{
    for (NSInteger idx = NSMaxRange(range) - 1; idx >= 0; idx--)
    {
        [self removeObjectAtIndex:idx];
    }
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)other range:(NSRange)otherRange
{
    NSUInteger count = otherRange.length;
    id objects[STACK_BUFFER_SIZE] = {0};
    id *objs = &objects[0];
    if (count > STACK_BUFFER_SIZE)
    {
        objs = malloc(sizeof(id) * count);
        if (objs == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d objects"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return;
        }
    }

    [other getObjects:objs range:otherRange];

    [self replaceObjectsInRange:range withObjects:objs count:count];

    if (objs != objects)
    {
        free(objs);
    }
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)other
{
    NSUInteger count = [other count];
    id objects[STACK_BUFFER_SIZE] = {0};
    id *objs = &objects[0];
    if (count > STACK_BUFFER_SIZE)
    {
        objs = malloc(sizeof(id) * count);
        if (objs == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d objects"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return;
        }
    }

    [other getObjects:objs range:NSMakeRange(0, count)];

    [self replaceObjectsInRange:range withObjects:objs count:count];

    if (objs != objects)
    {
        free(objs);
    }
}

- (void)setArray:(NSArray *)other
{
    NSUInteger count = [other count];
    id objects[STACK_BUFFER_SIZE] = {0};
    id *objs = &objects[0];
    if (count > STACK_BUFFER_SIZE)
    {
        objs = malloc(sizeof(id) * count);
        if (objs == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d objects"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return;
        }
    }

    [other getObjects:objs range:NSMakeRange(0, count)];
    [self replaceObjectsInRange:NSMakeRange(0, [self count]) withObjects:objs count:count];

    if (objs != objects)
    {
        free(objs);
    }
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context
{
    [self sortWithOptions:0 usingComparator:^(id obj1, id obj2){
        return compare(obj1, obj2, context);
    }];
}

- (void)sortUsingSelector:(SEL)comparator
{
    [self sortWithOptions:0 usingComparator:^(id obj1, id obj2){
        return ((NSComparisonResult (*)(id, SEL, id))objc_msgSend)(obj1, comparator, obj2);
    }];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indices
{
    NSUInteger currentIndex = [indices firstIndex];
    NSUInteger count = [objects count];
    if (count != [indices count])
    {
        CFStringRef format = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("indices specifies count of %d and objects specifies %d; one of them is wrong"), [indices count], count);
        [NSException raise:NSInvalidArgumentException format:(NSString *)format];
        CFRelease(format);
        return;
    }

    for (id object in objects)
    {
        if (currentIndex == NSNotFound)
        {
            break;
        }
        [self insertObject:object atIndex:currentIndex];
        currentIndex = [indices indexGreaterThanIndex:currentIndex];
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indices
{
    NSUInteger currentIndex = [indices lastIndex];
    while (currentIndex != NSNotFound)
    {
        [self removeObjectAtIndex:currentIndex];
        currentIndex = [indices indexLessThanIndex:currentIndex];
    }
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indices withObjects:(NSArray *)objects
{
    NSUInteger currentIndex = [indices lastIndex];
    NSUInteger count = [objects count];
    if (count != [indices count])
    {
        CFStringRef format = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("indices specifies count of %d and objects specifies %d; one of them is wrong"), [indices count], count);
        [NSException raise:NSInvalidArgumentException format:(NSString *)format];
        CFRelease(format);
        return;
    }
    while (currentIndex != NSNotFound)
    {
        [self replaceObjectAtIndex:currentIndex withObject:[objects objectAtIndex:count - 1]];
        currentIndex = [indices indexLessThanIndex:currentIndex];
        count--;
    }
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    NSUInteger count = [self count];
    if (obj == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Trying to insert a nil value into an array."];
        return;
    }
    if (idx > count)
    {
        [NSException raise:NSRangeException format:@"Trying to insert beyond end of array"];
        return;
    }
    else if (idx == count)
    {
        [self insertObject:obj atIndex:idx];
    }
    else
    {
        [self replaceObjectAtIndex:idx withObject:obj];
    }
}

- (void)sortRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)comparator
{
    if ([self count] <= 1) {
        return;
    }

    [self _mutate];
    NSUInteger count = range.length;
    id *objs = malloc(sizeof(id) * count);
    CFIndex *indexes = (CFIndex *)malloc(count * sizeof(CFIndex));
    [self getObjects:objs range:range];
    CFSortIndexes(indexes, count, opts, ^(CFIndex i1, CFIndex i2) {
        return (CFComparisonResult)comparator(objs[i1], objs[i2]);
    });
    assert(sizeof(id) == sizeof(CFIndex));
    for (int i = 0; i < count; i++) {
        indexes[i] = (CFIndex)objs[indexes[i]]; // re-use indexes allocation
    }
    [self replaceObjectsInRange:range withObjects:(id *)indexes count:count];
    free(indexes);
    free(objs);
}

- (void)sortUsingComparator:(NSComparator)comparator
{
    if (comparator == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passed a nil comparator to sortUsingComparator" userInfo:nil];
        return;
    }
    [self sortRange:NSMakeRange(0, [self count]) options:0 usingComparator:comparator];
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparator
{
    if (comparator == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Passed a nil comparator to sortWithOptions" userInfo:nil];
        return;
    }
    [self sortRange:NSMakeRange(0, [self count]) options:opts usingComparator:comparator];
}

@end


@implementation NSMutableArray (NSMutableArrayCreation)

+ (id)arrayWithCapacity:(NSUInteger)numItems
{
    return [[[self alloc] initWithCapacity:numItems] autorelease];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}


- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    self = [self initWithCapacity:cnt];

    if (self)
    {
        [self insertObjects:objects count:cnt atIndex:0];
    }

    return self;
}

@end

static CFArrayCallBacks sNSCFArrayCallBacks = {
    0,
    &_NSCFRetain2,
    &_NSCFRelease2,
    &_NSCFCopyDescription,
    &_NSCFEqual
};

static __NSPlaceholderArray *immutablePlaceholder = nil;
static __NSPlaceholderArray *mutablePlaceholder = nil;

@implementation __NSPlaceholderArray

+ (id)immutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        immutablePlaceholder = [__NSPlaceholderArray allocWithZone:nil];
    });
    return immutablePlaceholder;
}

+ (id)mutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        mutablePlaceholder = [__NSPlaceholderArray allocWithZone:nil];
    });
    return mutablePlaceholder;
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    if (self == mutablePlaceholder)
    {
        CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, cnt, &sNSCFArrayCallBacks);
        for (CFIndex idx = 0; idx < cnt; idx++)
        {
            id object = objects[idx];
            CFArrayInsertValueAtIndex(array, idx, (const void *)object);
        }
        return (id)array;
    }
    else
    {
        if (cnt == 0)
        {
            static dispatch_once_t once = 0L;
            static __NSArrayI *__NSArrayI0 = nil;
            dispatch_once(&once, ^{
                __NSArrayI0 = [__NSArrayI __new:nil :0 :0];
            });
            return (__NSPlaceholderArray *)[__NSArrayI0 retain];
        }
        else
        {
            return (__NSPlaceholderArray *)[__NSArrayI __new:objects :cnt :0];
        }
    }
}

SINGLETON_RR()

- (id)initWithContentsOfURL:(NSURL *)url
{
    return (id)[NSArray newWithContentsOf:url immutable:self == immutablePlaceholder];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return (id)[NSArray newWithContentsOf:path immutable:self == immutablePlaceholder];
}

- (id)init
{
    if (self == mutablePlaceholder)
    {
        return [self initWithCapacity:0];
    }
    else
    {
        return [self initWithObjects:nil count:0];
    }
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if (self == mutablePlaceholder)
    {
        NSCapacityCheck(capacity, 0x40000000, @"Please rethink the size of the capacity of the array you are creating: %d seems a bit exessive", capacity);
        return (id)CFArrayCreateMutable(kCFAllocatorDefault, capacity, &sNSCFArrayCallBacks);
    }
    else
    {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
}

@end



@implementation NSArray (NSExtendedArray)

- (NSArray *)arrayByAddingObject:(id)obj
{
    NSUInteger count = [self count] + 1;
    id *objects = malloc(sizeof(id) * count);
    if (UNLIKELY(objects == NULL))
    {
        return nil;
    }
    [self getObjects:objects range:NSMakeRange(0, count - 1)];
    objects[count - 1] = obj;
    NSArray *array = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    return [array autorelease];
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)other
{
    NSUInteger localCount = [self count];
    NSUInteger otherCount = [other count];
    NSUInteger count = localCount  + otherCount;
    id *objects = NULL;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        if (UNLIKELY(objects == NULL))
        {
            return nil;
        }
        if (localCount > 0)
        {
            [self getObjects:objects range:NSMakeRange(0, localCount)];
        }
        if (otherCount > 0)
        {
            [other getObjects:objects + localCount range:NSMakeRange(0, otherCount)];
        }
    }
    NSArray *array = [[NSArray alloc] initWithObjects:objects count:count];
    if (objects != NULL)
    {
        free(objects);
    }
    return [array autorelease];
}

- (NSString *)componentsJoinedByString:(NSString *)sep
{

    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    if ([sep isKindOfClass:objc_lookUpClass("NSString")])
    {
        id last = [self lastObject];
        for (id obj in self)
        {
            CFStringAppend(str, (CFStringRef)[obj description]);
            if (obj != last)
            {
                CFStringAppend(str, (CFStringRef)sep);
            }
        }
    }
    else
    {
        CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@ is not a string"), sep);
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:(NSString *)reason userInfo:nil];
        CFRelease(reason);
    }

    CFStringRef retVal = CFStringCreateCopy(kCFAllocatorDefault, str);
    CFRelease(str);
    return [(NSString *)retVal autorelease];
}

- (BOOL)containsObject:(id)obj
{
    for (id object in self)
    {
        if (object == obj || [object isEqual:obj])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [self descriptionWithLocale:locale indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    CFMutableStringRef description = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppendFormat(description, NULL, CFSTR("%*s(\n"), (int)level * strlen(INDENT), "");
    NSUInteger count = [self count];
    for (id obj in self)
    {
        NSString *valueDescription = nil;
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]])
        {
            valueDescription = [obj descriptionWithLocale:locale indent:level + 1];
        }
        else if ([obj respondsToSelector:@selector(descriptionWithLocale:)])
        {
            valueDescription = [obj descriptionWithLocale:locale];
        }
        else
        {
            valueDescription = [obj description];
        }
        count--;
        if (count == 0) // No comma
        {
            CFStringAppendFormat(description, NULL, CFSTR("%*s%@\n"), ((int)level + 1) * strlen(INDENT), "", valueDescription);
            break;
        }
        else
        {
            CFStringAppendFormat(description, NULL, CFSTR("%*s%@,\n"), ((int)level + 1) * strlen(INDENT), "", valueDescription);
        }
    }
    CFStringAppendFormat(description, NULL, CFSTR("%*s)"), (int)level * strlen(INDENT), "");
    CFStringRef desc = CFStringCreateCopy(kCFAllocatorDefault, description);
    CFRelease(description);
    return [(NSString *)desc autorelease];
}

- (id)firstObjectCommonWithArray:(NSArray *)other
{
    if (other && ![other isNSArray__])
    {
        [NSException raise:NSInvalidArgumentException format:@"argument must be an array"];
        return nil;
    }

    NSSet *objects = [NSSet setWithArray:other];
    for (id obj in self)
    {
        if ([objects containsObject:obj])
        {
            return obj;
        }
    }
    return nil;
}

- (void)getObjects:(id __unsafe_unretained [])objects
{
    [self getObjects:objects range:NSMakeRange(0, [self count])];
}

- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range
{
    NSUInteger objectIndex = 0;
    for (NSUInteger idx = range.location; idx < NSMaxRange(range); idx++)
    {
        objects[objectIndex] = [self objectAtIndex:idx];
        objectIndex++;
    }
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self indexOfObject:object inRange:NSMakeRange(0, [self count])];
}

- (NSUInteger)indexOfObject:(id)object inRange:(NSRange)range
{
    for (NSUInteger idx = range.location; idx < NSMaxRange(range); idx++)
    {
        id obj = [self objectAtIndex:idx];
        if (object == obj || [object isEqual:obj])
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)obj
{
    return [self indexOfObjectIdenticalTo:obj inRange:NSMakeRange(0, [self count])];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)obj inRange:(NSRange)range
{
    for (NSUInteger idx = range.location; idx < NSMaxRange(range); idx++)
    {
        if ([self objectAtIndex:idx] == obj)
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (BOOL)isEqualToArray:(NSArray *)other
{
    if (self == other)
    {
        return YES;
    }
    NSUInteger count1 = [self count];
    NSUInteger count2 = [other count];
    if (count1 != count2)
    {
        return NO;
    }

    if (count1 == 0) // && count2 == 0
    {
        return YES;
    }

    NSUInteger idx = 0;
    for (id obj1 in self)
    {
        id obj2 = [other objectAtIndex:idx];
        if (obj1 != obj2 && ![obj1 isEqual:obj2])
        {
            return NO;
        }
        idx++;
    }

    return YES;
}

- (id)firstObject
{
    NSUInteger count = [self count];
    if (count > 0)
    {
        return [self objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

- (id)lastObject
{
    NSUInteger count = [self count];
    if (count > 0)
    {
        return [self objectAtIndex:count - 1];
    }
    else
    {
        return nil;
    }
}

- (NSEnumerator *)objectEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (NSEnumerator *)reverseObjectEnumerator
{
    return [[[__NSArrayReverseEnumerator alloc] initWithObject:self] autorelease];
}

- (NSData *)sortedArrayHint
{
    NSUInteger count = [self count];
    id *objects = NULL;
    NSUInteger found = 0;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        if (UNLIKELY(objects == NULL))
        {
            return nil;
        }
        NSFastEnumerationState state;
        found = [self countByEnumeratingWithState:&state objects:objects count:count];
    }
    return [NSData dataWithBytesNoCopy:objects length:found * sizeof(id) freeWhenDone:YES];
}

- (NSArray *)sortedArrayFromRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    if (cmptr == nil)
    {
        [self doesNotRecognizeSelector:_cmd];
        CFStringRef format = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("-[%s <null selector>] unrecognized selector 0x%x"), object_getClassName(self), self);
        [NSException raise:NSInvalidArgumentException format:(NSString *)format];
        CFRelease(format);
        return nil;
    }

    NSUInteger count = range.length;
    id objects[STACK_BUFFER_SIZE] = {0};
    CFIndex indices[STACK_BUFFER_SIZE] = {0};
    id *objs = &objects[0];
    CFIndex *indexes = &indices[0];

    if (count > STACK_BUFFER_SIZE)
    {
        objs = malloc(sizeof(id) * count);
        if (objs == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d objects"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return nil;
        }
        indexes = malloc(sizeof(CFIndex) * count);
        if (indexes == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d indices"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return nil;
        }
    }

    [self getObjects:objs range:range];
    CFSortIndexes(indexes, count, opts, ^(CFIndex i1, CFIndex i2) {
        return (CFComparisonResult)cmptr(objs[i1], objs[i2]);
    });
    assert(sizeof(id) == sizeof(CFIndex));
    for (int i = 0; i < count; i++) {
        indexes[i] = (CFIndex)objs[indexes[i]]; // re-use indexes allocation
    }

    if (objs != objects)
    {
        free(objs);
    }

    // Note: the indexes is reused as an object store.
    NSArray *arr = [[NSArray alloc] initWithObjects:(id *)indexes count:count];
    if (indices != indexes)
    {
        free(indexes);
    }
    return [arr autorelease];
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context
{
    return [self sortedArrayUsingFunction:comparator context:context hint:nil];
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint
{
#warning TODO:  USE HINT
    return [self sortedArrayFromRange:NSMakeRange(0, [self count]) options:0 usingComparator: ^(id obj1, id obj2){
        return comparator(obj1, obj2, context);
    }];
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator
{
    return [self sortedArrayFromRange:NSMakeRange(0, [self count]) options:0 usingComparator:^(id obj1, id obj2) {
        return (NSComparisonResult)[obj1 performSelector:(comparator) withObject:obj2];
    }];
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator)comparator
{
    return [self sortedArrayWithOptions:NSSortStable usingComparator:comparator];
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparator
{
    return [self sortedArrayFromRange:NSMakeRange(0, [self count]) options:opts usingComparator:comparator];
}

- (NSArray *)subarrayWithRange:(NSRange)range
{
    id *objects = nil;
    if (range.length > 0)
    {
        objects = malloc(sizeof(id) * range.length);
        if (UNLIKELY(objects == NULL))
        {
            return nil;
        }
        [self getObjects:objects range:range];
    }
    NSArray *subarray = [[NSArray alloc] initWithObjects:objects count:range.length];
    if (objects != NULL)
    {
        free(objects);
    }
    return [subarray autorelease];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically
{
    NSData *data = (NSData *)_CFPropertyListCreateXMLData(kCFAllocatorDefault, (CFPropertyListRef)self, true);
    BOOL success = [data writeToFile:path atomically:atomically];
    [data release];
    return success;
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
    NSData *data = (NSData *)_CFPropertyListCreateXMLData(kCFAllocatorDefault, (CFPropertyListRef)self, true);
    BOOL success = [data writeToURL:url atomically:atomically];
    [data release];
    return success;
}

- (void)makeObjectsPerformSelector:(SEL)sel
{
    [self makeObjectsPerformSelector:sel withObject:nil];
}

- (void)makeObjectsPerformSelector:(SEL)sel withObject:(id)obj
{
    NSUInteger count = [self count];
    id *objects = NULL;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        [self getObjects:objects range:NSMakeRange(0, count)];
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            [objects[idx] performSelector:sel withObject:obj];
        }
        free(objects);
    }
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indices
{
    NSUInteger count = [indices count];
    id *objects = NULL;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        if (UNLIKELY(objects == NULL))
        {
            return nil;
        }
        NSUInteger currentIndex = [indices firstIndex];
        NSUInteger idx = 0;
        while (currentIndex != NSNotFound && idx < count) // idx check only here for buffer overrun prevention
        {
            objects[idx] = [self objectAtIndex:currentIndex];
            currentIndex = [indices indexGreaterThanIndex:currentIndex];
            idx++;
        }
    }
    NSArray *array = [[NSArray alloc] initWithObjects:objects count:count];
    if (objects != NULL)
    {
        free(objects);
    }
    return [array autorelease];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self objectAtIndex:idx];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    NSUInteger len = [self count];
    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;

        if (opts & NSEnumerationReverse)
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    NSUInteger i = len - 1 - iter;
                    block([self objectAtIndex:i], i, &stop);
                }
            });
        }
        else
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    block([self objectAtIndex:iter], iter, &stop);
                }
            });
        }
        return;
    }
    if (opts & NSEnumerationReverse)
    {
        for (int i = len - 1; i >= 0; i--)
        {
            BOOL stop = NO;
            block([self objectAtIndex:i], i, &stop);
            if (stop)
            {
                return;
            }
        }
    }
    else
    {
        NSUInteger i = 0;
        for (id obj in self)
        {
            BOOL stop = NO;
            block(obj, i, &stop);
            if (stop)
            {
                return;
            }
            i++;
        }
    }
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return;
    }
    NSIndexSet *indexes = [s copy];
    [indexes enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, BOOL *stop) {
        block([self objectAtIndex:idx], idx, stop);
    }];
    [indexes release];
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    return [self indexOfObjectWithOptions:0 passingTest:predicate];
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSUInteger len = [self count];
    __block NSUInteger found = NSNotFound;
    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;

        if (opts & NSEnumerationReverse)
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    NSUInteger i = len - 1 - iter;
                    if (predicate([self objectAtIndex:i], i, &stop))
                    {
                        stop = YES;
                        found = i;
                    }
                }
            });
        }
        else
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    if(predicate([self objectAtIndex:iter], iter, &stop))
                    {
                        stop = YES;
                        found = iter;
                    }
                }
            });
        }
    }
    if (opts & NSEnumerationReverse)
    {
        for (int i = len - 1; i >= 0; i--)
        {
            BOOL stop = NO;
            if (predicate([self objectAtIndex:i], i, &stop))
            {
                stop = YES;
                found = i;
            }
            if (stop)
            {
                break;
            }
        }
    }
    else
    {
        NSUInteger i = 0;
        for (id obj in self)
        {
            BOOL stop = NO;
            if (predicate(obj, i, &stop))
            {
                stop = YES;
                found = i;
            }
            if (stop)
            {
                break;
            }
            i++;
        }
    }
    return found;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    __block NSUInteger found = NSNotFound;
    [s enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, BOOL *stop) {
        if (predicate([self objectAtIndex:idx], idx, stop)) {
            found = idx;
        }
    }];
    return found;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    // NOTE: NS(Mutable)IndexSet is an upward linkage into Foundation
    NSObject *indexSet = [[objc_getClass("NSMutableIndexSet") alloc] init];
    NSUInteger len = [self count];
    BOOL stop = NO;
    for (NSUInteger i = 0; i < len; i++)
    {
        if (predicate([self objectAtIndex:i], i, &stop))
        {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indexSet, @selector(addIndex:), i);
        }
        if (stop)
        {
            break;
        }
    }
    return (NSIndexSet *)[indexSet autorelease];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSObject *indices = [[objc_getClass("NSMutableIndexSet") alloc] init];
    NSUInteger len = [self count];

    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;

        if (opts & NSEnumerationReverse)
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    NSUInteger i = len - 1 - iter;
                    if (predicate([self objectAtIndex:i], i, &stop))
                    {
                        ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), i);
                    }
                }
            });
        }
        else
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    if(predicate([self objectAtIndex:iter], iter, &stop))
                    {
                        ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), iter);
                    }
                }
            });
        }
    }
    if (opts & NSEnumerationReverse)
    {
        for (int i = len - 1; i >= 0; i--)
        {
            BOOL stop = NO;
            if (predicate([self objectAtIndex:i], i, &stop))
            {
                ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), i);
            }
            if (stop)
            {
                break;
            }
        }
    }
    else
    {
        NSUInteger i = 0;
        for (id obj in self)
        {
            BOOL stop = NO;
            if (predicate(obj, i, &stop))
            {
                ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), i);
            }
            if (stop)
            {
                break;
            }
            i++;
        }
    }
    return (NSIndexSet *)[indices autorelease];
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSObject *indices = [[objc_getClass("NSMutableIndexSet") alloc] init];
    [s enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, BOOL *stop) {
        if (predicate([self objectAtIndex:idx], idx, stop))
        {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), idx);
        }
    }];
    return (NSIndexSet *)[indices autorelease];
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)comparator
{
    NSUInteger count = [self count];
    if (NSMaxRange(r) > count)
    {
        CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("range {%d, %d} beyond array bounds (%d)"), r.location, r.length, count);
        @throw [NSException exceptionWithName:NSRangeException reason:(NSString *)reason userInfo:nil];
        CFRelease(reason);
        return 0;
    }
    if (count == 0) {
        if (opts & NSBinarySearchingInsertionIndex) {
            return 0;
        } else {
            return NSNotFound;
        }
    }
    return [self _indexOfObject:obj inSortedRange:r options:opts usingComparator:comparator];

}

- (NSUInteger)_indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)comparator {
    NSUInteger minIndex = r.location;
    NSUInteger midIndex = (r.length / 2) + r.location;
    NSUInteger maxIndex = NSMaxRange(r) - 1;
    id mid = [self objectAtIndex:midIndex];
    NSComparisonResult result = comparator(mid, obj);
    switch (result)
    {
        case NSOrderedAscending:
            if ((opts & NSBinarySearchingInsertionIndex) && midIndex == maxIndex)
            {
                return maxIndex + 1;
            }
            else if (midIndex == maxIndex)
            {
                return NSNotFound;
            }
            else
            {
                return [self _indexOfObject:obj inSortedRange:NSMakeRange(midIndex + 1, maxIndex - midIndex) options:opts usingComparator:comparator];
            }
            break;
        case NSOrderedDescending:
            if ((opts & NSBinarySearchingInsertionIndex) && (midIndex == minIndex))
            {
                return minIndex;
            }
            else if (midIndex == minIndex)
            {
                return NSNotFound;
            }
            else
            {
                return [self _indexOfObject:obj inSortedRange:NSMakeRange(minIndex, midIndex - minIndex) options:opts usingComparator:comparator];
            }
        case NSOrderedSame:
            if (opts & NSBinarySearchingFirstEqual)
            {
                for (NSUInteger idx = midIndex; ; idx--)
                {
                    mid = [self objectAtIndex:idx];
                    result = comparator(mid, obj);
                    if (result != NSOrderedSame)
                    {
                        return idx + 1;
                    }
                    if (idx == 0)
                    {
                        break;
                    }
                }
                return 0; //At this point is safe to assume that all the objects compared as equal in the range [0,midIndex]
            }
            else if (opts & NSBinarySearchingLastEqual)
            {
                for (NSUInteger idx = midIndex + 1; idx < [self count]; idx++)
                {
                    mid = [self objectAtIndex:idx];
                    result = comparator(mid, obj);
                    if (result != NSOrderedSame)
                    {
                        return idx;
                    }
                }
                return [self count]; //At this point is safe to assume that all the objects compared as equal in the range [midIndex, count)
            }
            else
            {
                return midIndex;
            }
            break;
    }
    return NSNotFound;
}

@end

@implementation NSArray (NSArrayCreation)

+ (instancetype)array
{
    return [[[self alloc] initWithObjects:NULL count:0] autorelease];
}

+ (instancetype)arrayWithObject:(id)obj
{
    return [[[self alloc] initWithObjects:&obj count:1] autorelease];
}
+ (instancetype)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    return [[[self alloc] initWithObjects:objects count:cnt] autorelease];
}

+ (instancetype)arrayWithObjects:(id)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    id value = firstObj;
    size_t size = 32;
    size_t count = 0;
    id *values = (id *)malloc(sizeof(id) * size);
    if (UNLIKELY(values == NULL))
    {
        return nil;
    }
    while(value != NULL)
    {
        count++;
        if (count > size)
        {
            size += 32;
            values = (id *)realloc(values, sizeof(id) * size);
            if (UNLIKELY(values == NULL))
            {
                return nil;
            }
        }
        values[count - 1] = value;
        value = va_arg(args, id);
    }
    NSArray *array = [[self alloc] initWithObjects:values count:count];
    free(values);
    return [array autorelease];
}

+ (instancetype)arrayWithArray:(NSArray *)other
{
    NSUInteger count = [other count];
    id *objects = NULL;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        if (UNLIKELY(objects == NULL))
        {
            return nil;
        }
        [other getObjects:objects range:NSMakeRange(0, count)];
    }
    NSArray *array = [[self alloc] initWithObjects:objects count:count];
    free(objects);
    return [array autorelease];
}

+ (instancetype)arrayWithContentsOfFile:(NSString *)path
{
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+ (instancetype)arrayWithContentsOfURL:(NSURL *)url
{
    return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (instancetype)initWithObjects:(id)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    id value = firstObj;
    size_t size = 32;
    size_t count = 0;
    id *values = (id *)malloc(sizeof(id) * size);
    if (UNLIKELY(values == NULL))
    {
        [self release];
        return nil;
    }
    while(value != NULL)
    {
        count++;
        if (count > size)
        {
            size += 32;
            values = (id *)realloc(values, sizeof(id) * size);
            if (UNLIKELY(values == NULL))
            {
                [self release];
                return nil;
            }
        }
        values[count - 1] = value;
        value = va_arg(args, id);
    }
    NSArray *array = [self initWithObjects:values count:count];
    free(values);
    return array;
}

- (instancetype)initWithArray:(NSArray *)other
{
    NSUInteger count = [other count];
    id *objects = NULL;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        if (UNLIKELY(objects == NULL))
        {
            [self release];
            return nil;
        }
        [other getObjects:objects range:NSMakeRange(0, count)];
    }
    NSArray *array = [self initWithObjects:objects count:count];
    if (objects != NULL)
    {
        free(objects);
    }
    return array;
}

- (instancetype)initWithArray:(NSArray *)other range:(NSRange)r copyItems:(BOOL)flag
{
    NSUInteger count = [other count];
    id *objects = NULL;
    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);
        if (UNLIKELY(objects == NULL))
        {
            [self release];
            return nil;
        }
        [other getObjects:objects range:NSMakeRange(0, count)];
        if (flag)
        {
            for (NSUInteger idx = 0; idx < count; idx++)
            {
                objects[idx] = [objects[idx] copy];
            }
        }
    }
    NSArray *array = [self initWithObjects:objects count:count];
    if (objects != NULL)
    {
        free(objects);
    }
    return array;
}

- (instancetype)initWithArray:(NSArray *)array copyItems:(BOOL)flag
{
    return [self initWithArray:array range:NSMakeRange(0, [array count]) copyItems:flag];
}

- (instancetype)initWithContentsOfFile:(NSString *)path
{
    [self release];
    return [NSArray newWithContentsOf:path immutable:YES];
}

- (instancetype)initWithContentsOfURL:(NSURL *)url
{
    [self release];
    return [NSArray newWithContentsOf:url immutable:YES];
}

@end

@implementation __NSCFArray

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)getObjects:(id __unsafe_unretained [])objs range:(NSRange)range
{
    CFArrayGetValues((CFArrayRef)self, CFRangeMake(range.location, range.length), (const void **)objs);
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        if (index >= [self count])
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("index (%d) beyond array bounds (%d)"), index, [self count]);
            @throw [NSException exceptionWithName:NSRangeException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
        }
        CFArrayRemoveValueAtIndex((CFMutableArrayRef)self, index);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj
{
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        if (index > CFArrayGetCount((CFArrayRef)self))
        {
            [NSException raise:NSRangeException format:@"%d is out of bounds of array", index];
        }

        if (obj == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"Attempt to insert nil object at index %d", index];
        }

        CFArraySetValueAtIndex((CFMutableArrayRef)self, index, obj);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)insertObject:(id)obj atIndex:(NSUInteger)index
{
    if (obj == nil)
    {
        CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Attempt to insert nil object at index %d"), index);
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:(NSString *)reason userInfo:nil];
        CFRelease(reason);
    }
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        if(index > self.count) {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("*** %s: index %d beyond bounds [0 .. %d]"),__PRETTY_FUNCTION__,index,self.count - 1);
            @throw [NSException exceptionWithName:NSRangeException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
        }
        CFArrayInsertValueAtIndex((CFMutableArrayRef)self, index, (const void *)obj);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    state->extra[0] = 1; // flag for NSFastEnumerator
    return _CFArrayFastEnumeration((CFArrayRef)self, state, buffer, len);
}

- (id)objectAtIndex:(NSUInteger)index
{
    const void *value = _CFArrayCheckAndGetValueAtIndex((CFArrayRef)self, index);
    if (value == (void *)-1) // this is flawed logic, but it is conformant ... you technically could store (void *)-1 as a value in a CFArray and then toll free bridge access it (even though it is silly to do so)
    {
        CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("index (%d) beyond array bounds (%d)"), index, [self count]);
        @throw [NSException exceptionWithName:NSRangeException reason:(NSString *)reason userInfo:nil];
        CFRelease(reason);
        return nil;
    }
    else
    {
        return value;
    }
}

- (void)removeLastObject
{
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        CFIndex count = CFArrayGetCount((CFArrayRef)self);
        if (count > 0)
        {
            CFArrayRemoveValueAtIndex((CFMutableArrayRef)self, count - 1);
        }
    }
}

- (void)removeAllObjects
{
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        CFArrayRemoveAllValues((CFMutableArrayRef)self);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)addObject:(id)object
{
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        CFArrayAppendValue((CFMutableArrayRef)self, (const void *)object);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (NSUInteger)count
{
    return CFArrayGetCount((CFArrayRef)self);
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return (id)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, (CFArrayRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFArrayCreateCopy(kCFAllocatorDefault, (CFArrayRef)self);
}

- (Class)classForCoder
{
    if (_CFArrayIsMutable((CFArrayRef)self))
    {
        return [NSMutableArray class];
    }
    else
    {
        return [NSArray class];
    }
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating((CFTypeRef)self);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain((CFTypeRef)self) != NULL;
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)retain
{
    return CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)obj
{
    if (obj == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)obj);
}

@end



@implementation __NSArrayReverseEnumerator {
    NSArray *_obj;
    NSUInteger _idx;
}

- (id)initWithObject:(NSArray *)object
{
    self = [super init];
    if (self)
    {
        _obj = [object retain];
        NSUInteger count = [object count];
        if (count == 0)
        {
            _idx = NSNotFound;
        }
        else
        {
            _idx = count - 1;
        }
    }
    return self;
}

- (void)dealloc
{
    [_obj release];
    [super dealloc];
}

- (id)nextObject
{
    if (_idx == NSNotFound)
    {
        return nil;
    }
    else
    {
        id obj = [_obj objectAtIndex:_idx];
        if (_idx > 0)
        {
            _idx--;
        }
        else
        {
            _idx = NSNotFound;
        }
        return obj;
    }
}

@end

@implementation __NSArrayI {
    NSUInteger _used;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return (id)[__NSPlaceholderArray immutablePlaceholder];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

+ (id)__new:(const id *)objects :(NSUInteger)count :(BOOL)tbd
{
    // is the extra bool actually used? it's not immutable
    NSUInteger sz = count * sizeof(id);
    __NSArrayI *array = ___CFAllocateObject2(self, sz);
    array->_used = count;
    CFTypeRef *objs = (CFTypeRef *)object_getIndexedIvars(array);
    for (NSUInteger idx = 0; idx < count; idx++)
    {
        if (objects[idx] != NULL) {
            objs[idx] = CFRetain(objects[idx]);
        } else {
            objs[idx] = NULL;
        }
    }
    return array;
}

- (void)dealloc
{
    CFTypeRef *objs = (CFTypeRef *)object_getIndexedIvars(self);
    for (NSUInteger idx = 0; idx < _used; idx++)
    {
        if (objs[idx] != NULL)
        {
            CFRelease(objs[idx]);
        }
    }
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    if (buffer == NULL && len != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot enumerate into NULL buffer of nonzero length"];
        return 0;
    }

    if (state->state != 0)
    {
        return 0;
    }

    static const unsigned long const_mu = 1;
    state->mutationsPtr = (unsigned long *)&const_mu;
    state->state = -1;
    state->itemsPtr = object_getIndexedIvars(self);

    return _used;
}

- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range
{
    id *objs = (id *)object_getIndexedIvars(self);
    memmove(objects, (char *)objs + sizeof(id) * range.location, sizeof(id) * range.length);
}

- (id)objectAtIndex:(NSUInteger)index
{
    if (_used > index)
    {
        id *objs = (id *)object_getIndexedIvars(self);
        return objs[index];
    }
    else
    {
        [NSException raise:NSRangeException format:@"%d is out of bounds of array", index];
        return nil;
    }
}

- (NSUInteger)count
{
    return _used;
}

@end
