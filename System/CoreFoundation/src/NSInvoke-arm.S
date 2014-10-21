#include <arm/arch.h>

.globl __invoke__
    .type __invoke__, %function

.macro ENTRY name
    .text
#ifdef THUMB
    .thumb
#endif
    .align 5
    .globl    \name
#ifdef THUMB
    .thumb_func
#endif
\name:
.endm

.macro END_ENTRY name
.endm


ENTRY __invoke__

# void __invoke__(void (*msgSend)(...),
#                 void *retdata,
#                 marg_list args,
#                 size_t len)

        # Save retdata, scratch register, and return address.
        push {r1, r7, lr}

        # Copy retdata/stack pointer somewhere that will be saved.
        mov r7, sp

        # Save msgSend and retdata.
        push {r0, r1}

        # Copy msgSend somewhere that doesn't need to be saved.
        mov r12, r0

        # Allocate len on the stack and double word align.
        sub sp, sp, r3
        bic sp, #7

        # Allocate an extra 8 bytes on the stack so that we can safely
        # pop into r0-r3 later. Note that len must be at least 8, for
        # the receiver and selector.
        sub sp, sp, #8

        # Copy args onto the stack for msgSend to consume.
        # r0: pointer into the stack
        # r1: scratch
        # r2: pointer into args
        # r3: remaining length
        mov r0, sp
Lpush:
        ldr r1, [r2]
        sub r3, r3, #4
        cmp r3, #0x0
        str r1, [r0]
        add r2, r2, #4
        add r0, r0, #4
        bne Lpush

        # Put up to four arguments in r0-r3.
        pop {r0, r1, r2, r3}

        # Call msgSend.
        mov lr, pc
        bx r12

        # Copy return value into retdata.
        ldr r12, [r7]
        stm r12, {r0, r1, r2, r3}

        # Return
        mov sp, r7
        pop {r1, r7, pc}

END_ENTRY __invoke__
