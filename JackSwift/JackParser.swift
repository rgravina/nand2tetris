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
    writeNextToken()  // 'class'
    writeNextToken()  // className
    writeNextToken()  // '{'
    compileClassVarDec()
    compileSubroutineDec()
    writeNextToken()  // '}'
    writeCloseTag("class")
  }
  
  private func compileClassVarDec() {
    // zero or more
    // classVarDec: ('static' | 'field') type varName (',' varName)* ';'
    var token = tokeniser.peek()!
    while(token.keyword == .Static || token.keyword == .Field) {
      writeOpenTag("classVarDec")
      writeNextToken()  // static or field
      writeNextToken()  // type
      writeNextToken()  // varName
      token = tokeniser.peek()!
      while(token.symbol != ";") {
        writeNextToken()  // comma
        writeNextToken()  // varName
        token = tokeniser.peek()!
      }
      writeNextToken()
      writeCloseTag("classVarDec")
      token = tokeniser.peek()!
    }
  }

  private func compileSubroutineDec() {
    // zero or more
    // subroutineDec: ('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' subroutineBody
    var token = tokeniser.peek()!
    while(token.symbol != "}") {
      writeOpenTag("subroutineDec")
      writeNextToken()  // constructor etc.
      writeNextToken()  // 'void' or type
      writeNextToken()  // subroutineName
      writeNextToken()  // '('
      compileParameterList()
      writeNextToken()  // ')'
      compileSubroutineBody()
      writeCloseTag("subroutineDec")
      token = tokeniser.peek()!
    }
  }

  private func compileParameterList() {
    // ((type varName) (',' type varName)*)?
    writeOpenTag("parameterList")
    var token = tokeniser.peek()!
    if token.symbol != ")" {
      writeNextToken()  // type
      writeNextToken()  // varName
      token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken()  // comma
        writeNextToken()  // type
        writeNextToken()  // varName
        token = tokeniser.peek()!
      }
    }
    writeCloseTag("parameterList")
  }

  private func compileSubroutineBody() {
    // '{' varDec* statements '}'
    writeOpenTag("subroutineBody")
    writeNextToken()  // '{'
    compileVarDec()
    compileStatements()
    writeNextToken()  // '}'
    writeCloseTag("subroutineBody")
  }

  private func compileVarDec() {
    var token = tokeniser.peek()!
    while token.keyword == .Var {
      writeOpenTag("varDec")
      writeNextToken()  // var
      writeNextToken()  // type
      writeNextToken()  // varName
      token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken()  // comma
        writeNextToken()  // varName
        token = tokeniser.peek()!
      }
      writeNextToken()  // ';'
      writeCloseTag("varDec")
      token = tokeniser.peek()!
    }
  }

  private func compileStatements() {
    // statement*
    writeOpenTag("statements")
    // letStatement | ifStatement | whileStatement | doStatement | returnStatement
    var token = tokeniser.peek()!
    while(token.symbol != "}") {
      switch(token.keyword!) {
      case .Let:
        writeOpenTag("letStatement")
        // 'let' varName ('[' expression ']')? '=' expression ';'
        writeNextToken()  // let
        writeNextToken()  // varName
        token = tokeniser.peek()!
        if(token.symbol == "[") {
          writeNextToken()  // '[]
          compileExpression()  // expression
          writeNextToken()  // ']'
        }
        writeNextToken()  // '='
        compileExpression()  // expression
        writeNextToken()  // ';'
        writeCloseTag("letStatement")
      case .If:
        writeOpenTag("ifStatement")
        writeNextToken()  // if
        writeNextToken()  // '('
        compileExpression()  // expression
        writeNextToken()  // ')'
        writeNextToken()  // '{'
        compileStatements() // statements
        writeNextToken()  // '}'
        writeCloseTag("ifStatement")
        token = tokeniser.peek()!
        if(token.keyword == .Else) {
          writeNextToken()  // else
          writeNextToken()  // '{'
          compileStatements() // statements
          writeNextToken()  // '}'
        }
      case .While:
        writeOpenTag("whileStatement")
        writeNextToken()  // while
        writeNextToken()  // '('
        compileExpression()  // expression
        writeNextToken()  // ')'
        writeNextToken()  // '{'
        compileStatements() // statements
        writeNextToken()  // '}'
        writeCloseTag("whileStatement")
      case .Do:
        writeOpenTag("doStatement")
        // 'do' subroutineCall ';'
        writeNextToken()  // 'do'
        compileSubroutineCall();
        writeNextToken()  // ';'
        writeCloseTag("doStatement")
      case .Return:
        // 'return' expression? ';'
        writeOpenTag("returnStatement")
        writeNextToken()  // 'return'
        token = tokeniser.peek()!
        if(token.symbol != ";") {
          compileExpression()
        }
        writeNextToken()  // ';'
        writeCloseTag("returnStatement")
        true
      default:
        true
      }
      token = tokeniser.peek()!
    }
    writeCloseTag("statements")
  }

  private func compileSubroutineCall() {
    // subroutineName '(' expressionList ')' |
    // (className | varName) '.' subroutineName '(' expressionList ')'
    writeNextToken()  // subroutineName | className or varName
    var token = tokeniser.peek()!
    if(token.symbol == "(") {
      writeNextToken()  // '('
      compileExpressionList()
    } else {
      writeNextToken()  // '.'
      writeNextToken()  // subroutineName
      writeNextToken()  // '('
      compileExpressionList()
    }
    writeNextToken()  // ')'
  }

  private func compileExpressionList() {
    // (expression (',' expression)*)?
    writeOpenTag("expressionList")
    var token = tokeniser.peek()!
    if(token.symbol != ")") {
      compileExpression()
      var token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken() // ','
        compileExpression()
        token = tokeniser.peek()!
      }
    }
    writeCloseTag("expressionList")
  }

  private func compileExpression() {
    // term (op term)*
    writeOpenTag("expression")
    writeOpenTag("term")
    compileTerm()
    writeCloseTag("term")
    var token = tokeniser.peek()!
    while(token.binaryOperator) {
      writeNextToken() // op
      compileTerm()
      token = tokeniser.peek()!
    }
    writeCloseTag("expression")
  }

  private func compileTerm() {
    // integerConstant | stringConstant | keywordConstant | varName | varName '[' expression ']' | subroutineCall | '(' expression ')' | unaryOp term
    writeNextToken() // identifier (for now)
  }

  private func writeOpenTag(tag: String) {
    var token = "<\(tag)>\n"
    println(token)
    out += token
  }

  private func writeCloseTag(tag: String) {
    var token = "</\(tag)>\n"
    println(token)
    out += token
  }

  private func writeNextToken() {
    var token = "\(tokeniser.next()!)\n"
    println(token)
    out += token
  }
}
