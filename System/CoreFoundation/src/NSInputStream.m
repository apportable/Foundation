//
//  NSInputStream.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSRunLoop.h>
#import <Foundation/NSError.h>
#import "NSStreamInternal.h"
#import "NSObjectInternal.h"

@implementation NSInputStream

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSInputStream class])
    {
        return [__NSCFInputStream allocWithZone:zone];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSRequestConcreteImplementation();
    return 0;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    NSRequestConcreteImplementation();
    return NO;
}

- (BOOL)hasBytesAvailable
{
    NSRequestConcreteImplementation();
    return 0;
}

@end

@implementation NSInputStream (NSInputStreamExtensions)

+ (id)inputStreamWithData:(NSData *)data
{
    return [[[self alloc] initWithData:data] autorelease];
}

+ (id)inputStreamWithFileAtPath:(NSString *)path
{
    return [[[self alloc] initWithFileAtPath:path] autorelease];
}

+ (id)inputStreamWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (id)initWithData:(NSData *)data
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithFileAtPath:(NSString *)path
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithURL:(NSURL *)url
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

@end

@implementation __NSCFInputStream

+ (id)allocWithZone:(NSZone *)zone
{
    static __NSCFOutputStream *placeholder = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        placeholder = (__NSCFOutputStream *)[super allocWithZone:zone];
    });
    return (id)placeholder;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)_unscheduleFromCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode
{
    CFReadStreamUnscheduleFromRunLoop((CFReadStreamRef)self, runLoop, mode);
}

- (void)_scheduleInCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode
{
    CFReadStreamScheduleWithRunLoop((CFReadStreamRef)self, runLoop, mode);
}

- (BOOL)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext *)context
{
    return CFReadStreamSetClient((CFReadStreamRef)self, flags, callback, context);
}

- (BOOL)hasBytesAvailable
{
    return CFReadStreamHasBytesAvailable((CFReadStreamRef)self);
}

- (BOOL)getBuffer:(uint8_t **)bytes length:(NSUInteger *)len
{
    const UInt8 *buffer = CFReadStreamGetBuffer((CFReadStreamRef)self, 0, (CFIndex *)len);
    if (buffer != NULL)
    {
        *bytes = (uint8_t *)buffer;
        return YES;
    }
    else
    {
        *bytes = NULL;
        return NO;
    }
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    return CFReadStreamRead((CFReadStreamRef)self, buffer, len);
}

- (NSError *)streamError
{
    CFStreamError err = CFReadStreamGetError((CFReadStreamRef)self);
    return [(NSError *)_CFErrorFromStreamError(kCFAllocatorDefault, &err) autorelease];
}

- (NSStreamStatus)streamStatus
{
    return (NSStreamStatus)CFReadStreamGetStatus((CFReadStreamRef)self);
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    if (aRunLoop == nil)
    {
        return;
    }
    
    CFReadStreamScheduleWithRunLoop((CFReadStreamRef)self, [aRunLoop getCFRunLoop], (CFStringRef)mode);
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    if (aRunLoop == nil)
    {
        return;
    }

    CFReadStreamUnscheduleFromRunLoop((CFReadStreamRef)self, [aRunLoop getCFRunLoop], (CFStringRef)mode);
}

- (id)propertyForKey:(NSString *)key
{
    return [(id)CFReadStreamCopyProperty((CFReadStreamRef)self, (CFStringRef)key) autorelease];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return CFReadStreamSetProperty((CFReadStreamRef)self, (CFStringRef)key, (CFTypeRef)property);
}

- (id <NSStreamDelegate>)delegate
{
    return _CFReadStreamGetClient((CFReadStreamRef)self);
}

static void __NSCFInputStreamCallback(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
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
    [self _setCFClientFlags:flags callback:&__NSCFInputStreamCallback context:&ctx];
}

- (void)close
{
    CFReadStreamClose((CFReadStreamRef)self);
}

- (void)open
{
    CFReadStreamOpen((CFReadStreamRef)self);
}

- (id)initWithURL:(NSURL *)url
{
    return (id)CFReadStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)url);
}

- (id)initWithFileAtPath:(NSString *)path
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    id stream = [self initWithURL:url];
    [url release];
    return stream;
}

- (id)initWithData:(NSData *)data
{
    return (id)CFReadStreamCreateWithData(kCFAllocatorDefault, (CFDataRef)data);
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
    return CFReadStreamGetTypeID();
}

@end
