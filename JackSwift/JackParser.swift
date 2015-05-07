import Foundation

class JackParse {
  let tokeniser:JackTokeniser
  let outputFile:String
  var out:String = ""

  init(path: String, file: String) {
    println("Parsing \(file)...")
    tokeniser = JackTokeniser(path: path, file: file)
    self.outputFile = path.stringByAppendingPathComponent("\(file[0..<count(file)-5])2.xml")
  }

  init(file: String) {
    tokeniser = JackTokeniser(file: file)
    self.outputFile = "\(file[0..<count(file)-5])2.xml"
  }

  func parse() {
    compileClass()
    out.writeToFile(outputFile, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
  }
  
  func compileClass() {
    writeOpenTag("class")
    writeNextToken()
    writeNextToken()
    writeNextToken()
    compileClassVarDec()
    compileSubroutineDec()
    writeCloseTag("class")
  }
  
  func compileClassVarDec() {
    // zero or more
  }

  func compileSubroutineDec() {
    // zero or more
  }

  private func writeOpenTag(tag: String) {
    out += "<\(tag)>\n"
  }

  private func writeCloseTag(tag: String) {
    out += "</\(tag)>\n"
  }

  private func writeNextToken() {
    out += "\(tokeniser.next()!)\n"
  }
}
