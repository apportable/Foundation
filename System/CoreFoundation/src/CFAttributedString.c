//
//  CFAttributedString.c
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include <CoreFoundation/CFAttributedString.h>
#include "CFRuntime.h"
#include "CFInternal.h"

typedef struct
{
    CFRange         _range;
    CFDictionaryRef _dictionary;
} __CFRunArrayItem;

typedef struct __CFAttributedString
{
    CFRuntimeBase       _base;
    CFStringRef         _string;
    __CFRunArrayItem    **_attributes;
    CFIndex             _runArrayCount;
    Boolean             _isMutable;
} __CFAttributedString;

static void mergeIntoDictionary(const void* key, const void* value, void* context) {
    CFMutableDictionaryRef into = (CFMutableDictionaryRef)context;
    CFDictionarySetValue(into, key, value);
}

static Boolean _CFRunArrayIsEqual(__CFAttributedString *aStr, __CFAttributedString *aStr2)
{
    if (aStr->_runArrayCount != aStr2->_runArrayCount)
    {
        return false;
    }
    __CFRunArrayItem **inputArray = aStr->_attributes;
    __CFRunArrayItem **inputArray2 = aStr2->_attributes;
    if (inputArray == inputArray2)
    {
        return true;
    }
    if (inputArray == NULL || inputArray2 == NULL)
    {
        return false;
    }
    for (CFIndex next, i = 0; i < aStr->_runArrayCount; i = next)
    {
        __CFRunArrayItem *inp = inputArray[i];
        __CFRunArrayItem *inp2 = inputArray2[i];
        if (inp)
        {
            if (inp2 == NULL)
            {
                return false;
            }
            if (inp->_range.location != inp2->_range.location || inp->_range.length != inp2->_range.length)
            {
                return false;
            }
            if (!CFEqual(inp->_dictionary, inp2->_dictionary))
            {
                return false;
            }
            next = i + inp->_range.length;
        }
        else
        {
            if (inp2)
            {
                return false;
            }
            next = i + 1;
        }
    }
    return true;
}


static __CFRunArrayItem * _CFRunArrayItemInit(CFRange range, CFDictionaryRef dict)
{
    __CFRunArrayItem *obj = (__CFRunArrayItem *)malloc(sizeof(__CFRunArrayItem));
    obj->_range = range;
    obj->_dictionary = CFRetain(dict);
    return obj;
}

static void _CFRunArrayItemDestroy(__CFRunArrayItem *ptr)
{
    if (ptr->_dictionary)
    {
        CFRelease(ptr->_dictionary);
    }
    free(ptr);
}

static void _CFRunArrayDestroyAttributesOfString(__CFAttributedString *aStr)
{
    __CFRunArrayItem **inputArray = aStr->_attributes;
    if (inputArray == NULL)
    {
        return;
    }
    for (CFIndex next, i = 0; i < aStr->_runArrayCount; i = next)
    {
        __CFRunArrayItem *inp = inputArray[i];
        if (inp)
        {
            next = i + inp->_range.length;
            _CFRunArrayItemDestroy(inp);
        }
        else
        {
            next = i + 1;
        }
    }
    free(aStr->_attributes);
}

