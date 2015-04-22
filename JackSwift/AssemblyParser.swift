import Foundation

class AssemblyParser {
  let reader:HackFileReader
  let symbolTable:AssemblerSymbolTable
  var commands = [AssemblyCommand]()
  var currentCommand = 0
  /**
  * Open the file, reads in input and parses all commands
  */
  init(file: String) {
    reader = HackFileReader(file: file)
    symbolTable = AssemblerSymbolTable()
    /**
     * First pass - read instructions and parse A and C instructions.
     * If an A instruction refers to an undefined symbol or label, store
     * the symbol name in the address field. If a label is found, add it to
     * the symbol table.
     */
    while let line = reader.nextCommand() {
      var command = AssemblyCommand(command: line)
      if command.type == .Label {
        // labels represent the address of the next command
        // so, don't add it to the command list
        symbolTable.add(command.address!, address: commands.count)
      } else {
        commands.append(command)
      }
    }

    /**
     * Second pass - resolve previously undefined symbols.
     * Symbols already in the symbol table refer to labels in the assembly code.
     * These can be simply replaced. For others, they must be variables so
     * they should be allocated in RAM.
     */
    for command in commands {
      if command.type == .Address {
        assert(command.address != nil)
        if let intValue = command.address!.toInt() {
        } else {
          if let address = symbolTable.get(command.address!) {
            command.address =  String(stringInterpolationSegment: address)
          }
        }
      }
    }
  }

  /**
  * Returns the next command
  */
  func advance() -> AssemblyCommand? {
    if currentCommand < count(commands) {
      return commands[currentCommand++]
    }
    return nil
  }
}