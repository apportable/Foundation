//
//  NSInputStreamTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#import <CoreFoundation/CoreFoundation.h>

@interface NSStream (CoreFoundation)
- (void)_unscheduleFromCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode;
- (void)_scheduleInCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode;
@end

@interface NSInputStream (CoreFoundation)
- (BOOL)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext *)context;
@end

@interface HTTPInputStream : NSInputStream <NSStreamDelegate>
@end

@implementation HTTPInputStream
{
    CFReadStreamRef _readStream;
    
    id<NSStreamDelegate> _delegate;
    
    CFStreamClientContext _client;
    CFReadStreamClientCallBack _readCallback;
    CFOptionFlags _flags;
}

static void HTTPInputStreamCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    HTTPInputStream *inputStream = (HTTPInputStream*)clientCallBackInfo;
    
    [inputStream stream:(NSInputStream*)stream handleEvent:(NSStreamEvent)type];
}

- (id)initWithURL:(NSURL *)url persistent:(BOOL)persistent
{
    if ((self = [super init]))
    {
        CFHTTPMessageRef request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)@"GET", (CFURLRef)url, kCFHTTPVersion1_1);
        
        _readStream = CFReadStreamCreateForStreamedHTTPRequest(kCFAllocatorDefault, request, NULL);
        
        if (persistent) {
            if (!CFReadStreamSetProperty(_readStream,  kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanTrue)) {
                [self release];
                [NSException raise:@"HTTPInputStream" format:@"Failed to enable kCFStreamPropertyHTTPAttemptPersistentConnection"];
                return nil;
            }
        }
        
        CFRelease(request);
        
        CFStreamClientContext clientContext = {0};
        clientContext.retain = (void*(*)(void*))CFRetain;
        clientContext.release = (void(*)(void*))CFRelease;
        clientContext.info = self;
        
        CFReadStreamSetClient(_readStream, ~kCFStreamEventNone, HTTPInputStreamCallBack, &clientContext);
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_readStream);
    
    [super dealloc];
}

- (void)open
{
    CFReadStreamOpen(_readStream);
}

- (void)close
{
    CFReadStreamClose(_readStream);
}

- (id < NSStreamDelegate >)delegate
{
    return _delegate;
}

