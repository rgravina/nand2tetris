import Foundation

class VirtualMachineParser {
  let reader:HackFileReader
  /**
   * Open the file
   */
  init(file: String) {
    reader = HackFileReader(file: file)
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func advance() -> VirtualMachineCommand? {
    if let line = reader.nextCommand() {
      return VirtualMachineCommand(command: line)
    }
    return nil
  }
}