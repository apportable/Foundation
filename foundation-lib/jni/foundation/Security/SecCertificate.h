#include <Security/SecBase.h>
#include <Security/SecTrust.h>
#include <CoreFoundation/CFData.h>

CFIndex SecTrustGetCertificateCount(SecTrustRef trust);
SecCertificateRef SecTrustGetCertificateAtIndex(SecTrustRef trust, CFIndex ix);
CFDataRef SecCertificateCopyData(SecCertificateRef certificate);