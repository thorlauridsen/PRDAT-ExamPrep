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
	sub esp, 4
	sub esp, 4
	mov eax, esp
	sub eax, 4
	sub esp, 400
	push eax
	mov eax, esp
	sub eax, 4
	sub esp, 400
	push eax
	mov eax, esp
	sub eax, 4
	sub esp, 400
	push eax
	mov eax, esp
	sub eax, 4
	sub esp, 400
	push eax
	lea ecx, [ebp - 8]
	mov ebx, 1
	mov [ecx], ebx
	jmp near L10
L9:				;Label
	lea ecx, [ebp - 412]
	mov ecx, [ecx]
	lea edx, [ebp - 8]
	mov edx, [edx]
	sal edx, 2
	sub ecx, edx
	mov ebx, 0
	mov [ecx], ebx
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
	sub esp, 0
L10:				;Label
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	lea ecx, [ebp - 0]
	mov ecx, [ecx]
	xor eax, eax
	cmp ebx, ecx
	setle al
	mov ebx, eax
	cmp ebx, 0
	jnz near L9
	lea ecx, [ebp - 8]
	mov ebx, 1
	mov [ecx], ebx
	jmp near L12
L11:				;Label
	lea ecx, [ebp - 816]
	mov ecx, [ecx]
	lea edx, [ebp - 8]
	mov edx, [edx]
	sal edx, 2
	sub ecx, edx
	lea edx, [ebp - 1220]
	mov edx, [edx]
	lea esi, [ebp - 8]
	mov esi, [esi]
	sal esi, 2
	sub edx, esi
	mov ebx, 0
	mov [edx], ebx
	mov [ecx], ebx
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
	sub esp, 0
L12:				;Label
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov ecx, 2
	lea edx, [ebp - 0]
	mov edx, [edx]
	mov eax, ecx
	imul edx
	mov ecx, eax
	xor eax, eax
	cmp ebx, ecx
	setle al
	mov ebx, eax
	cmp ebx, 0
	jnz near L11
	lea ecx, [ebp - 4]
	lea edx, [ebp - 8]
	mov ebx, 1
	mov [edx], ebx
	mov [ecx], ebx
	jmp near L14
L13:				;Label
	jmp near L16
L15:				;Label
	jmp near L18
L17:				;Label
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
L18:				;Label
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	lea ecx, [ebp - 0]
	mov ecx, [ecx]
	xor eax, eax
	cmp ebx, ecx
	setle al
	mov ebx, eax
	cmp ebx, 0
	jz near L19
	lea ebx, [ebp - 412]
	mov ebx, [ebx]
	lea ecx, [ebp - 8]
	mov ecx, [ecx]
	sal ecx, 2
	sub ebx, ecx
	mov ebx, [ebx]
	cmp ebx, 0
	jnz near L21
	lea ebx, [ebp - 816]
	mov ebx, [ebx]
	lea ecx, [ebp - 8]
	mov ecx, [ecx]
	lea edx, [ebp - 4]
	mov edx, [edx]
	sub ecx, edx
	lea edx, [ebp - 0]
	mov edx, [edx]
	add ecx, edx
	sal ecx, 2
	sub ebx, ecx
	mov ebx, [ebx]
L21:				;Label
	cmp ebx, 0
	jnz near L20
	lea ebx, [ebp - 1220]
	mov ebx, [ebx]
	lea ecx, [ebp - 8]
	mov ecx, [ecx]
	lea edx, [ebp - 4]
	mov edx, [edx]
	add ecx, edx
	sal ecx, 2
	sub ebx, ecx
	mov ebx, [ebx]
L20:				;Label
L19:				;Label
	cmp ebx, 0
	jnz near L17
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	lea ecx, [ebp - 0]
	mov ecx, [ecx]
	xor eax, eax
	cmp ebx, ecx
	setle al
	mov ebx, eax
	cmp ebx, 0
	jz near L22
	lea ecx, [ebp - 1624]
	mov ecx, [ecx]
	lea edx, [ebp - 4]
	mov edx, [edx]
	sal edx, 2
	sub ecx, edx
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov [ecx], ebx
	lea ecx, [ebp - 816]
	mov ecx, [ecx]
	lea edx, [ebp - 8]
	mov edx, [edx]
	lea esi, [ebp - 4]
	mov esi, [esi]
	sub edx, esi
	lea esi, [ebp - 0]
	mov esi, [esi]
	add edx, esi
	sal edx, 2
	sub ecx, edx
	lea edx, [ebp - 1220]
	mov edx, [edx]
	lea esi, [ebp - 8]
	mov esi, [esi]
	lea edi, [ebp - 4]
	mov edi, [edi]
	add esi, edi
	sal esi, 2
	sub edx, esi
	lea esi, [ebp - 412]
	mov esi, [esi]
	lea edi, [ebp - 8]
	mov edi, [edi]
	sal edi, 2
	sub esi, edi
	mov ebx, 1
	mov [esi], ebx
	mov [edx], ebx
	mov [ecx], ebx
	lea ecx, [ebp - 4]
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
	lea ecx, [ebp - 8]
	mov ebx, 1
	mov [ecx], ebx
	sub esp, 0
	jmp near L23
