//
//  NSNetServices.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSNetServices.h>
#import <Foundation/NSException.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <CFNetwork/CFNetServices.h>

NSString * const NSNetServicesErrorCode = @"NSNetServicesErrorCode";
NSString * const NSNetServicesErrorDomain = @"NSNetServicesErrorDomain";

#warning TODO: Move this to CFSocketStream.h
extern void CFStreamCreatePairWithSocketToNetService(CFAllocatorRef alloc, CFNetServiceRef service, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);

static const NSTimeInterval NSNetServiceDefaultTimeout = 5.0; // TODO: verify this

CF_PRIVATE
@interface NSNetServicesInternal : NSObject {
    NSMutableArray *_monitors;
    NSObject *_listener;
}

@property (retain) NSMutableArray *monitors;

- (void)setListener:(NSObject *)listener;
- (NSObject *)listener;
- (void)dealloc;

@end

@implementation NSNetServicesInternal

@synthesize monitors = _monitors;

- (void)setListener:(NSObject *)listener
{
    if (_listener != listener)
    {
        _listener = [listener retain];
    }
}

- (NSObject *)listener
{
    return _listener;
}

- (void)dealloc
{
    [_listener release];
    [_monitors release];
    [super dealloc];
}

@end

@interface NSNetService ()

- (CFNetServiceRef)_internalNetService;
- (void)_scheduleInDefaultRunLoopForMode:(CFStringRef)mode;
- (void)publishWithServer:(NSNetServiceOptions)options;
- (void)_internal_publishWithOptions:(NSNetServiceOptions)options;
- (NSArray *)_monitors;
- (void)_dispatchCallBackWithError:(CFStreamError *)error;

@end

@implementation NSNetService {
    CFNetServiceRef _netService;
    id _delegate;
    NSNetServicesInternal *_reserved;
}

+ (NSDictionary *)dictionaryFromTXTRecordData:(NSData *)txtData
{
    if (txtData == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"TXT record data cannot be nil"];
        return nil;
    }
    
    NSDictionary *dict = (NSDictionary *)CFNetServiceCreateDictionaryWithTXTData(kCFAllocatorDefault, (CFDataRef)txtData);
    return [dict autorelease];
}

+ (NSData *)dataFromTXTRecordDictionary:(NSDictionary *)txtDictionary
{
    if (txtDictionary == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"txt record dictionary cannot be nil"];
        return nil;
    }
    
    NSData *data = (NSData *)CFNetServiceCreateTXTDataWithDictionary(kCFAllocatorDefault, (CFDictionaryRef)txtDictionary);
    return [data autorelease];
}

static void _netServiceMonitorCallBack(CFNetServiceMonitorRef theMonitor, CFNetServiceRef theService, CFNetServiceMonitorType typeInfo, CFDataRef rdata, CFStreamError *error, void *info) {
    NSNetService *service = (NSNetService *)info;
    id delegate = [service delegate];
    if ([delegate respondsToSelector:@selector(netService:didUpdateTXTRecordData:)])
    {
        [delegate netService:service didUpdateTXTRecordData:(NSData *)rdata];
    }
}

- (id)initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name port:(int)port
{
    self = [super init];
    
    if (self)
    {
        _netService = CFNetServiceCreate(kCFAllocatorDefault, (CFStringRef)domain, (CFStringRef)type, (CFStringRef)name, port);
        _reserved = [[NSNetServicesInternal alloc] init];
        NSMutableArray *monitors = [[NSMutableArray alloc] init];
        _reserved.monitors = monitors;
        [monitors release];
        CFNetServiceClientContext ctx = {
            .version = 0,
            .info = self,
        };
        CFNetServiceMonitorRef monitor = CFNetServiceMonitorCreate(kCFAllocatorDefault, _netService, _netServiceMonitorCallBack, &ctx);
        if (monitor != NULL)
        {
            [monitors addObject:(id)monitor];
            CFRelease(monitor);
        }
        [self _scheduleInDefaultRunLoopForMode:kCFRunLoopCommonModes];
    }
    
    return self;
}

