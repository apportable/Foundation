//
//  CFStringTransform.c
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFString.h"
#include <unicode/utrans.h>

#define BUFFER_SIZE 256

// the ) is not a typo, these are the expected values...
const CFStringRef kCFStringTransformStripCombiningMarks = CFSTR(")kCFStringTransformStripCombiningMarks");
const CFStringRef kCFStringTransformToLatin = CFSTR(")kCFStringTransformToLatin");
const CFStringRef kCFStringTransformFullwidthHalfwidth = CFSTR(")kCFStringTransformFullwidthHalfwidth");
const CFStringRef kCFStringTransformLatinKatakana = CFSTR(")kCFStringTransformLatinKatakana");
const CFStringRef kCFStringTransformLatinHiragana = CFSTR(")kCFStringTransformLatinHiragana");
const CFStringRef kCFStringTransformHiraganaKatakana = CFSTR(")kCFStringTransformHiraganaKatakana");
const CFStringRef kCFStringTransformMandarinLatin = CFSTR(")kCFStringTransformMandarinLatin");
const CFStringRef kCFStringTransformLatinHangul = CFSTR(")kCFStringTransformLatinHangul");
const CFStringRef kCFStringTransformLatinArabic = CFSTR(")kCFStringTransformLatinArabic");
const CFStringRef kCFStringTransformLatinHebrew = CFSTR(")kCFStringTransformLatinHebrew");
const CFStringRef kCFStringTransformLatinThai = CFSTR(")kCFStringTransformLatinThai");
const CFStringRef kCFStringTransformLatinCyrillic = CFSTR(")kCFStringTransformLatinCyrillic");
const CFStringRef kCFStringTransformLatinGreek = CFSTR(")kCFStringTransformLatinGreek");
const CFStringRef kCFStringTransformToXMLHex = CFSTR(")kCFStringTransformToXMLHex");
const CFStringRef kCFStringTransformToUnicodeName = CFSTR(")kCFStringTransformToUnicodeName");
const CFStringRef kCFStringTransformStripDiacritics = CFSTR(")kCFStringTransformStripDiacritics");

static int32_t _CFStringTransformLength(const UReplaceable *rep) {
    CFMutableStringRef string = (CFMutableStringRef)rep;
    return CFStringGetLength(string);
}

static UChar _CFStringTransformCharAt(const UReplaceable *rep, int32_t offset) {
    CFMutableStringRef string = (CFMutableStringRef)rep;
    return CFStringGetCharacterAtIndex(string, offset);
}

static UChar32 _CFStringTransformChar32At(const UReplaceable *rep, int32_t offset) {
    CFMutableStringRef string = (CFMutableStringRef)rep;
    UniChar ch = CFStringGetCharacterAtIndex(string, offset);
    if (CFStringIsSurrogateHighCharacter(ch)) {
        UniChar low = CFStringGetCharacterAtIndex(string, offset + 1);
        return CFStringGetLongCharacterForSurrogatePair(ch, low);
    } else {
        return (UChar32)ch;
    }
}

static void _CFStringTransformReplace(UReplaceable *rep, int32_t start, int32_t limit, const UChar* text, int32_t textLength) {
    CFMutableStringRef string = (CFMutableStringRef)rep;
    CFStringRef replacement = CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, text, textLength, kCFAllocatorNull);
    CFStringReplace(string, CFRangeMake(start, limit - start), replacement);
    CFRelease(replacement);
}

static void _CFStringTransformExtract(UReplaceable *rep, int32_t start, int32_t limit, UChar* dst) {
    CFMutableStringRef string = (CFMutableStringRef)rep;
    CFStringGetCharacters(string, CFRangeMake(start, limit - start), dst);
}

static void _CFStringTransformCopy(UReplaceable *rep, int32_t start, int32_t limit, int32_t dest) {
    CFMutableStringRef string = (CFMutableStringRef)rep;
    UniChar stack_text[BUFFER_SIZE];
    UniChar *text = &stack_text[0];
    if (limit - start > BUFFER_SIZE) {
        text = malloc(limit - start);
        if (text == NULL) {
            // we cant throw a NSException here, but return before anything blows up...
            DEBUG_LOG("ICU Internal failure occurred, we are out of memory: time to go cry in a corner now...");
            return;
        }
    }

    CFStringGetCharacters(string, CFRangeMake(start, limit - start), text);
    CFStringRef insert = CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, text, limit - start, kCFAllocatorNull);
    CFStringInsert(string, dest, insert);
    CFRelease(insert);

    if (text != &stack_text[0]) {
        free(text);
    }
}

