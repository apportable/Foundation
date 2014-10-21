/*
 * Copyright (c) 1998-2003 Apple Computer, Inc. All Rights Reserved.
 * 
 * The contents of this file constitute Original Code as defined in and are
 * subject to the Apple Public Source License Version 1.2 (the 'License').
 * You may not use this file except in compliance with the License. Please 
 * obtain a copy of the License at http://www.apple.com/publicsource and 
 * read it before using this file.
 * 
 * This Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER 
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES, 
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. 
 * Please see the License for the specific language governing rights and 
 * limitations under the License.
 *
 * cuEnc64.h - encode/decode in 64-char IA5 format, per RFC 1421
 */

#ifndef _CU_ENC64_H_
#define _CU_ENC64_H_

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Given input buffer inbuf, length inlen, decode from 64-char IA5 format to
 * binary. Result is malloced and returned; its length is returned in *outlen.
 * NULL return indicates corrupted input.
 */
unsigned char *cuEnc64(const unsigned char *inbuf,
    unsigned inlen,
    unsigned *outlen);      // RETURNED

/*
 * Enc64, with embedded newlines every lineLen in result. A newline is
 * the UNIX \n. Result is mallocd.
 */
unsigned char *cuEnc64WithLines(const unsigned char *inbuf,
    unsigned inlen,
    unsigned linelen,
    unsigned *outlen);      // RETURNED

/*
 * Given input buffer inbuf, length inlen, decode from 64-char IA5 format to
 * binary. Result is malloced and returned; its length is returned in *outlen.
 * NULL return indicates corrupted input. All whitespace in inbuf is
 * ignored.
 */
unsigned char *cuDec64(const unsigned char *inbuf,
    unsigned inlen,
    unsigned *outlen);

/*
 * Determine if specified input data is valid enc64 format. Returns 1
 * if valid, 0 if not.
 */
int cuIsValidEnc64(const unsigned char *inbuf,
    unsigned inbufLen);

#ifdef __cplusplus
}
#endif

#endif  /*_CU_ENC64_H_*/
