//
//  NSStream.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSStreamInternal.h"

NSString *const NSStreamSocketSecurityLevelKey = @"kCFStreamPropertySocketSecurityLevel";
NSString *const NSStreamSocketSecurityLevelNone = @"kCFStreamSocketSecurityLevelNone";
NSString *const NSStreamSocketSecurityLevelSSLv2 = @"kCFStreamSocketSecurityLevelSSLv2";
NSString *const NSStreamSocketSecurityLevelSSLv3 = @"kCFStreamSocketSecurityLevelSSLv3";
NSString *const NSStreamSocketSecurityLevelTLSv1 = @"kCFStreamSocketSecurityLevelTLSv1";
NSString *const NSStreamSocketSecurityLevelNegotiatedSSL = @"kCFStreamSocketSecurityLevelNegotiatedSSL";
NSString *const NSStreamSOCKSProxyConfigurationKey = @"kCFStreamPropertySOCKSProxy";
NSString *const NSStreamSOCKSProxyHostKey = @"SOCKSProxy";
NSString *const NSStreamSOCKSProxyPortKey = @"SOCKSPort";
NSString *const NSStreamSOCKSProxyVersionKey = @"kCFStreamPropertySOCKSVersion";
NSString *const NSStreamSOCKSProxyUserKey = @"kCFStreamPropertySOCKSUser";
NSString *const NSStreamSOCKSProxyPasswordKey = @"kCFStreamPropertySOCKSPassword";
NSString *const NSStreamSOCKSProxyVersion4 = @"kCFStreamSocketSOCKSVersion4";
NSString *const NSStreamSOCKSProxyVersion5 = @"kCFStreamSocketSOCKSVersion5";
NSString *const NSStreamDataWrittenToMemoryStreamKey = @"kCFStreamPropertyDataWritten";
NSString *const NSStreamFileCurrentOffsetKey = @"kCFStreamPropertyFileCurrentOffset";
NSString *const NSStreamSocketSSLErrorDomain = @"NSStreamSocketSSLErrorDomain";
NSString *const NSStreamSOCKSErrorDomain = @"NSStreamSOCKSErrorDomain";
NSString *const NSStreamNetworkServiceType = @"kCFStreamNetworkServiceType";
NSString *const NSStreamNetworkServiceTypeVoIP = @"kCFStreamNetworkServiceTypeVoIP";
NSString *const NSStreamNetworkServiceTypeVideo = @"kCFStreamNetworkServiceTypeVideo";
NSString *const NSStreamNetworkServiceTypeBackground = @"kCFStreamNetworkServiceTypeBackground";
NSString *const NSStreamNetworkServiceTypeVoice = @"kCFStreamNetworkServiceTypeVoice";

@implementation NSStream

- (void)open
{
    NSRequestConcreteImplementation();
}

- (void)close
{
    NSRequestConcreteImplementation();
}

- (id <NSStreamDelegate>)delegate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)setDelegate:(id <NSStreamDelegate>)delegate
{
    NSRequestConcreteImplementation();
}

- (id)propertyForKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return nil;
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    NSRequestConcreteImplementation();
    return NO;
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    NSRequestConcreteImplementation();
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    NSRequestConcreteImplementation();
}

- (NSStreamStatus)streamStatus
{
    NSRequestConcreteImplementation();
    return NSStreamStatusNotOpen;
}

- (NSError *)streamError
{
    NSRequestConcreteImplementation();
    return nil;
}

@end
