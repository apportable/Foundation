#ifndef __CFURLAUTHCHALLENGE__
#define __CFURLAUTHCHALLENGE__

#include "CFURLCredential.h"
#include "CFURLProtectionSpace.h"
#include "CFURLResponse.h"
#include <CFNetwork/CFHTTPAuthentication.h>

#if PRAGMA_ONCE
#pragma once
#endif

__BEGIN_DECLS

typedef const struct __CFURLAuthChallenge *CFURLAuthChallengeRef;

CFURLAuthChallengeRef CFURLAuthChallengeCreateWithCFHTTPAuthentication(CFAllocatorRef allocator, CFHTTPAuthenticationRef auth);
CFURLProtectionSpaceRef CFURLAuthChallengeGetProtectionSpace(CFURLAuthChallengeRef challenge);
CFURLCredentialRef CFURLAuthChallengeGetCredential(CFURLAuthChallengeRef challenge);
CFURLResponseRef CFURLAuthChallengeGetResponse(CFURLAuthChallengeRef challenge);
CFIndex CFURLAuthChallengeGetPreviousFailureCount(CFURLAuthChallengeRef challenge);
CFErrorRef CFURLAuthChallengeGetError(CFURLAuthChallengeRef challenge);

__END_DECLS

#endif
