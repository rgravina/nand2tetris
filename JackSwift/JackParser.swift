import Foundation

class JackParse {
  let tokeniser:JackTokeniser
  let symbolTable:JackSymbolTable
  var vmWriter:JackVMWriter
  var whileRip = 0
  var ifRip = 0

  init(path: String, file: String) {
    println("Parsing \(file)...")
    tokeniser = JackTokeniser(path: path, file: file)
    symbolTable = JackSymbolTable()
    vmWriter = JackVMWriter(path: path, file: file)
  }

  init(file: String) {
    tokeniser = JackTokeniser(file: file)
    symbolTable = JackSymbolTable()
    vmWriter = JackVMWriter(file: file)
  }

  func parse() {
    compileClass()
    vmWriter.write()
  }
  
  private func compileClass() {
    // 'class' className '{' classVarDec* compileSubroutineDec* '}'
    writeOpenTag("class")
    writeNextToken()  // 'class'
    let className = writeNextToken()  // className
    writeNextToken()  // '{'
    compileClassVarDec()
    compileSubroutineDec(className)
    writeNextToken()  // '}'
    writeCloseTag("class")
  }

  private func getTypeName(type: JackToken) -> String {
    var typeName:String
    if (type.keyword != nil) {
      typeName = type.keyword!.rawValue
    } else {
      typeName = type.identifier!
    }
    return typeName
  }

  private func define(varName: JackToken, type: JackToken, kind:JackToken) {
    symbolTable.define(varName.identifier!, type: getTypeName(type), kind: kind.keyword!.rawValue)
  }