static void _CFRunArrayInsert(__CFAttributedString *attrStr, CFDictionaryRef dict, CFRange range, Boolean clearOther, CFStringRef subtractValue)
{
    if (range.length == 0)
    {
        return;
    }

    CFIndex rangeLimit = range.location + range.length;
    if (rangeLimit > attrStr->_runArrayCount)
    {
        __CFRunArrayItem **new = (__CFRunArrayItem **)calloc(sizeof(__CFRunArrayItem *), rangeLimit);
        if (attrStr->_attributes != NULL)
        {
            memcpy(new, attrStr->_attributes, sizeof(__CFRunArrayItem *) * attrStr->_runArrayCount);
            free(attrStr->_attributes);
        }
        attrStr->_attributes = new;
        attrStr->_runArrayCount = rangeLimit;
    }

    __CFRunArrayItem **indexArray = attrStr->_attributes;
    __CFRunArrayItem *ptr = indexArray[range.location];

    // First entry for this index
    if (ptr == nil && !subtractValue)
    {
        __CFRunArrayItem *obj = _CFRunArrayItemInit(CFRangeMake(range.location, 0), dict);
        for (CFIndex i = range.location; i < rangeLimit; i++)
        {
            if (indexArray[i] == nil)
            {
                indexArray[i] = obj;
                obj->_range.length++;
            }
            else
            {
                _CFRunArrayInsert(attrStr, dict, CFRangeMake(i, rangeLimit - i), clearOther, subtractValue);
                break;
            }
        }
        return;
    }

    Boolean split = false;
    CFIndex ptrRangeLimit = ptr->_range.location + ptr->_range.length;

    CFMutableDictionaryRef mergeDict = NULL;
    do {
        if (clearOther)
        {
            mergeDict = (CFMutableDictionaryRef)dict;
            CFRetain(mergeDict);
        }
        else
        {
            mergeDict = CFDictionaryCreateMutableCopy(NULL, 0, ptr->_dictionary);
            if (subtractValue != NULL)
            {
                CFDictionaryRemoveValue(mergeDict, subtractValue);
            }
            else
            {
                CFDictionaryApplyFunction(dict, mergeIntoDictionary, mergeDict);
            }
        }

        if (rangeLimit <= ptrRangeLimit && CFEqual(ptr->_dictionary, mergeDict))
        {
            // No need to do anymore - the requested insert dictionary is already there
            break; // CLEANUP
        }

        // Check for split at beginning of list
        if (ptr->_range.location < range.location)
        {
            if (CFEqual(ptr->_dictionary, mergeDict))
            {
                // Done with this item but still need to update subsequent run array items
                CFIndex restStart = ptrRangeLimit;
                CFIndex restLength = rangeLimit - restStart;
                _CFRunArrayInsert(attrStr, dict, CFRangeMake(restStart, restLength), clearOther, subtractValue);
                break; // CLEANUP
            }
            split = true;
            CFIndex objRangeLimit = ptr->_range.location + ptr->_range.length;
            ptr->_range.length = range.location - ptr->_range.location;
            // if *ptr goes beyond range, need to copy element for new range after insert
            if (objRangeLimit > rangeLimit)
            {
                __CFRunArrayItem *copy = _CFRunArrayItemInit(CFRangeMake(rangeLimit, objRangeLimit - rangeLimit), ptr->_dictionary);
                for (CFIndex i = rangeLimit; i < objRangeLimit; i++)
                {
                    indexArray[i] = copy;
                }
            }
            // fall through - now that preceding (and successive) indices are ready
        }

        __CFRunArrayItem *obj;
        CFIndex newRangeLength = __CFMin(range.length, ptrRangeLimit - range.location);
        if (range.location > 0 && CFEqual(indexArray[range.location - 1]->_dictionary, mergeDict))
        {
            // Can merge with previous
            obj = indexArray[range.location - 1];
            obj->_range.length += newRangeLength;
        }
        else if (ptrRangeLimit == rangeLimit && 
            rangeLimit < attrStr->_runArrayCount && 
            CFEqual(mergeDict, indexArray[rangeLimit]->_dictionary))
        {
            // can merge with next
            indexArray[rangeLimit]->_range.length += rangeLimit - range.location;
            indexArray[rangeLimit]->_range.location = range.location;
            for (CFIndex i = range.location; i < rangeLimit; i++)
            {
                indexArray[i] = indexArray[rangeLimit];
            }
            break; // CLEANUP
        }
        else
        {
            obj = _CFRunArrayItemInit(CFRangeMake(range.location, newRangeLength), mergeDict);
        }

        for (CFIndex i = range.location; i < range.location + newRangeLength; i++)
        {
            indexArray[i] = obj;
        }

        if (ptrRangeLimit > rangeLimit)
        {
            if (!split)
            {
                ptr->_range.location = rangeLimit;
                ptr->_range.length = ptr->_range.length - range.length;
            }
            break; // CLEANUP
        }
        else
        {
            if (!split)
            {
                _CFRunArrayItemDestroy(ptr);
            }
            if (ptrRangeLimit < rangeLimit)
            {
                CFIndex restStart = ptrRangeLimit;
                CFIndex restLength = rangeLimit - restStart;
                _CFRunArrayInsert(attrStr, dict, CFRangeMake(restStart, restLength), clearOther, subtractValue);
            }
        }
    } while(0);

    // CLEANUP:
    CFRelease(mergeDict);
}

