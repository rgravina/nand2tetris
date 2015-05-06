import Foundation

class JackParse {
  let tokeniser:JackTokeniser
  let outputFile:String

  init(path: String, file: String) {
    tokeniser = JackTokeniser(path: path, file: file)
    self.outputFile = path.stringByAppendingPathComponent("\(file[0..<count(file)-5])T2.xml")
  }

  init(file: String) {
    tokeniser = JackTokeniser(file: file)
    self.outputFile = "\(file[0..<count(file)-5])T2.xml"
  }

  func parse() {
    var out = "<tokens>\n"
    while let token = tokeniser.next() {
      out += "\(token.description)\n"
    }
    out += "<tokens>\n"
    out.writeToFile(outputFile, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
  }
}
