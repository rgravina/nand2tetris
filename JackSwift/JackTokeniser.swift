import Foundation

class JackTokeniser {
  let reader:HackFileReader

  /**
   * Open the file
   */
  init(path: String, file: String) {
    reader = HackFileReader(file: "\(path)/\(file)")
  }

  init(file: String) {
    reader = HackFileReader(file: file)
  }

  /**
  * Returns the next command and advances the current line (skips whitespace and blank lines)
  */
  func next() -> String? {
    if let line = reader.nextLine() {
      return line
    }
    return nil
  }
}
