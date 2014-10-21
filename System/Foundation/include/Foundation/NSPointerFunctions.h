#import <Foundation/NSObject.h>

#if !defined(__FOUNDATION_NSPOINTERFUNCTIONS__)
#define __FOUNDATION_NSPOINTERFUNCTIONS__ 1

enum {
    NSPointerFunctionsStrongMemory             = (0UL << 0),
    NSPointerFunctionsOpaqueMemory             = (2UL << 0),
    NSPointerFunctionsMallocMemory             = (3UL << 0),
    NSPointerFunctionsMachVirtualMemory        = (4UL << 0),
    NSPointerFunctionsWeakMemory               = (5UL << 0),
    NSPointerFunctionsObjectPersonality        = (0UL << 8),
    NSPointerFunctionsOpaquePersonality        = (1UL << 8),
    NSPointerFunctionsObjectPointerPersonality = (2UL << 8),
    NSPointerFunctionsCStringPersonality       = (3UL << 8),
    NSPointerFunctionsStructPersonality        = (4UL << 8),
    NSPointerFunctionsIntegerPersonality       = (5UL << 8),
    NSPointerFunctionsCopyIn                   = (1UL << 16)
};

typedef NSUInteger NSPointerFunctionsOptions;

@interface NSPointerFunctions : NSObject <NSCopying>

@property NSUInteger (*hashFunction)(const void *item, NSUInteger (*size)(const void *item));
@property BOOL (*isEqualFunction)(const void *item1, const void*item2, NSUInteger (*size)(const void *item));
@property NSUInteger (*sizeFunction)(const void *item);
@property NSString *(*descriptionFunction)(const void *item);
@property void (*relinquishFunction)(const void *item, NSUInteger (*size)(const void *item));
@property void *(*acquireFunction)(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy);
@property BOOL usesStrongWriteBarrier;
@property BOOL usesWeakReadAndWriteBarriers;
+ (id)pointerFunctionsWithOptions:(NSPointerFunctionsOptions)options;
- (id)initWithOptions:(NSPointerFunctionsOptions)options;

@end

#endif
