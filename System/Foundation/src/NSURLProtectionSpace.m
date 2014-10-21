//
//  NSURLProtectionSpace.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSURLProtectionSpaceInternal.h"
#import <Foundation/NSString.h>
#import <CFNetwork/CFURLProtectionSpace.h>

NSString * const NSURLProtectionSpaceHTTP = @"http";
NSString * const NSURLProtectionSpaceHTTPS = @"https";
NSString * const NSURLProtectionSpaceFTP = @"ftp";
NSString * const NSURLProtectionSpaceHTTPProxy = @"http";
NSString * const NSURLProtectionSpaceHTTPSProxy = @"https";
NSString * const NSURLProtectionSpaceFTPProxy = @"ftp";
NSString * const NSURLProtectionSpaceSOCKSProxy = @"SOCKS";

NSString * const NSURLAuthenticationMethodDefault = @"NSURLAuthenticationMethodDefault";
NSString * const NSURLAuthenticationMethodHTTPBasic = @"NSURLAuthenticationMethodDefault";
NSString * const NSURLAuthenticationMethodHTTPDigest = @"NSURLAuthenticationMethodHTTPDigest";
NSString * const NSURLAuthenticationMethodHTMLForm = @"NSURLAuthenticationMethodHTMLForm";
NSString * const NSURLAuthenticationMethodNTLM = @"NSURLAuthenticationMethodNTLM";
NSString * const NSURLAuthenticationMethodNegotiate = @"NSURLAuthenticationMethodNegotiate";
NSString * const NSURLAuthenticationMethodClientCertificate = @"NSURLAuthenticationMethodClientCertificate";
NSString * const NSURLAuthenticationMethodServerTrust = @"NSURLAuthenticationMethodServerTrust";

@class NSURLProtectionSpaceInternal;

@implementation NSURLProtectionSpace {
    NSURLProtectionSpaceInternal *_internal;
}

static CFURLProtectionSpaceServerType protocolToCFServerType(NSString * const protocol)
{
    if ([protocol isEqualToString:NSURLProtectionSpaceHTTP])
    {
        return kCFURLProtectionSpaceServerHTTP;
    }
    else if ([protocol isEqualToString:NSURLProtectionSpaceHTTPS])
    {
        return kCFURLProtectionSpaceServerHTTPS;
    }
    else if ([protocol isEqualToString:NSURLProtectionSpaceFTP])
    {
        return kCFURLProtectionSpaceServerFTP;
    }
    else if ([protocol isEqualToString:NSURLProtectionSpaceHTTPProxy])
    {
        return kCFURLProtectionSpaceProxyHTTP;
    }
    else if ([protocol isEqualToString:NSURLProtectionSpaceHTTPSProxy])
    {
        return kCFURLProtectionSpaceProxyHTTPS;
    }
    else if ([protocol isEqualToString:NSURLProtectionSpaceFTPProxy])
    {
        return kCFURLProtectionSpaceProxyFTP;
    }
    else if ([protocol isEqualToString:NSURLProtectionSpaceSOCKSProxy])
    {
        return kCFURLProtectionSpaceProxySOCKS;
    }
    else
    {
        return kCFURLProtectionSpaceServerHTTP;
    }
}

static CFURLProtectionSpaceAuthenticationSchemeType methodToCFAuthScheme(NSString * const method)
{
    if ([method isEqualToString:NSURLAuthenticationMethodDefault])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeDefault;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodHTTPBasic])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeHTTPBasic;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodHTTPDigest])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeHTTPDigest;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodHTMLForm])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeHTMLForm;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodNTLM])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeNTLM;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodNegotiate])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeNegotiate;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeServerTrustEvaluationRequested;
    }
    else if ([method isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        return kCFURLProtectionSpaceAuthenticationSchemeClientCertificateRequested;
    }
    else
    {
        return kCFURLProtectionSpaceAuthenticationSchemeDefault;
    }
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)init
{
    [self release];
    return nil;
}

- (id)_internalInit
{
    self = [super init];
    if (self != nil)
    {
        _internal = nil;
    }
    return self;
}

- (id)_initWithCFURLProtectionSpace:(CFURLProtectionSpaceRef)protectionSpace
{
    self = [self _internalInit];
    if (self != nil)
    {
        CFRetain(protectionSpace);
        _internal = (NSURLProtectionSpaceInternal *)protectionSpace;
    }
    return self;
}

- (id)initWithHost:(NSString *)host port:(NSInteger)port protocol:(NSString *)protocol realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod
{
    self = [self _internalInit];
    if (self != nil)
    {
        CFURLProtectionSpaceServerType serverType = protocolToCFServerType(protocol);
        CFURLProtectionSpaceAuthenticationSchemeType scheme = methodToCFAuthScheme(authenticationMethod);
        _internal = (NSURLProtectionSpaceInternal *)CFURLProtectionSpaceCreate(kCFAllocatorDefault, (CFStringRef)host, port, serverType, (CFStringRef)realm, scheme);
    }
    return self;
}

- (id)initWithProxyHost:(NSString *)host port:(NSInteger)port type:(NSString *)type realm:(NSString *)realm authenticationMethod:(NSString *)authenticationMethod
{
    return [self initWithHost:host port:port protocol:type realm:realm authenticationMethod:authenticationMethod];
}