  private func define(varName: JackToken, type: JackToken, kind: String) {
    symbolTable.define(varName.identifier!, type: getTypeName(type), kind: kind)
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
      define(varName, type: type, kind: kind)
      token = tokeniser.peek()!
      while(token.symbol != ";") {
        writeNextToken()  // comma
        varName = writeNextToken()  // varName
        define(varName, type: type, kind: kind)
        token = tokeniser.peek()!
      }
      writeNextToken()
      writeCloseTag("classVarDec")
      token = tokeniser.peek()!
    }
  }

  private func compileSubroutineDec(className: JackToken) {
    // zero or more
    // subroutineDec: ('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' subroutineBody
    var token = tokeniser.peek()!
    while(token.symbol != "}") {
      writeOpenTag("subroutineDec")
      let method = writeNextToken()  // constructor etc.
      let returnType = writeNextToken()  // 'void' or type
      let subroutineName = writeNextToken()  // subroutineName
      symbolTable.startSubroutineScope(method.keyword!.rawValue, className: className.identifier!)
      writeNextToken()  // '('
      compileParameterList()
      writeNextToken()  // ')'
      //FIXME: the num locals isn't known yet
      compileSubroutineBody(className, subroutineName: subroutineName)
      // rest RIPs
      whileRip = 0
      ifRip = 0
      writeCloseTag("subroutineDec")
      token = tokeniser.peek()!
    }
  }

  private func compileParameterList() {
    // ((type varName) (',' type varName)*)?
    writeOpenTag("parameterList")
    var token = tokeniser.peek()!
    if token.symbol != ")" {
      var type = writeNextToken()  // type
      var varName = writeNextToken()  // varName
      define(varName, type: type, kind: "arg")
      token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken()  // comma
        type = writeNextToken()  // type
        varName = writeNextToken()  // varName
        define(varName, type: type, kind: "arg")
        token = tokeniser.peek()!
      }
    }
    writeCloseTag("parameterList")
  }

  private func compileSubroutineBody(className: JackToken, subroutineName: JackToken) {
    // '{' varDec* statements '}'
    writeOpenTag("subroutineBody")
    writeNextToken()  // '{'
    compileVarDec()
    vmWriter.writeFunction(className.identifier!, subroutineName: subroutineName.identifier!, numLocals: symbolTable.varCount("var"))
    compileStatements()
    writeNextToken()  // '}'
    writeCloseTag("subroutineBody")
  }

  private func compileVarDec() {
    var token = tokeniser.peek()!
    while token.keyword == .Var {
      writeOpenTag("varDec")
      var kind = writeNextToken()  // var
      var type = writeNextToken()  // type
      var varName = writeNextToken()  // varName
      define(varName, type: type, kind: kind)
      token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken()  // comma
        varName = writeNextToken()  // varName
        define(varName, type: type, kind: kind)
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
        let varName = writeNextToken()  // varName
        token = tokeniser.peek()!
        if(token.symbol == "[") {
          writeNextToken()  // '[]
          compileExpression()  // expression
          writeNextToken()  // ']'
        }
        writeNextToken()  // '='
        compileExpression()  // expression
        let kind = symbolTable.kindOf(varName.identifier!)
        if kind == "var" {
          vmWriter.writePop("local", index: symbolTable.indexOf(varName.identifier!))
        } else {
          vmWriter.writePop("argument", index: symbolTable.indexOf(varName.identifier!))
        }
        writeNextToken()  // ';'
        writeCloseTag("letStatement")
      case .If:
        writeOpenTag("ifStatement")
        writeNextToken()  // if
        let rip = ifRip++
        writeNextToken()  // '('
        compileExpression()  // expression
        writeNextToken()  // ')'
        vmWriter.writeIf("IF_TRUE\(rip)")
        vmWriter.writeGoto("IF_FALSE\(rip)")
        vmWriter.writeLabel("IF_TRUE\(rip)")
        writeNextToken()  // '{'
        compileStatements() // statements
        writeNextToken()  // '}'
        writeCloseTag("ifStatement")
        vmWriter.writeGoto("IF_END\(rip)")
        vmWriter.writeLabel("IF_FALSE\(rip)")
        token = tokeniser.peek()!
        if(token.keyword == .Else) {
          writeNextToken()  // else
          writeNextToken()  // '{'
          compileStatements() // statements
          writeNextToken()  // '}'
        }
        vmWriter.writeLabel("IF_END\(rip)")
      case .While:
        writeOpenTag("whileStatement")
        writeNextToken()  // while
        let rip = whileRip++
        vmWriter.writeLabel("WHILE_EXP\(rip)")
        writeNextToken()  // '('
        compileExpression()  // expression
        // not the value and jump to test for truth
        vmWriter.writeArithmetic("not")
        vmWriter.writeIf("WHILE_END\(rip)")
        writeNextToken()  // ')'
        writeNextToken()  // '{'
        compileStatements() // statements
        vmWriter.writeGoto("WHILE_EXP\(rip)")
        writeNextToken()  // '}'
        vmWriter.writeLabel("WHILE_END\(rip)")
        writeCloseTag("whileStatement")
      case .Do:
        writeOpenTag("doStatement")
        // 'do' subroutineCall ';'
        writeNextToken()  // 'do'
        var callee = writeNextToken()  // subroutineName | className or varName
        compileSubroutineCall(callee);
        // igmore the return value
        vmWriter.writePop("temp", index: 0)
        writeNextToken()  // ';'
        writeCloseTag("doStatement")
      case .Return:
        // 'return' expression? ';'
        writeOpenTag("returnStatement")
        writeNextToken()  // 'return'
        token = tokeniser.peek()!
        if(token.symbol != ";") {
          compileExpression()
          vmWriter.writeReturn();
        } else {
          vmWriter.writePush("constant", index: 0);
          vmWriter.writeReturn();
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

  private func compileSubroutineCall(callee: JackToken) {
    // subroutineName '(' expressionList ')' |
    // (className | varName) '.' subroutineName '(' expressionList ')'
    // expects the caller has output the first token
    var token = tokeniser.peek()!
    if(token.symbol == "(") {
      writeNextToken()  // '('
      compileExpressionList()
      vmWriter.writeCall(callee.identifier!, numArgs: symbolTable.varCount("args"))
    } else {
      writeNextToken()  // '.'
      var subroutineName = writeNextToken()  // subroutineName
      writeNextToken()  // '('
      var numExpressions = compileExpressionList()
      vmWriter.writeCall("\(callee.identifier!).\(subroutineName.identifier!)", numArgs: numExpressions)
    }
    writeNextToken()  // ')'
  }

  private func compileExpressionList() -> Int {
    // (expression (',' expression)*)?
    writeOpenTag("expressionList")
    var numExpressions = 0
    var token = tokeniser.peek()!
    if(token.symbol != ")") {
      compileExpression()
      numExpressions++
      var token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken() // ','
        compileExpression()
        numExpressions++
        token = tokeniser.peek()!
      }
    }
    writeCloseTag("expressionList")
    return numExpressions
  }

  private func compileExpression() {
    // term (op term)*
    writeOpenTag("expression")
    compileTerm()
    var token = tokeniser.peek()!
    while(token.binaryOperator) {
      var op = writeNextToken() // op
      compileTerm()
      switch(op.symbol!) {
      case "*":
        vmWriter.writeCall("Math.multiply", numArgs: 2)
      case "/":
        vmWriter.writeCall("Math.divide", numArgs: 2)
      case "+":
        vmWriter.writeArithmetic("add")
      case "-":
        vmWriter.writeArithmetic("sub")
      case ">":
        vmWriter.writeArithmetic("gt")
      case "<":
        vmWriter.writeArithmetic("lt")
      case "=":
        vmWriter.writeArithmetic("eq")
      case "&":
        vmWriter.writeArithmetic("and")
      case "|":
        vmWriter.writeArithmetic("or")
      default:
        true
      }
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
      let int = writeNextToken()
      vmWriter.writePush("constant", index: int.intVal!)
    } else if (token.type == .StringConstant) {
      writeNextToken()
    } else if (token.keywordConstant) {
      let keyword = writeNextToken()
      // false
      if keyword.keyword == .False || keyword.keyword == .True {
        vmWriter.writePush("constant", index: 0)
        if keyword.keyword == .True {
          // not false to get true
          vmWriter.writeArithmetic("not")
        }
      }
    } else if (token.symbol == "(") {
      writeNextToken() // '('
      compileExpression()
      writeNextToken() // ')'
    } else if (token.unaryOperator) {
      let op = writeNextToken() // op
      compileTerm()
      switch(op.symbol!) {
      case "-":
        vmWriter.writeArithmetic("neg")
      case "~":
        vmWriter.writeArithmetic("not")
      default:
        true
      }
    } else {
      var varName = writeNextToken() // varName
      token = tokeniser.peek()!
      if (token.symbol == "[") {
        writeNextToken() // '['
        compileExpression()
        writeNextToken() // ']'
      } else if (token.symbol == "(" || token.symbol == ".") {
        compileSubroutineCall(varName)
      } else {
        // nothing else needs to be done for identifiers for parsing
        let kind = symbolTable.kindOf(varName.identifier!)
        if kind == "var" {
          vmWriter.writePush("local", index: symbolTable.indexOf(varName.identifier!))
        } else {
          vmWriter.writePush("argument", index: symbolTable.indexOf(varName.identifier!))
        }
      }
    }
    writeCloseTag("term")
  }

  private func writeOpenTag(tag: String) {
    //out += "<\(tag)>\n"
  }

  private func writeCloseTag(tag: String) {
    //out += "</\(tag)>\n"
  }

  private func writeNextToken() -> JackToken {
    var token = tokeniser.next()!
    //out += "\(token)\n"
    return token
  }
}
