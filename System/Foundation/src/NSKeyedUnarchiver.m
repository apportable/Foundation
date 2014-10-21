//
//  NSKeyedUnarchiver.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSKeyedArchiver.h>
#import "NSArchiver.h"
#import <Foundation/NSArray.h>
#import "NSCoderInternal.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSException.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSURL.h>
#import "NSTemporaryDirectory.h"
#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFNumber.h>
#import <CoreFoundation/CFStream.h>
#import "ForFoundationOnly.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
#import <stdlib.h>

static NSMutableDictionary *archiverClasses = nil;

NSString *const NSInvalidUnarchiveOperationException = @"NSInvalidUnarchiveOperationException";

@interface _NSKeyedUnarchiverHelper : NSObject
{
@public
    NSArray *_white;
    NSUInteger _lastRef;
    NSMutableArray *_allowedClasses;
}
- (BOOL)classNameAllowed:(Class)class;
- (void)setAllowedClassNames:(NSArray *)classNames;
- (NSArray *)allowedClassNames;
- (void)dealloc;
- (id)init;
@end

@implementation _NSKeyedUnarchiverHelper

- (void)dealloc
{
    if (_white != nil)
    {
        [_white release];
    }
    [_allowedClasses release];

    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _allowedClasses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)classNameAllowed:(Class)class
{
    if (_white == nil)
    {
        return YES;
    }

    while (class != Nil)
    {
        NSString *className = NSStringFromClass(class);
        if ([_white containsObject:className])
        {
            return YES;
        }
        class = class_getSuperclass(class);
    }

    return NO;
}

- (void)setAllowedClassNames:(NSArray *)classNames
{
    if (_white == classNames)
    {
        return;
    }
    if (_white != nil)
    {
        [_white release];
    }
    _white = [classNames copy];
}

- (NSArray *)allowedClassNames
{
    return [[_white retain] autorelease];
}

@end

typedef struct {
    CFBinaryPlistTrailer trailer;
    uint64_t offset;
    uint64_t valueOffset;
} offsetDataStruct;

@implementation NSKeyedUnarchiver {
    id<NSKeyedUnarchiverDelegate> _delegate;
    unsigned int _flags;
    CFMutableDictionaryRef _objRefMap;
    id _replacementMap;
    CFMutableDictionaryRef _nameClassMap;
    CFMutableDictionaryRef _tmpRefObjMap;
    CFMutableDictionaryRef _refObjMap;
    int _genericKey;
    CFDataRef _data;
    offsetDataStruct *_offsetData;  // trailer info
    CFMutableArrayRef _containers;  // for xml unarchives
    CFArrayRef _objects;            // for xml unarchives
    const char *_bytes;
    unsigned long long _len;
    _NSKeyedUnarchiverHelper *_helper;
    CFMutableDictionaryRef _reservedDictionary;
}

static NSString *unescapeKey(NSString *key)
{
    if (key == nil)
    {
        return nil;
    }

    if ([key length] == 0)
    {
        return key;
    }

    if ([key characterAtIndex:0] == '$')
    {
        return [key substringFromIndex:1];
    }

    return key;
}

static NSString *freshGenericKey(NSKeyedUnarchiver *unarchiver)
{
    NSUInteger key = unarchiver->_genericKey++;
    return [NSString stringWithFormat:@"$%d", key];
}

static BOOL raiseIfFinished(NSKeyedUnarchiver *unarchiver)
{
    if ((unarchiver->_flags & NSArchiverFinished) != 0)
    {
        [NSException raise:NSInvalidUnarchiveOperationException format:@"Tried to decode after unarchiver has completed"];
        return YES;
    }
    return NO;
}

// get int value and update buffer pointer 
static int64_t _getInt(uint8_t **ptrptr)
{
    uint8_t *ptr = *ptrptr;
    uint8_t encodeKey = *ptr++;
    if (encodeKey == kCFBinaryPlistMarkerInt)
    {
        *ptrptr += 2;
        return *ptr;
    }
    if (encodeKey == (kCFBinaryPlistMarkerInt | 1))
    {
        *ptrptr += 3;
        return ((*ptr << 8) + *(ptr + 1));
    }
    if (encodeKey == (kCFBinaryPlistMarkerInt | 2))
    {
        *ptrptr += 5;
        return ((*ptr << 24) + (*(ptr + 1) << 16) + (*(ptr + 2) << 8) + *(ptr + 3));
    }
    if  (encodeKey == (kCFBinaryPlistMarkerInt | 3)) {  // long long encoding, including all negative values
        *ptrptr += 9;
        int64_t acc = 0;
        for (int i = 0; i < 8; i++)
        {
            acc <<= 8;
            acc += ptr[i];
        }
        return acc;
    }
    DEBUG_BREAK();  // unrecognized key
    return 0;
}

static BOOL _getOffsetForNestedValueWrap(NSKeyedUnarchiver *unarchiver, NSString *key, uint64_t offset, uint64_t *offsetPtr)
{
    return __CFBinaryPlistGetOffsetForValueFromDictionary3(unarchiver->_bytes, unarchiver->_len, offset, 
        &unarchiver->_offsetData->trailer, key, NULL, offsetPtr, NO, unarchiver->_reservedDictionary);
}

static BOOL _getOffsetForValueWrap(NSKeyedUnarchiver *unarchiver, NSString *key, uint64_t *offsetPtr)
{
    return _getOffsetForNestedValueWrap(unarchiver, key, unarchiver->_offsetData->offset, offsetPtr);
}

static inline id getXMLVal(NSKeyedUnarchiver *unarchiver, NSString *key)
{
    CFDictionaryRef dict = CFArrayGetValueAtIndex(unarchiver->_containers, CFArrayGetCount(unarchiver->_containers) - 1);
    if (CFGetTypeID(dict) == CFArrayGetTypeID())
    {
        id uid = (id)CFArrayGetValueAtIndex((CFArrayRef)dict, 0);
        uid = [[uid retain] autorelease];
        CFArrayRemoveValueAtIndex((CFMutableArrayRef)dict, 0);
        return uid;
    }
    id val = (id)CFDictionaryGetValue(dict, key);
    return [[val retain] autorelease];
}

