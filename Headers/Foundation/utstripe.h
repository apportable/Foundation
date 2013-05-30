//
//  utstripe.h
//

#ifndef _UTSTRIPE_H_
#define _UTSTRIPE_H_

#include "uthash.h"

// In order to generate uniform stripe ids, pointer
// allocations are assumed to be at minimum word aligned
// The low bits and high bits determine the significant
// bits in order to generate a uniform mapping

#define HASH_STRIPE_LOWBITS 4
#define HASH_STRIPE_HIGHBITS 9

#define HASH_STRIPE(hash_type) hash_type ## _stripe

// In order to make the hash table access thread-safe
// a locking stragey has to be implemented. By default
// the locking stragey uses pthread_mutex based locking.
// To define a custom locking strategy, four defines
// must be declared before including this file:
// HASH_STRIPE_LOCK_TYPE:      determines the stripe hash
//                             lock variable type
// HASH_STRIPE_LOCKFN(lock):   defines the action taken
//                             to lock the stripe
// HASH_STRIPE_UNLOCKFN(lock): defines the action taken
//                             to unlock the stripe
// HASH_STRIPE_INIT:           determines the constant
//                             used to initialize the lock

#if !defined(HASH_STRIPE_LOCKING_CUSTOM)
#if !defined(HASH_STRIPE_LOCKING_PTHREAD)
#include <pthread.h>
#define HASH_STRIPE_LOCKING_PTHREAD 1
#endif
#if !defined(HASH_STRIPE_LOCKING_OSATOMIC)
#define HASH_STRIPE_LOCKING_OSATOMIC 0
#elif HASH_STRIPE_LOCKING_OSATOMIC
#include <libkern/OSAtomic.h>
#endif
#else
#define HASH_STRIPE_LOCKING_PTHREAD 0
#define HASH_STRIPE_LOCKING_OSATOMIC 0
#endif

#if HASH_STRIPE_LOCKING_PTHREAD

#define HASH_STRIPE_LOCK_TYPE pthread_mutex_t
#define HASH_STRIPE_LOCKFN(lock) pthread_mutex_lock(&(lock))
#define HASH_STRIPE_UNLOCKFN(lock) pthread_mutex_unlock(&(lock))
#define HASH_STRIPE_INIT PTHREAD_MUTEX_INITIALIZER

#elif HASH_STRIPE_LOCKING_OSATOMIC

#define HASH_STRIPE_LOCK_TYPE OSSpinLock
#define HASH_STRIPE_LOCKFN(lock) OSSpinLockLock(&(lock))
#define HASH_STRIPE_UNLOCKFN(lock) OSSpinLockUnlock(&(lock))
#define HASH_STRIPE_INIT OS_SPINLOCK_INIT

#else

#if !defined(HASH_STRIPE_LOCK_TYPE)
#error Lock type must defined for custom locking
#endif

#if !defined(HASH_STRIPE_LOCKFN)
#error Lock function must defined for custom locking
#endif

#if !defined(HASH_STRIPE_UNLOCKFN)
#error Unlock function must defined for custom locking
#endif

#if !defined(HASH_STRIPE_INIT)
#error Init constant must defined for custom locking
#endif

#endif

// In order to prevent lock contention a reasonable number
// of expected threads and a reasonable time differential
// to the access of the lock of the stripe table is required
// define HASH_NSTRIPES to circumvent the default behavior,
// only values of 1,2,4,8 or 16 are accepted due to initializer
// constriants. The default behavior is 8 threads which is
// more than reasonable for any realistic application.
// In other words, the more often the lock is hit, the higher
// the number needs to be.

#ifndef HASH_NSTRIPES
#define HASH_NSTRIPES 8
#endif

#define HASH_STRIPE_INITIALIZER_1 \
    {HASH_STRIPE_INIT, NULL}

#define HASH_STRIPE_INITIALIZER_2 \
    HASH_STRIPE_INITIALIZER_1, \
    HASH_STRIPE_INITIALIZER_1

#define HASH_STRIPE_INITIALIZER_4 \
    HASH_STRIPE_INITIALIZER_2, \
    HASH_STRIPE_INITIALIZER_2

#define HASH_STRIPE_INITIALIZER_8 \
    HASH_STRIPE_INITIALIZER_4, \
    HASH_STRIPE_INITIALIZER_4

