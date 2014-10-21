//
//  NSException.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>
#import "CFString.h"
#import "CFNumber.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
#import <execinfo.h>

@interface NSException ()
- (BOOL)_installStackTraceKeyIfNeeded;
@end

typedef id (*objc_exception_preprocessor)(id exception);
extern objc_exception_preprocessor objc_setExceptionPreprocessor(objc_exception_preprocessor fn);

static NSException *__exceptionPreprocess(NSException *exception)
{
// this is quite expensive (1/3 sec lag), when it can be made more performant (under 1/60 sec) this should be re-enabled
#if 0
    [exception _installStackTraceKeyIfNeeded];
#endif
    return exception;
}

static void NSExceptionInitializer() __attribute__((constructor));
static void NSExceptionInitializer()
{
    objc_setExceptionPreprocessor(&__exceptionPreprocess);
}

NSString *const NSGenericException = @"NSGenericException";
NSString *const NSRangeException = @"NSRangeException";
NSString *const NSInvalidArgumentException = @"NSInvalidArgumentException";
NSString *const NSInternalInconsistencyException = @"NSInternalInconsistencyException";
NSString *const NSMallocException = @"NSMallocException";
NSString *const NSObjectInaccessibleException = @"NSObjectInaccessibleException";
NSString *const NSObjectNotAvailableException = @"NSObjectNotAvailableException";
NSString *const NSDestinationInvalidException = @"NSDestinationInvalidException";
NSString *const NSPortTimeoutException = @"NSPortTimeoutException";
NSString *const NSInvalidSendPortException = @"NSInvalidSendPortException";
NSString *const NSInvalidReceivePortException = @"NSInvalidReceivePortException";
NSString *const NSPortSendException = @"NSPortSendException";
NSString *const NSPortReceiveException = @"NSPortReceiveException";
NSString *const NSCharacterConversionException = @"NSCharacterConversionException";
NSString *const NSFileHandleOperationException = @"NSFileHandleOperationException";

@implementation NSException {
    NSString *name;
    NSString *reason;
    NSDictionary *userInfo;
    id reserved;
}

- (id)init
{
    [self release]; // initWithName:reason:userInfo: is the only acceptable init method
    return nil;
}

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super init];
    if (self)
    {
        name = [aName copy];
        reason = [aReason copy];
        userInfo = [aUserInfo copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)dealloc
{
    [name release];
    [reason release];
    [userInfo release];
    [reserved release];
    [super dealloc];
}

- (void)raise
{
    @throw self;
}

+ (void)raise:(NSString *)name format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    CFStringRef reason = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, args);
    va_end(args);
    [[self exceptionWithName:name reason:(NSString *)reason userInfo:nil] raise];
    CFRelease(reason);
}

+ (void)raise:(NSString *)name format:(NSString *)format arguments:(va_list)args
{
    CFStringRef reason = CFStringCreateWithFormatAndArguments(kCFAllocatorDefault, NULL, (CFStringRef)format, args);
    [[self exceptionWithName:name reason:(NSString *)reason userInfo:nil] raise];
    CFRelease(reason);
}

+ (NSException *)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
    return [[[self alloc] initWithName:name reason:reason userInfo:userInfo] autorelease];
}

- (NSString *)name
{
    return name;
}

- (NSString *)reason
{
    return reason;
}

- (NSDictionary *)userInfo
{
    return userInfo;
}

- (BOOL)_installStackTraceKeyIfNeeded
{
    if (reserved == NULL)
    {
        reserved = [[NSMutableDictionary alloc] init];
    }

    NSArray *callStackSymbols = nil;
    if (userInfo != nil)
    {
        callStackSymbols = [userInfo objectForKey:@"NSStackTraceKey"];
    }

    if (callStackSymbols == nil)
    {
        callStackSymbols = [reserved objectForKey:@"callStackSymbols"];
    }
    else
    {
        [reserved setObject:callStackSymbols forKey:@"callStackSymbols"];
    }

    if (callStackSymbols == nil)
    {
        void *stack[128] = { NULL };
        CFStringRef symbols[128] = { nil };
        CFNumberRef returnAddresses[128] = { nil };

        int count = backtrace(stack, sizeof(stack)/sizeof(stack[0]));
        char **sym = backtrace_symbols(stack, count);
        if (sym == NULL)
        {
            return NO;
        }

        // make sure to skip this frame since it is just an instantiator
        for (int i = 1; i < count; i++)
        {
            returnAddresses[i - 1] = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &stack[i]);
            symbols[i - 1] = CFStringCreateWithCString(kCFAllocatorDefault, sym[i], kCFStringEncodingUTF8);
        }

        free(sym);
        callStackSymbols = [[NSArray alloc] initWithObjects:(id *)symbols count:count - 1];
        NSArray *callStackReturnAddresses = [[NSArray alloc] initWithObjects:(id *)returnAddresses count:count - 1];
        [reserved setObject:callStackSymbols forKey:@"callStackSymbols"];
        [reserved setObject:callStackReturnAddresses forKey:@"callStackReturnAddresses"];
        
        for (int i = 1; i < count; i++)
        {
            CFRelease(returnAddresses[i - 1]);
            CFRelease(symbols[i - 1]);
        }

        [callStackSymbols release];
        [callStackReturnAddresses release];
    }

    return callStackSymbols != nil;
}

- (NSArray *)callStackReturnAddresses
{
    return [reserved objectForKey:@"callStackReturnAddresses"];
}

- (NSArray *)callStackSymbols
{
    return [reserved objectForKey:@"callStackSymbols"];
}

- (NSString *)description
{
    if (reason != nil)
    {
        return reason;
    }

    return name;
}

@end