L22:				;Label
	lea ecx, [ebp - 4]
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov edx, 1
	sub ebx, edx
	mov [ecx], ebx
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov ecx, 0
	xor eax, eax
	cmp ebx, ecx
	setg al
	mov ebx, eax
	cmp ebx, 0
	jz near L24
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 1624]
	mov ebx, [ebx]
	lea edx, [ebp - 4]
	mov edx, [edx]
	sal edx, 2
	sub ebx, edx
	mov ebx, [ebx]
	mov [ecx], ebx
	lea ecx, [ebp - 816]
	mov ecx, [ecx]
	lea edx, [ebp - 8]
	mov edx, [edx]
	lea esi, [ebp - 4]
	mov esi, [esi]
	sub edx, esi
	lea esi, [ebp - 0]
	mov esi, [esi]
	add edx, esi
	sal edx, 2
	sub ecx, edx
	lea edx, [ebp - 1220]
	mov edx, [edx]
	lea esi, [ebp - 8]
	mov esi, [esi]
	lea edi, [ebp - 4]
	mov edi, [edi]
	add esi, edi
	sal esi, 2
	sub edx, esi
	lea esi, [ebp - 412]
	mov esi, [esi]
	lea edi, [ebp - 8]
	mov edi, [edi]
	sal edi, 2
	sub esi, edi
	mov ebx, 0
	mov [esi], ebx
	mov [edx], ebx
	mov [ecx], ebx
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
	sub esp, 0
	jmp near L25
L24:				;Label
	sub esp, 0
L25:				;Label
	sub esp, 0
L23:				;Label
	sub esp, 0
L16:				;Label
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	lea ecx, [ebp - 0]
	mov ecx, [ecx]
	xor eax, eax
	cmp ebx, ecx
	setle al
	mov ebx, eax
	cmp ebx, 0
	jz near L26
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov ecx, 0
	xor eax, eax
	cmp ebx, ecx
	setne al
	mov ebx, eax
L26:				;Label
	cmp ebx, 0
	jnz near L15
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	lea ecx, [ebp - 0]
	mov ecx, [ecx]
	xor eax, eax
	cmp ebx, ecx
	setg al
	mov ebx, eax
	cmp ebx, 0
	jz near L27
	sub esp, 4
	lea ecx, [ebp - 1628]
	mov ebx, 1
	mov [ecx], ebx
	jmp near L30
L29:				;Label
	lea ebx, [ebp - 1624]
	mov ebx, [ebx]
	lea ecx, [ebp - 1628]
	mov ecx, [ecx]
	sal ecx, 2
	sub ebx, ecx
	mov ebx, [ebx]
	push ebx
	call_prolog
	call _printi
	call_epilog
	add esp, 4
	lea ecx, [ebp - 1628]
	lea ebx, [ebp - 1628]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
	sub esp, 0
L30:				;Label
	lea ebx, [ebp - 1628]
	mov ebx, [ebx]
	lea ecx, [ebp - 0]
	mov ecx, [ecx]
	xor eax, eax
	cmp ebx, ecx
	setle al
	mov ebx, eax
	cmp ebx, 0
	jnz near L29
	mov ebx, 10
	push ebx
	call_prolog
	call _printc
	call_epilog
	add esp, 4
	lea ecx, [ebp - 4]
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov edx, 1
	sub ebx, edx
	mov [ecx], ebx
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov ecx, 0
	xor eax, eax
	cmp ebx, ecx
	setg al
	mov ebx, eax
	cmp ebx, 0
	jz near L31
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 1624]
	mov ebx, [ebx]
	lea edx, [ebp - 4]
	mov edx, [edx]
	sal edx, 2
	sub ebx, edx
	mov ebx, [ebx]
	mov [ecx], ebx
	lea ecx, [ebp - 816]
	mov ecx, [ecx]
	lea edx, [ebp - 8]
	mov edx, [edx]
	lea esi, [ebp - 4]
	mov esi, [esi]
	sub edx, esi
	lea esi, [ebp - 0]
	mov esi, [esi]
	add edx, esi
	sal edx, 2
	sub ecx, edx
	lea edx, [ebp - 1220]
	mov edx, [edx]
	lea esi, [ebp - 8]
	mov esi, [esi]
	lea edi, [ebp - 4]
	mov edi, [edi]
	add esi, edi
	sal esi, 2
	sub edx, esi
	lea esi, [ebp - 412]
	mov esi, [esi]
	lea edi, [ebp - 8]
	mov edi, [edi]
	sal edi, 2
	sub esi, edi
	mov ebx, 0
	mov [esi], ebx
	mov [edx], ebx
	mov [ecx], ebx
	lea ecx, [ebp - 8]
	lea ebx, [ebp - 8]
	mov ebx, [ebx]
	mov edx, 1
	add ebx, edx
	mov [ecx], ebx
	sub esp, 0
	jmp near L32
L31:				;Label
	sub esp, 0
L32:				;Label
	sub esp, -4
	jmp near L28
L27:				;Label
	sub esp, 0
L28:				;Label
	sub esp, 0
L14:				;Label
	lea ebx, [ebp - 4]
	mov ebx, [ebx]
	mov ecx, 0
	xor eax, eax
	cmp ebx, ecx
	setg al
	mov ebx, eax
	cmp ebx, 0
	jnz near L13
	sub esp, -1624
	add esp, 4
	pop ebp
	ret
