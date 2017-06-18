import Foundation

class VirtualMachineParser {
  let reader:HackFileReader
  let className:String

  /**
   * Open the file
   */
  init(path: String, file: String) {
    reader = HackFileReader(file: "\(path)/\(file)")
    self.className = file[(file.startIndex ..< file.characters.index(file.endIndex, offsetBy: -3))]
  }

  init(file: String) {
    reader = HackFileReader(file: file)
    self.className = file[(file.startIndex ..< file.characters.index(file.endIndex, offsetBy: -3))]
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func next() -> VirtualMachineCommand? {
    if let line = reader.nextLine() {
      return VirtualMachineCommand(className: className, command: line)
    }
    return nil
  }
}