- (id)initWithDomain:(NSString *)domain type:(NSString *)type name:(NSString *)name
{
    return [self initWithDomain:domain type:type name:name port:-1];
}

- (void)dealloc
{
    if (_netService)
    {
        CFNetServiceClientContext ctx = {
            .version = 0,
            .info = NULL
        };
        CFNetServiceSetClient([self _internalNetService], 0, &ctx);
        CFRelease(_netService);
    }
    [_reserved release];
    [super dealloc];
}

- (id <NSNetServiceDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id <NSNetServiceDelegate>)delegate
{
    _delegate = delegate;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    CFRunLoopRef rl = [aRunLoop getCFRunLoop];
    CFNetServiceScheduleWithRunLoop([self _internalNetService], rl, (CFStringRef)mode);
    for (id monitor in _reserved.monitors)
    {
        CFNetServiceMonitorScheduleWithRunLoop((CFNetServiceMonitorRef)monitor, rl, (CFStringRef)mode);
    }
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    CFRunLoopRef rl = [aRunLoop getCFRunLoop];
    CFNetServiceUnscheduleFromRunLoop([self _internalNetService], rl, (CFStringRef)mode);
    for (id monitor in _reserved.monitors)
    {
        CFNetServiceMonitorUnscheduleFromRunLoop((CFNetServiceMonitorRef)monitor, rl, (CFStringRef)mode);
    }
}

- (NSString *)domain
{
    if (_netService)
    {
        return (NSString *)CFNetServiceGetDomain([self _internalNetService]);
    }
    else
    {
        return nil;
    }
}

- (NSString *)type
{
    if (_netService)
    {
        return (NSString *)CFNetServiceGetType([self _internalNetService]);
    }
    else
    {
        return nil;
    }
}

- (NSString *)name
{
    if (_netService)
    {
        return (NSString *)CFNetServiceGetName([self _internalNetService]);
    }
    else
    {
        return nil;
    }
}

- (NSArray *)addresses
{

    if (_netService)
    {
        NSArray *array = (NSArray *)CFNetServiceGetAddressing([self _internalNetService]);
        return [[array copy] autorelease];
    }
    else
    {
        return [NSArray array];
    }
}

- (NSInteger)port
{
    if (_netService)
    {
        return CFNetServiceGetPortNumber(_netService);
    }
    else
    {
        return -1;
    }
}

- (void)publish
{
    [self publishWithOptions:[[self name] isEqual:@""] ? NSNetServiceNoAutoRename : 0];
}

- (void)publishWithOptions:(NSNetServiceOptions)options
{
    if ((options & 0x2) != 0)
    {
        [self publishWithServer:options];
    }
    else
    {
        [self _internal_publishWithOptions:options];
    }
}

- (void)resolve
{
    [self resolveWithTimeout:NSNetServiceDefaultTimeout];
}

- (void)stop
{
    if (_netService)
    {
        CFNetServiceSetClient([self _internalNetService], NULL, NULL);
        CFNetServiceCancel([self _internalNetService]);
    }
    if ([_delegate respondsToSelector:@selector(netServiceDidStop:)])
    {
        [_delegate netServiceDidStop:self];
    }
}

- (NSString *)hostName
{
    if (_netService)
    {
        return (NSString *)CFNetServiceGetTargetHost([self _internalNetService]);
    }
    else
    {
        return nil;
    }
}

static void _netServiceDispatchCallbackForResolving(CFNetServiceRef theService, CFStreamError *error, void *info)
{
    [(NSNetService *)info _dispatchCallBackWithError:error];
}

