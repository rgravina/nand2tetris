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
  let fileName = Process.arguments.last!
  let assemblyFile = fileName[Range(start:advance(fileName.endIndex, -4), end: fileName.endIndex)] == ".asm"
  let virtualMachineFile = fileName[Range(start:advance(fileName.endIndex, -3), end: fileName.endIndex)] == ".vm"
  if (assemblyFile) {
    let parser = AssemblyParser(file: Process.arguments.last!)
    while let command = parser.next() {
      println(command.machineCode)
    }
  } else if (virtualMachineFile) {
    let parser = VirtualMachineParser(file: Process.arguments.last!)
    for instruction in VirtualMachineCommand.setup {
      println(instruction)
    }
    println("//\n// Start of main program\n//\n")
    while let command = parser.next() {
      for instruction in command.instructions {
        println(instruction)
      }
    }
  } else {
    let fileManager = NSFileManager.defaultManager()
    var parser:VirtualMachineParser

    if let contents = fileManager.contentsOfDirectoryAtPath(fileName, error: nil) as? [String] {
      var printedSetup = false
      for file in contents {
        let virtualMachineFile = file[Range(start:advance(file.endIndex, -3), end: file.endIndex)] == ".vm"
        let jackSourceFile = file[Range(start:advance(file.endIndex, -5), end: file.endIndex)] == ".jack"
        if virtualMachineFile {
          if (!printedSetup) {
            for instruction in VirtualMachineCommand.setup {
              println(instruction)
            }
            printedSetup = true
          }
          parser = VirtualMachineParser(path: fileName, file: file)
          while let command = parser.next() {
            for instruction in command.instructions {
              println(instruction)
            }
          }
        } else if jackSourceFile {
          let parser = JackParse(path: fileName, file: file)
          parser.parse()
        }
      }
    }
  }
}