static void _CFRunArrayCopy(__CFAttributedString *to, __CFAttributedString *from)
{
    if (from->_attributes == NULL)
    {
        return;
    }
    _CFRunArrayDestroyAttributesOfString(to);
    to->_attributes = (__CFRunArrayItem **)calloc(sizeof(__CFRunArrayItem *), from->_runArrayCount);
    to->_runArrayCount = from->_runArrayCount;
    __CFRunArrayItem **inputArray = from->_attributes;
    __CFRunArrayItem **outputArray = to->_attributes;
    for (CFIndex next, i = 0; i < from->_runArrayCount; i = next)
    {
        __CFRunArrayItem *inp = inputArray[i];
        if (inp)
        {
            outputArray[i] = _CFRunArrayItemInit(inp->_range, inp->_dictionary);
            next = i + inp->_range.length;
            for (CFIndex j = i; j < next; j++)
            {
                outputArray[j] = outputArray[i];
            }
        }
        else
        {
            next = i + 1;
        }
    }
}

static CFDictionaryRef _CFRunArrayObjectAtIndex(__CFAttributedString *aStr, CFIndex loc, CFRange *effectiveRange)
{
    if (loc > aStr->_runArrayCount)
    {
        return NULL;
    }
    __CFRunArrayItem *ptr = aStr->_attributes[loc];
    if (effectiveRange)
    {
        *effectiveRange = ptr->_range;
    }
    return ptr->_dictionary;
}

static CFTypeID __kCFAttributedStringTypeID = _kCFRuntimeNotATypeID;

typedef CFTypeRef (*CF_STRING_CREATE_COPY)(CFAllocatorRef alloc, CFTypeRef theString);

static void __CFAttributedStringDeallocate(CFTypeRef cf) {
    __CFAttributedString *ptr = (__CFAttributedString *)cf;
    CFRelease(ptr->_string);
    _CFRunArrayDestroyAttributesOfString(ptr);
}

static Boolean __CFAttributedStringEqual(CFTypeRef cf1, CFTypeRef cf2) {
    __CFAttributedString *ptr1 = (__CFAttributedString *)cf1;
    __CFAttributedString *ptr2 = (__CFAttributedString *)cf2;
    if (!CFEqual(ptr1->_string, ptr2->_string))
    {
        return false;
    }
    return _CFRunArrayIsEqual(ptr1, ptr2);
}

CFHashCode __CFAttributedStringHash(CFTypeRef cf) {
    __CFAttributedString *ptr = (__CFAttributedString *)cf;
    return CFHash(ptr->_string);
}

static CFStringRef __CFAttributedStringCopyDescription(CFTypeRef cf) 
{
    // Update attributes
    __CFAttributedString *from = (__CFAttributedString *)cf;
    __CFRunArrayItem **inputArray = from->_attributes;
    if (inputArray == NULL)
    {
        return CFSTR("");
    }
    CFMutableStringRef out = CFStringCreateMutable(kCFAllocatorSystemDefault, 0);
    for (CFIndex next, i = 0; i < from->_runArrayCount; i = next)
    {
        __CFRunArrayItem *inp = inputArray[i];
        if (inp)
        {
            next = i + inp->_range.length;
            CFStringRef substr = CFStringCreateWithSubstring(NULL, from->_string, inp->_range);
            CFStringAppendFormat(out, NULL, CFSTR("%@ %@ Len %d\n\n"),
                substr,
                inp->_dictionary,
                inp->_range.length);
            CFRelease(substr);
        }
        else
        {
            next = i + 1;
        }
    }
    return out;
}