- (void)setDelegate:(id < NSStreamDelegate >)delegate
{
    if (_client.info && _client.release)
        _client.release(_client.info);
    memset(&_client, 0, sizeof(_client));
    
    _delegate = delegate;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [self _scheduleInCFRunLoop:[aRunLoop getCFRunLoop] forMode:(CFStringRef)mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [self _unscheduleFromCFRunLoop:[aRunLoop getCFRunLoop] forMode:(CFStringRef)mode];
}

- (id)propertyForKey:(NSString *)key
{
    id<NSObject> property = CFReadStreamCopyProperty(_readStream, (CFStringRef)key);
    return [property autorelease];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return CFReadStreamSetProperty(_readStream, (CFStringRef)key, (CFTypeRef)property);
}

- (NSStreamStatus)streamStatus
{
    return (NSStreamStatus)CFReadStreamGetStatus(_readStream);
}

- (NSError *)streamError
{
    CFStreamError error = CFReadStreamGetError(_readStream);
    return [NSError errorWithDomain:[NSString stringWithFormat:@"%ld", error.domain] code:error.error userInfo:nil];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    return CFReadStreamRead(_readStream, buffer, len);
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

- (BOOL)hasBytesAvailable
{
    return CFReadStreamHasBytesAvailable(_readStream);
}

- (BOOL)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext *)context
{
    [self setDelegate:nil];
    
    _flags = flags;
    _readCallback = callback;
    if (context) {
        _client = *context;
        if (_client.info && _client.retain) {
            _client.info = _client.retain(_client.info);
        }
    }
    
    return YES;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    [_delegate stream:self handleEvent:streamEvent];
    
    if (_readCallback && (streamEvent & _flags)) {
        _readCallback((CFReadStreamRef)self, (CFStreamEventType)streamEvent, _client.info);
    }
}

- (void)_unscheduleFromCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode
{
    CFReadStreamUnscheduleFromRunLoop(_readStream, runLoop, mode);
}

- (void)_scheduleInCFRunLoop:(CFRunLoopRef)runLoop forMode:(CFStringRef)mode
{
    CFReadStreamScheduleWithRunLoop(_readStream, runLoop, mode);
}

@end

@interface MyStreamDelegate : NSObject <NSStreamDelegate>

- (id)initWithResults:(NSMutableArray*)results;
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;

@end

@implementation MyStreamDelegate
{
    NSMutableArray *_results;
}

- (id)initWithResults:(NSMutableArray*)results
{
    if ((self = [super init]))
    {
        _results = [results retain];
    }
    return self;
}

- (void)dealloc
{
    [_results release];
    
    [super dealloc];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event
{
    if (event == NSStreamEventHasBytesAvailable)
    {
        char buffer[0x100];
        
        NSInputStream *inputStream = (NSInputStream*)stream;
        int length = [inputStream read:(uint8_t*)buffer maxLength:sizeof(buffer)];
        
        [_results addObject:[NSString stringWithCString:buffer length:length]];
    }
    else
    {
        [_results addObject:@(event)];
    }
}

@end

@testcase(NSInputStream)

#if !defined(__IPHONE_8_0)
test(CFStreamDelegateClass)
{
    Class CFStreamDelegate = NSClassFromString(@"_CFStreamDelegate");
    
    return CFStreamDelegate == Nil;
}
#endif

static void ReadCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    NSMutableArray *results = (NSMutableArray*)clientCallBackInfo;
    
    if (type == kCFStreamEventHasBytesAvailable)
    {
        char buffer[0x100];
        
        NSInputStream *inputStream = (NSInputStream*)stream;
        int length = [inputStream read:(uint8_t*)buffer maxLength:sizeof(buffer)];
        
        [results addObject:[NSString stringWithCString:buffer length:length]];
    }
    else
    {
        [results addObject:@(type)];
    }
}

test(SimpleNSInputStream)
{
    NSMutableArray *results = [NSMutableArray array];
    
    NSString *message = @"Hello, world!";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    TrackerProxy *proxy = [[TrackerProxy alloc] initWithObject:[NSInputStream inputStreamWithData:data]];
    
    NSInputStream *inputStream = (NSInputStream*)proxy;
    
    MyStreamDelegate *delegate = [[MyStreamDelegate alloc] initWithResults:results];
    
    [inputStream setDelegate:delegate];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10];
    while ([timeout timeIntervalSinceNow] > 0 && results.count < 2) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
    }
    
    [inputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    testassert([results isEqualToArray:@[@(1), message]]);
    
    //[proxy dumpVerification];
    testassert([proxy verifyCommands:@selector(setDelegate:), @selector(scheduleInRunLoop:forMode:), @selector(open), @selector(close), @selector(removeFromRunLoop:forMode:), nil]);
    
    [delegate release];
    [proxy release];
    
    return YES;
}

#if !defined(__IPHONE_8_0)

test(SimpleCFReadStream)
{
    NSMutableArray *results = [NSMutableArray array];
    
    NSString *message = @"Hello, world!";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    TrackerProxy *proxy = [[TrackerProxy alloc] initWithObject:[NSInputStream inputStreamWithData:data]];
    
    CFReadStreamRef readStream = (CFReadStreamRef)proxy;
    
    CFStreamClientContext clientContext = {0};
    clientContext.info = results;
    
    CFReadStreamSetClient(readStream, ~kCFStreamEventNone, ReadCallBack, &clientContext);

    CFReadStreamScheduleWithRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);

    CFReadStreamOpen(readStream);

    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10];
    while ([timeout timeIntervalSinceNow] > 0 && results.count < 2) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
    }
    
    CFReadStreamClose(readStream);
    
    CFReadStreamUnscheduleFromRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
    
    testassert([results isEqualToArray:@[@(1), message]]);
    
    //[proxy dumpVerification];
    testassert([proxy verifyCommands:@selector(_setCFClientFlags:callback:context:), @selector(_scheduleInCFRunLoop:forMode:), @selector(open), @selector(close), @selector(_unscheduleFromCFRunLoop:forMode:), nil]);
    
    [proxy release];
    
    return YES;
}

#endif