static int64_t _decodeInt(NSKeyedUnarchiver *unarchiver, NSString *key)
{
    if (unarchiver->_containers)
    {
        // XML
        id val = getXMLVal(unarchiver, key);
        int64_t intVal = -1;
        if (val == nil)
        {
            return 0;
        }
        if (CFGetTypeID(val) != CFNumberGetTypeID())
        {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Did not find number for key %@", key];
            return 0;
        }
        if (CFNumberIsFloatType((CFNumberRef)val))
        {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Expected an integer, not a float, for key %@", key];
            return 0;
        }
        if (!CFNumberGetValue((CFNumberRef)val, kCFNumberSInt64Type, &intVal))
        {
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Did not find value for key %@", key] userInfo:nil];
        }
        return intVal;
    }
    uint64_t voffset;
    if (!_getOffsetForValueWrap(unarchiver, key, &voffset))
    {
        return 0; // Does not distinguish failure from return 0 !
    }
    uint8_t *ptr = (uint8_t *)(unarchiver->_bytes + voffset);
    return _getInt(&ptr);
}


static BOOL _decodeBool(NSKeyedUnarchiver *unarchiver, NSString *key)
{
    if (unarchiver->_containers)
    {
        // XML
        id val = getXMLVal(unarchiver, key);
        if (val == nil)
        {
            return NO;
        }
        if (CFGetTypeID(val) != CFBooleanGetTypeID())
        {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Did not find bool value for key %@", key];
            return 0;
        }
        return CFBooleanGetValue((CFBooleanRef)val);
    }

    uint64_t voffset;
    if (!_getOffsetForValueWrap(unarchiver, key, &voffset))
    {
        return NO; // Does not distinguish failure from return NO !
    }
    uint8_t encodedVal = *(uint8_t *)(unarchiver->_bytes + voffset);
    if (encodedVal == kCFBinaryPlistMarkerTrue)
    {
        return YES;
    }
    else if (encodedVal == kCFBinaryPlistMarkerFalse)
    {
        return NO;
    }
    DEBUG_BREAK();  // Should never get here
    return NO;
}

static double _decodeDouble(NSKeyedUnarchiver *unarchiver, NSString *key)
{
    if (unarchiver->_containers)
    {
        // XML
        id val = getXMLVal(unarchiver, key);
        if (val == nil)
        {
            return 0;
        }
        if (CFGetTypeID(val) != CFNumberGetTypeID())
        {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Did not find number for key %@", key];
            return 0;
        }
        if (!CFNumberIsFloatType((CFNumberRef)val))
        {
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Did not find floating point typed number for key %@", key];
            return 0;
        }
        double doubleVal = -1.0;
        if (!CFNumberGetValue((CFNumberRef)val, kCFNumberFloat64Type, &doubleVal))
        {
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Did not find value for key %@", key] userInfo:nil];
        }
        return doubleVal;
    }
    uint64_t voffset;
    if (!_getOffsetForValueWrap(unarchiver, key, &voffset))
    {
        return 0.0; // Does not distinguish failure from return NO !
    }
    uint8_t *ptr = (uint8_t *)(unarchiver->_bytes + voffset);
    if (*ptr == kCFBinaryPlistMarkerReal + 3) // 8 byte float encoding
    {
        CFSwappedFloat64 swapped64;
        memmove(&swapped64, ptr + 1, 8);
        return CFConvertFloat64SwappedToHost(swapped64);
    }
    if (*ptr == kCFBinaryPlistMarkerReal + 2) // 4 byte float encoding
    {
        CFSwappedFloat32 swapped32;
        memmove(&swapped32, ptr + 1, 4);
        return (double)CFConvertFloat32SwappedToHost(swapped32);
    }
    DEBUG_BREAK(); // Should never get here
    return 0.0;
}

static const uint8_t *_decodeBytes(NSKeyedUnarchiver *unarchiver, NSString * key, NSUInteger *lenPtr)
{
    if (unarchiver->_containers)
    {
        // XML
        id val = getXMLVal(unarchiver, key);
        if (val == nil)
        {
            return NULL;
        }
        CFTypeID typeID = CFGetTypeID(val);
        if (typeID == CFStringGetTypeID() && CFEqual(val, @"$null"))
        {
            return nil;
        }
        if (typeID != CFDataGetTypeID())
        {
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Did not find byte array for key %@", key] userInfo:nil];
            return NULL;
        }
        *lenPtr = CFDataGetLength((CFDataRef)val);
        return CFDataGetBytePtr((CFDataRef)val);
    }
    uint64_t voffset;
    if (!_getOffsetForValueWrap(unarchiver, key, &voffset))
    {
        return NULL; // Does not distinguish failure from return NO !
    }
    uint8_t *ptr = (uint8_t *)(unarchiver->_bytes + voffset);
    uint8_t encodeKey = *ptr++;

    if ((encodeKey & 0xf0) == kCFBinaryPlistMarkerASCIIString)
    {
        CFPropertyListRef string;
        if (!__CFBinaryPlistCreateObject(unarchiver->_bytes, unarchiver->_len, voffset, &unarchiver->_offsetData->trailer, NULL, 0, unarchiver->_reservedDictionary, &string) ||
            string == nil)
        {
            return nil; // bad encoding
        }
        if (CFEqual(@"$null", string))
        {
            return nil;
        }
        DEBUG_BREAK(); // $null should be the only string (kCFBinaryPlistMarkerASCIIString) possible here
    }
    else if ((encodeKey & 0xf0) == kCFBinaryPlistMarkerData)
    {
        *lenPtr = encodeKey & 0xf;
        if (*lenPtr != 0xf)
        {
            return ptr;
        }
        else // If longer than 14, decode int for length
        {
            *lenPtr = (int)_getInt(&ptr);
            return ptr;
        }
    }
    DEBUG_BREAK(); // Should never get here
    return NULL;
}