static const CFRuntimeClass __CFAttributedStringClass = {
    _kCFRuntimeScannedObject,
    "CFAttributedString",
    NULL,      // init
    (CF_STRING_CREATE_COPY)CFAttributedStringCreateCopy,
    __CFAttributedStringDeallocate,
    __CFAttributedStringEqual,
    __CFAttributedStringHash,
    NULL,
    __CFAttributedStringCopyDescription
};

CF_PRIVATE void __CFAttributedStringInitialize(void) {
    __kCFAttributedStringTypeID = _CFRuntimeRegisterClass(&__CFAttributedStringClass);
}

CFTypeID CFAttributedStringGetTypeID(void) {
    if (__kCFAttributedStringTypeID == _kCFRuntimeNotATypeID) {
        __CFAttributedStringInitialize();
    }
    return __kCFAttributedStringTypeID;
}

static void _CFAttributedStringCreateAttributes(CFAllocatorRef alloc, __CFAttributedString *attrStr, CFDictionaryRef attributes, CFIndex len)
{
    CFRange range = CFRangeMake(0, len);
    if (attributes != NULL)
    {
        _CFRunArrayInsert(attrStr, attributes, range, false, NULL);
    }
    else
    {
        CFDictionaryRef insertDict = CFDictionaryCreate(alloc, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _CFRunArrayInsert(attrStr, insertDict, range, false, NULL);
        CFRelease(insertDict);
    }
}

CFAttributedStringRef CFAttributedStringCreate(CFAllocatorRef alloc, CFStringRef str, CFDictionaryRef attributes)
{
    CFIndex size = sizeof(struct __CFAttributedString) - sizeof(CFRuntimeBase);
    __CFAttributedString *newObj = (struct __CFAttributedString *)_CFRuntimeCreateInstance(alloc, CFAttributedStringGetTypeID(), size, NULL);
    newObj->_string = CFStringCreateCopy(alloc, str);
    newObj->_attributes = NULL;
    newObj->_runArrayCount = 0;
    newObj->_isMutable = false;
    _CFAttributedStringCreateAttributes(alloc, newObj, attributes, CFStringGetLength(str));
    return (CFAttributedStringRef)newObj;
}

CFAttributedStringRef CFAttributedStringCreateWithSubstring(CFAllocatorRef alloc, CFAttributedStringRef aStr, CFRange range)
{
    CFIndex length = CFAttributedStringGetLength(aStr);
    if (range.length == 0 || range.location + range.length > length)
    {
        return NULL;
    }
    CFStringRef s = CFAttributedStringGetString(aStr);
    CFStringRef substring = CFStringCreateWithSubstring(alloc, s, range);
    CFMutableAttributedStringRef obj = (CFMutableAttributedStringRef)CFAttributedStringCreate(alloc, substring, NULL);
    CFRelease(substring);

    CFIndex delta = range.location;
    NSUInteger newLength;

    for (CFIndex i = 0; i < range.length; i = i + newLength)
    {
        CFRange effRange;
        CFIndex selfIndex = i + delta;
        CFDictionaryRef attrs = CFAttributedStringGetAttributes(aStr, selfIndex, &effRange);  
        newLength = effRange.length;
        if (effRange.location < selfIndex)
        {
            newLength -= selfIndex - effRange.location;
        }
        CFAttributedStringSetAttributes(obj, CFRangeMake(i, newLength), attrs, false);
    }
    return (CFAttributedStringRef)obj;
}

CFAttributedStringRef CFAttributedStringCreateCopy(CFAllocatorRef alloc, CFAttributedStringRef aStr)
{
    if (((CFAttributedStringRef)aStr)->_isMutable)
    {
        CFAttributedStringRef retVal = (CFAttributedStringRef)CFAttributedStringCreateMutableCopy(alloc, 0, aStr);
        ((__CFAttributedString *)retVal)->_isMutable = false;
        return retVal;
    }
    else
    {
        return CFRetain(aStr);
    }
}

CFStringRef CFAttributedStringGetString(CFAttributedStringRef aStr)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, CFStringRef, (NSAttributedString *)aStr, string);
    return ((__CFAttributedString *)aStr)->_string;
}

CFIndex CFAttributedStringGetLength(CFAttributedStringRef aStr)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, CFIndex, (NSAttributedString *)aStr, length);
    return CFStringGetLength(CFAttributedStringGetString(aStr));
}

