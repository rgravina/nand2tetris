import Foundation

class Parser {
  // lines of the source file
  let lines: [String]?
  // line we have processed up to
  var linePos = 0

  // open and read the assembler file into an array of lines
  init(file: String) {
    let currentPath = NSFileManager.defaultManager()
    let content = String(contentsOfFile: file, encoding: NSUTF8StringEncoding, error: nil)
    if let fileContent = content {
      lines = fileContent.componentsSeparatedByString("\n")
    } else {
      println("Could not read contents of file: '\(file)'.")
    }
  }

  func hasMoreCommands() -> Bool {
    if let lines = lines {
      return linePos < lines.count-1
    } else {
      return false
    }
  }

  func advance() -> Command? {
    if let lines = lines {
      if linePos < lines.count-1 {
        linePos++;
        return Command(command: lines[linePos])
      }
    }
    return nil
  }
}