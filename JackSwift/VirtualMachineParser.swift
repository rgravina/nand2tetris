import Foundation

class VirtualMachineParser {
  // lines of the source file
  var lines: [String]
  // line we have processed up to
  var linePos = 0

  /**
   * Open and read the file into an array of lines.
   */
  init(file: String) {
    lines = []
    if let streamReader = StreamReader(path: file) {
      while let line = streamReader.nextLine() {
        lines.append(trimmed(line))
      }
      streamReader.close()
    } else {
      println("Could not read contents of file: '\(file)'.")
    }
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func advance() -> VirtualMachineCommand? {
    if linePos < lines.count {
      var line = lines[linePos]
      // skip lines if blank (just newline after trim) or starts with a comment
      while (count(line) == 0 || line[0..<2] == "//") {
        linePos++;
        line = lines[linePos]
      }
      // parse the next line as a command
      linePos++
      return VirtualMachineCommand(command: line)
    }
    return nil
  }

  private func trimmed(line: String) -> String {
    return line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
}