#ifndef _SECURITY_SECKEY_H_
#define _SECURITY_SECKEY_H_

#include <Security/SecBase.h>
#include <CoreFoundation/CFDictionary.h>
#include <sys/types.h>

__BEGIN_DECLS

enum {
    kSecPaddingNone        = 0x0000,
    kSecPaddingPKCS1       = 0x0001,
    kSecPaddingOAEP        = 0x0002,
    kSecPaddingPKCS1MD2    = 0x8000,
    kSecPaddingPKCS1MD5    = 0x8001,
    kSecPaddingPKCS1SHA1   = 0x8002,
    kSecPaddingPKCS1SHA224 = 0x8003,
    kSecPaddingPKCS1SHA256 = 0x8004,
    kSecPaddingPKCS1SHA384 = 0x8005,
    kSecPaddingPKCS1SHA512 = 0x8006,
};
typedef uint32_t SecPadding;

CFTypeID SecKeyGetTypeID(void);

extern CFTypeRef kSecPrivateKeyAttrs;
extern CFTypeRef kSecPublicKeyAttrs;

OSStatus SecKeyGeneratePair(CFDictionaryRef params, SecKeyRef *pubkey, SecKeyRef *privkey);
OSStatus SecKeyRawSign(SecKeyRef key, SecPadding padding, const uint8_t *data, size_t len, uint8_t *sig, size_t *sigLen);
OSStatus SecKeyRawVerify(SecKeyRef key, SecPadding padding, const uint8_t *data, size_t len, const uint8_t *sig, size_t sigLen);
OSStatus SecKeyEncrypt(SecKeyRef key, SecPadding padding, const uint8_t *plainText, size_t plainLen, uint8_t *cryptText, size_t *cryptLen);
OSStatus SecKeyDecrypt(SecKeyRef key, SecPadding padding, const uint8_t *cryptText, size_t cryptLen, uint8_t *plainText, size_t *plainLen);
size_t SecKeyGetBlockSize(SecKeyRef key);

__END_DECLS

#endif /*_SECURITY_SECKEY_H_*/
