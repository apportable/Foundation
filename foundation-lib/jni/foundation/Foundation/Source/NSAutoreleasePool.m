#import "Foundation/NSAutoreleasePool.h"

extern void *objc_autoreleasePoolPush(void);

extern void objc_autoreleasePoolPop(void *context);

extern void _objc_autoreleaseEmptyPool(void *context);

@implementation NSAutoreleasePool {
    void *context;
}

+ (id)allocWithZone:(NSZone *)zone
{
    NSAutoreleasePool *pool = [super allocWithZone:zone];
    pool->context = objc_autoreleasePoolPush();
    return pool;
}

+ (void)addObject:(id)anObject
{
    [anObject autorelease];
}

- (void)addObject:(id)anObject
{
    [anObject autorelease];
}

- (id)retain
{
    return self; // retaining an autoreleasepool makes little sense
}

- (id)autorelease
{
    return self; // makes even less sense than retaining
}

- (void)drain
{
    objc_autoreleasePoolPop(context);
    [self dealloc];
}

- (oneway void)release
{
    [self drain];
}

- (void)emptyPool
{
    objc_autoreleasePoolPop(context);
}

@end

