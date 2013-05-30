/*
 * Copyright (c) 2002-2010 Apple Inc. All Rights Reserved.
 * 
 * @APPLE_LICENSE_HEADER_START@
 * 
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 * 
 * @APPLE_LICENSE_HEADER_END@
 */

/*!
    @header SecTrust
    The functions and data types in SecTrust implement trust computation
    and allow the user to apply trust decisions to the trust configuration.
*/

#ifndef _SECURITY_SECTRUST_H_
#define _SECURITY_SECTRUST_H_

#include <Security/SecBase.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFData.h>
#include <CoreFoundation/CFDate.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
    @typedef SecTrustResultType
    @abstract Specifies the trust result type.
    @discussion SecTrustResultType results have two dimensions.  They specify
    both whether evaluation suceeded and whether this is because of a user
    decision.  In practice the commonly expected result is kSecTrustResultUnspecified, 
    which indicates a positive result that wasn't decided by the user.  The
    common failure is kSecTrustResultRecoverableTrustFailure, which means a
    negative result.  kSecTrustResultProceed and kSecTrustResultDeny are the
    positive and negative result respectively when decided by the user.  User
    decisions are persisted through the use of SecTrustCopyExceptions() and
    SecTrustSetExceptions().  Finally kSecTrustResultFatalTrustFailure is a
    negative result that should not be circumvented.  In fact only in the case
    of kSecTrustResultRecoverableTrustFailure should a user ever be asked.
    @constant kSecTrustResultInvalid Indicates an invalid setting or result.
    @constant kSecTrustResultProceed Indicates you may proceed.  This value
    may be returned by the SecTrustEvaluate function or stored as part of
    the user trust settings. 
    @constant kSecTrustResultConfirm Indicates confirmation with the user
    is required before proceeding.  This value may be returned by the
    SecTrustEvaluate function or stored as part of the user trust settings. 
    @constant kSecTrustResultDeny Indicates a user-configured deny; do not
    proceed. This value may be returned by the SecTrustEvaluate function
    or stored as part of the user trust settings. 
    @constant kSecTrustResultUnspecified Indicates user intent is unknown.
    This value may be returned by the SecTrustEvaluate function or stored
    as part of the user trust settings. 
    @constant kSecTrustResultRecoverableTrustFailure Indicates a trust
    framework failure; retry after fixing inputs. This value may be returned
    by the SecTrustEvaluate function but not stored as part of the user
    trust settings. 
    @constant kSecTrustResultFatalTrustFailure Indicates a trust framework
    failure; no "easy" fix. This value may be returned by the
    SecTrustEvaluate function but not stored as part of the user trust
    settings.
    @constant kSecTrustResultOtherError Indicates a failure other than that
    of trust evaluation. This value may be returned by the SecTrustEvaluate
    function but not stored as part of the user trust settings.
 */
typedef UInt32 SecTrustResultType;
enum {
    kSecTrustResultInvalid,
    kSecTrustResultProceed,
    kSecTrustResultConfirm,
    kSecTrustResultDeny,
    kSecTrustResultUnspecified,
    kSecTrustResultRecoverableTrustFailure,
    kSecTrustResultFatalTrustFailure,
    kSecTrustResultOtherError
};


/*!
    @typedef SecTrustRef
    @abstract CFType used for performing X.509 certificate trust evaluations.
*/
typedef struct __SecTrust *SecTrustRef;

/*!
    @function SecTrustGetTypeID
    @abstract Returns the type identifier of SecTrust instances.
    @result The CFTypeID of SecTrust instances.
*/
CFTypeID SecTrustGetTypeID(void);

/*!
    @function SecTrustCreateWithCertificates
    @abstract Creates a trust object based on the given certificates and
    policies.
    @param certificates The group of certificates to verify.  This can either
    be a CFArrayRef of SecCertificateRef objects or a single SecCertificateRef
    @param policies An array of one or more policies. You may pass a
    SecPolicyRef to represent a single policy.
    @param trust On return, a pointer to the trust management reference.
    @result A result code.  See "Security Error Codes" (SecBase.h).
    @discussion If multiple policies are passed in, all policies must verify
    for the chain to be considered valid.
*/
OSStatus SecTrustCreateWithCertificates(CFTypeRef certificates,
    CFTypeRef policies, SecTrustRef *trust);

/*!
    @function SecTrustSetAnchorCertificates
    @abstract Sets the anchor certificates for a given trust.
    @param trust A reference to a trust object.
    @param anchorCertificates An array of anchor certificates.
    @result A result code.  See "Security Error Codes" (SecBase.h).
    @discussion Calling this function without also calling
    SecTrustSetAnchorCertificatesOnly() will disable trusting any
    anchors other than the ones in anchorCertificates.
*/
OSStatus SecTrustSetAnchorCertificates(SecTrustRef trust,
    CFArrayRef anchorCertificates);

