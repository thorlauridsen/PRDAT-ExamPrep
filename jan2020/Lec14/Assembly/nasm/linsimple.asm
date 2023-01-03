;;; Simplified example of 32-bit mode Linux nasm assembly

global main                    	; Define entry point for this code
extern printf                  	; Refer to C library function

section .text
                
main:
        push ebp                ; Save old base pointer
        mov ebp, esp            ; Set new base pointer
        mov eax, [myint]        ; Load constant 3456 into EAX
        add eax, 120000         ; Add 120000 to EAX
        push eax                ; Push EAX value to print
        push dword mystring     ; Push format string reference
        call printf            	; Call C library printf function
        add esp, 8              ; Discard arguments, 8 bytes
        mov eax, 0              ; Set return value, success
        mov esp, ebp            ; Reset stack to base pointer
        pop ebp                 ; Restore old base pointer
        ret                     ; Return to caller

section .data
        myint           dd 3456
        mystring        db      'The result is ->%d<-', 10, 0
