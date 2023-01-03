;;; Recursive function (factorial) in 32-bit nasm assembly, with stack alignment

;;; Assemble, link and run like this from a Terminal:   
;;;    nasm -f macho macfac.asm -o try.o        ; Assemble            
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

;;; Compute and print fac(9), should be 362,880
	
_main:
        push 	ebp		; save old base pointer
        mov 	ebp, esp	; set new base pointer
        push 	ebx		; save EBX register (callee-saves convention)
	push	dword 9		; Push 9
	call	fac		; Compute fac(9) with result in EAX
	add	esp, 4		; Remove argument
        clib_prolog 12          ; 16-align stack, assuming 4 argument bytes
        push 	eax		; push EAX value to print
        call 	printi		; call printi function
        add 	esp, 4		; discard argument, 4 bytes
        push 	dword 10	; push ASCII dec 10 (newline) character to print
        call 	printc		; call printc function
        add 	esp, 4		; discard argument, 4 bytes
        clib_epilog 12          ; remove padding for stack alignment
        mov 	eax, 0		; set return value
        pop 	ebx		; restore EBX register
        mov 	esp, ebp	; reset stack to base pointer
        pop 	ebp		; restore old base pointer
        ret                     ; return to caller
	
;;; Function fac computes n! in register EAX

fac:
	push	ebp		; Save ebp on stack
	mov	ebp, esp	; Save stack pointer in ebp
	mov	eax, [ebp+8]	; Get argument n
	cmp	eax, 0
	je	.false		; If n==0 return 1
	dec	eax		; Else push n-1 ...
	push	eax
	call	fac		; ... and compute fac(n-1)
	add	esp, byte 4
	mul	dword [ebp+8]	; ... then multiply eax by n
	jmp	.end		
.false:	mov	eax, 1
.end:	mov	esp, ebp
	pop	ebp
	ret
		
;;; The printi and printc routines are called like this:
;;;	push	<argument>
;;;	call	printi (or printc)
;;;	add	esp, byte 4
;;; They preserve the contents of all registers, for use in debugging.
;;; If the stack top is 16-byte aligned before the functions are called,
;;; then also before _printf is called: they push return address (4 bytes),
;;; EBP (4 bytes), pushad (8 * 4 bytes), and two arguments (2 * 4 bytes).
	
printi:				; Print decimal integer
	push	ebp		; Save ebp on stack
	mov	ebp, esp	; Save stack pointer in ebp
	pushad			; Save all registers
	push	dword [ebp+8]	; Push (integer) argument, 2nd printf arg
	push	dword printistr ; Push format string, 1st printf arg
	call	_printf		; Print using C library printf
	add	esp, byte 8	; Pop printf's arguments
	popad			; Restore all registers
	mov	esp, ebp	; Restore stack pointer
	pop	ebp		; Restore ebp
	ret			; Return

printc:				; Print ASCII character
	push	ebp		; Save ebp on stack
	mov	ebp, esp	; Save stack pointer in ebp
	pushad			; Save all registers
	push	dword [ebp+8]	; Push (char) argument, 2nd printf arg
	push	dword printcstr	; Push format string, 1st printf arg
	call	_printf		; Print using C library printf
	add	esp, byte 8	; Pop printf's arguments
	popad			; Restore all registers
	mov	esp, ebp	; Restore stack pointer
	pop	ebp		; Restore ebp
	ret			; Return 
		
segment .data
	printistr	db	'%d ', 0
	printcstr	db	'%c', 0
