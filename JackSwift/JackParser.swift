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
  
  private func compileClass() {
    // 'class' className '{' classVarDec* compileSubroutineDec* '}'
    writeOpenTag("class")
    writeNextToken()
    writeNextToken()
    writeNextToken()
    compileClassVarDec()
    compileSubroutineDec()
    writeCloseTag("class")
  }
  
  private func compileClassVarDec() {
    // zero or more
    // classVarDec: ('static' | 'field') type varName (',' varName)* ';'
  }

  private func compileSubroutineDec() {
    // zero or more
    // subroutineDec: ('constructor' | 'function' | 'method' | 'void'  | type) subroutineName '(' parameterList ')' subroutineBody
  }

  private func compileType() {
    // 'int' | 'char' | 'boolean' | className
  }

  private func compileParameterList() {
    // ((type varName) (',' type varName)*)?
  }

  private func compileSubroutineBody() {
    // '{' varDec* statements '}'
  }

  private func compileVarName() {
    // identifier
  }

  private func compileClassName() {
    // identifier
  }

  private func subroutineName() {
    // identifier
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
