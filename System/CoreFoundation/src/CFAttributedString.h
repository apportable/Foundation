#if !defined(__COREFOUNDATION_CFATTRIBUTEDSTRING__)
#define __COREFOUNDATION_CFATTRIBUTEDSTRING__ 1

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>

CF_IMPLICIT_BRIDGING_ENABLED
CF_EXTERN_C_BEGIN

typedef const struct __CFAttributedString *CFAttributedStringRef;
typedef struct __CFAttributedString *CFMutableAttributedStringRef;

CF_EXPORT CFTypeID CFAttributedStringGetTypeID(void);
CF_EXPORT CFAttributedStringRef CFAttributedStringCreate(CFAllocatorRef alloc, CFStringRef str, CFDictionaryRef attributes);
CF_EXPORT CFAttributedStringRef CFAttributedStringCreateWithSubstring(CFAllocatorRef alloc, CFAttributedStringRef aStr, CFRange range);
CF_EXPORT CFAttributedStringRef CFAttributedStringCreateCopy(CFAllocatorRef alloc, CFAttributedStringRef aStr);
CF_EXPORT CFStringRef CFAttributedStringGetString(CFAttributedStringRef aStr);
CF_EXPORT CFIndex CFAttributedStringGetLength(CFAttributedStringRef aStr);
CF_EXPORT CFDictionaryRef CFAttributedStringGetAttributes(CFAttributedStringRef aStr, CFIndex loc, CFRange *effectiveRange);
CF_EXPORT CFTypeRef CFAttributedStringGetAttribute(CFAttributedStringRef aStr, CFIndex loc, CFStringRef attrName, CFRange *effectiveRange);
CF_EXPORT CFDictionaryRef CFAttributedStringGetAttributesAndLongestEffectiveRange(CFAttributedStringRef aStr, CFIndex loc, CFRange inRange, CFRange *longestEffectiveRange);
CF_EXPORT CFTypeRef CFAttributedStringGetAttributeAndLongestEffectiveRange(CFAttributedStringRef aStr, CFIndex loc, CFStringRef attrName, CFRange inRange, CFRange *longestEffectiveRange);
CF_EXPORT CFMutableAttributedStringRef CFAttributedStringCreateMutableCopy(CFAllocatorRef alloc, CFIndex maxLength, CFAttributedStringRef aStr);
CF_EXPORT CFMutableAttributedStringRef CFAttributedStringCreateMutable(CFAllocatorRef alloc, CFIndex maxLength);
CF_EXPORT void CFAttributedStringReplaceString(CFMutableAttributedStringRef aStr, CFRange range, CFStringRef replacement);
CF_EXPORT CFMutableStringRef CFAttributedStringGetMutableString(CFMutableAttributedStringRef aStr);
CF_EXPORT void CFAttributedStringSetAttributes(CFMutableAttributedStringRef aStr, CFRange range, CFDictionaryRef replacement, Boolean clearOtherAttributes);
CF_EXPORT void CFAttributedStringSetAttribute(CFMutableAttributedStringRef aStr, CFRange range, CFStringRef attrName, CFTypeRef value);
CF_EXPORT void CFAttributedStringRemoveAttribute(CFMutableAttributedStringRef aStr, CFRange range, CFStringRef attrName);
CF_EXPORT void CFAttributedStringReplaceAttributedString(CFMutableAttributedStringRef aStr, CFRange range, CFAttributedStringRef replacement);
CF_EXPORT void CFAttributedStringBeginEditing(CFMutableAttributedStringRef aStr);
CF_EXPORT void CFAttributedStringEndEditing(CFMutableAttributedStringRef aStr);

CF_EXPORT void _CFAttributedStringSetMutable(CFAttributedStringRef aStr, Boolean isMutable);

CF_EXTERN_C_END
CF_IMPLICIT_BRIDGING_DISABLED

#endif
