#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/mman.h>
#include <pthread.h>
#include <objc/runtime.h>
#include <Block.h>
#include "Block_private.h"

static void *executeBuffer = NULL;
static void *writeBuffer = NULL;
static ptrdiff_t offset = 0;
static pthread_mutex_t trampoline_lock = PTHREAD_MUTEX_INITIALIZER;

typedef struct {
    void *block_data;
    void *trampoline;
} block_trampoline_t;

static block_trampoline_t invalid_trampoline = { NULL, NULL };

static block_trampoline_t alloc_buffer(size_t size, void *ctx)
{
    block_trampoline_t tramp = invalid_trampoline;
    pthread_mutex_lock(&trampoline_lock);
    do {
        if (offset == 0 || offset + size >= PAGE_SIZE)
        {
            void *buffer = mmap(NULL, PAGE_SIZE, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_ANON|MAP_SHARED, -1, 0);
            if (__builtin_expect(buffer == MAP_FAILED, 0))
            {
                break;
            }
            executeBuffer = buffer;
            *((void**)buffer) = writeBuffer;
            writeBuffer = buffer;
            offset = sizeof(void*);
        }
        tramp.block_data = writeBuffer + offset;
        tramp.trampoline = executeBuffer + offset;
        offset += size;
    } while (0);
    pthread_mutex_unlock(&trampoline_lock);
    return tramp;
}

extern void __objc_block_trampoline;
extern void __objc_block_trampoline_end;
extern void __objc_block_trampoline_sret;
extern void __objc_block_trampoline_end_sret;

static unsigned long long massive_failure_imp(id self, SEL _cmd, ...)
{
    RELEASE_LOG("There has been a catastrophic failure in the objc runtime, set a breakpoint at massive_failure_imp to debug");
    return 0ULL;
}

IMP imp_implementationWithBlock(id block)
{
    struct Block_layout *b = (struct Block_layout *)block;
    void *start;
    void *end;

    if ((b->flags & BLOCK_USE_STRET) == BLOCK_USE_STRET)
    {
        start = &__objc_block_trampoline_sret;
        end = &__objc_block_trampoline_end_sret;
    }
    else
    {
        start = &__objc_block_trampoline;
        end = &__objc_block_trampoline_end;
    }

    size_t trampolineSize = end - start;
    // If we don't have a trampoline intrinsic for this architecture, return a
    // null IMP.
    if (0 >= trampolineSize) { return 0; }

    block_trampoline_t buf = alloc_buffer(trampolineSize + 2*sizeof(void*), block);
    if (__builtin_expect(buf.block_data == NULL || buf.trampoline == NULL, 0))
    {
        return (IMP)&massive_failure_imp;
    }
    void **out = buf.block_data;
    out[0] = (void*)b->invoke;
    out[1] = Block_copy(b);
    memcpy(&out[2], start, trampolineSize);
#if __arm__ || __mips__
    cacheflush((long)&out[2], (long)&out[2] + trampolineSize, 0);
#endif
    out = buf.trampoline;
    return (IMP)&out[2];
}

static void* isBlockIMP(void *anIMP)
{
    pthread_mutex_lock(&trampoline_lock);
    void *e = executeBuffer;
    void *w = writeBuffer;
    pthread_mutex_unlock(&trampoline_lock);
    while (e)
    {
        if ((anIMP > e) && (anIMP < e + PAGE_SIZE))
        {
            return ((char*)w) + ((char*)anIMP - (char*)e);
        }
        e = *(void**)e;
        w = *(void**)w;
    }
    return 0;
}

id imp_getBlock(IMP anImp)
{
    if (0 == isBlockIMP((void*)anImp)) { return 0; }
    return *(((void**)anImp) - 1);
}

BOOL imp_removeBlock(IMP anImp)
{
    void *w = isBlockIMP((void*)anImp);
    if (0 == w) { return NO; }
    Block_release(((void**)anImp) - 1);
    return YES;
}