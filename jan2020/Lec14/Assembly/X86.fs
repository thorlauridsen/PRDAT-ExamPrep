(* File Assembly/X86.fs

   Instructions and assembly code emission for a x86 machine.
   sestoft@itu.dk * 2017-05-01

   We use some aspects of Niels Kokholm's SML version (March 2002).

   This compiler takes a less template-based approach closer to the
   x86 spirit:

   * We use 32 bit (aka double word) protected mode code.

   * Expressions are compiled to register-based code without use of
     the stack.

   * All local variables and parameters are stored in the stack.

   * All function arguments are passed on the stack.

   * There is no optimized register allocation across expressions and statements. 

   * We use all 32-bit registers of the x86-64 architecture.  

   * We use the native x86 call and ret instructions, which means that
     we must pust some prologue code at each function start to obey
     the calling conventions of the abstract machine.  This is the
     most important reason for splitting labels into ordinary labels
     and function entry point labels.  *)

module X86

(* The MacOS and Windows linkers expect an underscore (_) before
   external and global names, whereas the Linux/gcc linker does not. *)

let isLinux = false
let prefix = if isLinux then "" else "_"

let printi    = prefix + "printi"
let printc    = prefix + "printc"
let checkargc = prefix + "checkargc"
let asm_main  = prefix + "asm_main"

type label = string

type flabel = string

type reg32 =
    | Eax | Ecx | Edx | Ebx | Esi | Edi | Esp | Ebp

type rand =
    | Cst of int                        (* immediate dword n               *)
    | Reg of reg32                      (* register ebx                    *)
    | Ind of reg32                      (* register indirect [ebx]         *)
    | EbpOff of int                     (* ebp offset indirect [ebp - n]   *)
    | Glovars                           (* stackbase [glovars]             *)

type x86 =
    | Label of label                    (* symbolic label; pseudo-instruc. *)
    | FLabel of flabel * int            (* function label, arity; pseudo.  *)
    | Ins of string                     (* eg. sub esp, 4                  *)
    | Ins1 of string * rand             (* eg. push eax                    *)
    | Ins2 of string * rand * rand      (* eg. add eax, [ebp - 32]         *)
    | Jump of string * label            (* eg. jz near lab                 *)
    | PRINTI                            (* print [esp] as integer          *)
    | PRINTC                            (* print [esp] as character        *)

let fromReg reg =
    match reg with
    | Eax  -> "eax"
    | Ecx  -> "ecx"
    | Edx  -> "edx"
    | Ebx  -> "ebx"
    | Esi  -> "esi"
    | Edi  -> "edi"
    | Esp  -> "esp"
    | Ebp  -> "ebp"

let operand rand : string =
    match rand with
        | Cst n    -> string n
        | Reg reg  -> fromReg reg
        | Ind reg  -> "[" + fromReg reg + "]"
        | EbpOff n -> "[ebp - " + string n + "]"
        | Glovars  -> "[glovars]"

(* The five registers that can be used for temporary values in i386.
Allowing EDX requires special handling across IMUL and IDIV *)

let temporaries =
    [Ecx; Edx; Ebx; Esi; Edi]

let mem x xs = List.exists (fun y -> x=y) xs

let getTemp pres : reg32 option =
    let rec aux available =
        match available with
            | []          -> None
            | reg :: rest -> if mem reg pres then aux rest else Some reg
    aux temporaries

(* Get temporary register not in pres; throw exception if none available *)

let getTempFor (pres : reg32 list) : reg32 =
    match getTemp pres with
    | None     -> failwith "no more registers, expression too complex"
    | Some reg -> reg

let pushAndPop reg code = [Ins1("push", Reg reg)] @ code @ [Ins1("pop", Reg reg)]

(* Preserve reg across code, on the stack if necessary *)

let preserve reg pres code =
    if mem reg pres then
       pushAndPop reg code
    else
        code

(* Preserve all live registers around code, eg a function call *)

let rec preserveAll pres code =
    match pres with
    | []          -> code
    | reg :: rest -> preserveAll rest (pushAndPop reg code)

(* Generate new distinct labels *)

let (resetLabels, newLabel) = 
    let lastlab = ref -1
    ((fun () -> lastlab := 0), (fun () -> (lastlab := 1 + !lastlab; "L" + string(!lastlab))))

(* Convert one bytecode instr into x86 instructions in text form and pass to out *)

