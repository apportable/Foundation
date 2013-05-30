//
// CoreFoundation
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//
// Permission is hereby granted,free of charge,to any person obtaining a 
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction,including without limitation 
// the rights to use,copy,modify,merge,publish,distribute,sublicense,and/or 
// sell copies of the Software,and to permit persons to whom the Software 
// is furnished to do so,subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS",WITHOUT WARRANTY OF ANY KIND,EXPRESS OR 
// IMPLIED,INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,DAMAGES OR OTHER 
// LIABILITY,WHETHER IN AN ACTION OF CONTRACT,TORT OR OTHERWISE,ARISING 
// FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
// IN THE SOFTWARE.
//

#include <math.h>
#include <assert.h>
#include <inttypes.h>
#include <stdbool.h>
#include <time.h>
#include <float.h>
#include <pthread.h>

#import <CoreFoundation/CFArray.h>
#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFBag.h>
#import <CoreFoundation/CFBundle.h>
#import <CoreFoundation/CFByteOrder.h>
#import <CoreFoundation/CFCalendar.h>
#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFDate.h>
#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFNumber.h>
#import <CoreFoundation/CFNumberFormatter.h>
#import <CoreFoundation/CFSet.h>
#import <CoreFoundation/CFString.h>
#import <CoreFoundation/CFRunLoop.h>
#import <CoreFoundation/CFURL.h>
#import <CoreFoundation/CFUUID.h>
#import <CoreFoundation/CFString.h>
#import <CoreFoundation/CFLocale.h>
#import <CoreFoundation/CFCharacterSet.h>
#import <CoreFoundation/CFStream.h>
#import <CoreFoundation/CFBinaryHeap.h>
#import <CoreFoundation/CFPreferences.h>
#import <CoreFoundation/CFPropertyList.h>
#import <CoreFoundation/CFFileDescriptor.h>
#import <CoreFoundation/CFNotificationCenter.h>
