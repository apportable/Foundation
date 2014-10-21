#include <i386/arch.h>

.globl __invoke__
    .type __invoke__, %function

.macro ENTRY name
    .text
    .align  4, 0x90
    .globl    \name
\name:
.endm

.macro END_ENTRY name
.endm


ENTRY __invoke__

# void __invoke__(void (*msgSend)(...),
#                 void *retdata,
#                 marg_list args,
#                 size_t frame_length,
#                 const char *return_type)

    # Save retdata, scratch register, and return address.
  push %ebp  # Prologue
  mov %esp, %ebp
  push %edi
  push %esi
  push %edx
  push %ebx

  mov 12+8(%ebp), %eax #$eax = frame_length
  mov 8+8(%ebp), %edx #$edx = args

  mov %esp, %ebx
  subl %eax, %esp  #push the stack down
  andl $-16, %esp  #and align

Lpush:
  movl -4(%eax,%edx), %edi
  movl %edi, -4(%esp,%eax)
  sub $4, %eax
  test %eax, %eax
  jne Lpush

  mov 0+8(%ebp), %edi #$edi = msgSend
  calll *%edi
  
  mov 4+8(%ebp), %esi #$esi = retdata

  mov %eax, (%esi) # copy the result (probably) into *retdata
  
  #next, check to see if we need to put something else (ie something from
  #the x87 registers or a 64-bit value) into *retdata instead. 

  mov 8+16(%ebp), %eax #$eax == return_type
  mov (%eax), %al
  cmpb $0x71, %al # if (returnType[0] == 'q') // int64_t
  je Lsixtyfourret
  cmpb $0x51, %al # if (returnType[0] == 'Q') // uint64_t
  je Lsixtyfourret
  cmpb $0x44, %al # if (returnType[0] == 'D') // long double
  je Llongdoubleret
  cmpb $0x64, %al # if (returnType[0] == 'd') // double
  je Ldoubleret
  cmpb $0x66, %al  # if (returnType[0] == 'f') // float
  jne Ldone
  fstps (%esi) # this is how to get things out of x87.
  # fstp pops and stores a certain length (determined by the suffix - 
  # s for float, l for double, t for long double - just go with it)
  # in the location given (in this case *$esi)
  jmp Ldone #then jump to to cleanup and return
Lsixtyfourret:
  # just store edx too
  mov %edx, 4(%esi)
  jmp Ldone
Ldoubleret:
  fstpl (%esi)
  jmp Ldone
Llongdoubleret:
  fstpt (%esi)

Ldone:
  mov %ebx, %esp # restore stack!
  pop %ebx
  pop %edx
  pop %esi
  pop %edi
  mov %ebp, %esp  # Epilogue
  pop %ebp
  ret

END_ENTRY __invoke__
