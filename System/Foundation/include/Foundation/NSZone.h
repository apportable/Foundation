#import <Foundation/NSObjCRuntime.h>
#import <CoreFoundation/CFBase.h>

@class NSString;

typedef struct _NSZone NSZone;

FOUNDATION_EXPORT NSZone *NSDefaultMallocZone(void);
FOUNDATION_EXPORT NSZone *NSCreateZone(NSUInteger startSize, NSUInteger granularity, BOOL canFree);
FOUNDATION_EXPORT void NSRecycleZone(NSZone *zone);
FOUNDATION_EXPORT void NSSetZoneName(NSZone *zone, NSString *name);
FOUNDATION_EXPORT NSString *NSZoneName(NSZone *zone);
FOUNDATION_EXPORT NSZone *NSZoneFromPointer(void *ptr);
FOUNDATION_EXPORT void *NSZoneMalloc(NSZone *zone, NSUInteger size);
FOUNDATION_EXPORT void *NSZoneCalloc(NSZone *zone, NSUInteger numElems, NSUInteger byteSize);
FOUNDATION_EXPORT void *NSZoneRealloc(NSZone *zone, void *ptr, NSUInteger size);
FOUNDATION_EXPORT void NSZoneFree(NSZone *zone, void *ptr);

#ifndef CF_CONSUMED
#if __has_feature(attribute_cf_consumed)
#define CF_CONSUMED __attribute__((cf_consumed))
#else
#define CF_CONSUMED
#endif
#endif

NS_INLINE NS_RETURNS_RETAINED id NSMakeCollectable(CFTypeRef CF_CONSUMED cf) NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
NS_INLINE NS_RETURNS_RETAINED id NSMakeCollectable(CFTypeRef CF_CONSUMED cf) {
#if __has_feature(objc_arc)
    return nil;
#else
    return (cf ? (id)CFMakeCollectable(cf) : nil);
#endif
}

FOUNDATION_EXPORT NSUInteger NSPageSize(void);
FOUNDATION_EXPORT NSUInteger NSLogPageSize(void);
FOUNDATION_EXPORT NSUInteger NSRoundUpToMultipleOfPageSize(NSUInteger bytes);
FOUNDATION_EXPORT NSUInteger NSRoundDownToMultipleOfPageSize(NSUInteger bytes);
FOUNDATION_EXPORT void *NSAllocateMemoryPages(NSUInteger bytes);
FOUNDATION_EXPORT void NSDeallocateMemoryPages(void *ptr, NSUInteger bytes);
FOUNDATION_EXPORT void NSCopyMemoryPages(const void *source, void *dest, NSUInteger bytes);
FOUNDATION_EXPORT NSUInteger NSRealMemoryAvailable(void);
