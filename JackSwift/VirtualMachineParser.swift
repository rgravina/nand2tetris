import Foundation

class VirtualMachineParser {
  // lines of the source file
  let lines: [String]
  // line we have processed up to
  var linePos = 0

  // open and read the assembler file into an array of lines
  init(file: String) {
    let currentPath = NSFileManager.defaultManager()
    let content = String(contentsOfFile: file, encoding: NSUTF8StringEncoding, error: nil)
    if let fileContent = content {
      lines = fileContent.componentsSeparatedByString("\n")
    } else {
      lines = []
      println("Could not read contents of file: '\(file)'.")
    }
  }

  // Returns the next command and advances the current line (skips whitespace and blank lines)
  func advance() -> VirtualMachineCommand? {
    if linePos < lines.count-1 {
      var line = trimmed(lines[linePos])
      // skip lines if blank (just newline after trim) or starts with a comment
      while (count(line) == 1 || line[0..<2] == "//") {
        linePos++;
        line = lines[linePos]
      }
      // parse the next line as a command
      return VirtualMachineCommand(command: lines[linePos++])
    }
    return nil
  }

  private func trimmed(line: String) -> String {
    return line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
}