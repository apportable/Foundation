//
//  CFHTTPCookie.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFHTTPCookie.h"
#include "CFNumber.h"
#include <unicode/uregex.h>
#include <assert.h>

static const CFStringRef kCFHTTPCookieName = CFSTR("Name");
static const CFStringRef kCFHTTPCookieValue = CFSTR("Value");
static const CFStringRef kCFHTTPCookieOriginURL = CFSTR("OriginURL");
static const CFStringRef kCFHTTPCookieVersion = CFSTR("Version");
static const CFStringRef kCFHTTPCookieDomain = CFSTR("Domain");
static const CFStringRef kCFHTTPCookiePath = CFSTR("Path");
static const CFStringRef kCFHTTPCookieSecure = CFSTR("Secure");
static const CFStringRef kCFHTTPCookieExpires = CFSTR("Expires");
static const CFStringRef kCFHTTPCookieComment = CFSTR("Comment");
static const CFStringRef kCFHTTPCookieCommentURL = CFSTR("CommentURL");
static const CFStringRef kCFHTTPCookieDiscard = CFSTR("Discard");
static const CFStringRef kCFHTTPCookieMaximumAge = CFSTR("Max-Age");
static const CFStringRef kCFHTTPCookiePort = CFSTR("Port");
static const CFStringRef kCFHTTPCookieHTTPOnly = CFSTR("HTTPOnly");

struct __CFHTTPCookie {
    CFRuntimeBase _base;
    CFDictionaryRef _properties;
    CFStringRef _domain;
};

static void __CFHTTPCookieDeallocate(CFTypeRef cf) {
    struct __CFHTTPCookie *item = (struct __CFHTTPCookie *)cf;
    CFRelease(item->_properties);
}

static CFTypeID __kCFHTTPCookieTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFHTTPCookieClass = {
    _kCFRuntimeScannedObject,
    "CFHTTPCookie",
    NULL,   // init
    NULL,   // copy
    __CFHTTPCookieDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static void __CFHTTPCookieInitialize(void) {
    __kCFHTTPCookieTypeID = _CFRuntimeRegisterClass(&__CFHTTPCookieClass);
}

CFTypeID CFHTTPCookieGetTypeID(void) {
    if (__kCFHTTPCookieTypeID == _kCFRuntimeNotATypeID) {
        __CFHTTPCookieInitialize();
    }
    return __kCFHTTPCookieTypeID;
}

CFHTTPCookieRef _CFHTTPCookieCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFHTTPCookie) - sizeof(CFRuntimeBase);
    return (CFHTTPCookieRef)_CFRuntimeCreateInstance(allocator, CFHTTPCookieGetTypeID(), size, NULL);
}

CFHTTPCookieRef CFHTTPCookieCreateWithProperties(CFDictionaryRef properties) {
    CFHTTPCookieRef cookie = _CFHTTPCookieCreate(kCFAllocatorDefault);
    cookie->_properties = CFRetain(CFDictionaryCreateCopy(kCFAllocatorDefault, properties));
    if (CFHTTPCookieGetDomain(cookie)==NULL||CFHTTPCookieGetPath(cookie)==NULL) {
        CFRelease(cookie);
        cookie = NULL;
    }
    
    return cookie;
}
CFNumberRef CFHTTPCookieGetVersion(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieVersion);
}

CFStringRef CFHTTPCookieGetName(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieName);
}

CFStringRef CFHTTPCookieGetDomain(CFHTTPCookieRef cookie) {
    if (cookie->_domain == NULL) {
        cookie->_domain = CFStringCreateCopy(kCFAllocatorDefault, CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieDomain));
        
        if (cookie->_domain == NULL) {
            CFTypeRef urlString = CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieOriginURL);
            if (urlString != NULL) {
                CFURLRef url = NULL;
                
                if (CFGetTypeID(urlString)==CFStringGetTypeID()) {
                    url = CFURLCreateWithString(kCFAllocatorDefault, urlString, NULL);
                } else {
                    url = CFRetain(urlString);
                }
                cookie->_domain = CFURLCopyHostName(url);
                
                CFRelease(url);
            }
        }
    }
    
    return cookie->_domain;
}


CFDateRef CFHTTPCookieGetExpirationDate(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieExpires);
}

