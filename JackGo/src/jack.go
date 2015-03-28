package main

import (
  "os"
  "jack"
)

func main() {
  argsWithoutProg := os.Args[1:]
  if len(argsWithoutProg) != 1 {
    usage()
  } else {
    parser := jack.AssemblyParser{}
    parser.Parse()
  }
}

func usage() {
  println("Usage: jack <input.asm>")
  println()
  println("A Jack compiler for the Hack platform.")  
}
