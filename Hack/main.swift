import Foundation

func usage() {
  println("Usage: hack <input.asm>")
  println()
  println("An assembler for the Hack platform.")
}

if Process.arguments.count != 2 {
  usage()
} else {
  let parser = Parser(file: Process.arguments.last!)
}