static uint64_t _getSizedInt(const uint8_t *data, uint8_t valSize) {
#if defined(__i386__) || defined(__x86_64__)
    if (valSize == 1) {
        return (uint64_t)*data;
    } else if (valSize == 2) {
        uint16_t val = *(uint16_t *)data;
        return (uint64_t)CFSwapInt16BigToHost(val);
    } else if (valSize == 4) {
        uint32_t val = *(uint32_t *)data;
        return (uint64_t)CFSwapInt32BigToHost(val);
    } else if (valSize == 8) {
        uint64_t val = *(uint64_t *)data;
        return CFSwapInt64BigToHost(val);
    }
#endif
    // Compatability with existing archives, including anything with a non-power-of-2 
    // size and 16-byte values, and architectures that don't support unaligned access
    uint64_t res = 0;
    for (CFIndex idx = 0; idx < valSize; idx++) {
        res = (res << 8) + data[idx];
    }
    return res;
}

static BOOL _getUIDFromData(uint8_t *ptr, NSUInteger *returnVal)
{
    if ((*ptr & 0xf0) != kCFBinaryPlistMarkerUID)
    {
        return NO;
    }
    NSUInteger cnt = (*ptr & 0xf) + 1;

    uint64_t bigint = _getSizedInt(++ptr, cnt);
    if (UINT32_MAX < bigint) 
    {
        return NO;
    }
    *returnVal = (NSUInteger)bigint;
    return YES;
}

static id _decodeObjectBinary(NSKeyedUnarchiver *unarchiver, NSUInteger uid1) NS_RETURNS_RETAINED
{
    uint64_t voffset = unarchiver->_offsetData->valueOffset;
    @autoreleasepool {
        id mapObject = nil;
        if (CFDictionaryGetValueIfPresent(unarchiver->_refObjMap, (const void *)uid1, (const void **)&mapObject) ||
            CFDictionaryGetValueIfPresent(unarchiver->_tmpRefObjMap, (const void *)uid1, (const void **)&mapObject))
        {
            // break infinite recursion
            return [mapObject retain];
        }
        uint64_t nestOffset;
        if (!__CFBinaryPlistGetOffsetForValueFromArray2(unarchiver->_bytes, unarchiver->_len, voffset, &unarchiver->_offsetData->trailer, uid1, &nestOffset, unarchiver->_reservedDictionary))
        {
            return nil;
        }

        //
        uint8_t *ptr = (uint8_t *)(unarchiver->_bytes + nestOffset);
        uint8_t marker = *ptr++;
        uint8_t markerTag = (marker & 0xf0);

        if (marker == kCFBinaryPlistMarkerNull)
        {
            return nil;
        }
        else if (marker == kCFBinaryPlistMarkerTrue)
        {
            return (id)kCFBooleanTrue;
        }
        else if (marker == kCFBinaryPlistMarkerFalse)
        {
            return (id)kCFBooleanFalse;
        }
        else if (markerTag == kCFBinaryPlistMarkerASCIIString)
        {
            CFPropertyListRef string;
            if (!__CFBinaryPlistCreateObject(unarchiver->_bytes, unarchiver->_len, nestOffset, &unarchiver->_offsetData->trailer, NULL, 0, unarchiver->_reservedDictionary, &string) ||
                string == nil)
            {
                return nil;
            }
            if (CFEqual(@"$null", string))
            {
                return nil; // This is a success. nil is the correctly decoded value here.
            }
            return string;
        }
        else if (markerTag == kCFBinaryPlistMarkerInt || markerTag == kCFBinaryPlistMarkerReal || markerTag == kCFBinaryPlistMarkerData || markerTag == kCFBinaryPlistMarkerUnicode16String)
        {
            CFPropertyListRef obj = NULL;
            if (!__CFBinaryPlistCreateObject(unarchiver->_bytes, unarchiver->_len, nestOffset, &unarchiver->_offsetData->trailer, NULL, 0, unarchiver->_reservedDictionary, &obj))
            {
                return nil;
            }
            return obj;
        }
        else if (markerTag != kCFBinaryPlistMarkerDict)
        {
            RELEASE_LOG("Unimplemented marker 0x%x", markerTag);  // TODO https://code.google.com/p/apportable/issues/detail?id=153 
            return nil;
        }
        uint64_t doffset;
        if (!_getOffsetForNestedValueWrap(unarchiver, @"$class", nestOffset, &doffset))
        {
            return nil;
        }
        NSUInteger uid2;
        if (!_getUIDFromData((uint8_t *)(unarchiver->_bytes + doffset), &uid2))
        {
            return nil;
        }
        uint64_t classOffset;
        if (!__CFBinaryPlistGetOffsetForValueFromArray2(unarchiver->_bytes, unarchiver->_len, voffset, &unarchiver->_offsetData->trailer, uid2, &classOffset, unarchiver->_reservedDictionary))
        {
            return nil;
        }
        uint64_t voffset2;
        if (!_getOffsetForNestedValueWrap(unarchiver, @"$classname", classOffset, &voffset2))
        {
            return nil;
        }

        CFPropertyListRef className;
        if (!__CFBinaryPlistCreateObject(unarchiver->_bytes, unarchiver->_len, voffset2, &unarchiver->_offsetData->trailer, NULL, 0, unarchiver->_reservedDictionary, &className))
        {
            return nil;
        }
        uint64_t unused;
        if (_getOffsetForNestedValueWrap(unarchiver, @"$classhints", classOffset, &unused))
        {
            #warning TODO Unimplemented $classhints https://code.google.com/p/apportable/issues/detail?id=153
        }
        if (!_getOffsetForNestedValueWrap(unarchiver, @"$classes", classOffset, &unused))
        {
            return nil;
        }
        Class class = [unarchiver classForClassName:className];
        if (class == nil)
        {
            class = [[unarchiver class] classForClassName:className];
        }
        if (class == nil)
        {
            class = NSClassFromString(className);
        }
        if (class == nil)
        {
            return nil;
        }
#warning TODO implement classNameAllowed https://code.google.com/p/apportable/issues/detail?id=153
        // if (![helper classNameAllowed:class])
        // {
        //     return nil;
        // }
        class = [class classForKeyedUnarchiver];
        if (class == nil)
        {
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"No classForKeyedUnarchiver class:%@", className] userInfo:nil];
            return nil;
        }
        if (className != nil)
        {
            CFRelease(className); 
        }
        if ([unarchiver requiresSecureCoding])
        {
            DEBUG_BREAK();
            // TODO https://code.google.com/p/apportable/issues/detail?id=153
        }

        uint64_t pushOldOffset = unarchiver->_offsetData->offset;
        unarchiver->_offsetData->offset = nestOffset;

        id allocated = [class allocWithZone:nil];
        CFDictionarySetValue(unarchiver->_tmpRefObjMap, (const void *)uid1, allocated);
        id instance = [allocated initWithCoder:unarchiver];
        if (instance != nil)
        {
            instance = [instance awakeAfterUsingCoder:unarchiver];

            NSCAssert(instance != nil, @"object was replaced as nil from awakeAfterUsingCoder:");

            unarchiver->_offsetData->offset = pushOldOffset; // pop it back to handle multiple nested objects

            if (unarchiver->_delegate)
            {
#warning TODO implement delegate https://code.google.com/p/apportable/issues/detail?id=153
            }
#warning TODO implement _replaceObject https://code.google.com/p/apportable/issues/detail?id=153
            //        [unarchiver _replaceObject:instance withObject:instance];  // TODO

            CFDictionarySetValue(unarchiver->_objRefMap, (const void *)instance, (const void *)uid1);
            CFDictionarySetValue(unarchiver->_refObjMap, (const void *)uid1, instance);
        }
        CFDictionaryRemoveValue(unarchiver->_tmpRefObjMap, (const void *)uid1);
        return instance;
    }
}

