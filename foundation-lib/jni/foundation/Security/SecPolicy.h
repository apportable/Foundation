
#ifndef _SECURITY_SECPOLICY_H_
#define _SECURITY_SECPOLICY_H_

#include <Security/SecBase.h>
#include <CoreFoundation/CFBase.h>

#if defined(__cplusplus)
extern "C" {
#endif

typedef struct __SecPolicy *SecPolicyRef;

CFTypeID SecPolicyGetTypeID(void);
SecPolicyRef SecPolicyCreateBasicX509(void);
SecPolicyRef SecPolicyCreateSSL(Boolean server, CFStringRef hostname);

#if defined(__cplusplus)
}
#endif

#endif /* !_SECURITY_SECPOLICY_H_ */
