//
//  NSObjCRuntime.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <assert.h>
#import <objc/runtime.h>

#import <Foundation/NSException.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSString.h>

#import "NSObjCRuntimeInternal.h"

double NSFoundationVersionNumber = 1047.22;

// NSGetSizeAndAlignment does not allow for debugging sizes, like
// those emitted by method_getTypeEncoding, to occur in the type
// declaration ("i8" compared to just "i"). However,
// initWithObjCTypes: requires us to parse essentially the same
// format, but with the size hints, and so we let NSMethodSignature
// know this naughty little detail.

const char *__NSGetSizeAndAlignment(const char *decl, NSUInteger *size, NSUInteger *alignment, BOOL stripSizeHints)
{
    decl = stripQualifiersAndComments(decl);

    switch (*decl++) {
        case _C_CHR: {
            *size += sizeof(char);
            *alignment = MAX(*alignment, __alignof(char));
            break;
        }

        case _C_SHT: {
            *size += sizeof(short);
            *alignment = MAX(*alignment, __alignof(short));
            break;
        }

        case _C_INT: {
            *size += sizeof(int);
            *alignment = MAX(*alignment, __alignof(int));
            break;
        }

        case _C_LNG: {
            *size += sizeof(long);
            *alignment = MAX(*alignment, __alignof(long));
            break;
        }

        case _C_LNG_LNG: {
            *size += sizeof(long long);
            *alignment = MAX(*alignment, __alignof(long long));
            break;
        }

        case _C_UCHR: {
            *size += sizeof(unsigned char);
            *alignment = MAX(*alignment, __alignof(unsigned char));
            break;
        }

        case _C_USHT: {
            *size += sizeof(unsigned short);
            *alignment = MAX(*alignment, __alignof(unsigned short));
            break;
        }

        case _C_UINT: {
            *size += sizeof(unsigned int);
            *alignment = MAX(*alignment, __alignof(unsigned int));
            break;
        }

        case _C_ULNG: {
            *size += sizeof(unsigned long);
            *alignment = MAX(*alignment, __alignof(unsigned long));
            break;
        }

        case _C_ULNG_LNG: {
            *size += sizeof(unsigned long long);
            *alignment = MAX(*alignment, __alignof(unsigned long long));
            break;
        }

        case _C_BOOL: {
            *size += sizeof(BOOL);
            *alignment = MAX(*alignment, __alignof(BOOL));
            break;
        }

        case _C_FLT: {
            *size += sizeof(float);
            *alignment = MAX(*alignment, __alignof(float));
            break;
        }

        case _C_DBL: {
            *size += sizeof(double);
            *alignment = MAX(*alignment, __alignof(double));
            break;
        }

        case _C_LNG_DBL: {
            *size += sizeof(long double);
            *alignment = MAX(*alignment, __alignof(long double));
            break;
        }

        case _C_VOID: {
            // Apple claims a size and alignment of 0 for void. A
            // GCCism does allow sizeof(void), but it doesn't do the
            // right thing anyway.
            break;
        }

        case _C_CHARPTR: {
            *size += sizeof(char *);
            *alignment += sizeof(char *);
            break;
        }

        case _C_ID: {
            *size += sizeof(id);
            *alignment = MAX(*alignment, __alignof(id));
            if (decl[0] == _C_UNDEF)
            {
                ++decl;
            }
            break;
        }

        case _C_CLASS: {
            *size += sizeof(Class);
            *alignment = MAX(*alignment, __alignof(Class));
            break;
        }

        case _C_SEL: {
            *size += sizeof(SEL);
            *alignment = MAX(*alignment, __alignof(SEL));
            break;
        }

        case _C_PTR: {
            *size += sizeof(void *);
            *alignment = MAX(*alignment, __alignof(void *));
            if (decl[0] == _C_UNDEF) {
                //special-case ^? - _C_UNDEF is an error anywhere but after a _C_PTR or _C_ID (if found in structs, it's just a ?, not a token)
                ++decl;
            }
            else {
                // All pointers are the same size, but we still have to
                // consume the rest of the type.
                NSUInteger dummy_size = 0;
                NSUInteger dummy_alignment = 0;
                decl = __NSGetSizeAndAlignment(decl, &dummy_size, &dummy_alignment, stripSizeHints);
            }
            break;
        }

        case _C_ARY_B: {
            // strol() Just Works, as Apple does parse "[i]" as an array
            // of 0 ints. They also only allow decimal sizes (no hex or
            // any such thing).
            size_t count = strtol((char *)decl, (char **)&decl, 10);

            // The alignment is the same as the alignment of the member
            // type. The size of an array is the count times the size of
            // an array member, rounded up to a multiple of its alignment.
            decl = __NSGetSizeAndAlignment(decl, size, alignment, stripSizeHints);
            *size *= count;

            // Consume the ']'.
            ++decl;
            break;
        }

        case _C_STRUCT_B: {
            // The struct name is delineated either by '=', or by '}' for
            // opaque types.
            while (*decl != 0 && !strchr("=}", *decl)) {
                decl++;
            }

            // Consume the '=' or '}'.
            if (*(decl++) == _C_STRUCT_E)
            {
                break;
            }

            while (*decl != _C_STRUCT_E) {
                NSUInteger field_size = 0;
                NSUInteger field_alignment = 0;
                decl = __NSGetSizeAndAlignment(decl, &field_size, &field_alignment, stripSizeHints);

                // Align the field, by rounding *size up to a multiple of
                // field_alignment.
                if (field_size > 0)
                {
                    size_t unalignment = *size % field_alignment;

                    if (unalignment > 0)
                    {
                        *size += field_alignment - unalignment;
                    }
                }

                // Add the size of the field, and possibly increase the
                // alignment of the struct.
                *size += field_size;
                *alignment = MAX(*alignment, field_alignment);
            }

            // The size must be a multiple of the alignment.
            if (*size > 0 && *alignment > 0)
            {
                size_t unalignment = *size % *alignment;
                if (unalignment > 0)
                {
                    *size += *alignment - unalignment;
                }
            }

            // Consume the '}'.
            ++decl;
            break;
        }

        case _C_UNION_B: {
            // The union name is delineated either by '=', or by ')' for
            // opaque types.
            while (*decl != 0 && !strchr("=)", *decl)) {
                decl++;
            }

            // Consume the '=' or ')'.
            if (*(decl++) == _C_UNION_E)
            {
                break;
            }

            while (*decl != _C_UNION_E) {
                NSUInteger field_size = 0;
                NSUInteger field_alignment = 0;
                decl = __NSGetSizeAndAlignment(decl, &field_size, &field_alignment, stripSizeHints);

                // The size and alignment are the maximum among all the fields.
                *size = MAX(*size, field_size);
                *alignment = MAX(*alignment, field_alignment);
            }

            // Consume the ')'.
            ++decl;
            break;
        }

        case _C_BFLD: // TODO throw an exception on bitfields.
        case 'j': // Unsupported
        default: {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
        }
    }

    if (stripSizeHints)
    {
        // Read off the advisory size.
        strtol((char *)decl, (char **)&decl, 10);
    }

    return decl;
}

const char *NSGetSizeAndAlignment(const char *decl, NSUInteger *sizep, NSUInteger *alignp)
{
    assert(decl != NULL);

    NSUInteger size = 0;
    NSUInteger alignment = 0;

    if (*decl != '\0')
    {
        decl = __NSGetSizeAndAlignment(decl, &size, &alignment, NO);
    }

    if (sizep != NULL) {
        *sizep = size;
    }
    
    if (alignp != NULL) {
        *alignp = alignment;
    }

    return decl;
}