static inline void deleteLastContainer(CFMutableArrayRef containers)
{
    uint32_t i = CFArrayGetCount(containers) - 1;
    const void *val = CFArrayGetValueAtIndex(containers, i);
    CFArrayRemoveValueAtIndex(containers, i);
    CFRelease(val);
}

static id _decodeObjectXML(NSKeyedUnarchiver *unarchiver, NSString *key)
{
    id val = getXMLVal(unarchiver, key);
    if (val == nil)
    {
        // Not an error condition for some reason?
        return nil;
    }
    if (CFGetTypeID(val) != _CFKeyedArchiverUIDGetTypeID())
    {
        @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Incorrect unarchiver object format"] userInfo:nil];
        return nil;
    }
    uint32_t uid = _CFKeyedArchiverUIDGetValue((CFKeyedArchiverUIDRef)val);
    if (uid == 0)
    {
        return nil;
    }

    id mapObject;
    if (CFDictionaryGetValueIfPresent(unarchiver->_refObjMap, (const void *)uid, (const void **)&mapObject) ||
        CFDictionaryGetValueIfPresent(unarchiver->_tmpRefObjMap, (const void *)uid, (const void **)&mapObject))
    {
        // break infinite recursion
        return [mapObject retain];
    }

    id obj = CFArrayGetValueAtIndex(unarchiver->_objects, uid);
    CFTypeID typeID = CFGetTypeID(obj);
    if (typeID == CFStringGetTypeID() && CFEqual(obj, @"$null"))
    {
        return nil;
    }
    if (typeID == CFStringGetTypeID() || typeID == CFNumberGetTypeID() || typeID == CFBooleanGetTypeID() || typeID == CFDataGetTypeID())
    {
        return [obj retain];
    }

    CFKeyedArchiverUIDRef keyedArchiverUID;
    if ((!(keyedArchiverUID = CFDictionaryGetValue((CFDictionaryRef)obj, @"$class"))) || CFGetTypeID(keyedArchiverUID) != _CFKeyedArchiverUIDGetTypeID())
    {
        @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Did not find $class in unarchiver"] userInfo:nil];
        return nil;
    }
    uint32_t innerUID = _CFKeyedArchiverUIDGetValue(keyedArchiverUID);
    CFDictionaryRef dict = CFArrayGetValueAtIndex(unarchiver->_objects, innerUID);
    NSString *className = (NSString *)CFDictionaryGetValue(dict, @"$classname");
    if (className == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Failed to find $classname"] userInfo:nil];
        return nil;
    }
    CFStringRef classHints = CFDictionaryGetValue(dict, @"$classhints");
    if (classHints != NULL)
    {
#warning TODO implement $classhints https://code.google.com/p/apportable/issues/detail?id=153
        RELEASE_LOG("Unimplemented classhints");
    }

    Class class = nil;
    if ((class = [unarchiver classForClassName:className]))
    {
#warning TODO implement classForClassNames https://code.google.com/p/apportable/issues/detail?id=153
        // TODO
    } 
    else if ((class = [[unarchiver class] classForClassName:className]))
    {
        // TODO
    }
    else
    {
        class = NSClassFromString(className);
    }
    if (class == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Failed to convert class %@ for %@", className, key] userInfo:nil];
        return nil;
    }
#warning TODO implement classNameAllowed https://code.google.com/p/apportable/issues/detail?id=153
    // if (![helper classNameAllowed:class])
    // {
    //     return nil;
    // }
    class = [class classForKeyedUnarchiver];
    if (class == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"No classForKeyedUnarchiver class:%@ key:%@", className, key] userInfo:nil];
        return nil;
    }
    CFRetain(obj);
    CFArrayAppendValue(unarchiver->_containers, obj);

    if ([unarchiver requiresSecureCoding])
    {
        DEBUG_BREAK();
#warning TODO requiresSecureCoding https://code.google.com/p/apportable/issues/detail?id=153
    }

    id allocated = [class allocWithZone:nil];
    CFDictionarySetValue(unarchiver->_tmpRefObjMap, (const void *)uid, allocated);
    id instance = [allocated initWithCoder:unarchiver];
    if (instance != nil)
    {
        instance = [instance awakeAfterUsingCoder:unarchiver];
        NSCAssert(instance != nil, @"object was replaced as nil from awakeAfterUsingCoder:");
        deleteLastContainer(unarchiver->_containers);

    #warning TODO flag update for arrays?   https://code.google.com/p/apportable/issues/detail?id=153
        // if (CFArrayCount(_containers) > 0)
        // {
        //     CFTypeRef cVal = CFArrayGetValueAtIndex(unarchiver->_containers, i - 1);
        //     if (CFGetTypeID(cVal) == CFArrayGetTypeID())
        //     {
        //         // TODO modify flags
        //         // Do something to _replacementMap
        //     }
        // }
        if (unarchiver->_delegate)
        {
#warning TODO implement delegate https://code.google.com/p/apportable/issues/detail?id=153
        }
#warning TODO implement _replaceObject https://code.google.com/p/apportable/issues/detail?id=153
    //        [unarchiver _replaceObject:instance withObject:instance];  // TODO
        CFDictionarySetValue(unarchiver->_objRefMap, (const void *)instance, (const void *)uid);
        CFDictionarySetValue(unarchiver->_refObjMap, (const void *)uid, instance);
    }

    CFDictionaryRemoveValue(unarchiver->_tmpRefObjMap, (const void *)uid);
    return instance;
}

