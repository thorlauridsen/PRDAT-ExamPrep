;;; Simplified example of 32-bit mode Windows nasm assembly

;;; To assemble, link and run on Windows 10 (64-bit OS):
;;; 
;;;   nasm -fwin32 winsimple.asm
;;;   cl winsimple.obj msvcrt.lib legacy_stdio_definitions.lib  /Fetry.exe
;;;   try.exe
;;;
;;; To run the Microsoft C linker cl you need an installation of Visual
;;; Studio C/C++ tools, and the middle command line above should be executed
;;; in a "x86 Native Tools Command Prompt for VS 2017" to link correctly,
;;; and NOT "x64 Native Tools Command Prompt for VS 2017".
	
global _main                   ; Define entry point for this code
extern _printf                 ; Refer to C library function

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
