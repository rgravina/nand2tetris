import Foundation

func usage() {
  println("Usage: jack <input>")
  println("A Jack compiler for the Hack platform.")
  println()
  println("Assembler")
  println("- <input.asm> Compiles Hack assembly to Hack machine code.")
  println()
  println("VM compiler")
  println("- <input.vm> Compiles Jack VM code to Hack assembly.")
  println("- <directory> Compiles directory of Jack VM code to Hack assembly.")
}

if Process.arguments.count != 2 {
  usage()
} else {
  let parser = AssemblyParser(file: Process.arguments.last!)
  while let command = parser.advance() {
    //...
  }
}
