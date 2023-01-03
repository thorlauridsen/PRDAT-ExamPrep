;; Prolog and epilog for 1-argument C function call (needed on MacOS)
%macro call_prolog 0
       mov ebx, esp            ; Save pre-alignment stack pointer
       pop eax                 ; Pop the argument
       and esp, 0xFFFFFFF0     ; Align esp to 16 byte multiple
       sub esp, 8              ; Pad 8 bytes
       push ebx                ; Push old stack top
       push eax                ; Push argument again
%endmacro

%macro call_epilog 0
       add esp, 4              ; Pop argument
       pop ebx                 ; Get saved pre-alignment stack pointer
       mov esp, ebx            ; Restore stack top to pre-alignment state
%endmacro

EXTERN _printi
EXTERN _printc
EXTERN _checkargc
GLOBAL _asm_main
section .data
	glovars dd 0
section .text
_asm_main:
	push ebp
	mov ebp, esp
	pushad
	mov dword [glovars], esp
	sub dword [glovars], 4
	;check arg count:
	push dword [ebp+8]
	push dword 1
	call _checkargc
	add esp, 8
	; allocate globals:
	;set up command line arguments on stack:
	mov ecx, [ebp+8]
	mov esi, [ebp+12]
_args_next:
	cmp ecx, 0
	jz _args_end
	push dword [esi]
	add esi, 4
	sub ecx, 1
	jmp _args_next               ;repeat until --ecx == 0
_args_end:
	sub ebp, 4                   ; make ebp point to first arg
	push ebp
	call near _main
	;clean up stuff pushed onto stack:
	mov esp, dword [glovars]
	add esp, 4
	popad
	mov esp, ebp
	pop ebp
	ret
_main:				;start set up frame
	pop eax			; retaddr
	pop ebx			; oldbp
	sub esp, 8
	mov esi, esp
	mov ebp, esp
	add ebp, 4		; 4*arity
_main_pro_1:			; slide arguments
	cmp ebp, esi
	jz _main_pro_2
	mov ecx, [esi+8]
	mov [esi], ecx
	add esi, 4
	jmp _main_pro_1
_main_pro_2:
	sub ebp, 4
	mov [ebp+8], eax
	mov [ebp+4], ebx
_main_tc:	;end set up frame
	jmp near L2
L1:				;Label
	lea ebx, [ebp - 0]
	mov ebx, [ebx]
	push ebx
	call_prolog
	call _printi
	call_epilog
	add esp, 4
	lea ecx, [ebp - 0]
	lea ebx, [ebp - 0]
	mov ebx, [ebx]
	mov edx, 1
	sub ebx, edx
	mov [ecx], ebx
	sub esp, 0
L2:				;Label
	lea ebx, [ebp - 0]
	mov ebx, [ebx]
	mov ecx, 0
	xor eax, eax
	cmp ebx, ecx
	setg al
	mov ebx, eax
	cmp ebx, 0
	jnz near L1
	mov ebx, 10
	push ebx
	call_prolog
	call _printc
	call_epilog
	add esp, 4
	sub esp, 0
	add esp, 4
	pop ebp
	ret
