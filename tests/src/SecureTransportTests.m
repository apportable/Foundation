//
//  SecureTransportTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <Security/SecureTransport.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netdb.h>

@testcase(SecureTransport)

static OSStatus readFunc(SSLConnectionRef connection, void *data, size_t *dataLength)
{
    void *eptr = data + *dataLength;
    
    ssize_t res;
    
    do {
        
        res = read(*(int*)connection, data, eptr - data);
        
        if(res < 1)
            return errSSLClosedGraceful;
        
        data += res;
    
    } while (data < eptr);
    
    return noErr;
}

static OSStatus writeFunc(SSLConnectionRef connection, const void *data, size_t *dataLength)
{
    ssize_t res = send(*(int*)connection, data, (int)*dataLength, 0);
    
    *dataLength = res > 0 ? res : 0;
    
    if(res < 1)
        return errSSLClosedGraceful;
    
    return noErr;
}

static int connectTo(const char *hostname, unsigned short port)
{
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    
#ifdef APPORTABLE
    extern struct hostent *
    __real_gethostbyname2(const char *name, int af);
    
    struct hostent *hostent = __real_gethostbyname2("google.com", AF_INET);
#else
    struct hostent *hostent = gethostbyname2("google.com", AF_INET);
#endif
    
    NSCAssert(hostent, @"gethostbyname2");
    NSCAssert(hostent->h_addr_list[0], @"gethostbyname2");
    
    struct sockaddr_in sockaddr;
    
    memset(&sockaddr, 0, sizeof(sockaddr));
    
    testassert(hostent != NULL);
    memcpy(&sockaddr.sin_addr, *hostent->h_addr_list, hostent->h_length);
    sockaddr.sin_port = htons(port);
    
    int res = connect(fd, (void*)&sockaddr, sizeof(sockaddr));
    
    NSCAssert(res != -1, @"connect");
    
    return fd;
}

test(BadParams)
{
    testassert(SSLCreateContext(NULL, 55, kSSLStreamType) != NULL);
    testassert(SSLCreateContext(NULL, kSSLClientSide, 55) != NULL);
    testassert(SSLCreateContext(NULL, 55, 55) != NULL);
    
    return YES;
}

test(BadDomain)
{
    int fd = connectTo("google.com", 443);
    
    SSLContextRef ref = SSLCreateContext(NULL, kSSLClientSide, kSSLStreamType);
    
    testassert(ref != NULL);
    
    OSStatus res;
    
    res = SSLSetIOFuncs(ref, readFunc, writeFunc);
    
    testassert(res == 0);
    
    res = SSLSetConnection(ref, &fd);
    
    testassert(res == 0);
    
    res = SSLSetPeerDomainName(ref, "baddomain.com", strlen("baddomain.com"));
    
    testassert(res == 0);
    
    res = SSLHandshake(ref);
    
    testassert(res == errSSLXCertChainInvalid);
    
    CFRelease(ref);
    
    close(fd);
    
    return YES;
}

test(Request)
{
    int fd = connectTo("google.com", 443);
    
    SSLContextRef ref = SSLCreateContext(NULL, kSSLClientSide, kSSLStreamType);
    
    testassert(ref != NULL);
    
    OSStatus res;
    
    res = SSLSetIOFuncs(ref, readFunc, writeFunc);
    
    testassert(res == 0);
    
    res = SSLSetConnection(ref, &fd);
    
    testassert(res == 0);
    
    res = SSLSetPeerDomainName(ref, "google.com", strlen("google.com"));
    
    testassert(res == 0);
    
    res = SSLHandshake(ref);
    
    testassert(res == 0);
    
    const char *request = "GET / HTTP/1.0\r\n\r\n";
    size_t proccessed = 0;
    
    res = SSLWrite(ref, request, strlen(request), &proccessed);
    
    testassert(proccessed == strlen(request));
    
    char buf[1024];
    proccessed = 0;
    
    SSLRead(ref, buf, sizeof(buf) - 1, &proccessed);
    
    buf[proccessed] = 0;
    
    testassert(NULL != strstr(buf, "HTTP/1.0 200 OK"));
    
    CFRelease(ref);
    
    close(fd);
    
    return YES;
}

@end
