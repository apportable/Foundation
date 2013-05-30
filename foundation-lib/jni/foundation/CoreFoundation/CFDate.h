//
// CFDate.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFDATE_H_
#define _CFDATE_H_

#import <CoreFoundation/CFBase.h>

typedef double CFTimeInterval;
typedef CFTimeInterval CFAbsoluteTime;

CF_EXPORT CFAbsoluteTime CFAbsoluteTimeGetCurrent();

#endif /* _CFDATE_H_ */
