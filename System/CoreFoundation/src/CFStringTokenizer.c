//
//  CFStringTokenizer.c
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFStringTokenizer.h"
#include <unicode/ubrk.h>

#define TYPE_MASK 0x000000FF

struct __CFStringTokenizer {
    CFRuntimeBase _base;
    CFStringRef _string;
    CFRange _range;
    CFOptionFlags _options;
    CFLocaleRef _locale;
    UBreakIterator *_break_itr;
};

static void __CFStringTokenizerDeallocate(CFTypeRef cf) {
    struct __CFStringTokenizer *tokenizer = (struct __CFStringTokenizer *)cf;
    if (tokenizer->_string) {
        CFRelease(tokenizer->_string);
    }

    if (tokenizer->_locale) {
        CFRelease(tokenizer->_locale);
    }

    if (tokenizer->_break_itr) {
        ubrk_close(tokenizer->_break_itr);
    }
}


static CFTypeID __kCFStringTokenizerTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFStringTokenizerClass = {
    _kCFRuntimeScannedObject,
    "CFStringTokenizer",
    NULL,   // init
    NULL,   // copy
    __CFStringTokenizerDeallocate,
    NULL,   // __CFStringTokenizerEqual,
    NULL,   // __CFStringTokenizerHash,
    NULL,   // 
    NULL
};

void __CFStringTokenizerInitialize(void) {
    __kCFStringTokenizerTypeID = _CFRuntimeRegisterClass(&__CFStringTokenizerClass);
}


CFTypeID CFStringTokenizerGetTypeID(void) {
    if (__kCFStringTokenizerTypeID == _kCFRuntimeNotATypeID) {
        __CFStringTokenizerInitialize();
    }
    return __kCFStringTokenizerTypeID;
}

#define BUFFER_SIZE 768

CFStringTokenizerRef CFStringTokenizerCreate(CFAllocatorRef allocator, CFStringRef string, CFRange range, CFOptionFlags options, CFLocaleRef locale) {
    CFIndex size = sizeof(struct __CFStringTokenizer) - sizeof(CFRuntimeBase);
    struct __CFStringTokenizer *tokenizer = (struct __CFStringTokenizer *)_CFRuntimeCreateInstance(allocator, CFStringTokenizerGetTypeID(), size, NULL);
    tokenizer->_string = CFStringCreateCopy(allocator, string);
    tokenizer->_range = range;
    tokenizer->_options = options;
    if (locale == NULL) {
        tokenizer->_locale = CFLocaleCopyCurrent();
    } else {
        tokenizer->_locale = CFRetain(locale);
    }


    CFStringRef localeName = locale ? CFLocaleGetIdentifier(locale) : CFSTR("");
    char buffer[BUFFER_SIZE];
    const char *cstr = CFStringGetCStringPtr(localeName, kCFStringEncodingASCII);
    if (NULL == cstr) {
        if (CFStringGetCString(localeName, buffer, BUFFER_SIZE, kCFStringEncodingASCII)) {
            cstr = buffer;
        }
    }

    if (NULL == cstr) {
        CFRelease((CFTypeRef)tokenizer);
        return NULL;
    }

    UBreakIteratorType type;
    // UBRK_CHARACTER, UBRK_WORD, UBRK_LINE, UBRK_SENTENCE
    switch (options & TYPE_MASK) { // mask off the high bits since they can be options
        case kCFStringTokenizerUnitWord:
        case kCFStringTokenizerUnitWordBoundary:
            type = UBRK_WORD;
            break;
        case kCFStringTokenizerUnitSentence:
        case kCFStringTokenizerUnitParagraph: // this seems incorrect.
            type = UBRK_SENTENCE;
            break;
        case kCFStringTokenizerUnitLineBreak:
            type = UBRK_LINE;
            break;
    }

    UChar stack_text[BUFFER_SIZE] = {0};
    UChar *text = &stack_text[0];
    CFIndex len = CFStringGetLength(string);
    if (len > BUFFER_SIZE) {
        text = malloc(len * sizeof(UChar));
        if (text == NULL) {
            CFRelease(tokenizer);
            return NULL;
        }
    }
    CFStringGetCharacters(string, CFRangeMake(0, len), (UniChar *)text);
    UErrorCode err = 0;
    tokenizer->_break_itr = ubrk_open(type, cstr, text, len, &err);
    if (text != &stack_text[0]) {
        free(text);
    }

    if (tokenizer->_break_itr == NULL) {
        CFRelease(tokenizer);
        return NULL;
    }

    return tokenizer;
}

/*
This requires a fairly massive database and heuristic modeling of langauge.
CFStringRef CFStringTokenizerCopyBestStringLanguage(CFStringRef string, CFRange range) {

}
*/

void CFStringTokenizerSetString(CFStringTokenizerRef tokenizer, CFStringRef string, CFRange range) {

#warning TODO: range is not handled currently

    UChar stack_text[BUFFER_SIZE] = { 0 };
    UChar *text = &stack_text[0];
    CFIndex len = CFStringGetLength(string);
    if (len > BUFFER_SIZE) {
        text = malloc(len * sizeof(UChar));
        if (text == NULL) {
            return;
        }
    }
    CFStringGetCharacters(string, CFRangeMake(0, len), (UniChar *)text);
    UErrorCode err = 0;
    ubrk_setText(tokenizer->_break_itr, text, len, &err);
    if (text != &stack_text[0]) {
        free(text);
    }  
}

CFStringTokenizerTokenType CFStringTokenizerGoToTokenAtIndex(CFStringTokenizerRef tokenizer, CFIndex index) {
    int32_t res = ubrk_following(tokenizer->_break_itr, index);
    if (res == UBRK_DONE) {
        return kCFStringTokenizerTokenNone;
    } else {
        return kCFStringTokenizerTokenNormal;
    }
}

CFStringTokenizerTokenType CFStringTokenizerAdvanceToNextToken(CFStringTokenizerRef tokenizer) {
    int32_t type = ubrk_next(tokenizer->_break_itr);
    return type == UBRK_DONE ? kCFStringTokenizerTokenNone : kCFStringTokenizerTokenNormal;
}

CFRange CFStringTokenizerGetCurrentTokenRange(CFStringTokenizerRef tokenizer) {
    int32_t prev = ubrk_previous(tokenizer->_break_itr);
    int32_t curr = ubrk_next(tokenizer->_break_itr);
    if (curr == UBRK_DONE) {
        return CFRangeMake(0, -1);
    } else {
        return CFRangeMake(prev, curr - prev);
    }
}

CFTypeRef CFStringTokenizerCopyCurrentTokenAttribute(CFStringTokenizerRef tokenizer, CFOptionFlags attribute) {
    // docs says this can validly return null, seems reasonable...
    return NULL;
}

/*
This requires linguistic databases for compound words.
CFIndex CFStringTokenizerGetCurrentSubTokens(CFStringTokenizerRef tokenizer, CFRange *ranges, CFIndex maxRangeLength, CFMutableArrayRef derivedSubTokens) {

}
*/

