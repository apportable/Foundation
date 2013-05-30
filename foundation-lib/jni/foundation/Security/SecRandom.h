#ifndef _SECURITY_SECRANDOM_H_
#define _SECURITY_SECRANDOM_H_

#include <stdint.h>
#include <sys/types.h>
#include <Security/SecBase.h>

#if defined(__cplusplus)
extern "C" {
#endif

typedef const struct __SecRandom * SecRandomRef;

extern const SecRandomRef kSecRandomDefault;

int SecRandomCopyBytes(SecRandomRef rnd, size_t count, uint8_t *bytes);

#if defined(__cplusplus)
}
#endif

#endif /* !_SECURITY_SECRANDOM_H_ */