static id _decodeObject(NSKeyedUnarchiver *unarchiver, NSString *key)
{
    if (unarchiver->_containers)
    {
        id xmlReturn;
        @autoreleasepool
        {
            xmlReturn = _decodeObjectXML(unarchiver, key);
        }
        return [xmlReturn autorelease];
    }
    uint64_t voffset;
    if (!_getOffsetForValueWrap(unarchiver, key, &voffset))
    {
        return nil;
    }

    NSUInteger uid1;
    if (!_getUIDFromData((uint8_t *)(unarchiver->_bytes + voffset), &uid1))
    {
        return nil;
    }
    id binaryReturn = nil;

    @autoreleasepool
    {
        binaryReturn = _decodeObjectBinary(unarchiver, uid1);
    }

    return [binaryReturn autorelease];
}

static void createArchiverClasses(void)
{
    static dispatch_once_t archiverClassesOnce = 0L;
    dispatch_once(&archiverClassesOnce, ^{
        archiverClasses = [[NSMutableDictionary alloc] init];
    });
}

static Class classForClassName(NSString *codedName)
{
    createArchiverClasses();
    Class cls = [archiverClasses objectForKey:codedName];

    if (cls == Nil)
    {
        cls = NSClassFromString(codedName);
    }

    return cls;
}

static void setClassForClassName(Class cls, NSString *codedName)
{
    createArchiverClasses();
    [archiverClasses setObject:cls forKey:codedName];
}

+ (Class)classForClassName:(NSString *)codedName
{
    return classForClassName(codedName);
}

+ (void)setClass:(Class)cls forClassName:(NSString *)codedName
{
    setClassForClassName(cls, codedName);
}

+ (id)unarchiveObjectWithData:(NSData *)data
{
    id obj = nil;
    @autoreleasepool {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        obj = [[unarchiver decodeObjectForKey:@"root"] retain];
        [unarchiver finishDecoding];
        [unarchiver release];
    }
    return [obj autorelease];
}

+ (id)unarchiveObjectWithFile:(NSString *)path
{
    id obj = nil;
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfMappedFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        obj = [[unarchiver decodeObjectForKey:@"root"] retain];
        [unarchiver finishDecoding];
        [unarchiver release];
    }
    return [obj autorelease];
}

+ (void)initialize
{
#warning TODO -- https://code.google.com/p/apportable/issues/detail?id=528
    //[NSKeyedArchiver setClassName:@"NSLocalTimeZone" forClass:NSClassFromString(@"__NSLocalTimeZone")];
}

- (id)initWithStream:(CFReadStreamRef)stream
{
    if (stream == nil || CFGetTypeID(stream) == CFReadStreamGetTypeID())
    {
        [NSException raise:NSInvalidArgumentException format:@"invalid stream"];
        [self release];
        return nil;
    }
    if (CFReadStreamGetStatus(stream) < kCFStreamStatusOpen)
    {
        [NSException raise:NSInvalidArgumentException format:@"stream is not open"];
        [self release];
        return nil;
    }
    CFIndex capacity = 1024;
    CFIndex length = 0;
    CFIndex amt = 0;
    UInt8 *buffer = malloc(capacity);
    if (buffer == NULL)
    {
        [self release];
        return nil;
    }
    do {
        if (capacity < 1024 + length)
        {
            capacity *= 2;
            UInt8 *newBuffer = realloc(buffer, capacity);
            if (newBuffer == NULL)
            {
                [self release];
                free(buffer);
                return nil;
            }
            buffer = newBuffer;
        }
        amt = CFReadStreamRead(stream, buffer + length, 1024);
        if (amt > 0)
        {
            length += amt;
        }
        else
        {
            if (amt < 0)
            {
                free(buffer);
                [self release];
                return nil;
            }
            break;
        }
    } while (amt > 0);
    NSData *data = [[NSData alloc] initWithBytesNoCopy:buffer length:length freeWhenDone:YES];
    self = [self initForReadingWithData:data];
    [data release];
    return self;
}

- (id)_initWithStream:(CFReadStreamRef)stream data:(NSData *)data topDict:(CFDictionaryRef)masterDictionary
{
    _nameClassMap = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    _objRefMap = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    _tmpRefObjMap = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, NULL);
    _refObjMap = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    return self;
}

