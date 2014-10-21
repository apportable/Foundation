//
//  NSOutputStream.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSError.h>
#import <Foundation/NSRunLoop.h>
#import "NSStreamInternal.h"
#import "NSObjectInternal.h"

@implementation NSOutputStream

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSOutputStream class])
    {
        return [__NSCFOutputStream allocWithZone:zone];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSRequestConcreteImplementation();
    return 0;
}

- (BOOL)hasSpaceAvailable
{
    NSRequestConcreteImplementation();
    return NO;
}

@end

@implementation NSOutputStream (NSOutputStreamExtensions)

+ (id)outputStreamToMemory
{
    return [[[self alloc] initToMemory] autorelease];
}

+ (id)outputStreamToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity
{
    return [[[self alloc] initToBuffer:buffer capacity:capacity] autorelease];
}

+ (id)outputStreamToFileAtPath:(NSString *)path append:(BOOL)shouldAppend
{
    return [[[self alloc] initToFileAtPath:path append:shouldAppend] autorelease];
}

+ (id)outputStreamWithURL:(NSURL *)url append:(BOOL)shouldAppend
{
    return [[[self alloc] initWithURL:url append:shouldAppend] autorelease];
}

- (id)initToMemory
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initToFileAtPath:(NSString *)path append:(BOOL)shouldAppend
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithURL:(NSURL *)url append:(BOOL)shouldAppend
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

@end

@implementation __NSCFOutputStream


+ (id)allocWithZone:(NSZone *)zone
{
    static __NSCFOutputStream *placeholder = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        placeholder = [super allocWithZone:zone];
    });
    return placeholder;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)_unscheduleFromCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode
{
    CFWriteStreamUnscheduleFromRunLoop((CFWriteStreamRef)self, runLoop, mode);
}

- (void)_scheduleInCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode
{
    CFWriteStreamUnscheduleFromRunLoop((CFWriteStreamRef)self, runLoop, mode);
}

- (BOOL)_setCFClientFlags:(CFOptionFlags)flags callback:(CFWriteStreamClientCallBack)callback context:(CFStreamClientContext *)context
{
    return CFWriteStreamSetClient((CFWriteStreamRef)self, flags, callback, context);
}

- (BOOL)hasSpaceAvailable
{
    return CFWriteStreamCanAcceptBytes((CFWriteStreamRef)self);
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
    return CFWriteStreamWrite((CFWriteStreamRef)self, buffer, len);
}

- (NSError *)streamError
{
    CFStreamError err = CFWriteStreamGetError((CFWriteStreamRef)self);
    return [(NSError *)_CFErrorFromStreamError(kCFAllocatorDefault, &err) autorelease];
}

- (NSStreamStatus)streamStatus
{
    return (NSStreamStatus)CFWriteStreamGetStatus((CFWriteStreamRef)self);
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    if (aRunLoop == nil)
    {
        return;
    }

    CFWriteStreamScheduleWithRunLoop((CFWriteStreamRef)self, [aRunLoop getCFRunLoop], (CFStringRef)mode);
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    if (aRunLoop == nil)
    {
        return;
    }
    
    CFWriteStreamUnscheduleFromRunLoop((CFWriteStreamRef)self, [aRunLoop getCFRunLoop], (CFStringRef)mode);
}

- (id)propertyForKey:(NSString *)key
{
    return [(id)CFWriteStreamCopyProperty((CFWriteStreamRef)self, (CFStringRef)key) autorelease];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return CFWriteStreamSetProperty((CFWriteStreamRef)self, (CFStringRef)key, (CFTypeRef)property);
}

- (id <NSStreamDelegate>)delegate
{
    return _CFWriteStreamGetClient((CFWriteStreamRef)self);
}

static void __NSCFOutputStreamCallback(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    id<NSStreamDelegate> delegate = [(NSStream *)stream delegate];
    [delegate stream:(NSStream *)stream handleEvent:(NSStreamEvent)type];
}

- (void)setDelegate:(id <NSStreamDelegate>)delegate
{
    CFStreamClientContext ctx = {
        0,
        delegate,
        NULL,
        NULL,
        (CFStringRef (*)(void *))&_NSCFCopyDescription
    };
    CFOptionFlags flags = kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    [self _setCFClientFlags:flags callback:&__NSCFOutputStreamCallback context:&ctx];
}

- (void)close
{
    CFWriteStreamClose((CFWriteStreamRef)self);
}

- (void)open
{
    CFWriteStreamOpen((CFWriteStreamRef)self);
}

- (id)initWithURL:(NSURL *)url append:(BOOL)shouldAppend
{
    CFWriteStreamRef stream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)url);
    if (stream != NULL && shouldAppend)
    {
        CFWriteStreamSetProperty(stream, kCFStreamPropertyAppendToFile, kCFBooleanTrue);
    }
    return (id)stream;
}

- (id)initToFileAtPath:(NSString *)path append:(BOOL)shouldAppend
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    id stream = [self initWithURL:url append:shouldAppend];
    [url release];
    return stream;
}

- (id)initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity
{
    return (id)CFWriteStreamCreateWithBuffer(kCFAllocatorDefault, buffer, capacity);
}

- (id)initToMemory
{
    return (id)CFWriteStreamCreateWithAllocatedBuffers(kCFAllocatorDefault, kCFAllocatorDefault);
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
    return (id)CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

- (CFTypeID)_cfTypeID
{
    return CFWriteStreamGetTypeID();
}

@end