CFDictionaryRef CFAttributedStringGetAttributes(CFAttributedStringRef aStr, CFIndex loc, CFRange *effectiveRange)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, CFDictionaryRef, (NSAttributedString *)aStr, attributesAtIndex:loc effectiveRange:effectiveRange);
    return _CFRunArrayObjectAtIndex((__CFAttributedString *)aStr, loc, effectiveRange);
}

CFTypeRef CFAttributedStringGetAttribute(CFAttributedStringRef aStr, CFIndex loc, CFStringRef attrName, CFRange *effectiveRange)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, id, (NSAttributedString *)aStr, attribute:attrName AtIndex:loc effectiveRange:effectiveRange);
    CFDictionaryRef dict = CFAttributedStringGetAttributes(aStr, loc, effectiveRange);
    return CFDictionaryGetValue(dict, attrName);
}

CFDictionaryRef CFAttributedStringGetAttributesAndLongestEffectiveRange(CFAttributedStringRef aStr, CFIndex loc, CFRange inRange, CFRange *longestEffectiveRange)
{
    CFDictionaryRef retVal = CFAttributedStringGetAttributes(aStr, loc, longestEffectiveRange);
    if (longestEffectiveRange == NULL)
    {
        return retVal;
    }
    CFIndex min = longestEffectiveRange->location;  // inclusive end
    CFIndex max = longestEffectiveRange->location + longestEffectiveRange->length;  // exclusive end
    CFRange tempRange;
    CFTypeRef compareVal;
    CFIndex minLimit = __CFMax(0, inRange.location);
    while (min > minLimit && 
        (compareVal = CFAttributedStringGetAttributes(aStr, min - 1, &tempRange)) &&
        CFEqual(retVal, compareVal))
    {
        min = tempRange.location;
    }

    CFIndex inRangeLimit = inRange.location + inRange.length;
    CFIndex maxLimit = __CFMin(CFAttributedStringGetLength(aStr), inRangeLimit);
    while (max < maxLimit && 
        (compareVal = CFAttributedStringGetAttributes(aStr, max, &tempRange)) &&
        CFEqual(retVal, compareVal))
    {
        max = tempRange.location + tempRange.length;
    }
    CFIndex newLocation = __CFMax(min, inRange.location);
    CFIndex newLength = __CFMin(max, inRangeLimit) - newLocation;
    *longestEffectiveRange = CFRangeMake(newLocation, newLength);
    return retVal;
}

CFTypeRef CFAttributedStringGetAttributeAndLongestEffectiveRange(CFAttributedStringRef aStr, CFIndex loc, CFStringRef attrName, CFRange inRange, CFRange *longestEffectiveRange)
{
    CFTypeRef retVal = CFAttributedStringGetAttribute(aStr, loc, attrName, longestEffectiveRange);
    if (longestEffectiveRange == NULL)
    {
        return retVal;
    }
    CFIndex min = longestEffectiveRange->location;  // inclusive end
    CFIndex max = longestEffectiveRange->location + longestEffectiveRange->length;  // exclusive end
    CFRange tempRange;
    CFTypeRef compareVal;
    CFIndex minLimit = __CFMax(0, inRange.location);
    while (min > minLimit && 
        (compareVal = CFAttributedStringGetAttribute(aStr, min - 1, attrName, &tempRange)) &&
        CFEqual(retVal, compareVal))
    {
        min = tempRange.location;
    }

    CFIndex inRangeLimit = inRange.location + inRange.length;
    CFIndex maxLimit = __CFMin(CFAttributedStringGetLength(aStr), inRangeLimit);
    while (max < maxLimit && 
        (compareVal = CFAttributedStringGetAttribute(aStr, max, attrName, &tempRange)) &&
        CFEqual(retVal, compareVal))
    {
        max = tempRange.location + tempRange.length;
    }
    CFIndex newLocation = __CFMax(min, inRange.location);
    CFIndex newLength = __CFMin(max, inRangeLimit) - newLocation;
    *longestEffectiveRange = CFRangeMake(newLocation, newLength);
    return retVal;
}