- (id)initForReadingWithData:(NSData *)data
{
    if (data == nil)
    {
        [self release];
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        _helper = [[_NSKeyedUnarchiverHelper alloc] init];

        const uint8_t *bytePtr = CFDataGetBytePtr((CFDataRef)data);
        NSUInteger len = CFDataGetLength((CFDataRef)data);
        if (bytePtr == NULL || len == 0)
        {
            [self release];
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:@"Failed to open archive" userInfo:nil];
            return nil;
        }
        if (len <= strlen("<?xml version="))
        {
            [self release];
            return nil;
        }
        if (bytePtr[1] == '\v')
        {
            // TODO
            [self release];
            return nil;
        }

        uint8_t marker;
        CFBinaryPlistTrailer trailer;
        uint64_t offset;
        if (!__CFBinaryPlistGetTopLevelInfo(bytePtr, len, &marker, &offset, &trailer))
        {
            //handle XML list
            CFPropertyListRef plist = CFPropertyListCreateWithData(kCFAllocatorSystemDefault, (CFDataRef)data, kCFPropertyListMutableContainers, NULL, NULL);
            if (plist == NULL)
            {
                [self release];
                return nil;
            }
            CFNumberRef version = CFDictionaryGetValue((CFDictionaryRef)plist, @"$version");

            int32_t intVal;
            if (version == NULL || CFGetTypeID(version) != CFNumberGetTypeID() || !CFNumberGetValue(version, kCFNumberSInt32Type, &intVal) || intVal != NSKeyedArchiverPlistVersion)
            {
                CFRelease(plist);
                RELEASE_LOG("NSKeyedArchiver: Failed to open archive");
                [self release];
                return nil;
            }
            id top = CFDictionaryGetValue((CFDictionaryRef)plist, @"$top");
            _objects = CFDictionaryGetValue((CFDictionaryRef)plist, @"$objects");
            CFRetain(_objects);

            if (top == NULL || _objects == NULL)
            {
                [self release];
                @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:@"Improperly formatted archive" userInfo:nil];
                return nil;
            }
            _containers = CFArrayCreateMutable(NULL, 0, NULL);
            if (_containers == NULL)
            {
                // TODO error
                CFRelease(plist);
                [self release];
                return nil;
            }
            
            CFRetain(top);
            CFArrayAppendValue(_containers, top);

            [self _initWithStream:nil data:nil topDict:(CFDictionaryRef)plist];
            CFRelease(plist);
        }
        else
        {
            // Binary plist
            uint64_t voffset;
            CFPropertyListRef plist;

            if (!__CFBinaryPlistGetOffsetForValueFromDictionary3(bytePtr, len, offset, &trailer, @"$version", NULL, &voffset, NO, NULL) ||
                !__CFBinaryPlistCreateObject(bytePtr, len, voffset, &trailer, NULL, 0, NULL, &plist))
            {
                [self release];
                return nil;
            }
            [(id)plist autorelease];
            int32_t intVal;
            if (CFGetTypeID(plist) != CFNumberGetTypeID() || !CFNumberGetValue((CFNumberRef)plist, kCFNumberSInt32Type, &intVal) || intVal != NSKeyedArchiverPlistVersion)
            {
                [self release];
                return nil;
            }

            _offsetData = (offsetDataStruct *)malloc(sizeof(offsetDataStruct));
            memcpy(_offsetData, &trailer, sizeof(CFBinaryPlistTrailer));

            if (!__CFBinaryPlistGetOffsetForValueFromDictionary3(bytePtr, len, offset, &trailer, @"$top", NULL, &_offsetData->offset, NO, NULL))
            {
                [self release];
                return nil;
            }
            if (!__CFBinaryPlistGetOffsetForValueFromDictionary3(bytePtr, len, offset, &trailer, @"$objects", NULL, &_offsetData->valueOffset, NO, NULL))
            {
                [self release];
                return nil;
            }

            _data = CFRetain(data);
            _bytes = bytePtr;
            _len = len;

            _nameClassMap = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            _objRefMap = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
            _tmpRefObjMap = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, NULL);
            _refObjMap = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
            _reservedDictionary = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        }
    }
    return self;
}

- (id)init
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot use -init on %@", [self class]];
    [self release];
    return nil;
}

- (void)dealloc
{
    [_helper release];
    if (_offsetData) {
        free(_offsetData); //CFBinaryPlistTrailers are not CFTypes.
    }
    if (_data) {
        CFRelease(_data);
    }
    if (_nameClassMap) {
        CFRelease(_nameClassMap);
    }
    if (_objRefMap) {
        CFRelease(_objRefMap);
    }
    if (_tmpRefObjMap) {
        CFRelease(_tmpRefObjMap);
    }
    if (_reservedDictionary) {
        CFRelease(_reservedDictionary);
    }
    if (_containers) {
        CFIndex count = CFArrayGetCount(_containers);
        for (int i = 0; i < count; i++)
        {
            const void *val = CFArrayGetValueAtIndex(_containers, i);
            CFRelease(val);
        }
        CFRelease(_containers);
    }
    if (_objects) {
        CFRelease(_objects);
    }
    if (_refObjMap) {
        CFRelease(_refObjMap);
    }

    [super dealloc];
}

- (NSUInteger)systemVersion
{
    return NSKeyedArchiverSystemVersion;
}

- (NSInteger)versionForClassName:(NSString *)className
{
#warning TODO implement versionForClassName: // TODO https://code.google.com/p/apportable/issues/detail?id=153 
    DEBUG_BREAK();
    return 0;
}

- (void)decodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(void *)array
{
    if (raiseIfFinished(self))
    {
        return;
    }
    if (type == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL type"];
        return;
    }
    if (array == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL array"];
        return;
    }
    if (count == 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Zero count"];
        return;
    }

    switch (*type)
    {
        case _C_STRUCT_B:
        case _C_UNION_B:
        case _C_ARY_B:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported type"];
            return;

        default:
        {
            id objects = [self decodeObject];
            if (![objects isKindOfClass:[_NSKeyedCoderOldStyleArray class]])
            {
                [NSException raise:NSInvalidUnarchiveOperationException format:@"Decoded object was not an array of objects"];
                return;
            }
            [objects fillObjCType:*type count:count at:array];
        }
    }
}

- (void)decodeValueOfObjCType:(const char *)type at:(void *)addr
{
    if (raiseIfFinished(self))
    {
        return;
    }
    if (type == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL type"];
        return;
    }
    if (addr == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL address"];
        return;
    }

    switch (*type)
    {
        case _C_CLASS:
        {
            id className = _decodeObject(self, freshGenericKey(self));
            Class class = NSClassFromString((NSString *)className);
            *(Class *)addr = class;
            break;
        }

        case _C_ID:
        {
            id object = _decodeObject(self, freshGenericKey(self));
            *(id *)addr = object;
            break;
        }

        case _C_SEL:
        {
            id selectorName = _decodeObject(self, freshGenericKey(self));
            SEL selector = NSSelectorFromString((NSString *)selectorName);
            *(SEL *)addr = selector;
            break;
        }

        case _C_CHARPTR:
        case _C_ATOM:
        {
            id string = _decodeObject(self, freshGenericKey(self));
            const char *cString = [(NSString *)string UTF8String];
            *(const char **)addr = cString;
            break;
        }

        case _C_CHR:
        case _C_UCHR:
        {
            *(char *)addr = (char)_decodeInt(self, freshGenericKey(self));
            break;
        }

        case _C_SHT:
        case _C_USHT:
        {
            *(short *)addr = (short)_decodeInt(self, freshGenericKey(self));
            break;
        }

        case _C_INT:
        case _C_UINT:
        {
            *(int *)addr = (int)_decodeInt(self, freshGenericKey(self));
            break;
        }

        case _C_LNG:
        case _C_ULNG:
        {
            *(long *)addr = (long)_decodeInt(self, freshGenericKey(self));
            break;
        }

        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        {
            *(long long *)addr = (long long)_decodeInt(self, freshGenericKey(self));
            break;
        }

        case _C_FLT:
        {
            *(float *)addr = (float)_decodeDouble(self, freshGenericKey(self));
            break;
        }

        case _C_DBL:
        {
            *(double *)addr = _decodeDouble(self, freshGenericKey(self));
            break;
        }

        case _C_ARY_B:
        {
            char *elementType = NULL;
            NSUInteger count = strtol(type + 1, &elementType, 10);
            if (*elementType == ']')
            {
                [NSException raise:NSInvalidArgumentException format:@"Malformed array type encoding"];
                return;
            }

            [self decodeArrayOfObjCType:elementType count:count at:addr];

            break;
        }

        case _C_STRUCT_B:
        case _C_UNION_B:
        default:
        {
            [NSException raise:NSInvalidArgumentException format:@"Unsupported type: %c", *type];
            return;
        }
    }
}

