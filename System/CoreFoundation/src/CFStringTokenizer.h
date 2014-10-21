#if !defined(__COREFOUNDATION_CFSTRINGTOKENIZER__)
#define __COREFOUNDATION_CFSTRINGTOKENIZER__ 1

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFLocale.h>
#include <CoreFoundation/CFString.h>

CF_IMPLICIT_BRIDGING_ENABLED
CF_EXTERN_C_BEGIN

typedef struct __CFStringTokenizer *CFStringTokenizerRef;

enum {
    kCFStringTokenizerUnitWord                     = 0,
    kCFStringTokenizerUnitSentence                 = 1,
    kCFStringTokenizerUnitParagraph                = 2,
    kCFStringTokenizerUnitLineBreak                = 3,
    kCFStringTokenizerUnitWordBoundary             = 4,
    kCFStringTokenizerAttributeLatinTranscription  = 1UL << 16,
    kCFStringTokenizerAttributeLanguage            = 1UL << 17,
};

typedef CF_OPTIONS(CFOptionFlags, CFStringTokenizerTokenType) {
    kCFStringTokenizerTokenNone                    = 0,
    kCFStringTokenizerTokenNormal                  = 1UL << 0,
    kCFStringTokenizerTokenHasSubTokensMask        = 1UL << 1,
    kCFStringTokenizerTokenHasDerivedSubTokensMask = 1UL << 2,
    kCFStringTokenizerTokenHasHasNumbersMask       = 1UL << 3,
    kCFStringTokenizerTokenHasNonLettersMask       = 1UL << 4,
    kCFStringTokenizerTokenIsCJWordMask            = 1UL << 5
};

CF_EXPORT CFStringRef CFStringTokenizerCopyBestStringLanguage(CFStringRef string, CFRange range);
CF_EXPORT CFTypeID CFStringTokenizerGetTypeID(void);
CF_EXPORT CFStringTokenizerRef CFStringTokenizerCreate(CFAllocatorRef alloc, CFStringRef string, CFRange range, CFOptionFlags options, CFLocaleRef locale);
CF_EXPORT void CFStringTokenizerSetString(CFStringTokenizerRef tokenizer, CFStringRef string, CFRange range);
CF_EXPORT CFStringTokenizerTokenType CFStringTokenizerGoToTokenAtIndex(CFStringTokenizerRef tokenizer, CFIndex index);
CF_EXPORT CFStringTokenizerTokenType CFStringTokenizerAdvanceToNextToken(CFStringTokenizerRef tokenizer);
CF_EXPORT CFRange CFStringTokenizerGetCurrentTokenRange(CFStringTokenizerRef tokenizer);
CF_EXPORT CFTypeRef CFStringTokenizerCopyCurrentTokenAttribute(CFStringTokenizerRef tokenizer, CFOptionFlags attribute);
CF_EXPORT CFIndex CFStringTokenizerGetCurrentSubTokens(CFStringTokenizerRef tokenizer, CFRange *ranges, CFIndex maxRangeLength, CFMutableArrayRef derivedSubTokens);

CF_EXTERN_C_END
CF_IMPLICIT_BRIDGING_DISABLED

#endif /* ! __COREFOUNDATION_CFSTRINGTOKENIZER__ */
