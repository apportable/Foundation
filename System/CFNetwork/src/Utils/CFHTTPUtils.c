//
//  CFHTTPUtils.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFHTTPUtils.h"
#include "CFHTTPMessagePriv.h"

CFIndex _CFHTTPSkipUntil(const UniChar* string, CFIndex pos, const char* stopChars) {
    for (; string[pos]; ++pos) {
        for (const char* s = stopChars; *s; ++s) {
            if (string[pos] == *s) {
                return pos;
            }
        }
    }
    return pos;
}

CFIndex _CFHTTPSkipWhitespace(const UniChar* string, CFIndex pos, CFIndex delta) {
    assert(delta == +1 || delta == -1);
    if (delta < 0) {
        if (pos + delta < 0) {
            return pos;
        }
        pos += delta;
    }
    while (true) {
        UniChar ch = string[pos];
        if (ch != ' ' && ch != '\t') {
            break;
        }
        if (pos + delta < 0) {
            break;
        }
        pos += delta;
    }
    return pos;
}

CFDictionaryRef _CFHTTPParseCacheControlField(CFStringRef valueString) {
    if (!valueString) {
        return NULL;
    }

    CFIndex length = CFStringGetLength(valueString);
    if (!length) {
        return NULL;
    }

    CFMutableDictionaryRef cacheControl = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    UniChar value[length + 1];
    CFStringGetCharacters(valueString, CFRangeMake(0, length), value);
    value[length] = 0;

    for (CFIndex pos = 0; pos < length; ++pos) {
        CFIndex tokenStart = _CFHTTPSkipWhitespace(value, pos, +1);
        pos = _CFHTTPSkipUntil(value, tokenStart, "=,");
        CFIndex tokenEnd = _CFHTTPSkipWhitespace(value, pos, -1);
        if (!pos || tokenStart > tokenEnd) {
            continue;
        }

        CFStringRef directive = CFStringCreateWithCharacters(
            kCFAllocatorDefault,
            value + tokenStart, tokenEnd - tokenStart + 1);

        if (pos == length || value[pos] == ',') {
            CFDictionarySetValue(cacheControl, directive, kCFNull);
            CFRelease(directive);
            continue;
        }

        pos++; // consume '='
        pos = _CFHTTPSkipWhitespace(value, pos, +1);

        if (pos < length && value[pos] == '\"') {
            tokenStart = pos + 1; // consume quote
            pos = _CFHTTPSkipUntil(value, tokenStart, "\"");
            tokenEnd = pos - 1;
            pos += 1; // consume quote
        } else {
            tokenStart = _CFHTTPSkipWhitespace(value, pos, +1);
            pos = _CFHTTPSkipUntil(value, tokenStart, ",");
            tokenEnd = _CFHTTPSkipWhitespace(value, pos, -1);
        }

        CFStringRef parameter = CFStringCreateWithCharacters(
            kCFAllocatorDefault,
            value + tokenStart, tokenEnd - tokenStart + 1);

        CFDictionarySetValue(cacheControl, directive, parameter);
        CFRelease(directive);
        CFRelease(parameter);
    }

    return cacheControl;
}

Boolean _CFHTTPParseSeconds(CFTimeInterval* seconds, CFStringRef string) {
    if (seconds) {
        *seconds = 0;
    }
    if (!string) {
        return false;
    }

    CFTimeInterval value = 0;
    for (CFIndex i = 0; i != CFStringGetLength(string); ++i) {
        UniChar ch = CFStringGetCharacterAtIndex(string, i);
        if (ch < '0' || ch > '9') {
            return false;
        }
        value = value * 10 + (ch - '0');
    }

    if (seconds) {
        *seconds = value;
    }
    return true;
}

