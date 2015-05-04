import Foundation

class VirtualMachineParser {
  let reader:HackFileReader
  let fileName:String

  /**
   * Open the file
   */
  init(path: String, file: String) {
    reader = HackFileReader(file: "\(path)/\(file)")
    self.fileName = file[Range(start:file.startIndex, end:advance(file.endIndex, -3))]
  }

  init(file: String) {
    reader = HackFileReader(file: file)
    self.fileName = file[Range(start:file.startIndex, end:advance(file.endIndex, -3))]
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func next() -> VirtualMachineCommand? {
    if let line = reader.nextCommand() {
      return VirtualMachineCommand(fileName: fileName, command: line)
    }
    return nil
  }
}