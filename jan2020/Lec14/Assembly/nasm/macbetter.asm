;;; Example of 32-bit mode Mac OS nasm assembly, with stack alignment

;;; In the MacOS ABI, system functions such as _printf must be
;;; called with the stack aligned to a 16 byte boundary.  Assuming
;;; that _main was called with 16-byte alignment, this works below
;;; because we push 12 bytes (EBP, EAX, mystring) and the x86 call
;;; instruction pushes 4 bytes (EIP), so the stack remains 16-byte
;;; aligned.

;;; This code adheres to the C calling convention where the called
;;; function must preserve the EBX register across the call.

;;; Assemble, link and run like this from a Terminal:   
;;;    nasm -f macho macbetter.asm -o try.o     ; Assemble            
;;;    gcc -arch i386 -Wl,-no_pie try.o -o try  ; Link with C library 
;;;    ./try                                    ; Run                 

;;; Macros for 16-byte stack alignment. The argument is the amount of
;;; padding in bytes, and should be 16 minus the argument size in
;;; bytes modulo 16.  If you push a 4-byte argument, the padding
;;; should be 12 bytes.
        
%macro clib_prolog 1
    mov ebx, esp        ; remember current esp
    and esp, 0xFFFFFFF0 ; align to next 16 byte boundary
    sub esp, 12         ; skip ahead 12 so we can store original esp
    push ebx            ; store esp (16 bytes aligned again)
    sub esp, %1         ; pad for arguments 
%endmacro

; arg must match most recent call to clib_prolog
%macro clib_epilog 1
    add esp, %1         ; remove arg padding
    pop ebx             ; get original esp
    mov esp, ebx        ; restore
%endmacro

        
global _main                    ; Define entry point for this code
extern _printf                  ; Refer to C library function

section .text
 
_main:
        push ebp                ; save old base pointer
        mov ebp, esp            ; set new base pointer
        push ebx                ; save EBX register (callee-saves convention)

        clib_prolog 8           ; 16-align stack, assuming 8 argument bytes
        mov eax, [myint]        ; load constant 3456 into EAX
        add eax, 120000         ; add 120000 to EAX
        push eax                ; push EAX value to print
        push dword mystring     ; push format string reference
        call _printf            ; call C library printf function
        add esp, 8		; discard arguments, 8 bytes
        clib_epilog 8           ; remove padding for stack alignment

        clib_prolog 8           ; 16-align stack, assuming 8 argument bytes
        push dword [myint]      ; push value to print
        push dword mystring     ; push format string reference
        call _printf            ; call C library printf function
        add esp, 8              ; discard arguments, 8 bytes
        clib_epilog 8           ; remove padding for stack alignment

        mov eax, 0              ; set return value
        pop ebx                 ; restore EBX register
        mov esp, ebp            ; reset stack to base pointer
        pop ebp                 ; restore old base pointer
        ret                     ; return to caller

section .data
        myint           dd 3456
        mystring        db      'The result is ->%d<-', 10, 0
