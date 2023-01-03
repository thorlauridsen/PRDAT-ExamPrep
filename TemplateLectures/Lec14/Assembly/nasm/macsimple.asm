;;; Simplified example of 32-bit mode Mac OS nasm assembly

;;; In MacOS, system functions such as _printf must be
;;; called with the stack aligned to a 16 byte boundary.  Assuming
;;; that _main was called with 16-byte alignment, this works below
;;; because the call to _main pushed a 4-byte return address and we push
;;; 12 bytes (EBP, EAX, mystring), so the stack is (accidentally)
;;; 16-byte aligned again before the call to _printf.

;;; The C calling convention actually requires the called function to
;;; preserve the EBX register across the call; it is a callee-saves
;;; register.  This is done properly in the macbetter.asm example,
;;; which also shows how to deal with 16-byte stack alignment.
        
;;; Assemble, link and run like this from a Terminal:
;;;    nasm -f macho macsimple.asm -o try.o             ; Assemble            
;;;    gcc -arch i386 -Wl,-no_pie try.o -o try          ; Link with C library 
;;;    ./try                                            ; Run                 

global _main                    ; Define entry point for this code
extern _printf                  ; Refer to C library function

section .text
                
_main:
        push ebp                ; Save old base pointer
        mov ebp, esp            ; Set new base pointer
        mov eax, [myint]        ; Load constant 3456 into EAX
        add eax, 120000         ; Add 120000 to EAX
        push eax                ; Push EAX value to print
        push dword mystring     ; Push format string reference
        call _printf            ; Call C library printf function
        add esp, 8              ; Discard arguments, 8 bytes
        mov eax, 0              ; Set return value, success
        mov esp, ebp            ; Reset stack to base pointer
        pop ebp                 ; Restore old base pointer
        ret                     ; Return to caller

section .data
        myint           dd 3456
        mystring        db      'The result is ->%d<-', 10, 0