- (id)initWithCoder:(NSCoder *)coder
{
    DEBUG_BREAK();
    [self release];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    DEBUG_BREAK();
}

- (void)dealloc
{
    if (_internal != nil)
    {
        CFRelease((CFURLProtectionSpaceRef)_internal);
    }

    [super dealloc];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }

    if (![other isKindOfClass:[NSURLProtectionSpace self]])
    {
        return NO;
    }

    CFURLProtectionSpaceRef otherSpace = (CFURLProtectionSpaceRef)(((NSURLProtectionSpace *)other)->_internal);

    if ((CFURLProtectionSpaceRef)_internal == NULL || otherSpace == NULL)
    {
        return NO;
    }

    return CFEqual((CFURLProtectionSpaceRef)_internal, otherSpace) ? YES : NO;
}

- (NSUInteger)hash
{
    return CFHash((CFURLProtectionSpaceRef)_internal);
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSString *)description
{
    NSString *superDescription = [super description];
    NSString *host = [self host];
    NSString *protocol = [self protocol];
    NSString *realm = [self protocol];
    long port = [self port];
    NSString *isProxy = [self protocol] ? @"yes" : @"no";
    NSString *proxyType = [self protocol];
    NSString *authenticationMethod = [self protocol];

    return [NSString stringWithFormat:@"%@ host:%@ protocol:%@ realm:%@ port:%ld isProxy:%@ proxyType:%@ authenticationMethod:%@",
                     superDescription, host, protocol, realm, port, isProxy, proxyType, authenticationMethod];
}

- (CFURLProtectionSpaceRef)_cfurlprtotectionspace
{
    return (CFURLProtectionSpaceRef)_internal;
}

- (NSString *)realm
{
    CFStringRef cfrealm = CFURLProtectionSpaceGetRealm((CFURLProtectionSpaceRef)_internal);
    return [[(NSString *)cfrealm retain] autorelease];
}

- (BOOL)receivesCredentialSecurely
{
    return CFURLProtectionSpaceReceivesCredentialSecurely((CFURLProtectionSpaceRef)_internal) ? YES : NO;
}

- (BOOL)isProxy
{
    return CFURLProtectionSpaceIsProxy((CFURLProtectionSpaceRef)_internal) ? YES : NO;
}

- (NSString *)host
{
    CFStringRef cfhost = CFURLProtectionSpaceGetHost((CFURLProtectionSpaceRef)_internal);
    return [[(NSString *)cfhost retain] autorelease];
}

- (NSInteger)port
{
    return CFURLProtectionSpaceGetPort((CFURLProtectionSpaceRef)_internal);
}

- (NSString *)proxyType
{
    if ([self isProxy])
    {
        return [self protocol];
    }
    else
    {
        return nil;
    }
}

- (NSString *)protocol
{
    switch ((UInt32)CFURLProtectionSpaceGetServerType((CFURLProtectionSpaceRef)_internal))
    {
        case kCFURLProtectionSpaceServerHTTP:
        {
            return NSURLProtectionSpaceHTTP;
        }
        case kCFURLProtectionSpaceServerHTTPS:
        {
            return NSURLProtectionSpaceHTTPS;
        }
        case kCFURLProtectionSpaceServerFTP:
        {
            return NSURLProtectionSpaceFTP;
        }
        case kCFURLProtectionSpaceProxyHTTP:
        {
            return NSURLProtectionSpaceHTTPProxy;
        }
        case kCFURLProtectionSpaceProxyHTTPS:
        {
            return NSURLProtectionSpaceHTTPSProxy;
        }
        case kCFURLProtectionSpaceProxyFTP:
        {
            return NSURLProtectionSpaceFTPProxy;
        }
        case kCFURLProtectionSpaceProxySOCKS:
        {
            return NSURLProtectionSpaceSOCKSProxy;
        }
        default:
        {
            return NSURLProtectionSpaceHTTP;
        }
    }
}

- (NSString *)authenticationMethod
{
    switch ((UInt32)CFURLProtectionSpaceGetAuthenticationScheme((CFURLProtectionSpaceRef)_internal))
    {
        case kCFURLProtectionSpaceAuthenticationSchemeDefault:
        {
            return NSURLAuthenticationMethodDefault;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeHTTPBasic:
        {
            return NSURLAuthenticationMethodHTTPBasic;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeHTTPDigest:
        {
            return NSURLAuthenticationMethodHTTPDigest;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeHTMLForm:
        {
            return NSURLAuthenticationMethodHTMLForm;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeNTLM:
        {
            return NSURLAuthenticationMethodNTLM;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeNegotiate:
        {
            return NSURLAuthenticationMethodNegotiate;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeServerTrustEvaluationRequested:
        {
            return NSURLAuthenticationMethodServerTrust;
        }
        case kCFURLProtectionSpaceAuthenticationSchemeClientCertificateRequested:
        {
            return NSURLAuthenticationMethodClientCertificate;
        }
        default:
        {
            return NSURLAuthenticationMethodDefault;
        }
    }
}

- (NSArray *)distinguishedNames
{
    return (NSArray *)CFURLProtectionSpaceGetDistinguishedNames((CFURLProtectionSpaceRef)_internal);
}

- (SecTrustRef)serverTrust
{
    return CFURLProtectionSpaceGetServerTrust((CFURLProtectionSpaceRef)_internal);
}

@end
