//
//  NSURLResponse.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSURLResponseInternal.h"
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>

@implementation NSURLResponseInternal

- (id)initWithURLResponse:(CFURLResponseRef)resp
{
    self = [super init];
    if (self)
    {
        response = (CFURLResponseRef)CFRetain(resp);
    }
    return self;
}

- (void)dealloc
{
    CFRelease(response);
    [super dealloc];
}

@end

@implementation NSURLResponse {
    NSURLResponseInternal *_internal;
}

+ (id)_responseWithCFURLResponse:(CFURLResponseRef)response
{
    if (response == NULL)
    {
        return nil;
    }
    
    return [[[self alloc] _initWithCFURLResponse:response] autorelease];
}

- (id)init
{
    return [self initWithURL:nil MIMEType:nil expectedContentLength:0 textEncodingName:nil];
}

- (id)initWithURL:(NSURL *)URL MIMEType:(NSString *)MIMEType expectedContentLength:(NSInteger)length textEncodingName:(NSString *)name
{
    CFURLResponseRef resp = CFURLResponseCreate(kCFAllocatorDefault, (CFURLRef)URL, (CFStringRef)MIMEType, length, (CFStringRef)name);
    id response = [self _initWithCFURLResponse:resp];
    CFRelease(resp);
    return response;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{

}

- (id)_initWithCFURLResponse:(CFURLResponseRef)response
{
    self = [super init];
    if (self)
    {
        _internal = [[NSURLResponseInternal alloc] initWithURLResponse:response];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)dealloc
{
    [_internal release];
    [super dealloc];
}

- (NSString *)suggestedFilename
{
    return [(NSString *)CFURLResponseCopySuggestedFilename([self _CFURLResponse]) autorelease];
}

- (long long)expectedContentLength
{
    return CFURLResponseGetExpectedContentLength([self _CFURLResponse]);
}

- (NSString *)textEncodingName
{
    return (NSString *)CFURLResponseGetTextEncodingName([self _CFURLResponse]);
}

- (NSString *)MIMEType
{
    return (NSString *)CFURLResponseGetMIMEType([self _CFURLResponse]);
}

- (NSURL *)URL
{
    return (NSURL *)CFURLResponseGetURL([self _CFURLResponse]);
}

- (CFURLResponseRef)_CFURLResponse
{
    return _internal->response;
}

@end

static inline NSString *NSURLLocalizedString(NSString *key)
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=256
    return key;
}

@implementation NSHTTPURLResponseInternal

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{

}

- (void)dealloc
{
    if (peerTrust != NULL)
    {
        CFRelease(peerTrust);
    }
    [super dealloc];
}

@end

@implementation NSHTTPURLResponse {
    NSHTTPURLResponseInternal *_httpInternal;
}

+ (BOOL)isErrorStatusCode:(NSInteger)statusCode
{
    if (statusCode < 100)
    {
        return YES;
    }
    else if (statusCode < 400)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {

    }
    return self;
}

- (id)initWithURL:(NSURL *)URL statusCode:(NSInteger)statusCode HTTPVersion:(NSString *)version headerFields:(NSDictionary *)fields
{
    CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, (int)statusCode, NULL, (CFStringRef)version);
    for (NSString *fieldKey in fields)
    {
        NSString *fieldValue = [fields objectForKey:fieldKey];
        CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)fieldKey, (CFStringRef)fieldValue);
    }
    CFURLResponseRef response = CFURLResponseCreateWithCFHTTPMessage(kCFAllocatorDefault, (CFURLRef)URL, message);
    CFRelease(message);
    self = [super _initWithCFURLResponse:response];
    CFRelease(response);
    if (self)
    {

    }
    return self;
}

- (id)initWithURL:(NSURL *)URL statusCode:(NSInteger)statusCode headerFields:(NSDictionary *)fields requestTime:(NSTimeInterval)ti
{
    return [self initWithURL:URL statusCode:statusCode HTTPVersion:(NSString *)kCFHTTPVersion1_1 headerFields:fields];
}

- (id)_initWithCFURLResponse:(CFURLResponseRef)response
{
    self = [super _initWithCFURLResponse:response];
    if (self)
    {

    }
    return self;
}

- (SecTrustRef)_peerTrust
{
    return _httpInternal->peerTrust;
}

- (void)_setPeerTrust:(SecTrustRef)trust
{
    if (_httpInternal->peerTrust != trust)
    {
        if (_httpInternal->peerTrust != NULL)
        {
            CFRelease(_httpInternal->peerTrust);
        }
        if (trust != NULL) {
            _httpInternal->peerTrust = (SecTrustRef)CFRetain(trust);
        } else {
            _httpInternal->peerTrust = NULL;
        }
    }
}

- (id)_clientCertificateState
{
    return nil;
}

- (id)_clientCertificateChain
{
    return nil;
}

- (id)_peerCertificateChain
{
    return nil;
}