test(HTTPInputStream)
{
    NSMutableArray *results = [NSMutableArray array];
    
    NSURL *url = [NSURL URLWithString:@"http://www.apportable.com"];
    
    HTTPInputStream *inputStream = [[HTTPInputStream alloc] initWithURL:url persistent:NO];
    
    MyStreamDelegate *delegate = [[MyStreamDelegate alloc] initWithResults:results];
    
    [inputStream setDelegate:delegate];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10];
    while ([timeout timeIntervalSinceNow] > 0 && results.count < 2) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
    }
    
    [inputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    testassert(results.count == 2);
    testassert([results[0] isEqual:@(1)]);
    testassert([[results[1] substringToIndex:6] isEqualToString:@"<head>"]);
    
    [delegate release];
    [inputStream release];
    
    return YES;
}

test(CFHTTPInputStream)
{
    NSMutableArray *results = [NSMutableArray array];
    
    NSURL *url = [NSURL URLWithString:@"http://www.apportable.com"];
    
    HTTPInputStream *inputStream = [[HTTPInputStream alloc] initWithURL:url persistent:NO];
    
    CFReadStreamRef readStream = (CFReadStreamRef)inputStream;
    
    CFStreamClientContext clientContext = {0};
    clientContext.info = results;
    
    CFReadStreamSetClient(readStream, ~kCFStreamEventNone, ReadCallBack, &clientContext);
    
    CFReadStreamScheduleWithRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
    
    CFReadStreamOpen(readStream);
    
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10];
    while ([timeout timeIntervalSinceNow] > 0 && results.count < 2) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
    }
    
    CFReadStreamClose(readStream);
    
    CFReadStreamUnscheduleFromRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
    
    testassert(results.count == 2);
    testassert([results[0] isEqual:@(1)]);
    testassert([[results[1] substringToIndex:6] isEqualToString:@"<head>"]);
    
    [inputStream release];
    
    return YES;
}

static void PersistentReadCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    NSMutableArray *results = (NSMutableArray*)clientCallBackInfo;
    
    if (type == kCFStreamEventHasBytesAvailable)
    {
        char buffer[0x100];
        NSInputStream *inputStream = (NSInputStream*)stream;
        [inputStream read:(uint8_t*)buffer maxLength:sizeof(buffer)];
        
        if (results.count > 0 && [results.lastObject intValue] == type)
            return;
    }
    
    [results addObject:@(type)];
}

test(CFHTTPInputStreamPersistentConnection)
{
    NSURL *url = [NSURL URLWithString:@"http://www.apportable.com"];
    
    const int count = 4;
    HTTPInputStream *inputStreamArr[count];
    
    for (int i=0; i<count; ++i)
    {
        NSMutableArray *results = [NSMutableArray array];
        HTTPInputStream *inputStream = [[HTTPInputStream alloc] initWithURL:url persistent:YES];
        inputStreamArr[i] = inputStream;
        
        CFReadStreamRef readStream = (CFReadStreamRef)inputStream;
        
        CFStreamClientContext clientContext = {0};
        clientContext.info = results;
        
        CFReadStreamSetClient(readStream, ~kCFStreamEventNone, PersistentReadCallBack, &clientContext);
        
        CFReadStreamScheduleWithRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
        
        CFReadStreamOpen(readStream);
        
        NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:10];
        while ([timeout timeIntervalSinceNow] > 0) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeout];
            if (results.count > 0) {
                if ([results.lastObject isEqual:@(kCFStreamEventErrorOccurred)])
                    break;
                if ([results.lastObject isEqual:@(kCFStreamEventEndEncountered)])
                    break;
            }
        }
        
        CFReadStreamUnscheduleFromRunLoop(readStream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
        
        testassert(results.count == 3);
        testassert([results[0] isEqual:@(kCFStreamEventOpenCompleted)]);
        testassert([results[1] isEqual:@(kCFStreamEventHasBytesAvailable)]);
        testassert([results[2] isEqual:@(kCFStreamEventEndEncountered)]);
    }
    
    for (int i=0; i<count; ++i)
    {
        CFReadStreamClose((CFReadStreamRef)inputStreamArr[i]);
        
        [inputStreamArr[i] release];
    }
    
    return YES;
}

@end
