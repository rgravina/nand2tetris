import Foundation

func usage() {
  print("Usage: jack <input>")
  print("A Jack compiler for the Hack platform.")
  print("")
  print("Assembler")
  print("- <input.asm> Compiles Hack assembly to Hack machine code.")
  print("")
  print("VM compiler")
  print("- <input.vm> Compiles Jack VM code to Hack assembly.")
  print("- <directory> Compiles directory of Jack VM code to Hack assembly.")
}

if Process.arguments.count != 2 {
  usage()
} else {
  let fileName = Process.arguments.last!
  let assemblyFile = fileName[Range(start:fileName.endIndex.advancedBy(-4), end: fileName.endIndex)] == ".asm"
  let virtualMachineFile = fileName[Range(start:fileName.endIndex.advancedBy(-3), end: fileName.endIndex)] == ".vm"
  if (assemblyFile) {
    let parser = AssemblyParser(file: Process.arguments.last!)
    while let command = parser.next() {
      print(command.machineCode)
    }
  } else if (virtualMachineFile) {
    let parser = VirtualMachineParser(file: Process.arguments.last!)
    for instruction in VirtualMachineCommand.setup {
      print(instruction)
    }
    print("//\n// Start of main program\n//\n")
    while let command = parser.next() {
      for instruction in command.instructions {
        print(instruction)
      }
    }
  } else {
    let fileManager = NSFileManager.defaultManager()
//    var parser:VirtualMachineParser

    if let contents = (try! fileManager.contentsOfDirectoryAtPath(fileName)) as [String]? {
//      var printedSetup = false
      for file in contents {
//        let virtualMachineFile = file[Range(start:advance(file.endIndex, -3), end: file.endIndex)] == ".vm"
        let jackSourceFile = file[Range(start:file.endIndex.advancedBy(-5), end: file.endIndex)] == ".jack"
//        if virtualMachineFile {
//          if (!printedSetup) {
//            for instruction in VirtualMachineCommand.setup {
//              println(instruction)
//            }
//            printedSetup = true
//          }
//          parser = VirtualMachineParser(path: fileName, file: file)
//          while let command = parser.next() {
//            for instruction in command.instructions {
//              println(instruction)
//            }
//          }
//        } else if jackSourceFile {
          if jackSourceFile {
            let parser = JackParse(path: fileName, file: file)
            parser.parse()
          }
//        }
      }
    }
  }
}