+ (NSString *)localizedStringForStatusCode:(NSInteger)statusCode
{
    if (statusCode < 100)
    {
        return NSURLLocalizedString(@"server error");
    }
    else if (statusCode == 100)
    {
        return NSURLLocalizedString(@"continue");
    }
    else if (statusCode == 101)
    {
        return NSURLLocalizedString(@"switching protocols");
    }
    else if (102 <= statusCode && statusCode <= 199)
    {
        return NSURLLocalizedString(@"informational");
    }
    else if (statusCode == 200)
    {
        return NSURLLocalizedString(@"no error");
    }
    else if (statusCode == 201)
    {
        return NSURLLocalizedString(@"created");
    }
    else if (statusCode == 202)
    {
        return NSURLLocalizedString(@"accepted");
    }
    else if (statusCode == 203)
    {
        return NSURLLocalizedString(@"non-authoritative information");
    }
    else if (statusCode == 204)
    {
        return NSURLLocalizedString(@"no content");
    }
    else if (statusCode == 205)
    {
        return NSURLLocalizedString(@"resetContent");
    }
    else if (statusCode == 206)
    {
        return NSURLLocalizedString(@"partial content");
    }
    else if (207 <= statusCode && statusCode <= 299)
    {
        return NSURLLocalizedString(@"success");
    }
    else if (statusCode == 300)
    {
        return NSURLLocalizedString(@"multiple choices");
    }
    else if (statusCode == 301)
    {
        return NSURLLocalizedString(@"moved permanently");
    }
    else if (statusCode == 302)
    {
        return NSURLLocalizedString(@"found");
    }
    else if (statusCode == 303)
    {
        return NSURLLocalizedString(@"see other");
    }
    else if (statusCode == 304)
    {
        return NSURLLocalizedString(@"not modified");
    }
    else if (statusCode == 305)
    {
        return NSURLLocalizedString(@"needs proxy");
    }
    else if (statusCode == 306)
    {
        return NSURLLocalizedString(@"redirected");
    }
    else if (statusCode == 307)
    {
        return NSURLLocalizedString(@"temporarily redirected");
    }
    else if (308 <= statusCode && statusCode <= 399)
    {
        return NSURLLocalizedString(@"redirected");
    }
    else if (statusCode == 400)
    {
        return NSURLLocalizedString(@"bad request");
    }
    else if (statusCode == 401)
    {
        return NSURLLocalizedString(@"unauthorized");
    }
    else if (statusCode == 402)
    {
        return NSURLLocalizedString(@"payment required");
    }
    else if (statusCode == 403)
    {
        return NSURLLocalizedString(@"forbidden");
    }
    else if (statusCode == 404)
    {
        return NSURLLocalizedString(@"not found");
    }
    else if (statusCode == 405)
    {
        return NSURLLocalizedString(@"method not allowed");
    }
    else if (statusCode == 406)
    {
        return NSURLLocalizedString(@"unacceptable");
    }
    else if (statusCode == 407)
    {
        return NSURLLocalizedString(@"proxy authentication required");
    }
    else if (statusCode == 408)
    {
        return NSURLLocalizedString(@"request timed out");
    }
    else if (statusCode == 409)
    {
        return NSURLLocalizedString(@"conflict");
    }
    else if (statusCode == 410)
    {
        return NSURLLocalizedString(@"no longer exists");
    }
    else if (statusCode == 411)
    {
        return NSURLLocalizedString(@"length required");
    }
    else if (statusCode == 412)
    {
        return NSURLLocalizedString(@"precondition failed");
    }
    else if (statusCode == 413)
    {
        return NSURLLocalizedString(@"request too large");
    }
    else if (statusCode == 414)
    {
        return NSURLLocalizedString(@"requested URL too long");
    }
    else if (statusCode == 416)
    {
        return NSURLLocalizedString(@"requested range not satisfiable");
    }
    else if (statusCode == 417)
    {
        return NSURLLocalizedString(@"expectation failed");
    }
    else if (418 <= statusCode && statusCode <= 499)
    {
        return NSURLLocalizedString(@"client error");
    }
    else if (statusCode == 500)
    {
        return NSURLLocalizedString(@"internal server error");
    }
    else if (statusCode == 501)
    {
        return NSURLLocalizedString(@"unimplemented");
    }
    else if (statusCode == 502)
    {
        return NSURLLocalizedString(@"bad gateway");
    }
    else if (statusCode == 503)
    {
        return NSURLLocalizedString(@"service unavailable");
    }
    else if (statusCode == 504)
    {
        return NSURLLocalizedString(@"gateway unavailable");
    }
    else if (statusCode == 505)
    {
        return NSURLLocalizedString(@"unsupported version");
    }
    else /*if (statusCode <= 506)*/
    {
        return NSURLLocalizedString(@"server error");
    }
}

- (NSInteger)statusCode
{
    return (NSInteger)CFURLResponseGetStatusCode([self _CFURLResponse]);
}

- (NSDictionary *)allHeaderFields
{
    return (NSDictionary *)CFURLResponseGetHeaderFields([self _CFURLResponse]);
}

@end
