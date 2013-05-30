#import "Foundation/NSObject.h"

#define ABNOXIOUS_API_WARNING \
    DEBUG_LOG("WARNING! Functionality that depends on this method should consider using using alternate means.")

id NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone)
{
    return class_createInstance(aClass, extraBytes);
}

void NSDeallocateObject(id anObject)
{
    [anObject dealloc];
}

BOOL NSShouldRetainWithZone(NSObject *anObject, NSZone *requestedZone)
{
    return YES;
}

BOOL NSDecrementExtraRefCountWasZero(id anObject)
{
    ABNOXIOUS_API_WARNING;
    NSUInteger refCnt = NSExtraRefCount(anObject);
    [anObject release];
    return (refCnt <= 1);
}

NSUInteger NSExtraRefCount(id anObject)
{
    ABNOXIOUS_API_WARNING;
    return [anObject retainCount];
}

void NSIncrementExtraRefCount(id anObject)
{
    [anObject retain];
}