CFMutableAttributedStringRef CFAttributedStringCreateMutableCopy(CFAllocatorRef alloc, CFIndex maxLength, CFAttributedStringRef aStr)
{
    CFMutableAttributedStringRef retVal = (CFMutableAttributedStringRef)CFAttributedStringCreate(alloc, CFAttributedStringGetString(aStr), NULL);
    _CFRunArrayCopy((__CFAttributedString *)retVal, (__CFAttributedString *)aStr);
    ((__CFAttributedString *)retVal)->_isMutable = true;
    return retVal;
}

CFMutableAttributedStringRef CFAttributedStringCreateMutable(CFAllocatorRef alloc, CFIndex maxLength)
{
    // iOS also seems to ignore the maxLength parameter - it's passed to CFStringCreateMutable, but at most is used as
    // a hint - not as an absolute limit as implied by docs.
    CFMutableAttributedStringRef retVal = (CFMutableAttributedStringRef)CFAttributedStringCreate(alloc, CFSTR(""), NULL);
    ((__CFAttributedString *)retVal)->_isMutable = true;
    return retVal;
}

void CFAttributedStringReplaceString(CFMutableAttributedStringRef aStr, CFRange range, CFStringRef replacement)
{
    CF_OBJC_FUNCDISPATCHV (__kCFAttributedStringTypeID, void, (NSAttributedString *)aStr, replaceCharactersInRange:NSMakeRange(range.location, range.length) withString:replacement);
    CFIndex adding = CFStringGetLength(replacement);
    __CFAttributedString *ptr = (struct __CFAttributedString *)aStr;
    CFIndex oldLength = CFStringGetLength(ptr->_string);
    CFMutableStringRef str = CFStringCreateMutableCopy(NULL, 0, ptr->_string);
    CFStringReplace(str, range, replacement);
    CFRelease(ptr->_string);
    ptr->_string = str;

    if (oldLength == 0)
    {
        _CFAttributedStringCreateAttributes(NULL, ptr, NULL, adding);
    }
    else if (range.location == oldLength)
    {
        // Extending old string at end. Attributes copied from last character
        ptr->_attributes[oldLength - 1]->_range.length += adding;
        ptr->_attributes = (__CFRunArrayItem **)realloc(ptr->_attributes, sizeof(__CFRunArrayItem *) * (ptr->_runArrayCount + adding));
        ptr->_runArrayCount += adding;
        for (CFIndex i = oldLength; i < ptr->_runArrayCount; i++)
        {
            ptr->_attributes[i] = ptr->_attributes[oldLength - 1];
        }
    }
    else
    {
        // Now fix up attribute ranges. Inserted string takes the attributes of the character at the start
        CFIndex deleting = range.length;
        CFIndex delta = adding - deleting;

        __CFRunArrayItem *startRunPtr = ptr->_attributes[range.location];
        CFIndex next = startRunPtr->_range.location + startRunPtr->_range.length;
        CFIndex deleteLimit = 0;
        CFIndex startRangeDelta = range.location - startRunPtr->_range.location;
        if (startRunPtr->_range.length - startRangeDelta >= deleting)
        {
            if (delta == 0)
            {
                // No adjustments necessary
                return;
            }
            startRunPtr->_range.length += delta;
        }
        else
        {
            deleteLimit = range.location + range.length;
            startRunPtr->_range.length = startRangeDelta + adding;
        }
        if (startRunPtr->_range.length == 0)
        {
            _CFRunArrayItemDestroy(startRunPtr);
        }
        for (CFIndex i = next; i < oldLength; i = next)
        {
            __CFRunArrayItem *runPtr = ptr->_attributes[i];
            next = runPtr->_range.location + runPtr->_range.length;
            if (next <= deleteLimit)
            {
                _CFRunArrayItemDestroy(runPtr);
            }
            else if (i >= deleteLimit)
            {
                runPtr->_range.location += delta;
            }
            else
            {
                runPtr->_range.length -= deleteLimit - i;
                runPtr->_range.location = range.location + adding;
            }
        }
        // Get attributes array in the right place
        if (delta > 0)
        {
            ptr->_attributes = (__CFRunArrayItem **)realloc(ptr->_attributes, sizeof(__CFRunArrayItem *) * (ptr->_runArrayCount + delta));
            CFIndex updateStart = range.location;
            memmove(&ptr->_attributes[updateStart + delta], &ptr->_attributes[updateStart], sizeof(__CFRunArrayItem *) * (ptr->_runArrayCount - updateStart));
        }
        else if (delta < 0)
        {
            CFIndex updateStart = range.location + adding;
            CFIndex count = ptr->_runArrayCount - updateStart + delta;
            if (count > 0)
            {
                memmove(&ptr->_attributes[updateStart], &ptr->_attributes[updateStart - delta], sizeof(__CFRunArrayItem *) * count);
            }
        }
        ptr->_runArrayCount += delta;

        // Make sure attribute array is correct for length of new string
        CFIndex endNewAdd = range.location + adding;
        for (CFIndex i = range.location + 1; i < endNewAdd; i++)
        {
            ptr->_attributes[i] = startRunPtr;
        }
    }
}

