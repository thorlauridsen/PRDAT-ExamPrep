Compiling and loading the micro-C evaluator and parser (Assembly/README.TXT)
----------------------------------------------------------------------------

Archive assembly.zip contains the files used below.

A. To assemble, link and run x86 assembly programs, see nasm/README.TXT


B. To compile the nasm-generating micro-C compiler and use it.

   First compile and load the micro-C lexer and parser specifications,
   the bytecode assembler, and the assembly-generating micro-C
   compiler:
   
   fslex --unicode CLex.fsl
   fsyacc --module CPar CPar.fsy
   fsharpi -r FsLexYacc.Runtime.dll Absyn.fs CPar.fs CLex.fs Parse.fs X86.fs X86Comp.fs ParseAndComp.fs

   open ParseAndComp;;
   compileToFile (fromFile "ex1.c") "ex1.asm";;
   compileToFile (fromFile "ex6.c") "ex6.asm";;
   compileToFile (fromFile "ex11.c") "ex11.asm";;

   Then the generated assembly code in the .asm files must be
   assembled and linked with the C driver code in driver.c.  Precisely
   how depends on the platform; see below.


C. Build a micro-C compiler (generating assembly code) as a command-line program microccasm

   fslex --unicode CLex.fsl
   fsyacc --module CPar CPar.fsy
   fsharpc --standalone -r FsLexYacc.Runtime.dll  Absyn.fs CPar.fs CLex.fs Parse.fs X86.fs X86Comp.fs ParseAndComp.fs MicroCCAsm.fs -o microccasm.exe

   fsc -r FsLexYacc.Runtime.dll  Absyn.fs CPar.fs CLex.fs Parse.fs X86.fs X86Comp.fs ParseAndComp.fs MicroCCAsm.fs -o microccasm.exe

   microccasm ex11.c

----------------------------------------------------------------------

ASSEMBLING, LINKING AND RUNNING COMPILED MICRO-C PROGRAMS

MacOS: NOT SUPPORTED

------

Linux:

   gcc -m32 -c driver.c		
   nasm -f elf ex11.asm
   gcc -m32 driver.o ex11.o -o try11
   ./try11 8

   No underscores (_) in external function names.

   Stack alignment constraints are not needed, but harmless.

------

Windows (Windows 10, Command Prompt for VS 2017):

   cl -c driver.c
   nasm -f win32 ex11.asm
   cl driver.obj ex11.obj /Fetry11.exe
   try11.exe 8
   
   Must use underscore-prefixed external names _printi, _printc, ...

   Stack alignment constraints are not needed, but harmless.
