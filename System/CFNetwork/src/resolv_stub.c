//
//  resolv_stub.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include <mach/mach.h>

int32_t dns_async_handle_reply(void *msg) {
    return -1;
}

typedef void (*dns_async_callback)(int32_t status, char *buf, uint32_t len, struct sockaddr *from, int fromlen, void *context);

int32_t dns_async_start(mach_port_t *p, const char *name, uint16_t dnsclass, uint16_t dnstype, uint32_t do_search, dns_async_callback callback, void *context) {
    return -1;
}
