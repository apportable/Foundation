//
//  NSURLAuthenticationChallenge.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSURLAuthenticationChallengeInternal.h"
#import <Foundation/NSError.h>
#import <Foundation/NSURLConnection.h>
#import "NSURLCredentialInternal.h"
#import "NSURLProtectionSpaceInternal.h"
#import "NSURLResponseInternal.h"
#import <CFNetwork/CFURLAuthChallenge.h>

@implementation NSURLAuthenticationChallenge
{
    NSURLProtectionSpace *_protectionSpace;
    NSURLCredential *_proposedCredential;
    NSInteger _previousFailureCount;
    NSURLResponse *_failureResponse;
    NSError *_error;
    id<NSURLAuthenticationChallengeSender> _sender;
}

+ (BOOL)supportsSecureCoding
{
    DEBUG_BREAK();
    return NO;
}

- (void)dealloc
{
    [_proposedCredential release];
    [_protectionSpace release];
    [_failureResponse release];
    [_error release];
    [_sender release];

    [super dealloc];
}

- (id)_initWithCFAuthChallenge:(CFURLAuthChallengeRef)cfchallenge sender:(id<NSURLAuthenticationChallengeSender>)sender
{
    NSURLProtectionSpace *space = nil;
    CFURLProtectionSpaceRef cfspace = CFURLAuthChallengeGetProtectionSpace(cfchallenge);
    if (cfspace != NULL)
    {
        space = [[[NSURLProtectionSpace alloc] _initWithCFURLProtectionSpace:cfspace] autorelease];
    }

    NSURLCredential *credential = nil;
    CFURLCredentialRef cfcredential = CFURLAuthChallengeGetCredential(cfchallenge);
    if (cfcredential != NULL)
    {
        credential = [[[NSURLCredential alloc] _initWithCFURLCredential:cfcredential] autorelease];
    }

    NSURLResponse *response = nil;
    CFURLResponseRef cfresponse = CFURLAuthChallengeGetResponse(cfchallenge);
    if (cfresponse != NULL)
    {
        response = [NSURLResponse _responseWithCFURLResponse:cfresponse];
    }

    NSInteger previousFailureCount = CFURLAuthChallengeGetPreviousFailureCount(cfchallenge);

    NSError *error = (NSError *)CFURLAuthChallengeGetError(cfchallenge);

    return [self initWithProtectionSpace:space proposedCredential:credential previousFailureCount:previousFailureCount failureResponse:response error:error sender:sender];
}


- (id)init
{
    [self release];
    return nil;
}

- (id)initWithProtectionSpace:(NSURLProtectionSpace *)space proposedCredential:(NSURLCredential *)credential previousFailureCount:(NSInteger)previousFailureCount failureResponse:(NSURLResponse *)response error:(NSError *)error sender:(id<NSURLAuthenticationChallengeSender>)sender
{
    self = [super init];
    if (self != nil)
    {
        _protectionSpace = [space retain];
        _proposedCredential = [credential retain];
        _previousFailureCount = previousFailureCount;
        _failureResponse = [response retain];
        _error = [error retain];
        _sender = [sender retain];
    }
    return self;
}

- (id)initWithAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge sender:(id<NSURLAuthenticationChallengeSender>)sender
{
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSURLCredential *proposedCredential = [challenge proposedCredential];
    NSInteger previousFailureCount = [challenge previousFailureCount];
    NSURLResponse *failureResponse = [challenge failureResponse];
    NSError *error = [challenge error];

    return [self initWithProtectionSpace:protectionSpace
                      proposedCredential:proposedCredential
                    previousFailureCount:previousFailureCount
                         failureResponse:failureResponse
                                   error:error
                                  sender:sender];
}

- (NSURLProtectionSpace *)protectionSpace
{
    return _protectionSpace;
}

- (NSURLCredential *)proposedCredential
{
    return _proposedCredential;
}

- (NSInteger)previousFailureCount
{
    return _previousFailureCount;
}

- (NSURLResponse *)failureResponse
{
    return _failureResponse;
}

- (NSError *)error
{
    return _error;
}

- (id<NSURLAuthenticationChallengeSender>)sender
{
    return _sender;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    [self release];
    DEBUG_BREAK();
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    DEBUG_BREAK();
}

@end