- (void)decodeValuesOfObjCTypes:(const char *)types, ...
{
    va_list addrs;
    va_start(addrs, types);

    while (*types)
    {
        void *addr = va_arg(addrs, void *);
        [self decodeValueOfObjCType:types at:addr];
        // Note that this method only supports primitive types, so we
        // can simply increment the pointer, as all allowed types have
        // one character encodings.
        types++;
    }

    va_end(addrs);
}

- (void *)decodeBytesWithReturnedLength:(NSUInteger *)len
{
#warning TODO
    DEBUG_BREAK();
    return NULL;
}

- (NSData *)decodeDataObject
{
    return [self decodeObject];
}

- (id)decodeObject
{
    return _decodeObject(self, freshGenericKey(self));
}

- (unsigned int)_currentUniqueIdentifier
{
#warning TODO
    DEBUG_BREAK();
    return 0;
}

- (id)_decodePropertyListForKey:(NSString *)key
{
    id obj = nil;
    if (_containers)
    {
        CFIndex count = CFArrayGetCount(_containers);
        CFTypeRef last = (CFTypeRef)CFArrayGetValueAtIndex(_containers, count - 1);
        CFTypeID type = CFGetTypeID(last);
        if (type == CFArrayGetTypeID())
        {
            obj = [[(id)CFArrayGetValueAtIndex((CFArrayRef)last, 0) retain] autorelease];
        }
        else
        {
            obj = [[(id)CFDictionaryGetValue((CFDictionaryRef)last, key) retain] autorelease];
        }
    }
    else
    {
        uint64_t voffset;
        if (__CFBinaryPlistGetOffsetForValueFromDictionary3(_bytes, _len, _offsetData->offset, &_offsetData->trailer, key, NULL, &voffset, NO, _reservedDictionary))
        {
            CFPropertyListRef value = NULL;
            if (!__CFBinaryPlistCreateObject(_bytes, _len, voffset, &_offsetData->trailer, NULL, 0, _reservedDictionary, &value))
            {
                [(id)value release];
                [NSException raise:NSInvalidUnarchiveOperationException format:@"data is corrupted?"];
                return nil;
            }
            obj = [(id)value autorelease];
        }
    }
    return obj;
}

- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)len
{
    if (raiseIfFinished(self))
    {
        return NULL;
    }
    return _decodeBytes(self, key, len);
}

- (double)decodeDoubleForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return 0.0;
    }

    return _decodeDouble(self, unescapeKey(key));
}

- (float)decodeFloatForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return 0.0f;
    }

    return (float)_decodeDouble(self, unescapeKey(key));
}

- (long long)decodeInt64ForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return 0ll;
    }

    return (long long)_decodeInt(self, unescapeKey(key));
}

- (int)decodeInt32ForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return 0;
    }

    return (int)_decodeInt(self, unescapeKey(key));
}

- (int)decodeIntForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return 0;
    }

    return _decodeInt(self, unescapeKey(key));
}

- (BOOL)decodeBoolForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return NO;
    }

    return _decodeBool(self, unescapeKey(key));
}

- (NSArray *)_decodeArrayOfObjectsForKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return nil;
    }

    if (_containers)
    {
        // XML
        NSArray *array = getXMLVal(self, key);
        if (array == nil)
        {
            return nil;
        }
        if (CFGetTypeID((id)array) != CFArrayGetTypeID())
        {
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Did not find array for key %@", key] userInfo:nil];
            return nil;
        }
        int len = [array count];

        if (len == 0)
        {
            return [NSArray array];
        }

        id objs[256];
        id *elements = objs;
        if (len > 256)
        {
            elements = (id *)malloc(len * sizeof(id));
            if (elements == NULL)
            {
                @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Failed to allocate memory for %@", key] userInfo:nil];
                return nil;
            }
        }
        
        CFRetain(array);
        CFArrayAppendValue(_containers, array);

#warning TODO _flags management
        for (int i = 0; i < len; i++)
        {
            elements[i] = _decodeObjectXML(self, nil);
        }
        deleteLastContainer(_containers);

#warning TODO _flags management
        // CFTypeRef tbd = CFArrayGetValueAtIndex(_containers, index - 1);

        NSArray *retVal = [[NSArray alloc] initWithObjects:elements count:len];
        for (int i = len - 1; i >= 0; i--)
        {
            [elements[i] release];
        }
        if (elements != objs)
        {
            free(elements);
        }
        return [retVal autorelease];
    }

    uint64_t voffset;
    if (!_getOffsetForValueWrap(self, unescapeKey(key), &voffset))
    {
        return nil;
    }

    uint8_t *ptr = (uint8_t *)(_bytes + voffset);
    uint8_t encodeKey = *ptr++;

    if ((encodeKey & 0xf0) != kCFBinaryPlistMarkerArray)
    {
        DEBUG_BREAK();
        return nil;
        // TODO
    }
    int len = encodeKey & 0xf;
    if (len == 0xf)
    {
        len = (int)_getInt(&ptr);
    }

    if (len == 0) {
        return [NSArray array];
    }
    id objs[256];
    id *elements = &objs[0];
    if (len > 256)
    {
        elements = (id *)malloc(len * sizeof(id));
        if (elements == NULL)
        {
            @throw [NSException exceptionWithName:NSInvalidUnarchiveOperationException reason:[NSString stringWithFormat:@"Failed to allocate memory for %@", key] userInfo:nil];
            return nil;
        }
    }
    BOOL error = NO;

    for (int i = 0; i < len; i++)
    {
        uint64_t offset2;
        if (!__CFBinaryPlistGetOffsetForValueFromArray2(_bytes, _len, voffset, &_offsetData->trailer, i, &offset2, _reservedDictionary))
        {
            error = YES;
        }
        NSUInteger uid1 = 0;
        if (!_getUIDFromData((uint8_t *)(_bytes + offset2), &uid1))
        {
            error = YES;
        }
        elements[i] = _decodeObjectBinary(self, uid1);
        if (elements[i] == nil)
        {
            error = YES;
        }
        if (error)
        {
            RELEASE_LOG("failed to decode array element");
            len = i;
            break;
        }
    }

    NSArray *array = error ? nil : [[NSArray alloc] initWithObjects:elements count:len];

    for (int i = len - 1; i >= 0; i--)
    {
        [elements[i] release];
    }
    if (elements != &objs[0])
    {
        free(elements);
    }
    return [array autorelease];
}