// TODO: simplify this by using parsing functions above
Boolean _CFHTTPParseContentTypeField(CFStringRef* textEncoding,
                                     CFStringRef* mimeType,
                                     CFStringRef content_type)
{
    if (textEncoding) {
        *textEncoding = NULL;
    }
    if (mimeType) {
        *mimeType = NULL;
    }
    if (!content_type) {
        return false;
    }

    static CFCharacterSetRef semicolonSet;
    static CFCharacterSetRef equalSignSet;
    static CFCharacterSetRef notSpaceSet;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        semicolonSet = CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, CFSTR(";"));
        equalSignSet = CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, CFSTR("="));
        notSpaceSet = CFCharacterSetCreateInvertedSet(kCFAllocatorDefault, CFCharacterSetGetPredefined(kCFCharacterSetWhitespace));
    });
    CFRange found = CFRangeMake(0, 0);
    CFIndex length = CFStringGetLength(content_type);
    CFRange needle = CFRangeMake(0, length);
    CFIndex charsetStart = -1;
    CFIndex charsetEnd = -1;
    CFIndex mimeTypeStart = 0;
    CFIndex mimeTypeEnd = length - 1;
    if (CFStringFindCharacterFromSet(content_type, semicolonSet, needle, 0, &found)) {
        needle = CFRangeMake(found.location + found.length, length - (found.location + found.length));
        mimeTypeEnd = found.location - 1;
        if (CFStringFindWithOptionsAndLocale(content_type, CFSTR("charset="), needle, 0, NULL, &found)) {
            charsetStart = found.location;
        }
    }

    needle = CFRangeMake(0, mimeTypeEnd + 1);
    if (CFStringFindCharacterFromSet(content_type, notSpaceSet, needle, 0, &found)) {
        mimeTypeStart = found.location;
    }

    if (CFStringFindCharacterFromSet(content_type, notSpaceSet, needle, kCFCompareBackwards, &found)) {
        mimeTypeEnd = found.location;
    }

    if (charsetStart != -1 && textEncoding) {

        needle = CFRangeMake(charsetStart, length - charsetStart);
        if (CFStringFindCharacterFromSet(content_type, notSpaceSet, needle, 0, &found)) {
            charsetStart = found.location;
        }

        if (CFStringFindCharacterFromSet(content_type, notSpaceSet, needle, kCFCompareBackwards, &found)) {
            charsetEnd = found.location;
        }

        *textEncoding = CFStringCreateWithSubstring(kCFAllocatorDefault, content_type, CFRangeMake(charsetStart, charsetEnd - charsetStart + 1));
    }

    if (mimeTypeEnd - mimeTypeStart > 0 && mimeType) {
        *mimeType = CFStringCreateWithSubstring(kCFAllocatorDefault, content_type, CFRangeMake(mimeTypeStart, mimeTypeEnd - mimeTypeStart + 1));
    }

    return true;
}

Boolean _CFHTTPParseDateField(CFAbsoluteTime* date, CFStringRef string) {
    if (date) {
        *date = 0;
    }
    if (!string) {
        return false;
    }

    CFGregorianDate gregorianDate = {0};
    CFTimeZoneRef timeZone = 0;

    if (!_CFGregorianDateCreateWithString(kCFAllocatorDefault, string, &gregorianDate, &timeZone)) {
        return false;
    }
    if (date) {
        *date = CFGregorianDateGetAbsoluteTime(gregorianDate, timeZone);
    }
    if (timeZone) {
        CFRelease(timeZone);
    }

    return true;
}

CFArrayRef _CFHTTPParseVaryField(CFStringRef string) {
    if (!string) {
        return NULL;
    }

    CFIndex length = CFStringGetLength(string);
    UniChar value[length + 1];
    CFStringGetCharacters(string, CFRangeMake(0, length), value);
    value[length] = 0;

    CFMutableArrayRef fields = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    for (CFIndex pos = 0; pos < length; ++pos) {
        CFIndex tokenStart = _CFHTTPSkipWhitespace(value, pos, +1);
        pos = _CFHTTPSkipUntil(value, tokenStart, ",");
        CFIndex tokenEnd = _CFHTTPSkipWhitespace(value, pos, -1);
        if (!pos || tokenStart > tokenEnd) {
            continue;
        }

        CFStringRef field = CFStringCreateWithCharacters(
            kCFAllocatorDefault,
            value + tokenStart, tokenEnd - tokenStart + 1);
        CFArrayAppendValue(fields, field);
        CFRelease(field);
    }

    return fields;
}
