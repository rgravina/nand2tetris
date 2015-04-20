import Foundation

class VirtualMachineParser {
  let streamReader:StreamReader?
  /**
   * Open the file
   */
  init(file: String) {
    streamReader = StreamReader(path: file)
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func advance() -> VirtualMachineCommand? {
    if let reader = streamReader {
      var line = reader.nextLine()
      if (line == nil) {
        reader.close()
        return nil
      }
      line = trimmed(line!)
      while (count(line!) == 0 || line![0..<2] == "//") {
        line = reader.nextLine()
        if (line == nil) {
          reader.close()
          return nil
        }
        line = trimmed(line!)
      }
      return VirtualMachineCommand(command: line!)
    }
    return nil
  }

  private func trimmed(line: String) -> String {
    return line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
}