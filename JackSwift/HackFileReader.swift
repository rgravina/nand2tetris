/**
* Reads a hack or VM file a line at a time when nextLine is called.
* Skips whitespace and comments, and trims lines.
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
  func nextLine() -> String? {
    if let reader = streamReader {
      var line = reader.nextLine()
      if (line == nil) {
        reader.close()
        return nil
      }
      line = trimmed(line!)
      while ((line!).characters.count == 0 || ((line!).characters.count > 2 && line![0..<2] == "//")) {
        line = reader.nextLine()
        if (line == nil) {
          reader.close()
          return nil
        }
        line = trimmed(line!)
      }
      // remove end of line comments
      let commentIndex = line!.range(of: "//")
      if (commentIndex != nil) {
        line = trimmed(line![line!.startIndex..<commentIndex!.lowerBound])
      }
      return line!
    }
    return nil
  }

  fileprivate func trimmed(_ line: String) -> String {
    return line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }
}
