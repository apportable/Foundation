#ifndef _CFNETWORKERRORS_H_
#define _CFNETWORKERRORS_H_

#include <CoreFoundation/CFString.h>

#ifdef __cplusplus
extern "C" {
#endif

extern const CFStringRef kCFErrorDomainCFNetwork;
extern const CFStringRef kCFErrorDomainWinSock;

typedef enum {
    kCFHostErrorHostNotFound = 1,
    kCFHostErrorUnknown = 2, 
    kCFSOCKSErrorUnknownClientVersion = 100,
    kCFSOCKSErrorUnsupportedServerVersion = 101, 
    kCFSOCKS4ErrorRequestFailed = 110,  
    kCFSOCKS4ErrorIdentdFailed = 111,  
    kCFSOCKS4ErrorIdConflict = 112,  
    kCFSOCKS4ErrorUnknownStatusCode = 113,
    kCFSOCKS5ErrorBadState = 120,
    kCFSOCKS5ErrorBadResponseAddr = 121,
    kCFSOCKS5ErrorBadCredentials = 122,
    kCFSOCKS5ErrorUnsupportedNegotiationMethod = 123, 
    kCFSOCKS5ErrorNoAcceptableMethod = 124,
    kCFFTPErrorUnexpectedStatusCode = 200,
    kCFErrorHTTPAuthenticationTypeUnsupported = 300,
    kCFErrorHTTPBadCredentials = 301,
    kCFErrorHTTPConnectionLost = 302,
    kCFErrorHTTPParseFailure = 303,
    kCFErrorHTTPRedirectionLoopDetected = 304,
    kCFErrorHTTPBadURL = 305,
    kCFErrorHTTPProxyConnectionFailure = 306,
    kCFErrorHTTPBadProxyCredentials = 307,
    kCFErrorPACFileError = 308,
    kCFErrorPACFileAuth = 309,
    kCFErrorHTTPSProxyConnectionFailure = 310,
    kCFURLErrorUnknown = -998,
    kCFURLErrorCancelled = -999,
    kCFURLErrorBadURL = -1000,
    kCFURLErrorTimedOut = -1001,
    kCFURLErrorUnsupportedURL = -1002,
    kCFURLErrorCannotFindHost = -1003,
    kCFURLErrorCannotConnectToHost = -1004,
    kCFURLErrorNetworkConnectionLost = -1005,
    kCFURLErrorDNSLookupFailed = -1006,
    kCFURLErrorHTTPTooManyRedirects = -1007,
    kCFURLErrorResourceUnavailable = -1008,
    kCFURLErrorNotConnectedToInternet = -1009,
    kCFURLErrorRedirectToNonExistentLocation = -1010,
    kCFURLErrorBadServerResponse = -1011,
    kCFURLErrorUserCancelledAuthentication = -1012,
    kCFURLErrorUserAuthenticationRequired = -1013,
    kCFURLErrorZeroByteResource = -1014,
    kCFURLErrorCannotDecodeRawData = -1015,
    kCFURLErrorCannotDecodeContentData = -1016,
    kCFURLErrorCannotParseResponse = -1017,
    kCFURLErrorInternationalRoamingOff = -1018,
    kCFURLErrorCallIsActive = -1019,
    kCFURLErrorDataNotAllowed = -1020,
    kCFURLErrorRequestBodyStreamExhausted = -1021,
    kCFURLErrorFileDoesNotExist = -1100,
    kCFURLErrorFileIsDirectory = -1101,
    kCFURLErrorNoPermissionsToReadFile = -1102,
    kCFURLErrorDataLengthExceedsMaximum = -1103,
    kCFURLErrorSecureConnectionFailed = -1200,
    kCFURLErrorServerCertificateHasBadDate = -1201,
    kCFURLErrorServerCertificateUntrusted = -1202,
    kCFURLErrorServerCertificateHasUnknownRoot = -1203,
    kCFURLErrorServerCertificateNotYetValid = -1204,
    kCFURLErrorClientCertificateRejected = -1205,
    kCFURLErrorClientCertificateRequired = -1206,
    kCFURLErrorCannotLoadFromNetwork = -2000,
    kCFURLErrorCannotCreateFile = -3000,
    kCFURLErrorCannotOpenFile = -3001,
    kCFURLErrorCannotCloseFile = -3002,
    kCFURLErrorCannotWriteToFile = -3003,
    kCFURLErrorCannotRemoveFile = -3004,
    kCFURLErrorCannotMoveFile = -3005,
    kCFURLErrorDownloadDecodingFailedMidStream = -3006,
    kCFURLErrorDownloadDecodingFailedToComplete = -3007,
    kCFHTTPCookieCannotParseCookieFile = -4000,
    kCFNetServiceErrorUnknown = -72000L,
    kCFNetServiceErrorCollision = -72001L,
    kCFNetServiceErrorNotFound = -72002L,
    kCFNetServiceErrorInProgress = -72003L,
    kCFNetServiceErrorBadArgument = -72004L,
    kCFNetServiceErrorCancel = -72005L,
    kCFNetServiceErrorInvalid = -72006L,
    kCFNetServiceErrorTimeout = -72007L,
    kCFNetServiceErrorDNSServiceFailure = -73000L 
} CFNetworkErrors;

extern const CFStringRef kCFURLErrorFailingURLErrorKey;
extern const CFStringRef kCFURLErrorFailingURLStringErrorKey;
extern const CFStringRef kCFGetAddrInfoFailureKey;
extern const CFStringRef kCFSOCKSStatusCodeKey;
extern const CFStringRef kCFSOCKSVersionKey;
extern const CFStringRef kCFSOCKSNegotiationMethodKey;
extern const CFStringRef kCFDNSServiceFailureKey;
extern const CFStringRef kCFFTPStatusCodeKey;
    
#ifdef __cplusplus
}
#endif

#endif /* _CFNETWORKERRORS_H_ */