- (void)resolveWithTimeout:(NSTimeInterval)timeout
{
    if (_netService)
    {
        CFNetServiceClientContext ctx = {
            .version = 0,
            .info = self
        };
        CFNetServiceSetClient([self _internalNetService], _netServiceDispatchCallbackForResolving, &ctx);
        CFStreamError err;
        if (CFNetServiceResolveWithTimeout([self _internalNetService], timeout, &err))
        {
            if ([_delegate respondsToSelector:@selector(netServiceWillResolve:)])
            {
                [_delegate netServiceWillResolve:self];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(netService:didNotResolve:)])
            {
                [_delegate netService:self didNotResolve:@{
                   NSNetServicesErrorCode: @(err.error),
                   NSNetServicesErrorDomain: @(err.domain),
                }];
            }
        }
    }
}

- (BOOL)getInputStream:(out __strong NSInputStream **)inputStream outputStream:(out __strong NSOutputStream **)outputStream
{
    id delegate = [[self delegate] retain];
    CFStreamCreatePairWithSocketToNetService(kCFAllocatorDefault, [self _internalNetService], (CFReadStreamRef *)inputStream, (CFWriteStreamRef *)outputStream);
    [self setDelegate:delegate];
    [delegate release];
    if (inputStream != NULL && outputStream != NULL)
    {
        return (*inputStream != NULL) && (*outputStream != NULL);
    }
    else if (inputStream != NULL)
    {
        return *inputStream != NULL;
    }
    else if (outputStream != NULL)
    {
        return *outputStream != NULL;
    }
    return YES;
}

- (BOOL)setTXTRecordData:(NSData *)recordData
{
    return CFNetServiceSetTXTData([self _internalNetService], (CFDataRef)recordData);
}

- (NSData *)TXTRecordData
{
    return [[[NSData alloc] initWithData:(NSData *)CFNetServiceGetTXTData([self _internalNetService])] autorelease];
}

- (void)startMonitoring
{
    for (id monitor in [self _monitors])
    {
        CFNetServiceMonitorStart((CFNetServiceMonitorRef)monitor, kCFNetServiceMonitorTXT, NULL);
    }
}

- (void)stopMonitoring
{
    for (id monitor in [self _monitors])
    {
        CFNetServiceMonitorStop((CFNetServiceMonitorRef)monitor, NULL);
    }
}

#pragma mark - Internal/Private methods

- (CFNetServiceRef)_internalNetService
{
    return _netService;
}

- (void)_scheduleInDefaultRunLoopForMode:(CFStringRef)mode
{
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFNetServiceScheduleWithRunLoop([self _internalNetService], rl, mode);
    for (id monitor in _reserved.monitors)
    {
        CFNetServiceMonitorScheduleWithRunLoop((CFNetServiceMonitorRef)monitor, rl, mode);
    }
}

- (void)publishWithServer:(NSNetServiceOptions)options
{
#warning TODO: implement publishWithServer
}

- (void)_internal_publishWithOptions:(NSNetServiceOptions)options
{
#warning TODO: implement _internal_publishWithOptions
}

- (NSArray *)_monitors
{
    return [_reserved monitors];
}

- (void)_dispatchCallBackWithError:(CFStreamError *)error
{
#warning TODO: implement _dispatchCallBackWithError
}

@end

@interface NSNetServiceBrowser ()

@property (nonatomic, assign) BOOL includesPeerToPeer;

- (void)_dispatchCallBack:(CFTypeRef)domainOrService flags:(CFOptionFlags)flags error:(CFStreamError *)error;
- (CFNetServiceBrowserRef)_internalNetServiceBrowser;

@end

@implementation NSNetServiceBrowser {
    CFNetServiceBrowserRef _netServiceBrowser;
    id _delegate;
    void *_tbd;
    BOOL _includesPeerToPeer;
}

static void _netServiceBrowserDispatchCallBack(CFNetServiceBrowserRef browser, CFOptionFlags flags, CFTypeRef domainOrService, CFStreamError *error, void *info) {
    [(NSNetServiceBrowser *)info _dispatchCallBack:domainOrService flags:flags error:error];
}