static inline UTransliterator *utrans_find(CFStringRef transform, UTransDirection dir, UErrorCode *error) {
    UEnumeration *uenum = NULL;
    UTransliterator *trans = NULL;
    do {
        uenum = utrans_openIDs(error);
        if (U_FAILURE(*error)) {
            DEBUG_LOG("%s", u_errorName(*error));
            break;
        }

        int32_t count = uenum_count(uenum, error);
        if (U_FAILURE(*error)) {
            DEBUG_LOG("%s", u_errorName(*error));
            break;
        }
        int32_t trans_idx = 0;
        while (trans_idx < count && trans == NULL) {
            int32_t idLen = 0;
            const UChar *uid = uenum_unext(uenum, &idLen, error);
            if (U_FAILURE(*error)) {
                DEBUG_LOG("%s", u_errorName(*error));
                break;
            }
            // this seems rather unlikely since we should have already broken
            // by the trans_idx exceeding the count
            if (uid == NULL) {
                break;
            }

            CFStringRef name = CFStringCreateWithCharactersNoCopy(kCFAllocatorDefault, uid, idLen, kCFAllocatorNull);
            // It would have been nice if these stirng constants were actually defined somewhere in icu, but sadly they are runtime metadata...
            if ((CFEqual(name, CFSTR("Any-Remove")) && CFEqual(transform, kCFStringTransformStripCombiningMarks)) ||
                (CFEqual(name, CFSTR("Any-Latin")) && CFEqual(transform, kCFStringTransformToLatin)) ||
                (CFEqual(name, CFSTR("Latin-Katakana")) && CFEqual(transform, kCFStringTransformLatinKatakana)) ||
                (CFEqual(name, CFSTR("Latin-Hiragana")) && CFEqual(transform, kCFStringTransformLatinHiragana)) ||
                (CFEqual(name, CFSTR("Hiragana-Katakana")) && CFEqual(transform, kCFStringTransformHiraganaKatakana)) ||
                (CFEqual(name, CFSTR("Latin-Hangul")) && CFEqual(transform, kCFStringTransformLatinHangul)) ||
                (CFEqual(name, CFSTR("Latin-Arabic")) && CFEqual(transform, kCFStringTransformLatinArabic)) ||
                (CFEqual(name, CFSTR("Latin-Hebrew")) && CFEqual(transform, kCFStringTransformLatinHebrew)) ||
                (CFEqual(name, CFSTR("Latin-Thai")) && CFEqual(transform, kCFStringTransformLatinThai)) ||
                (CFEqual(name, CFSTR("Latin-Cyrillic")) && CFEqual(transform, kCFStringTransformLatinCyrillic)) ||
                (CFEqual(name, CFSTR("Latin-Greek")) && CFEqual(transform, kCFStringTransformLatinGreek)) ||
                (CFEqual(name, CFSTR("Any-Hex/XML")) && CFEqual(transform, kCFStringTransformToXMLHex)) ||
                (CFEqual(name, CFSTR("Any-Name")) && CFEqual(transform, kCFStringTransformToUnicodeName)) ||
                (CFEqual(name, CFSTR("Accents-Any")) && CFEqual(transform, kCFStringTransformStripDiacritics))) {
                trans = utrans_openU(uid, idLen, dir, NULL, 0, NULL, error);
            }
            CFRelease(name);
            trans_idx++;
        }
    } while (0);

    if (uenum != NULL) {
        uenum_reset(uenum, error);
        uenum_close(uenum);
    }

    if (trans == NULL && (CFEqual(transform, kCFStringTransformStripCombiningMarks) ||
                          CFEqual(transform, kCFStringTransformToLatin) ||
                          CFEqual(transform, kCFStringTransformLatinKatakana) ||
                          CFEqual(transform, kCFStringTransformLatinHiragana) ||
                          CFEqual(transform, kCFStringTransformHiraganaKatakana) ||
                          CFEqual(transform, kCFStringTransformLatinHangul) ||
                          CFEqual(transform, kCFStringTransformLatinArabic) ||
                          CFEqual(transform, kCFStringTransformLatinHebrew) ||
                          CFEqual(transform, kCFStringTransformLatinCyrillic) ||
                          CFEqual(transform, kCFStringTransformLatinGreek) ||
                          CFEqual(transform, kCFStringTransformToXMLHex) ||
                          CFEqual(transform, kCFStringTransformToUnicodeName) ||
                          CFEqual(transform, kCFStringTransformStripDiacritics))) {
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            RELEASE_LOG("Unable to find transliterators in icu data: likely this is from not including the Transliterators section in building your icu.dat file");
        });
    }

    return trans;
}

Boolean CFStringTransform(CFMutableStringRef string, CFRange *range, CFStringRef transform, Boolean reverse) {
    UErrorCode err = 0;
    static UReplaceableCallbacks callbacks = {
        .length = &_CFStringTransformLength,
        .charAt = &_CFStringTransformCharAt,
        .char32At = &_CFStringTransformChar32At,
        .replace = &_CFStringTransformReplace,
        .extract = &_CFStringTransformExtract,
        .copy = &_CFStringTransformCopy,
    };
    UTransliterator *trans = NULL;
    Boolean success = false;
    int32_t start = 0;
    int32_t limit = CFStringGetLength(string);
    if (range != NULL) {
        range->location = kCFNotFound;
        range->length = 0;
    }
    do {
        // technically this data could potentially be cached, if it is used often, we should consider doing so, until then this should work
        trans = utrans_find(transform, reverse ? UTRANS_REVERSE : UTRANS_FORWARD, &err);
        if (trans == NULL) {
            break;
        }
        utrans_trans(trans, (UReplaceable *)string, &callbacks, start, &limit, &err);
        if (U_FAILURE(err)) {
            break;
        }
        utrans_close(trans);
        success = true;
    } while (0);

    if (success) {
        range->location = start;
        range->length = limit - start;
    }

    return success;
}

