Running x86 assembly programs (Assembly/nasm/README.TXT)
--------------------------------------------------------

A1. To assemble and run assembly program macsimple.asm on MacOS:

NOT SUPPORTED

A2. To assemble and run assembly program linsimple.asm on Linux:

   nasm -f elf linsimple.asm -o try.o

   Then link the object file with the C library for the 32-bit x86
   (i386) architecture, producing an executable file called "try":
   
   gcc try.o -o try

   [Presumably some option is needed on a 64-bit machine, but which?]

   Then run the executable file:

   ./try


A3. To assemble and run assembly program winsimple.asm on Windows:

    Assemble file winsimple.asm for Windows (as a 32-bit target):

      nasm -fwin32 winsimple.asm

    Then link the object file with the C library for the 32-bit x86
    (i386) architecture, producing an executable file called "try":

      cl winsimple.obj msvcrt.lib legacy_stdio_definitions.lib /Fetry.exe

    Run the resulting try.exe file:

      try.exe

    To run the Microsoft C linker cl you need an installation of Visual
    Studio C/C++ tools, and the middle command line above should be executed
    in a "x86 Native Tools Command Prompt for VS 2017" to link correctly,
    and NOT "x64 Native Tools Command Prompt for VS 2017".


B1. To assemble and run assembly program macbetter on MacOS:

    nasm -f macho macbetter.asm -o try.o     ; Assemble            
    gcc -arch i386 -Wl,-no_pie try.o -o try  ; Link with C library 
    ./try                                    ; Run                 


C1. To assemble and run assembly program macfac on MacOS:

    nasm -f macho macfac.asm -o try.o        ; Assemble            
    gcc -arch i386 -Wl,-no_pie try.o -o try  ; Link with C library 
    ./try                                    ; Run                 

    Should print the number 362880 and a newline.