let x86instr2int out instr =
    let outlab lab = out (lab + ":\t\t\t\t;Label\n")
    let outins ins = out ("\t" + ins + "\n")
    match instr with
      | Label lab -> outlab lab
      | FLabel (lab, n)  -> out (lab + ":\t\t\t\t;start set up frame\n" +
                                 "\tpop eax\t\t\t; retaddr\n" +
                                 "\tpop ebx\t\t\t; oldbp\n" +
                                 "\tsub esp, 8\n" +
                                 "\tmov esi, esp\n" +
                                 "\tmov ebp, esp\n" +
                                 "\tadd ebp, " + string(4*n) + "\t\t; 4*arity\n" +
                                 lab + "_pro_1:\t\t\t; slide arguments\n" +
                                 "\tcmp ebp, esi\n" +
                                 "\tjz " + lab + "_pro_2\n" +
                                 "\tmov ecx, [esi+8]\n" +
                                 "\tmov [esi], ecx\n" +
                                 "\tadd esi, 4\n" +
                                 "\tjmp " + lab + "_pro_1\n" +
                                 lab + "_pro_2:\n" +
                                 "\tsub ebp, 4\n" +
                                 "\tmov [ebp+8], eax\n" +
                                 "\tmov [ebp+4], ebx\n" +
                                 lab + "_tc:\t;end set up frame\n")
      | Ins ins               -> outins ins
      | Ins1 (ins, op1)       -> outins (ins + " " + operand op1)
      | Ins2 (ins, op1, op2)  -> outins (ins + " " + operand op1 + ", " + operand op2)
      | Jump (ins, lab)       -> outins (ins + " near " + lab)
      | PRINTI         -> List.iter outins [ "call_prolog"; "call " + printi; "call_epilog"]
      | PRINTC         -> List.iter outins [ "call_prolog"; "call " + printc; "call_epilog"]

(* Convert instruction list to list of assembly code fragments *)
 
let code2x86asm (code : x86 list) : string list =
    let bytecode = ref []
    let outinstr i   = (bytecode := i :: !bytecode)
    List.iter (x86instr2int outinstr) code;
    List.rev (!bytecode)

let stdheader = ";; Prolog and epilog for 1-argument C function call (needed on MacOS)\n" +
                "%macro call_prolog 0\n" +
                "       mov ebx, esp            ; Save pre-alignment stack pointer\n" +
                "       pop eax                 ; Pop the argument\n" +
                "       and esp, 0xFFFFFFF0     ; Align esp to 16 byte multiple\n" +
                "       sub esp, 8              ; Pad 8 bytes\n" +
                "       push ebx                ; Push old stack top\n" +
                "       push eax                ; Push argument again\n" +
                "%endmacro\n" +
                "\n" +
                "%macro call_epilog 0\n" +
                "       add esp, 4              ; Pop argument\n" +
                "       pop ebx                 ; Get saved pre-alignment stack pointer\n" +
                "       mov esp, ebx            ; Restore stack top to pre-alignment state\n" +
                "%endmacro\n" +
                "\n" +
                "EXTERN " + printi + "\n" +
                "EXTERN " + printc + "\n" +
                "EXTERN " + checkargc + "\n" +
                "GLOBAL " + asm_main + "\n" +
                "section .data\n" +
                "\tglovars dd 0\n" +
                "section .text\n"

let beforeinit argc = asm_main + ":\n" +
                      "\tpush ebp\n" +
                      "\tmov ebp, esp\n" +
                      "\tpushad\n" +
                      "\tmov dword [glovars], esp\n" +
                      "\tsub dword [glovars], 4\n" +
                      "\t;check arg count:\n" +
                      "\tpush dword [ebp+8]\n" +
                      "\tpush dword " + string(argc) + "\n" +
                      "\tcall " + checkargc + "\n" +
                      "\tadd esp, 8\n" +
                      "\t; allocate globals:\n"

let pushargs = "\t;set up command line arguments on stack:\n" +
                "\tmov ecx, [ebp+8]\n" +
                "\tmov esi, [ebp+12]\n" +
                "_args_next:\n" +
                "\tcmp ecx, 0\n" +
                "\tjz _args_end\n" +
                "\tpush dword [esi]\n" +
                "\tadd esi, 4\n" +
                "\tsub ecx, 1\n" +
                "\tjmp _args_next               ;repeat until --ecx == 0\n" +
                "_args_end:\n" +
                "\tsub ebp, 4                   ; make ebp point to first arg\n"

let popargs =   "\t;clean up stuff pushed onto stack:\n" +
                "\tmov esp, dword [glovars]\n" +
                "\tadd esp, 4\n" +
                "\tpopad\n" +
                "\tmov esp, ebp\n" +
                "\tpop ebp\n" +
                "\tret\n"