CFStringRef CFHTTPCookieGetPath(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookiePath);
}

CFStringRef CFHTTPCookieGetValue(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieValue);
}


CFStringRef CFHTTPCookieGetComment(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieComment);
}

CFURLRef CFHTTPCookieGetCommentURL(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieCommentURL);
}

CFArrayRef CFHTTPCookieGetPortArray(CFHTTPCookieRef cookie) {
    return CFDictionaryGetValue(cookie->_properties, kCFHTTPCookiePort);
}



Boolean CFHTTPCookieIsSecure(CFHTTPCookieRef cookie) {
    return CFBooleanGetValue(CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieSecure));
}

Boolean CFHTTPCookieIsHTTPOnly(CFHTTPCookieRef cookie) {
    return CFBooleanGetValue(CFDictionaryGetValue(cookie->_properties, kCFHTTPCookieHTTPOnly));
}


Boolean CFHTTPCookieIsSessionOnly(CFHTTPCookieRef cookie) {
    return 0; //fixme
}

CFDictionaryRef CFHTTPCookieCopyProperties(CFHTTPCookieRef cookie) {
    return CFDictionaryCreateCopy(kCFAllocatorDefault, cookie->_properties);
}


CFDictionaryRef CFHTTPCookieCopyRequestHeaderFields(CFArrayRef cookies) {
    if (CFArrayGetCount(cookies)>0) {
        CFMutableStringRef resultCookieString = CFStringCreateMutable(kCFAllocatorDefault, 4*1024*1024);
        for (int i=0; i<CFArrayGetCount(cookies); i++) {
            if (i>0) {
                CFStringAppend(resultCookieString, CFSTR("; "));
            }
            
            CFHTTPCookieRef cookie = (CFHTTPCookieRef)CFArrayGetValueAtIndex(cookies, i);
            CFStringRef name = CFHTTPCookieGetName(cookie);
            CFStringRef value = CFHTTPCookieGetValue(cookie);
            CFStringAppendFormat(resultCookieString, NULL, CFSTR("%@=%@"), name, value);
            
        }
  
        CFStringRef cookieString = CFStringCreateCopy(kCFAllocatorDefault, resultCookieString);
        CFRelease(resultCookieString);
        const void *keys[] =   { CFSTR("Cookie")};
        const void *values[] = { cookieString };
        
        
        CFDictionaryRef result = CFDictionaryCreate(NULL, keys, values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFRelease(cookieString);
        return result;
    } else {
        return nil;
    }

}


CFArrayRef CFHTTPCookieCreateWithResponseHeaderFields(CFDictionaryRef headerFields, CFURLRef url) {
    CFStringRef cookieString = CFDictionaryGetValue(headerFields, CFSTR("Set-Cookie"));
    if (cookieString!=NULL) {
        
        UErrorCode status = U_ZERO_ERROR;
        UParseError parse_err = { 0 };
        //fixme. regex parsing is evil. adopt parsing algorithm from firefox or from somewhere
        
        CFStringRef pattern = CFSTR("(.*?)(=(.*?))?($|;|,(?! [1-9][0-9])) *");
        
        Boolean patNeedsFree = false;
        const UChar *pat =  CFStringGetCharactersPtr(pattern);

        CFIndex patLen = CFStringGetLength(pattern);
        if (pat == NULL)
        {
            pat = malloc(sizeof(UChar) * patLen);
            CFStringGetCharacters(pattern, CFRangeMake(0, patLen), (UChar*)pat);
            patNeedsFree = true;
        }

        URegularExpression *pExpr = uregex_open((const UChar *)pat, patLen, 0, &parse_err, &status);
            
        assert(U_SUCCESS(status));
        
        /* Configure the text that the regular expression operates on. */
        
        const UChar *text =  CFStringGetCharactersPtr(cookieString);
        Boolean needsFree = false;
        CFIndex len = CFStringGetLength(cookieString);
        if (text == NULL)
        {
            text = malloc(sizeof(UChar) * len);
            CFStringGetCharacters(cookieString, CFRangeMake(0, len), (UChar*)text);
            needsFree = true;
        }
        
        uregex_setText(pExpr, text, len, &status);
        assert(U_SUCCESS(status));

        
        /* Attempt the match */
        UBool res = uregex_findNext(pExpr, &status);
        
        CFStringRef path = NULL;
        CFMutableDictionaryRef cookiesNamesValues = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        while (res) {
            int64_t nameStart = uregex_start64(pExpr, 1, &status);
            int64_t nameEnd = uregex_end64(pExpr, 1, &status);
            int64_t valueStart = uregex_start64(pExpr, 3, &status);
            int64_t valueEnd = uregex_end64(pExpr, 3, &status);
            CFStringRef name = CFStringCreateWithSubstring(kCFAllocatorDefault, cookieString, CFRangeMake(nameStart, nameEnd-nameStart));
            CFStringRef value = CFStringCreateWithSubstring(kCFAllocatorDefault, cookieString, CFRangeMake(valueStart, valueEnd-valueStart));
            //fixme: apply to last cookie only
            if (CFStringCompare(name, CFSTR("path"), kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
                path = CFStringCreateCopy(kCFAllocatorDefault, value);
            } else if (CFStringCompare(name, CFSTR("domain"), kCFCompareCaseInsensitive)==kCFCompareEqualTo)  {
            } else if (CFStringCompare(name, CFSTR("expires"), kCFCompareCaseInsensitive)==kCFCompareEqualTo)  {
            } else if (CFStringCompare(name, CFSTR("httponly"), kCFCompareCaseInsensitive)==kCFCompareEqualTo)  {
            } else if (CFStringCompare(name, CFSTR("secure"), kCFCompareCaseInsensitive)==kCFCompareEqualTo)  {
            } else if (value != NULL && CFStringGetLength(name)>0){
                CFDictionarySetValue(cookiesNamesValues, name, value);
            }
            
            CFRelease(name);
            CFRelease(value);
            
            
            res = uregex_findNext(pExpr, &status);
        }
        if (path==NULL) {
            path = CFSTR("/");
        }
        
        CFMutableArrayRef mutableResult = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        
        CFTypeRef names[CFDictionaryGetCount(cookiesNamesValues)];
        CFTypeRef values[CFDictionaryGetCount(cookiesNamesValues)];
        CFDictionaryGetKeysAndValues(cookiesNamesValues, names, values);
        for (int i=0; i<CFDictionaryGetCount(cookiesNamesValues); i++) {
            CFTypeRef propertyKeys[] = {kCFHTTPCookieName, kCFHTTPCookieValue, kCFHTTPCookieOriginURL, kCFHTTPCookiePath};
            CFTypeRef propertyValues[] = {names[i], values[i], url, path};
            
            CFDictionaryRef properties = CFDictionaryCreate(kCFAllocatorDefault, propertyKeys, propertyValues, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            
            CFHTTPCookieRef cookie = CFHTTPCookieCreateWithProperties(properties);
            CFRelease(properties);
            CFArrayAppendValue(mutableResult, cookie);
            CFRelease(cookie);
            
        }
        CFRelease(path);
        
        
        
        CFRelease(cookiesNamesValues);
        
        assert(U_SUCCESS(status));

        
        
        
        
        uregex_close(pExpr);
        if (needsFree)
        {
            free((UChar *)text);
        }
        if (patNeedsFree)
        {
            free((UChar *)pat);
        }
        
        /*
        
        NSMutableDictionary *cookiesKeyValue = [NSMutableDictionary dictionary];
        __block NSString *path = @"/";
        
        [regex enumerateMatchesInString:cookieString options:0 range:NSMakeRange(0, cookieString.length) usingBlock:^(NSTextCheckingResult *checkingResult, NSMatchingFlags flags, BOOL *stop) {
         NSString *name = [cookieString substringWithRange:[checkingResult rangeAtIndex:1]];
         NSString *value = [cookieString substringWithRange:[checkingResult rangeAtIndex:2]];
         if ([name isEqual:@"Path"]) {
         path = value;
         } else {
         [cookiesKeyValue setObject:value forKey:name];
         }
         }];
        
        [cookiesKeyValue enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:@{NSHTTPCookieName: key, NSHTTPCookieValue:obj, NSHTTPCookieOriginURL:URL, NSHTTPCookiePath: path}];
         [result addObject:cookie];
         }];*/
        
        CFArrayRef result = CFArrayCreateCopy(kCFAllocatorDefault, mutableResult);
        CFRelease(mutableResult);
        return result;
    } else {
        return NULL;
    }

}
