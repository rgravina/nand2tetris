import Foundation

class AssemblyParser {
  let reader:HackFileReader
  let symbolTable:AssemblerSymbolTable
  /**
  * Open the file
  */
  init(file: String) {
    reader = HackFileReader(file: file)
    symbolTable = AssemblerSymbolTable()
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func advance() -> AssemblyCommand? {
    if let line = reader.nextCommand() {
      return AssemblyCommand(command: line)
    }
    return nil
  }
}