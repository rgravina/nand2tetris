import Foundation

class VirtualMachineParser {
  let reader:HackFileReader
  let fileName:String

  /**
   * Open the file
   */
  init(path: String, file: String) {
    reader = HackFileReader(file: "\(path)/\(file)")
    self.fileName = file
  }

  init(file: String) {
    reader = HackFileReader(file: file)
    self.fileName = file
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func advance() -> VirtualMachineCommand? {
    if let line = reader.nextCommand() {
      return VirtualMachineCommand(fileName: fileName, command: line)
    }
    return nil
  }
}