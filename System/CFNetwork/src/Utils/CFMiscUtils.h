#ifndef __CFMISCUTILS__
#define __CFMISCUTILS__

#define PARCEL_SET_URL(parcel, source, name) \
    { \
        CFPropertyListRef source__ = source; \
        if (source__) { \
            CFURLRef absoluteURL__ = CFURLCopyAbsoluteURL(source__); \
            CFDictionarySetValue(parcel, CFSTR(name), CFURLGetString(absoluteURL__)); \
            CFRelease(absoluteURL__); \
        } \
    }

#define PARCEL_GET_URL(parcel, target, name) \
    { \
        CFTypeRef item__ = CFDictionaryGetValue(parcel, CFSTR(name)); \
        if (item__ && CFGetTypeID(item__) == CFStringGetTypeID()) { \
            target = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)item__, NULL); \
        } \
    }

#define PARCEL_SET_OBJECT(parcel, source, name) \
    { \
        CFPropertyListRef source__ = source; \
        if (source__) { \
            CFDictionarySetValue(parcel, CFSTR(name), source__); \
        } \
    }

#define PARCEL_GET_RETAINED_OBJECT(parcel, typeTag, target, name) \
    { \
        CFTypeRef item__ = CFDictionaryGetValue(parcel, CFSTR(name)); \
        if (item__ && CFGetTypeID(item__) == typeTag##GetTypeID()) { \
            target = (typeTag##Ref)CFRetain(item__); \
        } \
    }

#define PARCEL_SET_NUMBER(parcel, typeTag, type, source, name) \
    { \
        type source__ = source; \
        CFNumberRef value__ = CFNumberCreate( \
            kCFAllocatorDefault, \
            kCFNumber##typeTag##Type, &source__); \
        CFDictionarySetValue(parcel, CFSTR(name), value__); \
        CFRelease(value__); \
    }

#define PARCEL_GET_NUMBER(parcel, typeTag, type, target, name) \
    { \
        CFTypeRef item__ = CFDictionaryGetValue(parcel, CFSTR(name)); \
        if (item__ && CFGetTypeID(item__) == CFNumberGetTypeID()) { \
            type value__; \
            CFNumberGetValue((CFNumberRef)item__, kCFNumber##typeTag##Type, &value__); \
            target = (__typeof(target))value__; \
        } \
    }

#define PARCEL_SET_BOOL(parcel, source, name) \
    PARCEL_SET_NUMBER(parcel, SInt8, SInt8, source, name)

#define PARCEL_GET_BOOL(parcel, target, name) \
    PARCEL_GET_NUMBER(parcel, SInt8, SInt8, target, name)

#define PARCEL_SET_ENUM(parcel, target, name) \
    PARCEL_SET_NUMBER(parcel, Int, int, target, name)

#define PARCEL_GET_ENUM(parcel, source, name) \
    PARCEL_GET_NUMBER(parcel, Int, int, source, name)

#define PARCEL_SET_TIME(parcel, source, name) \
    PARCEL_SET_NUMBER(parcel, Double, double, source, name)

#define PARCEL_GET_TIME(parcel, source, name) \
    PARCEL_GET_NUMBER(parcel, Double, double, source, name)

#define PARCEL_SET_CFINDEX(parcel, source, name) \
    PARCEL_SET_NUMBER(parcel, CFIndex, CFIndex, source, name)

#define PARCEL_GET_CFINDEX(parcel, source, name) \
    PARCEL_GET_NUMBER(parcel, CFIndex, CFIndex, source, name)

#endif // __CFMISCUTILS__
