//
//  Security.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _SECURITY_H_
#define _SECURITY_H_

#include <Security/SecBase.h>
#include <Security/SecRandom.h>
#include <Security/SecKey.h>
#include <Security/SecItem.h>
#include <Security/SecTrust.h>
#include <Security/SecCertificate.h>
#include <Security/SecPolicy.h>

extern CFTypeRef kSecValueData;
extern CFTypeRef kSecValueRef;
extern CFTypeRef kSecValuePersistentRef;
extern CFTypeRef kSecClassGenericPassword;
extern CFTypeRef kSecAttrGeneric;
extern CFTypeRef kSecAttrAccount;
extern CFTypeRef kSecAttrService;
extern CFTypeRef kSecMatchLimitOne;
extern CFTypeRef kSecMatchLimitAll;
extern CFTypeRef kSecMatchLimit;
extern CFTypeRef kSecClass;

extern CFTypeRef kSecAttrLabel;

extern CFTypeRef kSecReturnAttributes;
extern CFTypeRef kSecAttrDescription;
extern CFTypeRef kSecReturnData;
extern CFTypeRef kSecAttrAccessGroup;

extern CFTypeRef kSecAttrServer;
extern CFTypeRef kSecAttrAuthenticationTypeDefault;

extern CFTypeRef kSecAttrSecurityDomain;

extern CFTypeRef kSecClassInternetPassword;

extern CFTypeRef kSecAttrAccessible;

extern CFTypeRef kSecAttrAccessibleWhenUnlocked;

extern CFTypeRef kSecAttrAccessibleWhenUnlockedThisDeviceOnly;

extern CFTypeRef kSecAttrAuthenticationType;

extern CFTypeRef kSecReturnPersistentRef;

extern CFTypeRef kSecAttrType;



OSStatus SecItemAdd (CFDictionaryRef attributes,CFTypeRef *result);
OSStatus SecItemCopyMatching (CFDictionaryRef query, CFTypeRef *result);
OSStatus SecItemDelete (CFDictionaryRef query);
OSStatus SecItemUpdate (CFDictionaryRef query, CFDictionaryRef attributesToUpdate);

#endif /* _SECURITY_H_ */
