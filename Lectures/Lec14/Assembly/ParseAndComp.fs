(* File Assembly/ParseAndComp.fs *)

module ParseAndComp

let fromString = Parse.fromString

let fromFile = Parse.fromFile

let compileToFile = X86Comp.compileToFile
