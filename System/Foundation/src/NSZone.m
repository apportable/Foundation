//
//  NSZone.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSZone.h>
#import <Foundation/NSString.h>
#import <malloc/malloc.h>
#import <limits.h>
#import <mach/mach.h>
#import <strings.h>

NSZone *NSDefaultMallocZone(void)
{
    return (NSZone *)malloc_default_zone();
}

NSZone *NSCreateZone(NSUInteger startSize, NSUInteger granularity, BOOL canFree)
{
    return (NSZone *)malloc_create_zone(startSize, 0);
}

void NSRecycleZone(NSZone *zone)
{
    malloc_destroy_zone((malloc_zone_t *)zone);
}

void NSSetZoneName(NSZone *zone, NSString *name)
{
    malloc_set_zone_name((malloc_zone_t *)zone, [name UTF8String]);
}

NSString *NSZoneName(NSZone *zone)
{
    return [NSString stringWithUTF8String:malloc_get_zone_name((malloc_zone_t *)zone)];
}

NSZone *NSZoneFromPointer(void *ptr)
{
    return (NSZone *)malloc_zone_from_ptr(ptr);
}

void *NSZoneMalloc(NSZone *zone, NSUInteger size)
{
    return malloc_zone_malloc((malloc_zone_t *)zone, size);
}

void *NSZoneCalloc(NSZone *zone, NSUInteger numElems, NSUInteger byteSize)
{
    return malloc_zone_calloc((malloc_zone_t *)zone, numElems, byteSize);
}

void *NSZoneRealloc(NSZone *zone, void *ptr, NSUInteger size)
{
    return malloc_zone_realloc((malloc_zone_t *)zone, ptr, size);
}

void NSZoneFree(NSZone *zone, void *ptr)
{
    malloc_zone_free((malloc_zone_t *)zone, ptr);
}

NSUInteger NSPageSize(void)
{
    return PAGE_SIZE;
}

NSUInteger NSLogPageSize(void)
{
    return flsl(NSPageSize()) - 1;
}

NSUInteger NSRoundUpToMultipleOfPageSize(NSUInteger bytes)
{
    NSUInteger a = NSPageSize();
    if (bytes % a == 0)
    {
        return bytes;
    }
    else
    {
        return (bytes / a + 1) * a;
    }
}

NSUInteger NSRoundDownToMultipleOfPageSize(NSUInteger bytes)
{
    NSUInteger size = NSPageSize();
     return (bytes / size) * size;
}

void *NSAllocateMemoryPages(NSUInteger bytes)
{
    vm_size_t sz = NSRoundUpToMultipleOfPageSize(bytes);
    void *buffer = NULL;
    kern_return_t err = vm_allocate(mach_task_self(), (vm_address_t *)&buffer, sz, 1);
    if (err != KERN_SUCCESS)
    {
        return NULL;
    }

    return buffer;
}

void NSDeallocateMemoryPages(void *ptr, NSUInteger bytes)
{
    vm_deallocate(mach_task_self (), (vm_address_t)ptr, NSRoundUpToMultipleOfPageSize(bytes));
}

void NSCopyMemoryPages(const void *src, void *dest, NSUInteger bytes)
{
    vm_copy(mach_task_self(), (vm_address_t)src, bytes, (vm_address_t)dest);
}

NSUInteger NSRealMemoryAvailable(void)
{
    struct task_basic_info info;
    mach_msg_type_number_t count;
    if (task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS)
    {
        return info.resident_size;
    }
    else
    {
        return 0;
    }
}