/*!
    @function SecTrustSetAnchorCertificatesOnly
    @abstract Reenables trusting anchor certificates in addition to those
    passed in via the SecTrustSetAnchorCertificates API.
    @param trust A reference to a trust object.
    @param anchorCertificatesOnly If true, disables trusting any anchors other
    than the ones passed in via SecTrustSetAnchorCertificates().  If false,
    the built in anchor certificates are also trusted.
    @result A result code.  See "Security Error Codes" (SecBase.h).
*/
OSStatus SecTrustSetAnchorCertificatesOnly(SecTrustRef trust,
    Boolean anchorCertificatesOnly);

/*!
    @function SecTrustGetVerifyTime
    @abstract Returns the verify time.
    @param trust A reference to the trust object to verify.
    @result A CFAbsoluteTime value representing the time at which certificates
    should be checked for validity.
*/
CFAbsoluteTime SecTrustGetVerifyTime(SecTrustRef trust);

/*!
    @function SecTrustEvaluate
    @abstract Evaluates a trust.
    @param trust A reference to the trust object to evaluate.
    @param result A pointer to a result type.
    @result A result code.  See "Security Error Codes" (SecBase.h). 
*/
OSStatus SecTrustEvaluate(SecTrustRef trust, SecTrustResultType *result);

/*!
    @function SecTrustCopyPublicKey
    @abstract Return the public key for a leaf certificate after it has 
    been evaluated.
    @param trust A reference to the trust object which has been evaluated.
    @result The certificate's public key, or NULL if it the public key could
    not be extracted (this can happen with DSA certificate chains if the
        parameters in the chain cannot be found).  The caller is responsible
        for calling CFRelease on the returned key when it is no longer needed.
*/
SecKeyRef SecTrustCopyPublicKey(SecTrustRef trust);

/*!
    @function SecTrustGetCertificateCount
    @abstract Returns the number of certificates in an evaluated certificate
    chain.
    @param trust Reference to a trust object.
    @result The number of certificates in the trust chain.  This function will
    return 1 if the trust has not been evaluated, and the number of
    certificates in the chain including the anchor if it has.
*/
CFIndex SecTrustGetCertificateCount(SecTrustRef trust);

/*!
    @function SecTrustGetCertificateAtIndex
    @abstract Returns a certificate from the trust chain.
    @param trust Reference to a trust object.
    @param ix The index of the requested certificate.  Indices run from 0
    (leaf) to the anchor (or last certificate found if no anchor was found).
    The leaf cert (index 0) is always present regardless of whether the trust
    reference has been evaluated or not.
    @result A SecCertificateRef for the requested certificate.
*/
SecCertificateRef SecTrustGetCertificateAtIndex(SecTrustRef trust, CFIndex ix);

/*!
    @function SecTrustCopyExceptions
    @abstract Returns an opauqe cookie which will allow future evaluations
    of the current certificate to succeed.
    @param trust A reference to an evaluated trust object.
    @result An opaque cookie which when passed to SecTrustSetExceptions() will
    cause a call to SecTrustEvaluate() return kSecTrustResultProceed.  This
    will happen upon subsequent evaluation of the current certificate unless
    some new error starts happening that wasn't being reported when the cookie
    was returned from this function, for example if the certificate expires
    evaluation will start failing again.
    @discussion Normally this API should only be called once the errors have
    been presented to the user and the user decided to trust the current
    certificate chain regardless of the errors being presented, for the
    current application/server/protocol/etc.
*/
CFDataRef SecTrustCopyExceptions(SecTrustRef trust);

/*!
    @function SecTrustSetExceptions
    @abstract Set a trust cookie to be used for evaluating this certificate chain.
    @param trust A reference to an not yet evaluated trust object.
    @param exceptions An exceptions cookie as returned by a call to
    SecTrustCopyExceptions() in the past.
    @result Upon calling SecTrustEvaluate(), any failures that where present at the
    time the exceptions object was created are ignored, and instead of returning
    kSecTrustResultRecoverableTrustFailure, kSecTrustResultProceed will be returned
    (if the certificate for which exceptions was created matches the current leaf
    certificate).
    @discussion Clients of this interface will need to establish the context of this
    exception to later decide when this exception cookie is to be used.
    Examples of elements of this context would be the server we are connecting to, the
    ssid of the network this cert is for the account for which this cert should be
    considered valid, etc.
    @result true if the exceptions cookies was valid and matches the current leaf
    certificate, false otherwise.  Note that this function returning true doesn't
    mean the caller can skip calling SecTrustEvaluate(), as something could have
    changed causing the evaluation to fail after all.
*/
bool SecTrustSetExceptions(SecTrustRef trust, CFDataRef exceptions);

#if defined(__cplusplus)
}
#endif

#endif /* !_SECURITY_SECTRUST_H_ */
