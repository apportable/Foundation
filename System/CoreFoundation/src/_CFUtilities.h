#include <CoreFoundation/CFString.h>
#include <stdlib.h>

static char *CFStringUTF8Copy(CFStringRef cfString) {
    CFIndex length = CFStringGetLength(cfString);
    CFIndex size = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8);
    char *buffer = (char *)malloc(size);
    CFStringGetCString(cfString, buffer, size, kCFStringEncodingUTF8);
    return buffer;
}
