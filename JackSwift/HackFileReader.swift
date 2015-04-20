/**
* Reads a hack or VM file a command at a time when nextCommand is called.
* Skips whitespace and comments, and trims commands.
*/
import Foundation

class HackFileReader {
  let streamReader:StreamReader?

  /**
  * Open the file
  */
  init(file: String) {
    streamReader = StreamReader(path: file)
  }

  /**
  * Returns the next line (skips whitespace and blank lines)
  */
  func nextCommand() -> String? {
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
      return line!
    }
    return nil
  }

  private func trimmed(line: String) -> String {
    return line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
}