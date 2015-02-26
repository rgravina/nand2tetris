package main

import "os"

func main() {
  argsWithoutProg := os.Args[1:]
  if len(argsWithoutProg) != 1 {
    usage()
  } else {
    parser := new(Parser)
  }
}

func usage() {
  println("Usage: hack <input.asm>")
  println()
  println("An assembler for the Hack platform.")  
}