- (id)init
{
    self = [super init];

    if (self)
    {
        CFNetServiceClientContext ctx = {
            .version = 0,
            .info = self,
        };
        _netServiceBrowser = CFNetServiceBrowserCreate(kCFAllocatorDefault, &_netServiceBrowserDispatchCallBack, &ctx);
        CFNetServiceBrowserScheduleWithRunLoop([self _internalNetServiceBrowser], CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }

    return self;
}

- (void)dealloc
{
    if (_netServiceBrowser)
    {
        CFNetServiceBrowserInvalidate(_netServiceBrowser);
        CFRelease(_netServiceBrowser);
    }
    [super dealloc];
}

- (id <NSNetServiceBrowserDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id <NSNetServiceBrowserDelegate>)delegate
{
    _delegate = delegate;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    CFRunLoopRef rl = [aRunLoop getCFRunLoop];
    CFNetServiceBrowserScheduleWithRunLoop([self _internalNetServiceBrowser], rl, (CFStringRef)mode);
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    CFRunLoopRef rl = [aRunLoop getCFRunLoop];
    CFNetServiceBrowserUnscheduleFromRunLoop([self _internalNetServiceBrowser], rl, (CFStringRef)mode);
}

- (void)searchForBrowsableDomains
{
    if (_netServiceBrowser)
    {
        CFStreamError err;
        if (CFNetServiceBrowserSearchForDomains([self _internalNetServiceBrowser], false, &err))
        {
            if ([_delegate respondsToSelector:@selector(netServiceBrowserWillSearch:)])
            {
                [_delegate netServiceBrowserWillSearch:self];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(netServiceBrowser:didNotSearch:)])
            {
                [_delegate netServiceBrowser:self didNotSearch:@{
                    NSNetServicesErrorCode: @(err.error),
                    NSNetServicesErrorDomain: @(err.domain),
                }];
            }
        }
    }
}

- (void)searchForRegistrationDomains
{
    if (_netServiceBrowser)
    {
        CFStreamError err;
        if (CFNetServiceBrowserSearchForDomains([self _internalNetServiceBrowser], true, &err))
        {
            if ([_delegate respondsToSelector:@selector(netServiceBrowserWillSearch:)])
            {
                [_delegate netServiceBrowserWillSearch:self];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(netServiceBrowser:didNotSearch:)])
            {
                [_delegate netServiceBrowser:self didNotSearch:@{
                    NSNetServicesErrorCode: @(err.error),
                    NSNetServicesErrorDomain: @(err.domain),
                }];
            }
        }
    }
}

- (void)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domainString
{
    if (_netServiceBrowser)
    {
        CFStreamError err;
#warning TODO: searchForServicesOfType should invoke a private api to consume _includesPeerTOPeer via _CFNetServiceBrowserSearchForServices
        if (CFNetServiceBrowserSearchForServices([self _internalNetServiceBrowser], (CFStringRef)domainString, (CFStringRef)type, &err))
        {
            if ([_delegate respondsToSelector:@selector(netServiceBrowserWillSearch:)])
            {
                [_delegate netServiceBrowserWillSearch:self];
            }
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(netServiceBrowser:didNotSearch:)])
            {
                [_delegate netServiceBrowser:self didNotSearch:@{
                    NSNetServicesErrorCode: @(err.error),
                    NSNetServicesErrorDomain: @(err.domain),
                }];
            }
        }
    }
}

- (void)stop
{
    CFNetServiceBrowserStopSearch([self _internalNetServiceBrowser], NULL);
}

#pragma mark - Private

- (void)_dispatchCallBack:(CFTypeRef)domainOrService flags:(CFOptionFlags)flags error:(CFStreamError *)error
{
#warning TODO: implement delegation callback for CFNetServiceBrowser to NSNetServiceBrowser delegation
}

- (CFNetServiceBrowserRef)_internalNetServiceBrowser
{
    return _netServiceBrowser;
}


@end

@implementation NSNetServiceBrowser (NSDeprecated)

- (void)searchForAllDomains
{
    [self searchForBrowsableDomains];
}

@end
