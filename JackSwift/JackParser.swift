import Foundation

class JackParse {
  let tokeniser:JackTokeniser
  let symbolTable:JackSymbolTable
  let outputFile:String
  var out:String = ""

  init(path: String, file: String) {
    println("Parsing \(file)...")
    tokeniser = JackTokeniser(path: path, file: file)
    symbolTable = JackSymbolTable()
    self.outputFile = path.stringByAppendingPathComponent("\(file[0..<count(file)-5])2.xml")
  }

  init(file: String) {
    tokeniser = JackTokeniser(file: file)
    symbolTable = JackSymbolTable()
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
      var kind = writeNextToken()  // static or field
      var type = writeNextToken()  // type
      var varName = writeNextToken()  // varName
      if (type.keyword != nil) {
        // int, bool etc.
        symbolTable.define(varName.identifier!, type: type.keyword!, kind: kind.keyword!)
      } else {
        // class
        symbolTable.define(varName.identifier!, type: type.identifier!, kind: kind.keyword!)
      }
      token = tokeniser.peek()!
      while(token.symbol != ";") {
        writeNextToken()  // comma
        varName = writeNextToken()  // varName
        if (type.keyword != nil) {
          // int, bool etc.
          symbolTable.define(varName.identifier!, type: type.keyword!, kind: kind.keyword!)
        } else {
          // class
          symbolTable.define(varName.identifier!, type: type.identifier!, kind: kind.keyword!)
        }
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
        writeNextToken()  // subroutineName | className or varName
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
    // expects the caller has output the first token
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
    compileTerm()
    var token = tokeniser.peek()!
    while(token.binaryOperator) {
      writeNextToken() // op
      compileTerm()
      token = tokeniser.peek()!
    }
    writeCloseTag("expression")
  }

  private func compileTerm() {
    // integerConstant | stringConstant | keywordConstant 
    //   | varName
    //   | varName '[' expression ']'
    //   | subroutineCall
    //   | '(' expression ')'
    //   | unaryOp term
    // To test if varName, varName '[' expression ']' or subroutineCall need to lookahead twice.
    //   -> subroutineCall: subroutineName '(' expressionList ')' | (className | varName) '.' subroutineName '(' expressionList ')'
    writeOpenTag("term")
    var token = tokeniser.peek()!
    if (token.type == .IntConstant) {
      writeNextToken()
    } else if (token.type == .StringConstant) {
      writeNextToken()
    } else if (token.keywordConstant) {
      writeNextToken()
    } else if (token.symbol == "(") {
      writeNextToken() // '('
      compileExpression()
      writeNextToken() // ')'
    } else if (token.unaryOperator) {
      writeNextToken() // op
      compileTerm()
    } else {
      writeNextToken() // varName
      token = tokeniser.peek()!
      if (token.symbol == "[") {
        writeNextToken() // '['
        compileExpression()
        writeNextToken() // ']'
      } else if (token.symbol == "(" || token.symbol == ".") {
        compileSubroutineCall()
      } else {
        // nothing else needs to be done for identifiers
      }
    }
    writeCloseTag("term")
  }

  private func writeOpenTag(tag: String) {
    out += "<\(tag)>\n"
  }

  private func writeCloseTag(tag: String) {
    out += "</\(tag)>\n"
  }

  private func writeNextToken() -> JackToken {
    var token = tokeniser.next()!
    out += "\(token)\n"
    return token
  }
}
