/** Implementation of GSFFIInvocation for GNUStep
   Copyright (C) 2000 Free Software Foundation, Inc.

   Written: Adam Fedor <fedor@gnu.org>
   Date: Apr 2002

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
 */

#import "common.h"

#include <objc/runtime.h>

#define EXPOSE_NSInvocation_IVARS   1
#import "Foundation/NSException.h"
#import "Foundation/NSCoder.h"
#import "Foundation/NSDistantObject.h"
#import "Foundation/NSData.h"
#import "GSInvocation.h"
#import "GNUstepBase/GSObjCRuntime.h"
#import <pthread.h>
#import "cifframe.h"
#import "GSPrivate.h"

#ifdef __GNUSTEP_RUNTIME__
#include <objc/hooks.h>
#endif

#ifdef __GNU_LIBOBJC__
#include <objc/message.h>
#endif

#ifndef INLINE
#define INLINE inline
#endif

@interface NSInvocation (Private)
- (BOOL)_validReturn;
@end

#define ALIGN_TO(value, alignment) \
    (((value) % (alignment)) ? \
     ((value) + (alignment) - ((value) % (alignment))) : \
     (value) \
    )

static long long forward(id self, SEL sel, marg_list args)
{
    long long result = 0LL;

    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
    if (sig == nil) {
        DEBUG_LOG("selector not found %c[%s %s]", class_isMetaClass(object_getClass(self)) ? '+' : '-', class_getName(object_getClass(self)), sel_getName(sel));
        //DEBUG_BREAK();
        return result;
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    const char *returnType = [sig methodReturnType];
    [inv setTarget:self];
    [inv setSelector:sel];
    void *arguments = (void *)args;
    switch (*returnType)
    {
    case _C_ID:
    case _C_CLASS:
    case _C_SEL:
    case _C_BOOL:
    case _C_CHR:
    case _C_UCHR:
    case _C_SHT:
    case _C_USHT:
    case _C_INT:
    case _C_UINT:
    case _C_LNG:
    case _C_ULNG:
    case _C_LNG_LNG:
    case _C_ULNG_LNG:
    case _C_PTR:
    case _C_CHARPTR:
    case _C_VOID:
    case _C_FLT:
    case _C_DBL:
        break;
    default:
        if (objc_sizeof_type(returnType) > sizeof(void *))
        {
            arguments += sizeof(void *);     // account for stret
        }
        break;
    }

    arguments += sizeof(id) + sizeof(SEL);

    for (NSUInteger i = 2; i < [sig numberOfArguments]; i++)
    {
        const char *type = [sig getArgumentTypeAtIndex:i];
        size_t size = objc_sizeof_type(type);
        size_t align = objc_alignof_type(type);
        if (align)
        {
            arguments = (void *)ALIGN_TO((uintptr_t)arguments, align);
        }
        [inv setArgument:arguments atIndex:i];
        arguments += ALIGN_TO(size, sizeof(void *));
    }

    [self forwardInvocation:inv];
    switch (*returnType)
    {
    case _C_ID:
    case _C_CLASS:
    case _C_SEL:
    case _C_BOOL:
    case _C_CHR:
    case _C_UCHR:
    case _C_SHT:
    case _C_USHT:
    case _C_INT:
    case _C_UINT:
    case _C_LNG:
    case _C_ULNG:
    case _C_LNG_LNG:
    case _C_ULNG_LNG:
    case _C_PTR:
    case _C_CHARPTR:
    case _C_FLT:
    case _C_DBL:
        [inv getReturnValue:&result];
        break;
    case _C_VOID:
        break;
    default:
        if (objc_sizeof_type(returnType) > sizeof(void *))
        {
            [inv getReturnValue:*(void **)args];
        }
        else
        {
            [inv getReturnValue:&result];
        }
        break;
    }
    return result;
}

@implementation NSObject (Forward)

- (long long)forward:(SEL)sel :(marg_list)args
{
    return forward(self, sel, args);
}

@end

@implementation NSProxy (Forward)

- (long long)forward:(SEL)sel :(marg_list)args
{
    return forward(self, sel, args);
}

@end

/* Function that implements the actual forwarding */
typedef void (*ffi_closure_fun) (ffi_cif*,void*,void**,void*);

typedef void (*f_fun) ();

static void GSFFIInvocationCallback(ffi_cif*, void*, void **, void*);

/*
 * If we are using the GNU ObjC runtime we could simplify this
 * function quite a lot because this function is already present in
 * the ObjC runtime.  However, it is not part of the public API, so we
 * work around it.
 */

static INLINE GSMethod
gs_method_for_receiver_and_selector (id receiver, SEL sel)
{
    if (receiver)
    {
        return GSGetMethod((GSObjCIsInstance(receiver)
                            ? object_getClass(receiver) : (Class)receiver),
                           sel,
                           GSObjCIsInstance(receiver),
                           YES);
    }

    return 0;
}

@implementation GSFFIInvocation

static inline unsigned long long nil_imp(id self, SEL _cmd, ...)
{
    return 0LL;
}

static IMP gs_objc_msg_forward2 (id receiver, SEL sel)
{
    NSMutableData       *frame;
    cifframe_t            *cframe;
    ffi_closure           *cclosure;
    void            *executable;
    NSMethodSignature     *sig = nil;
    GSCodeBuffer          *memory;
    const char            *types;

    /*
     * If we're called with a typed selector, then use this when deconstructing
     * the stack frame.  This deviates from OS X behaviour (where there are no
     * typed selectors), but it always more reliable because the compiler will
     * set the selector types to represent the layout of the call frame.  This
     * means that the invocation will always deconstruct the call frame
     * correctly.
     */

    if (NULL != (types = GSTypesFromSelector(sel)))
    {
        sig = [NSMethodSignature signatureWithObjCTypes:types];
    }

    /* Take care here ... the receiver may be nil (old runtimes) or may be
     * a proxy which implements a method by forwarding it (so calling the
     * method might cause recursion).  However, any sane proxy ought to at
     * least implement -methodSignatureForSelector: in such a way that it
     * won't cause infinite recursion, so we check for that method being
     * implemented and call it.
     * NB. object_getClass() and class_respondsToSelector() should both
     * return NULL when given NULL arguments, so they are safe to use.
     */
    if (nil == sig)
    {
        Class c = object_getClass(receiver);

        if (class_respondsToSelector(c, @selector(methodSignatureForSelector:)))
        {
            sig = [receiver methodSignatureForSelector:sel];
        }
        if (nil == sig)
        {
            [NSException raise:NSInvalidArgumentException
             format:@"%c[%s %s]: unrecognized selector sent to instance %p",
             (class_isMetaClass(c) ? '+' : '-'),
             class_getName(c), sel_getName(sel), receiver];
            return (IMP)&nil_imp;
        }
    }

    /* Construct the frame and closure. */
    /* Note: We obtain cframe here, but it's passed to GSFFIInvocationCallback
       where it becomes owned by the callback invocation, so we don't have to
       worry about ownership */
    frame = cifframe_from_signature(sig);
    cframe = [frame mutableBytes];
    /* Autorelease the closure through GSAutoreleasedBuffer */

    memory = [GSCodeBuffer memoryWithSize:NSPageSize()];
    cclosure = [memory buffer];
    executable = [memory executable];
    if (cframe == NULL || cclosure == NULL)
    {
        [NSException raise:NSMallocException format:@"Allocating closure"];
    }
#if HAVE_FFI_PREP_CLOSURE_LOC
    if (ffi_prep_closure_loc(cclosure, &(cframe->cif),
                             GSFFIInvocationCallback, frame, executable) != FFI_OK)
    {
        [NSException raise:NSGenericException format:@"Preping closure"];
    }
#else
    if (ffi_prep_closure(cclosure, &(cframe->cif),
                         GSFFIInvocationCallback, frame) != FFI_OK)
    {
        [NSException raise:NSGenericException format:@"Preping closure"];
    }
#endif
    [memory protect];

    return (IMP)executable;
}

static __attribute__ ((__unused__))
IMP gs_objc_msg_forward (SEL sel)
{
    return gs_objc_msg_forward2 (nil, sel);
}
#ifdef __GNUSTEP_RUNTIME__
pthread_key_t thread_slot_key;
static struct objc_slot *
gs_objc_msg_forward3(id receiver, SEL op)
{
    /* The slot has its version set to 0, so it can not be cached.  This makes
       it
     * safe to free it when the thread exits. */
    struct objc_slot *slot = pthread_getspecific(thread_slot_key);

    if (NULL == slot)
    {
        slot = calloc(sizeof(struct objc_slot), 1);
        pthread_setspecific(thread_slot_key, slot);
    }
    slot->method = gs_objc_msg_forward2(receiver, op);
    return slot;
}

/** Hidden by legacy API define.  Declare it locally */
BOOL class_isMetaClass(Class cls);
BOOL class_respondsToSelector(Class cls, SEL sel);

/**
 * Runtime hook used to provide message redirections with libobjc2.
 * If lookup fails but this function returns non-nil then the lookup
 * will be retried with the returned value.
 *
 * Note: Every message sent by this function MUST be understood by the
 * receiver.  If this is not the case then there is a potential for infinite
 * recursion.
 */
static id gs_objc_proxy_lookup(id receiver, SEL op)
{
    id cls = object_getClass(receiver);
    BOOL resolved = NO;

    /* Note that __GNU_LIBOBJC__ implements +resolveClassMethod: and
     +resolveInstanceMethod: directly in the runtime instead.  */

    /* Let the class try to add a method for this thing. */
    if (class_isMetaClass(cls))
    {
        if (class_respondsToSelector(cls, @selector(resolveClassMethod:)))
        {
            resolved = [receiver resolveClassMethod:op];
        }
    }
    else
    {
        if (class_respondsToSelector(object_getClass(cls),
                                     @selector(resolveInstanceMethod:)))
        {
            resolved = [cls resolveInstanceMethod:op];
        }
    }
    if (resolved)
    {
        return receiver;
    }
    if (class_respondsToSelector(cls, @selector(forwardingTargetForSelector:)))
    {
        return [receiver forwardingTargetForSelector:op];
    }
    return nil;
}
#endif

/*
 *	This is the designated initialiser.
 */
- (id)initWithMethodSignature:(NSMethodSignature*)aSignature
{
    int i;

    if (aSignature == nil)
    {
        DESTROY(self);
        return nil;
    }
    _sig = RETAIN(aSignature);
    _numArgs = [aSignature numberOfArguments];
    _info = [aSignature methodInfo];
    _frame = cifframe_from_signature(_sig);
    [_frame retain];
    _cframe = [_frame mutableBytes];

    /* Make sure we have somewhere to store the return value if needed.
     */
    _retval = _retptr = 0;
    i = objc_sizeof_type (objc_skip_type_qualifiers ([_sig methodReturnType]));
    if (i > 0)
    {
        if (i <= sizeof(_retbuf))
        {
            _retval = _retbuf;
        }
        else
        {
            _retptr = NSAllocateCollectable(i, NSScannedOption);
            _retval = _retptr;
        }
    }
    return self;
}

/* Initializer used when we get a callback. uses the data provided by
   the callback. The cifframe was allocated by the forwarding function,
   but we own it now so we can free it */
- (id)initWithCallback:(ffi_cif *)cif
    values:(void **)vals
    frame:(void *)frame
    signature:(NSMethodSignature*)aSignature
{
    cifframe_t *f;
    int i;

    _sig = RETAIN(aSignature);
    _numArgs = [aSignature numberOfArguments];
    _info = [aSignature methodInfo];
    _frame = (NSMutableData*)frame;
    [_frame retain];
    _cframe = [_frame mutableBytes];
    f = (cifframe_t *)_cframe;
    f->cif = *cif;

    /* Copy the arguments into our frame so that they are preserved
     * in the NSInvocation if the stack is changed before the
     * invocation is used.
     */
    for (i = 0; i < f->nargs; i++)
    {
        memcpy(f->values[i], vals[i], f->arg_types[i]->size);
    }

    /* Make sure we have somewhere to store the return value if needed.
     */
    _retval = _retptr = 0;
    i = objc_sizeof_type (objc_skip_type_qualifiers ([_sig methodReturnType]));
    if (i > 0)
    {
        if (i <= sizeof(_retbuf))
        {
            _retval = _retbuf;
        }
        else
        {
            _retptr = NSAllocateCollectable(i, NSScannedOption);
            _retval = _retptr;
        }
    }
    return self;
}

/*
 * This is implemented as a function so it can be used by other
 * routines (like the DO forwarding)
 */
void
GSFFIInvokeWithTargetAndImp(NSInvocation *inv, id anObject, IMP imp)
{
    /* Do it */
    ffi_call(inv->_cframe, (f_fun)imp, (inv->_retval),
             ((cifframe_t *)inv->_cframe)->values);

    /* Don't decode the return value here (?) */
}

- (void)invokeWithTarget:(id)anObject
{
    id old_target;
    const char  *type;
    IMP imp;

    CLEAR_RETURN_VALUE_IF_OBJECT;
    _validReturn = NO;
    type = objc_skip_type_qualifiers([_sig methodReturnType]);

    /*
     *	A message to a nil object returns nil.
     */
    if (anObject == nil)
    {
        if (_retval)
        {
            memset(_retval, '\0', objc_sizeof_type (type));
        }
        _validReturn = YES;
        return;
    }

    /* Make sure we have a typed selector for forwarding.
     */
    NSAssert(_selector != 0, @"you must set the selector before invoking");
    if (0 == GSTypesFromSelector(_selector))
    {
        _selector = GSSelectorFromNameAndTypes(sel_getName(_selector),
                                               [_sig methodType]);
    }

    /*
     *	Temporarily set new target and copy it (and the selector) into the
     *	_cframe.
     */
    old_target = RETAIN(_target);
    [self setTarget:anObject];

    cifframe_set_arg((cifframe_t *)_cframe, 0, &_target, sizeof(id));
    cifframe_set_arg((cifframe_t *)_cframe, 1, &_selector, sizeof(SEL));

    if (_sendToSuper == YES)
    {
        Class cls;
        if (GSObjCIsInstance(_target)) {
            cls = class_getSuperclass(object_getClass(_target));
        }
        else{
            cls = class_getSuperclass((Class)_target);
        }
        {
            imp = class_getMethodImplementation(cls, _selector);
        }
    }
    else
    {
        GSMethod method;
        method = GSGetMethod((GSObjCIsInstance(_target)
                              ? (Class)object_getClass(_target)
                              : (Class)_target),
                             _selector,
                             GSObjCIsInstance(_target),
                             YES);
        imp = method_getImplementation(method);
    }

    [self setTarget:old_target];
    RELEASE(old_target);

    GSFFIInvokeWithTargetAndImp(self, anObject, imp);

    /* Decode the return value */
    if (*type != _C_VOID)
    {
        cifframe_decode_arg(type, _retval);
    }

    RETAIN_RETURN_VALUE;
    _validReturn = YES;
}

@end

/*
 * Return YES if the selector contains protocol qualifiers.
 */
static BOOL
gs_protocol_selector(const char *types)
{
    if (types == 0)
    {
        return NO;
    }
    while (*types != '\0')
    {
        if (*types == '+' || *types == '-')
        {
            types++;
        }
        while (isdigit(*types))
        {
            types++;
        }
        while (*types == _C_CONST
#ifdef _C_GCINVISIBLE
               || *types == _C_GCINVISIBLE
#endif
               )
        {
            types++;
        }
        if (*types == _C_IN
            || *types == _C_INOUT
            || *types == _C_OUT
            || *types == _C_BYCOPY
#ifdef _C_BYREF
            || *types == _C_BYREF
#endif
            || *types == _C_ONEWAY)
        {
            return YES;
        }
        if (*types == '\0')
        {
            return NO;
        }
        types = objc_skip_typespec(types);
    }
    return NO;
}

static void
GSFFIInvocationCallback(ffi_cif *cif, void *retp, void **args, void *user)
{
    id obj;
    SEL selector;
    GSFFIInvocation *invocation;
    NSMethodSignature   *sig;

    obj      = *(id *)args[0];
    selector = *(SEL *)args[1];

    if (!class_respondsToSelector(object_getClass(obj),
                                  @selector(forwardInvocation:)))
    {
        [NSException raise:NSInvalidArgumentException
         format:@"GSFFIInvocation: Class '%s'(%s) does not respond"
                @" to forwardInvocation: for '%s'",
         GSClassNameFromObject(obj),
         GSObjCIsInstance(obj) ? "instance":"class",
         selector ? sel_getName(selector):"(null)"];
    }

    sig = nil;
    if (gs_protocol_selector(GSTypesFromSelector(selector)) == YES)
    {
        sig = [NSMethodSignature signatureWithObjCTypes:
               GSTypesFromSelector(selector)];
    }
    if (sig == nil)
    {
        sig = [obj methodSignatureForSelector:selector];
    }

    /*
     * If we got a method signature from the receiving object,
     * ensure that the selector we are using matches the types.
     */
    if (sig != nil)
    {
        const char  *receiverTypes = [sig methodType];
        const char  *runtimeTypes = GSTypesFromSelector(selector);

        if (NO == GSSelectorTypesMatch(receiverTypes, runtimeTypes))
        {
            const char  *runtimeName = sel_getName(selector);

            selector = GSSelectorFromNameAndTypes(runtimeName, receiverTypes);
            if (runtimeTypes != 0)
            {
                /*
                 * FIXME ... if we have a typed selector, it probably came
                 * from the compiler, and the types of the proxied method
                 * MUST match those that the compiler supplied on the stack
                 * and the type it expects to retrieve from the stack.
                 * We should therefore discriminate between signatures where
                 * type qalifiers and sizes differ, and those where the
                 * actual types differ.
                 */
                NSDebugFLog(@"Changed type signature '%s' to '%s' for '%s'",
                            runtimeTypes, receiverTypes, runtimeName);
            }
        }
    }

    if (sig == nil)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"Can not determine type information for %s[%s %s]",
         GSObjCIsInstance(obj) ? "-":"+",
         GSClassNameFromObject(obj),
         selector ? sel_getName(selector):"(null)"];
    }
    if (sig)
    {
        invocation = [[GSFFIInvocation alloc] initWithCallback:cif
                      values:args
                      frame:user
                      signature:sig];
        IF_NO_GC([invocation autorelease]; )
        [invocation setTarget : obj];
        [invocation setSelector:selector];

        [obj forwardInvocation:invocation];

        /* If we are returning a value, we must copy it from the invocation
         * to the memory indicated by 'retp'.
         */
        if (retp != 0 && [invocation _validReturn] == YES)
        {
            [invocation getReturnValue:retp];
        }

        /* We need to (re)encode the return type for it's trip back. */
        if (retp) {
            cifframe_encode_arg([sig methodReturnType], retp);
        }
    }
}
