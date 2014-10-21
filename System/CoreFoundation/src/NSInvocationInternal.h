#import <objc/message.h>

// By grabbing at least 4 words for retSize, we can blindly copy r0-r3
// into retdata when returning from an invocation.
#define RET_SIZE_ARGS (4 * sizeof(int))

void __invoke__(void *send, void *retdata, marg_list args, size_t len, const char *rettype);

extern void _CF_forwarding_prep_0();
extern void _CF_forwarding_prep_1();