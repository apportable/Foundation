# Original - Christopher Lloyd <cjwl@objc.net>
.globl _objc_msgSendv
        .type   _objc_msgSendv, @function
_objc_msgSendv:
        pushl   %ebp
        movl    %esp, %ebp
        subl    $4,%esp    # align on 16-byte boundary
        pushl   12(%ebp)
        pushl   8(%ebp)
        call    _objc_msg_lookup
        movl 16(%ebp),%ecx # ecx=argumentFrameByteSize
        movl 20(%ebp),%edx # edx=argumentFrame
pushNext:
        subl $4,%ecx       # argumentFrameByteSize-=sizeof(int)
        cmpl $4,%ecx       # check if we're at _cmd in argumentFrame
        jle done
        pushl (%edx,%ecx)
        jmp pushNext
done:
        pushl 12(%ebp) # push _cmd
        pushl 8(%ebp)  # push self
        call *%eax
        leave
        ret
        .size   _objc_msgSendv, .-_objc_msgSendv
        .ident  "GCC: (GNU) 3.3.2"
