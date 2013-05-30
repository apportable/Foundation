//
// CFBundle.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFBUNDLE_H_
#define _CFBUNDLE_H_

typedef struct __NSBundle *CFBundleRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFURL.h>
#import <CoreFoundation/CFArray.h>
#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFError.h>
#import <CoreFoundation/CFPlugIn.h>

CF_EXPORT const CFStringRef kCFBundleNameKey;
CF_EXPORT const CFStringRef kCFBundleVersionKey;
CF_EXPORT const CFStringRef kCFBundleIdentifierKey;
CF_EXPORT const CFStringRef kCFBundleInfoDictionaryVersionKey;
CF_EXPORT const CFStringRef kCFBundleLocalizationsKey;
CF_EXPORT const CFStringRef kCFBundleExecutableKey;
CF_EXPORT const CFStringRef kCFBundleDevelopmentRegionKey;

CF_EXPORT CFTypeID CFBundleGetTypeID(void);

CF_EXPORT CFBundleRef CFBundleGetMainBundle(void);
CF_EXPORT CFArrayRef CFBundleGetAllBundles(void);
CF_EXPORT CFStringRef CFCopyLocalizedString(CFStringRef key, const char *comment);
CF_EXPORT CFStringRef CFCopyLocalizedStringFromTable(CFStringRef key, CFStringRef tableName, const char *comment);

CF_EXPORT CFBundleRef CFBundleCreate(CFAllocatorRef allocator, CFURLRef bundleURL);
CF_EXPORT CFArrayRef CFBundleCreateBundlesFromDirectory(CFAllocatorRef allocator, CFURLRef directoryURL, CFStringRef bundleType);

CF_EXPORT CFURLRef CFBundleCopyAuxiliaryExecutableURL(CFBundleRef self, CFStringRef executableName);
CF_EXPORT CFURLRef CFBundleCopyBuiltInPlugInsURL(CFBundleRef self);
CF_EXPORT CFArrayRef CFBundleCopyBundleLocalizations(CFBundleRef self);
CF_EXPORT CFURLRef CFBundleCopyBundleURL(CFBundleRef self);
CF_EXPORT CFArrayRef CFBundleCopyExecutableArchitectures(CFBundleRef self);
CF_EXPORT CFArrayRef CFBundleCopyExecutableArchitecturesForURL(CFURLRef url);
CF_EXPORT CFURLRef CFBundleCopyExecutableURL(CFBundleRef self);
CF_EXPORT CFDictionaryRef CFBundleCopyInfoDictionaryForURL(CFURLRef url);
CF_EXPORT CFDictionaryRef CFBundleCopyInfoDictionaryInDirectory(CFURLRef bundleURL);
CF_EXPORT CFArrayRef CFBundleCopyLocalizationsForPreferences(CFArrayRef locArray, CFArrayRef prefArray);
CF_EXPORT CFArrayRef CFBundleCopyLocalizationsForURL(CFURLRef url);
CF_EXPORT CFStringRef CFBundleCopyLocalizedString(CFBundleRef self, CFStringRef key, CFStringRef value, CFStringRef tableName);
CF_EXPORT CFArrayRef CFBundleCopyPreferredLocalizationsFromArray(CFArrayRef locArray);
CF_EXPORT CFURLRef CFBundleCopyPrivateFrameworksURL(CFBundleRef self);

CF_EXPORT CFURLRef CFBundleCopyResourcesDirectoryURL(CFBundleRef self);
CF_EXPORT CFURLRef CFBundleCopyResourceURL(CFBundleRef self, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName);
CF_EXPORT CFURLRef CFBundleCopyResourceURLForLocalization(CFBundleRef self, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName, CFStringRef localizationName);
CF_EXPORT CFURLRef CFBundleCopyResourceURLInDirectory(CFURLRef bundleURL, CFStringRef resourceName, CFStringRef resourceType, CFStringRef subDirName);

CF_EXPORT CFArrayRef CFBundleCopyResourceURLsOfType(CFBundleRef self, CFStringRef resourceType, CFStringRef subDirName);
CF_EXPORT CFArrayRef CFBundleCopyResourceURLsOfTypeForLocalization(CFBundleRef self, CFStringRef resourceType, CFStringRef subDirName, CFStringRef localizationName);
CF_EXPORT CFArrayRef CFBundleCopyResourceURLsOfTypeInDirectory(CFURLRef bundleURL, CFStringRef resourceType, CFStringRef subDirName);
CF_EXPORT CFURLRef CFBundleCopySharedFrameworksURL(CFBundleRef self);
CF_EXPORT CFURLRef CFBundleCopySharedSupportURL(CFBundleRef self);
CF_EXPORT CFURLRef CFBundleCopySupportFilesDirectoryURL(CFBundleRef self);
CF_EXPORT CFBundleRef CFBundleGetBundleWithIdentifier(CFStringRef bundleID);
CF_EXPORT void * CFBundleGetDataPointerForName(CFBundleRef self, CFStringRef name);
CF_EXPORT void CFBundleGetDataPointersForNames(CFBundleRef self, CFArrayRef names, void *symbolTable[]);
CF_EXPORT CFStringRef CFBundleGetDevelopmentRegion(CFBundleRef self);
CF_EXPORT void * CFBundleGetFunctionPointerForName(CFBundleRef self, CFStringRef  name);
CF_EXPORT void CFBundleGetFunctionPointersForNames(CFBundleRef self, CFArrayRef names, void *functionTable[]);
CF_EXPORT CFStringRef CFBundleGetIdentifier(CFBundleRef self);
CF_EXPORT CFDictionaryRef CFBundleGetInfoDictionary(CFBundleRef self);
CF_EXPORT CFDictionaryRef CFBundleGetLocalInfoDictionary(CFBundleRef self);
CF_EXPORT void CFBundleGetPackageInfo(CFBundleRef self, CFUInteger *packageType, CFUInteger *packageCreator);
CF_EXPORT Boolean CFBundleGetPackageInfoInDirectory(CFURLRef url, CFUInteger *packageType, CFUInteger *packageCreator);
CF_EXPORT CFPlugInRef CFBundleGetPlugIn(CFBundleRef self);
CF_EXPORT CFTypeRef CFBundleGetValueForInfoDictionaryKey(CFBundleRef self, CFStringRef key);
CF_EXPORT CFUInteger CFBundleGetVersionNumber(CFBundleRef self);
CF_EXPORT Boolean CFBundleIsExecutableLoaded(CFBundleRef self);
CF_EXPORT Boolean CFBundleLoadExecutable(CFBundleRef self);
CF_EXPORT Boolean CFBundleLoadExecutableAndReturnError(CFBundleRef self, CFErrorRef *error);
CF_EXPORT Boolean CFBundlePreflightExecutable(CFBundleRef self, CFErrorRef *error);
CF_EXPORT void CFBundleUnloadExecutable(CFBundleRef self);
CF_EXPORT CFStringRef CFCopyLocalizedStringFromTableInBundle(CFStringRef key, CFStringRef tableName, CFBundleRef self, const char *comment);
CF_EXPORT CFStringRef CFCopyLocalizedStringWithDefaultValue(CFStringRef key, CFStringRef tableName, CFBundleRef self, CFStringRef value, const char *comment);

#endif /* _CFBUNDLE_H_ */
