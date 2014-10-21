
#import <CFNetwork/CFNetwork.h>
#import <Foundation/NSObjCRuntime.h>

@class NSString;

FOUNDATION_EXPORT NSString * const NSURLErrorDomain;
FOUNDATION_EXPORT NSString * const NSURLErrorFailingURLErrorKey;
FOUNDATION_EXPORT NSString * const NSURLErrorFailingURLStringErrorKey;
FOUNDATION_EXPORT NSString * const NSErrorFailingURLStringKey;
FOUNDATION_EXPORT NSString * const NSURLErrorFailingURLPeerTrustErrorKey;

enum {
    NSURLErrorUnknown                          = -1,
    NSURLErrorCancelled                        = kCFURLErrorCancelled,
    NSURLErrorBadURL                           = kCFURLErrorBadURL,
    NSURLErrorTimedOut                         = kCFURLErrorTimedOut,
    NSURLErrorUnsupportedURL                   = kCFURLErrorUnsupportedURL,
    NSURLErrorCannotFindHost                   = kCFURLErrorCannotFindHost,
    NSURLErrorCannotConnectToHost              = kCFURLErrorCannotConnectToHost,
    NSURLErrorNetworkConnectionLost            = kCFURLErrorNetworkConnectionLost,
    NSURLErrorDNSLookupFailed                  = kCFURLErrorDNSLookupFailed,
    NSURLErrorHTTPTooManyRedirects             = kCFURLErrorHTTPTooManyRedirects,
    NSURLErrorResourceUnavailable              = kCFURLErrorResourceUnavailable,
    NSURLErrorNotConnectedToInternet           = kCFURLErrorNotConnectedToInternet,
    NSURLErrorRedirectToNonExistentLocation    = kCFURLErrorRedirectToNonExistentLocation,
    NSURLErrorBadServerResponse                = kCFURLErrorBadServerResponse,
    NSURLErrorUserCancelledAuthentication      = kCFURLErrorUserCancelledAuthentication,
    NSURLErrorUserAuthenticationRequired       = kCFURLErrorUserAuthenticationRequired,
    NSURLErrorZeroByteResource                 = kCFURLErrorZeroByteResource,
    NSURLErrorCannotDecodeRawData              = kCFURLErrorCannotDecodeRawData,
    NSURLErrorCannotDecodeContentData          = kCFURLErrorCannotDecodeContentData,
    NSURLErrorCannotParseResponse              = kCFURLErrorCannotParseResponse,
    NSURLErrorFileDoesNotExist                 = kCFURLErrorFileDoesNotExist,
    NSURLErrorFileIsDirectory                  = kCFURLErrorFileIsDirectory,
    NSURLErrorNoPermissionsToReadFile          = kCFURLErrorNoPermissionsToReadFile,
    NSURLErrorDataLengthExceedsMaximum         = kCFURLErrorDataLengthExceedsMaximum,
    NSURLErrorSecureConnectionFailed           = kCFURLErrorSecureConnectionFailed,
    NSURLErrorServerCertificateHasBadDate      = kCFURLErrorServerCertificateHasBadDate,
    NSURLErrorServerCertificateUntrusted       = kCFURLErrorServerCertificateUntrusted,
    NSURLErrorServerCertificateHasUnknownRoot  = kCFURLErrorServerCertificateHasUnknownRoot,
    NSURLErrorServerCertificateNotYetValid     = kCFURLErrorServerCertificateNotYetValid,
    NSURLErrorClientCertificateRejected        = kCFURLErrorClientCertificateRejected,
    NSURLErrorClientCertificateRequired        = kCFURLErrorClientCertificateRequired,
    NSURLErrorCannotLoadFromNetwork            = kCFURLErrorCannotLoadFromNetwork,
    NSURLErrorCannotCreateFile                 = kCFURLErrorCannotCreateFile,
    NSURLErrorCannotOpenFile                   = kCFURLErrorCannotOpenFile,
    NSURLErrorCannotCloseFile                  = kCFURLErrorCannotCloseFile,
    NSURLErrorCannotWriteToFile                = kCFURLErrorCannotWriteToFile,
    NSURLErrorCannotRemoveFile                 = kCFURLErrorCannotRemoveFile,
    NSURLErrorCannotMoveFile                   = kCFURLErrorCannotMoveFile,
    NSURLErrorDownloadDecodingFailedMidStream  = kCFURLErrorDownloadDecodingFailedMidStream,
    NSURLErrorDownloadDecodingFailedToComplete = kCFURLErrorDownloadDecodingFailedToComplete,
    NSURLErrorInternationalRoamingOff          = kCFURLErrorInternationalRoamingOff,
    NSURLErrorCallIsActive                     = kCFURLErrorCallIsActive,
    NSURLErrorDataNotAllowed                   = kCFURLErrorDataNotAllowed,
    NSURLErrorRequestBodyStreamExhausted       = kCFURLErrorRequestBodyStreamExhausted,
};
