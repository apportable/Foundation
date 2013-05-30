//
// CFPlugIn.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFPLUGIN_H_
#define _CFPLUGIN_H_

typedef struct __CFPlugIn *CFPlugInRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFUUID.h>
#import <CoreFoundation/CFBundle.h>

typedef void (*CFPlugInDynamicRegisterFunction)(CFPlugInRef self);
typedef void *(*CFPlugInFactoryFunction)(CFAllocatorRef allocator, CFUUIDRef type);
typedef void (*CFPlugInUnloadFunction)(CFPlugInRef self);

CF_EXPORT const CFStringRef kCFPlugInDynamicRegistrationKey;
CF_EXPORT const CFStringRef kCFPlugInDynamicRegisterFunctionKey;
CF_EXPORT const CFStringRef kCFPlugInUnloadFunctionKey;
CF_EXPORT const CFStringRef kCFPlugInFactoriesKey;
CF_EXPORT const CFStringRef kCFPlugInTypesKey;

CF_EXPORT CFTypeID CFPlugInGetTypeID(void);

CF_EXPORT Boolean CFPlugInRegisterPlugInType(CFUUIDRef factory, CFUUIDRef type);
CF_EXPORT Boolean CFPlugInUnregisterFactory(CFUUIDRef factory);
CF_EXPORT void CFPlugInAddInstanceForFactory(CFUUIDRef factory);
CF_EXPORT CFArrayRef CFPlugInFindFactoriesForPlugInType(CFUUIDRef type);
CF_EXPORT CFArrayRef CFPlugInFindFactoriesForPlugInTypeInPlugIn(CFUUIDRef type, CFPlugInRef self);
CF_EXPORT void *CFPlugInInstanceCreate(CFAllocatorRef allocator, CFUUIDRef factory, CFUUIDRef type);
CF_EXPORT Boolean CFPlugInRegisterFactoryFunction(CFUUIDRef factory, CFPlugInFactoryFunction function);
CF_EXPORT Boolean CFPlugInRegisterFactoryFunctionByName(CFUUIDRef factory, CFPlugInRef self, CFStringRef name);
CF_EXPORT void CFPlugInRemoveInstanceForFactory(CFUUIDRef factory);
CF_EXPORT Boolean CFPlugInUnregisterPlugInType(CFUUIDRef factory, CFUUIDRef type);


CF_EXPORT CFPlugInRef CFPlugInCreate(CFAllocatorRef allocator, CFURLRef url);

CF_EXPORT CFBundleRef CFPlugInGetBundle(CFPlugInRef self);
CF_EXPORT Boolean CFPlugInIsLoadOnDemand(CFPlugInRef self);
CF_EXPORT void CFPlugInSetLoadOnDemand(CFPlugInRef self, Boolean flag);

#endif /* _CFPLUGIN_H_ */
