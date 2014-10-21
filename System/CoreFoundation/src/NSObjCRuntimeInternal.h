#include <string.h>

static inline const char *stripQualifiersAndComments(const char *decl)
{
    static const char *qualifiersAndComments = "nNoOrRV\"";

    // Skip type qualifiers.
    while (*decl != 0 && strchr(qualifiersAndComments, *decl)) {
        if (*decl == '"') {
            decl++;
            while (*decl++ != '"');
        }
        else {
            decl++;
        }
    }

    return decl;
}


const char *__NSGetSizeAndAlignment(const char *decl, NSUInteger *size, NSUInteger *alignment, BOOL stripSizeHints);

#define _C_LNG_DBL 'D' //add missing long double method signature constant character