#define HASH_STRIPE_INITIALIZER_16 \
    HASH_STRIPE_INITIALIZER_8, \
    HASH_STRIPE_INITIALIZER_8

#if HASH_NSTRIPES == 1
#warning Using only one stripe may lead to performance degradation
#define HASH_STRIPE_INITIALIZER_ HASH_STRIPE_INITIALIZER_1
#elif HASH_NSTRIPES == 2
#define HASH_STRIPE_INITIALIZER_ HASH_STRIPE_INITIALIZER_2
#elif HASH_NSTRIPES == 4
#define HASH_STRIPE_INITIALIZER_ HASH_STRIPE_INITIALIZER_4
#elif HASH_NSTRIPES == 8
#define HASH_STRIPE_INITIALIZER_ HASH_STRIPE_INITIALIZER_8
#elif HASH_NSTRIPES == 16
#define HASH_STRIPE_INITIALIZER_ HASH_STRIPE_INITIALIZER_16
#else
#error Unsupported number of hash stripes, please define to 1,2,4,8 or 16
#endif

#define HASH_STRIPE_INITIALIZER { \
        HASH_STRIPE_INITIALIZER_ \
}

#define HASH_STRIPE_T(hash_type) \
    struct { \
        HASH_STRIPE_LOCK_TYPE lock; \
        hash_type *ht; \
    } HASH_STRIPE(hash_type)

#define HASH_STRIPE_IDENT_PTR(ptr) \
    ((((uintptr_t)ptr >> HASH_STRIPE_LOWBITS) ^ \
      ((uintptr_t)ptr >> HASH_STRIPE_HIGHBITS)) & (HASH_NSTRIPES - 1))

#define HASH_STRIPE_IDENT(key, elt) \
    HASH_STRIPE_IDENT_PTR(elt->key)

#define HASH_STRIPE_ADD_PTR(stripes, key, elt) \
    HASH_STRIPETABLE_ADD_PTR(hh, stripes, key, sizeof(void *), elt)

#define HASH_STRIPETABLE_ADD_PTR(hh, stripes, key, sz, elt) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT(key, elt)]; \
        HASH_STRIPE_LOCKFN(__stripe->lock); \
        HASH_ADD(hh, __stripe->ht, key, sz, elt); \
        HASH_STRIPE_UNLOCKFN(__stripe->lock); \
} while(0)

#define HASH_STRIPE_DEL(stripes, key, elt) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT(key, elt)]; \
        HASH_STRIPE_LOCKFN(__stripe->lock); \
        HASH_DEL(__stripe->ht, elt); \
        HASH_STRIPE_UNLOCKFN(__stripe->lock); \
} while(0)

#define HASH_STRIPE_DELUNLOCKED(stripes, key, elt) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT(key, elt)]; \
        HASH_DEL(__stripe->ht, elt); \
} while(0)


#define HASH_STRIPE_FIND(stripes, findptr, out) \
    HASH_STRIPETABLE_FIND(hh, stripes, findptr, sizeof(void *), out)

#define HASH_STRIPETABLE_FIND(hh, stripes, findptr, sz, out) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT_PTR(*findptr)]; \
        HASH_STRIPE_LOCKFN(__stripe->lock); \
        HASH_FIND(hh, __stripe->ht, findptr, sz, out); \
        HASH_STRIPE_UNLOCKFN(__stripe->lock); \
} while(0)

#define HASH_STRIPE_FINDLOCK(stripes, findptr, out) \
    HASH_STRIPETABLE_FINDLOCK(hh, stripes, findptr, sizeof(void *), out)

#define HASH_STRIPETABLE_FINDLOCK(hh, stripes, findptr, sz, out) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT_PTR(*findptr)]; \
        HASH_STRIPE_LOCKFN(__stripe->lock); \
        HASH_FIND(hh, __stripe->ht, findptr, sz, out); \
} while(0)

#define HASH_STRIPE_LOCK(stripes, ptr) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT_PTR(*ptr)]; \
        HASH_STRIPE_LOCKFN(__stripe->lock); \
} while(0)

#define HASH_STRIPE_UNLOCK(stripes, ptr) do { \
        typeof(stripes[0]) *__stripe = &stripes[HASH_STRIPE_IDENT_PTR(*ptr)]; \
        HASH_STRIPE_UNLOCKFN(__stripe->lock); \
} while(0)

#endif
