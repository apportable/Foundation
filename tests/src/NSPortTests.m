//
//  NSPortTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSPort)

test(Alloc)
{
    return [[NSPort alloc] class] == [NSMachPort class];
}

static NSMutableData *data = nil;
static volatile BOOL gotEndEvent = NO;

#if !defined(TARGET_OS_MAC) || !TARGET_OS_MAC

test(PortMaker)
{
    dispatch_queue_t queue = dispatch_queue_create("testPortMaker", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        
        NSMachPort *port = (id)[NSPort new];
        [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
        NSInputStream *input = [[NSInputStream alloc] initWithFileAtPath:[[NSBundle mainBundle] pathForResource:@"bigfile" ofType:@"txt"]];
        
        [input setDelegate:(id<NSStreamDelegate>)self];
        
        [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [input open];
        
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        while (!gotEndEvent && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    });
    
    dispatch_release(queue);
    
    BOOL result = gotEndEvent && data.length == 45525;
    
    [data release];
    data = nil;
    
    return result;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            data = [NSMutableData new];
            break;
        case NSStreamEventHasBytesAvailable:
        {
            unsigned int bytesRead = 0;
            uint8_t buffer[7]; // We use a tiny buffer to exagerate the behavior
            bytesRead = [(NSInputStream *)aStream read:buffer maxLength:sizeof(buffer)];
            if(bytesRead > 0)
            {
                [data appendBytes:(const void *)buffer length:bytesRead];
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            [data release];
            data = nil;
            break;
        }
        case NSStreamEventEndEncountered: {
            gotEndEvent = YES;
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventNone:
        default:
            break;
    }
}

#endif

@end
