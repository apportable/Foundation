//
//  SecBase.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _SECBASE_H_
#define _SECBASE_H_

#if defined(__cplusplus)
extern "C" {
#endif

typedef struct __SecCertificate *SecCertificateRef;

typedef struct __SecIdentity *SecIdentityRef;

typedef struct __SecKey *SecKeyRef;

enum
{
    errSecSuccess                = 0,
    errSecUnimplemented          = -4,
    errSecParam                  = -50, 
    errSecAllocate               = -108,
    errSecNotAvailable           = -25291,
    errSecDuplicateItem          = -25299,
    errSecItemNotFound           = -25300,
    errSecInteractionNotAllowed  = -25308,
    errSecDecode                 = -26275,
    errSecAuthFailed             = -25293,
};

#if defined(__cplusplus)
}
#endif

#endif /* _SECBASE_H_ */