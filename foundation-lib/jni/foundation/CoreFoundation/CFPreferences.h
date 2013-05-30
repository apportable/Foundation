//
// CFPreferences.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFPREFERENCES_H_
#define _CFPREFERENCES_H_

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFPropertyList.h>

CF_EXPORT const CFStringRef kCFPreferencesCurrentApplication;
CF_EXPORT const CFStringRef kCFPreferencesCurrentHost;
CF_EXPORT const CFStringRef kCFPreferencesCurrentUser;

CF_EXPORT const CFStringRef kCFPreferencesAnyApplication;
CF_EXPORT const CFStringRef kCFPreferencesAnyHost;
CF_EXPORT const CFStringRef kCFPreferencesAnyUser;

CF_EXPORT void CFPreferencesAddSuitePreferencesToApp(CFStringRef application, CFStringRef suite);
CF_EXPORT Boolean CFPreferencesAppSynchronize(CFStringRef application);
CF_EXPORT Boolean CFPreferencesAppValueIsForced(CFStringRef key, CFStringRef application);

CF_EXPORT CFArrayRef CFPreferencesCopyApplicationList(CFStringRef user, CFStringRef host);
CF_EXPORT CFPropertyListRef CFPreferencesCopyAppValue(CFStringRef key, CFStringRef application);
CF_EXPORT Boolean CFPreferencesGetAppBooleanValue(CFStringRef key, CFStringRef application, Boolean *validKey);
CF_EXPORT CFIndex CFPreferencesGetAppIntegerValue(CFStringRef key, CFStringRef application, Boolean *validKey);

CF_EXPORT CFArrayRef CFPreferencesCopyKeyList(CFStringRef application, CFStringRef user, CFStringRef host);
CF_EXPORT CFDictionaryRef CFPreferencesCopyMultiple(CFArrayRef keysToFetch, CFStringRef application, CFStringRef user, CFStringRef host);
CF_EXPORT CFPropertyListRef CFPreferencesCopyValue(CFStringRef key, CFStringRef application, CFStringRef user, CFStringRef host);
CF_EXPORT void CFPreferencesSetAppValue(CFStringRef key, CFPropertyListRef value, CFStringRef application);
CF_EXPORT void CFPreferencesSetMultiple(CFDictionaryRef dictionary, CFArrayRef removeTheseKeys, CFStringRef application, CFStringRef user, CFStringRef host);
CF_EXPORT void CFPreferencesSetValue(CFStringRef key, CFPropertyListRef value, CFStringRef application, CFStringRef user, CFStringRef host);

CF_EXPORT void CFPreferencesRemoveSuitePreferencesFromApp(CFStringRef application, CFStringRef suite);
CF_EXPORT Boolean CFPreferencesSynchronize(CFStringRef application, CFStringRef user, CFStringRef host);

#endif /* _CFPREFERENCES_H_ */