- (void)setRequiresSecureCoding:(BOOL)secured
{
    if (secured)
    {
        _flags |= NSSecureCodingFlag;
    }
    else
    {
        _flags &= ~NSSecureCodingFlag;
    }
}

- (BOOL)requiresSecureCoding
{
    return (_flags & NSSecureCodingFlag) != 0;
}

- (NSSet *)allowedClasses
{
    if ([self requiresSecureCoding])
    {
        return [_helper->_allowedClasses lastObject];
    }
    else
    {
        return [super allowedClasses];
    }
}

- (id)decodeObjectOfClasses:(NSSet *)classes forKey:(NSString *)key
{
    if ([self requiresSecureCoding])
    {
        if (classes == nil)
        {
            return [self decodeObjectForKey:key];
        }
        else
        {
            [_helper->_allowedClasses addObject:classes];
            id object= [self decodeObjectForKey:key];
            [_helper->_allowedClasses removeLastObject];
            return object;
        }
    }
    else
    {
        return [super decodeObjectOfClasses:classes forKey:key];
    }
}

- (id)decodeObjectOfClass:(Class)cls forKey:(NSString *)key
{
    if ([self requiresSecureCoding])
    {
        NSSet *classSet = nil;
        if (cls != Nil)
        {
            classSet = [NSSet setWithObject:cls];
        }
        return [self decodeObjectOfClasses:classSet forKey:key];
    }
    else
    {
        return [super decodeObjectOfClass:cls forKey:key];
    }
}

- (id)decodeObjectForKey:(NSString *)key
{
    return _decodeObject(self, unescapeKey(key));
}

- (BOOL)containsValueForKey:(NSString *)key
{
    NSString *uKey = unescapeKey(key);
    if (_containers != nil)
    {
        // XML
        return getXMLVal(self, uKey) != nil;
    }
    return _getOffsetForValueWrap(self, uKey, NULL);
}

- (void)_replaceObject:(id)obj withObject:(id)replacement
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=153
    DEBUG_BREAK();
}

- (void)replaceObject:(id)obj withObject:(id)replacement
{
    if (obj != replacement)
    {
        [self _temporaryMapReplaceObject:obj withObject:replacement];
    }
}

- (void)_temporaryMapReplaceObject:(id)obj withObject:(id)replacement
{
#define BUFFER_SIZE 128
    CFIndex count = CFDictionaryGetCount(_tmpRefObjMap);
    if (count == 0)
    {
        return;
    }

    id stack_objects[BUFFER_SIZE] = {nil};
    void *stack_keys[BUFFER_SIZE] = {nil};
    id *objects = &stack_objects[0];
    void **keys = &stack_keys[0];
    if (count > BUFFER_SIZE)
    {
        objects = malloc(sizeof(id) * count);
        if (objects == NULL) {
            return;
        }
        keys = malloc(sizeof(void *) * count);
        if (keys == NULL) {
            free(objects);
            return;
        }
    }

    CFDictionaryGetKeysAndValues(_tmpRefObjMap, (const void **)keys, (const void **)objects);
    for (CFIndex idx = 0; idx < count; idx++)
    {
        if (objects[idx] == obj)
        {
            CFDictionarySetValue(_tmpRefObjMap, keys[idx], replacement);
            break;
        }
    }

    if (keys != NULL && keys != &stack_keys[0])
    {
        free(keys);
    }
    if (objects != NULL && objects != &stack_objects[0])
    {
        free(objects);
    }
}

- (void)finishDecoding
{
    if ((_flags & NSArchiverFinished) != 0)
    {
        return;
    }

    _flags |= NSArchiverFinished;

    if ((_delegate != nil) && [_delegate respondsToSelector:@selector(unarchiverWillFinish:)])
    {
        [_delegate unarchiverWillFinish:self];
    }

    if ((_delegate != nil) && [_delegate respondsToSelector:@selector(unarchiverDidFinish:)])
    {
        [_delegate unarchiverDidFinish:self];
    }
}

- (void)setAllowedClasses:(NSArray *)classes
{
    [self _setAllowedClassNames:classes];
}

- (void)_setAllowedClassNames:(NSArray *)classNames
{
    [_helper setAllowedClassNames:classNames];
}

- (NSArray *)_allowedClassNames
{
    return [_helper allowedClassNames];
}

- (Class)classForClassName:(NSString *)className
{
    Class cls = CFDictionaryGetValue(_nameClassMap, className);
    
    if (cls == Nil)
    {
        cls = [NSKeyedUnarchiver classForClassName:className];
    }

    return cls;
}

- (void)setClass:(Class)cls forClassName:(NSString *)name
{
    CFDictionarySetValue(_nameClassMap, name, cls);
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id <NSKeyedUnarchiverDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
    }
}

- (BOOL)allowsKeyedCoding
{
    return YES;
}

- (id)description
{
    return [super description];
}

- (id)_blobForCurrentObject
{
#warning TODO
    DEBUG_BREAK();
    return nil;
}

@end