CFMutableStringRef CFAttributedStringGetMutableString(CFMutableAttributedStringRef aStr)
{
    // iOS only returns a real value for the NS version
    return nil;
}

void CFAttributedStringSetAttributes(CFMutableAttributedStringRef aStr, CFRange range, CFDictionaryRef replacement, Boolean clearOtherAttributes)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, void, (NSMutableAttributedString *)aStr, addAttributes:(NSDictionary *)replacement range:NSMakeRange(range.location, range.length));
    _CFRunArrayInsert((__CFAttributedString *)aStr, replacement, range, clearOtherAttributes, NULL);
}

void CFAttributedStringSetAttribute(CFMutableAttributedStringRef aStr, CFRange range, CFStringRef attrName, CFTypeRef value)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, void, (NSAttributedString *)aStr, setAttribute:attrName value:value range:NSMakeRange(range.location, range.length));

    CFDictionaryRef dict = CFDictionaryCreate(NULL, (const void **)&attrName, (const void **)&value, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFAttributedStringSetAttributes((__CFAttributedString *)aStr, range, dict, false);
    CFRelease(dict);
}

void CFAttributedStringRemoveAttribute(CFMutableAttributedStringRef aStr, CFRange range, CFStringRef attrName)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, void, (NSAttributedString *)aStr, removeAttribute:attrName range:NSMakeRange(range.location, range.length));
    _CFRunArrayInsert(aStr, NULL, range, false, attrName);
}

void CFAttributedStringReplaceAttributedString(CFMutableAttributedStringRef aStr, CFRange range, CFAttributedStringRef replacement)
{
    CF_OBJC_FUNCDISPATCHV(__kCFAttributedStringTypeID, void, (NSAttributedString *)aStr, replaceCharactersInRange:NSMakeRange(range.location, range.length) withAttributeString:replacement);
    
    // Replace string
    CFStringRef replaceString = CFAttributedStringGetString(replacement);
    CFAttributedStringReplaceString(aStr, range, replaceString);

    // Update attributes
    CFIndex len = CFStringGetLength(replaceString);
    for (CFIndex next, i = 0; i < len; i = next)
    {
        CFRange replacementRange;
        CFDictionaryRef attrs = CFAttributedStringGetAttributes(replacement, i, &replacementRange);
        _CFRunArrayInsert(aStr, attrs, CFRangeMake(i + range.location, replacementRange.length), true, NULL);
        next = i + replacementRange.length;
    }
}

void CFAttributedStringBeginEditing(CFMutableAttributedStringRef aStr)
{
    static int printed = 0;
    if (printed == 0)
    {
        DEBUG_LOG("CFAttributedStringBeginEditing and CFAttributedStringEndEditing are currently no-ops");
        printed = 1;
    }
}

void CFAttributedStringEndEditing(CFMutableAttributedStringRef aStr)
{
}

void _CFAttributedStringSetMutable(CFAttributedStringRef aStr, Boolean isMutable)
{
    ((__CFAttributedString *)aStr)->_isMutable = isMutable;
}
