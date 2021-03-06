import Foundation

class JackParse {
  let tokeniser:JackTokeniser
  let symbolTable:JackSymbolTable
  var vmWriter:JackVMWriter
  var whileRip = 0
  var ifRip = 0

  init(path: String, file: String) {
    print("Compiling \(file)...")
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
  
  fileprivate func compileClass() {
    // 'class' className '{' classVarDec* compileSubroutineDec* '}'
    writeOpenTag("class")
    writeNextToken()  // 'class'
    let className = writeNextToken()  // className
    symbolTable.className = className.identifier!
    writeNextToken()  // '{'
    compileClassVarDec()
    compileSubroutineDec(className)
    writeNextToken()  // '}'
    writeCloseTag("class")
  }

  fileprivate func getTypeName(_ type: JackToken) -> String {
    let typeName:String
    if (type.keyword != nil) {
      typeName = type.keyword!.rawValue
    } else {
      typeName = type.identifier!
    }
    return typeName
  }

  fileprivate func define(_ varName: JackToken, type: JackToken, kind:JackToken) {
    symbolTable.define(varName.identifier!, type: getTypeName(type), kind: kind.keyword!.rawValue)
  }

  fileprivate func define(_ varName: JackToken, type: JackToken, kind: String) {
    symbolTable.define(varName.identifier!, type: getTypeName(type), kind: kind)
  }

  fileprivate func compileClassVarDec() {
    // zero or more
    // classVarDec: ('static' | 'field') type varName (',' varName)* ';'
    var token = tokeniser.peek()!
    while(token.keyword == .Static || token.keyword == .Field) {
      writeOpenTag("classVarDec")
      let kind = writeNextToken()  // static or field
      let type = writeNextToken()  // type
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

  fileprivate func compileSubroutineDec(_ className: JackToken) {
    // zero or more
    // subroutineDec: ('constructor' | 'function' | 'method') ('void' | type) subroutineName '(' parameterList ')' subroutineBody
    var token = tokeniser.peek()!
    while(token.symbol != "}") {
      writeOpenTag("subroutineDec")
      let method = writeNextToken()  // constructor etc.
      writeNextToken()  // returnType is 'void' or type
      let subroutineName = writeNextToken()  // subroutineName
      symbolTable.startSubroutineScope(method.keyword!.rawValue, className: className.identifier!)
      writeNextToken()  // '('
      compileParameterList()
      writeNextToken()  // ')'
      //FIXME: the num locals isn't known yet
      compileSubroutineBody(className, subroutineName: subroutineName, method: method)
      // rest RIPs
      whileRip = 0
      ifRip = 0
      writeCloseTag("subroutineDec")
      token = tokeniser.peek()!
    }
  }

  fileprivate func compileParameterList() {
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

  fileprivate func compileSubroutineBody(_ className: JackToken, subroutineName: JackToken, method: JackToken) {
    // '{' varDec* statements '}'
    writeOpenTag("subroutineBody")
    writeNextToken()  // '{'
    compileVarDec()
    vmWriter.writeFunction(className.identifier!, subroutineName: subroutineName.identifier!, numLocals: symbolTable.varCount("var"))
    // if a constructor, allocate RAM for the object
    // e.g. for three fields
    //  push constant 3
    //  call Memory.alloc 1
    //  pop pointer 0   // pops return value of Memory.alloc to this
    if (method.keyword!.rawValue == "constructor") {
      vmWriter.writePush("constant", index: symbolTable.varCount("field"))
      vmWriter.writeCall("Memory.alloc", numArgs: 1)
      vmWriter.writePop("pointer", index: 0)
    } else if (method.keyword!.rawValue == "method") {
      // this
      vmWriter.writePush("argument", index: 0)
      vmWriter.writePop("pointer", index: 0)
    }
    compileStatements()
    writeNextToken()  // '}'
    writeCloseTag("subroutineBody")
  }

  fileprivate func compileVarDec() {
    var token = tokeniser.peek()!
    while token.keyword == .Var {
      writeOpenTag("varDec")
      let kind = writeNextToken()  // var
      let type = writeNextToken()  // type
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

  fileprivate func compileStatements() {
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
          writeNextToken()  // '['
          compileExpression()  // expression
          writeNextToken()  // ']'
          pushVariableOffset(varName)
          vmWriter.writeArithmetic("add")
        }
        writeNextToken()  // '='
        compileExpression()  // expression
        if(token.symbol == "[") {
          // pop temp 0
          // pop pointer 1
          // push temp 0
          // pop that 0
          vmWriter.writePop("temp", index: 0)
          vmWriter.writePop("pointer", index: 1)
          vmWriter.writePush("temp", index: 0)
          vmWriter.writePop("that", index: 0)
        } else {
          popVariableOffset(varName)
        }
        writeNextToken()  // ';'
        writeCloseTag("letStatement")
      case .If:
        writeOpenTag("ifStatement")
        writeNextToken()  // if
        let rip = ifRip += 1
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
        token = tokeniser.peek()!
        if(token.keyword == .Else) {
          vmWriter.writeGoto("IF_END\(rip)")
        }
        vmWriter.writeLabel("IF_FALSE\(rip)")
        if(token.keyword == .Else) {
          writeNextToken()  // else
          writeNextToken()  // '{'
          compileStatements() // statements
          writeNextToken()  // '}'
        }
        if(token.keyword == .Else) {
          vmWriter.writeLabel("IF_END\(rip)")
        }
      case .While:
        writeOpenTag("whileStatement")
        writeNextToken()  // while
        let rip = whileRip += 1
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
        let callee = writeNextToken()  // subroutineName | className or varName
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

  fileprivate func compileSubroutineCall(_ callee: JackToken) {
    // subroutineName '(' expressionList ')' |
    // (className | varName) '.' subroutineName '(' expressionList ')'
    // expects the caller has output the first token
    let token = tokeniser.peek()!
    if(token.symbol == "(") {
      writeNextToken()  // '('
      // it's a method call, need to put this onto the stack
      vmWriter.writePush("pointer", index: 0)
      let numExpressions = compileExpressionList()
      vmWriter.writeCall("\(symbolTable.className!).\(callee.identifier!)", numArgs: numExpressions+1)
    } else {
      writeNextToken()  // '.'
      let subroutineName = writeNextToken()  // subroutineName
      writeNextToken()  // '('
      let calleeType = symbolTable.typeOf(callee.identifier!)
      if (calleeType != nil) {
        // if the callee does exist in the symbol table
        // push the location of the callee on the stack
        let calleeKind = symbolTable.kindOf(callee.identifier!)
        if (calleeKind == "field") {
          vmWriter.writePush("this", index: symbolTable.indexOf(callee.identifier!))
        } else {
          vmWriter.writePush("local", index: symbolTable.indexOf(callee.identifier!))
        }
      }
      let numExpressions = compileExpressionList()
      // (className | varName) '.' subroutineName '(' expressionList ')'
      // e.g. Foo.new, Foo.something, foo.something
      if (calleeType != nil) {
        vmWriter.writeCall("\(calleeType!).\(subroutineName.identifier!)", numArgs: numExpressions+1)
      } else {
        // if the callee doesn't exist in the symbol table, assume it's a class function
        vmWriter.writeCall("\(callee.identifier!).\(subroutineName.identifier!)", numArgs: numExpressions)
      }
    }
    writeNextToken()  // ')'
  }

  fileprivate func compileExpressionList() -> Int {
    // (expression (',' expression)*)?
    writeOpenTag("expressionList")
    var numExpressions = 0
    let token = tokeniser.peek()!
    if(token.symbol != ")") {
      compileExpression()
      numExpressions += 1
      var token = tokeniser.peek()!
      while(token.symbol == ",") {
        writeNextToken() // ','
        compileExpression()
        numExpressions += 1
        token = tokeniser.peek()!
      }
    }
    writeCloseTag("expressionList")
    return numExpressions
  }

  fileprivate func compileExpression() {
    // term (op term)*
    writeOpenTag("expression")
    compileTerm()
    var token = tokeniser.peek()!
    while(token.binaryOperator) {
      let op = writeNextToken() // op
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

  fileprivate func compileTerm() {
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
    if (token.type == .intConstant) {
      let int = writeNextToken()
      vmWriter.writePush("constant", index: int.intVal!)
    } else if (token.type == .stringConstant) {
      let stringToken = writeNextToken()
      // e.g. "How many numbers? "
      //push constant 18
      //call String.new 1
      let stringVal = stringToken.stringVal!
      vmWriter.writePush("constant", index: stringVal.characters.count)
      vmWriter.writeCall("String.new", numArgs: 1)
      // write each character
      //push constant 72
      //call String.appendChar 2
      let chars = stringVal.unicodeScalars
      for char in chars {
        vmWriter.writePush("constant", index: Int(char.value))
        vmWriter.writeCall("String.appendChar", numArgs: 2)
      }
    } else if (token.keywordConstant) {
      let keyword = writeNextToken()
      // false
      if keyword.keyword == .False || keyword.keyword == .True {
        vmWriter.writePush("constant", index: 0)
        if keyword.keyword == .True {
          // not false to get true
          vmWriter.writeArithmetic("not")
        }
      } else if keyword.keyword == .This {
        vmWriter.writePush("pointer", index: 0)
      } else if keyword.keyword == .Null {
        vmWriter.writePush("constant", index: 0)
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
      let varName = writeNextToken() // varName
      token = tokeniser.peek()!
      if (token.symbol == "[") {
        writeNextToken() // '['
        compileExpression()
        writeNextToken() // ']'
        pushVariableOffset(varName)
        vmWriter.writeArithmetic("add")
        vmWriter.writePop("pointer", index: 1)
        vmWriter.writePush("that", index: 0)
      } else if (token.symbol == "(" || token.symbol == ".") {
        compileSubroutineCall(varName)
      } else {
        // nothing else needs to be done for identifiers for parsing
        pushVariableOffset(varName)
      }
    }
    writeCloseTag("term")
  }

  fileprivate func pushVariableOffset(_ varName: JackToken) {
    let kind = symbolTable.kindOf(varName.identifier!)
    switch(kind) {
    case "var":
      vmWriter.writePush("local", index: symbolTable.indexOf(varName.identifier!))
    case "field":
      vmWriter.writePush("this", index: symbolTable.indexOf(varName.identifier!))
    case "static":
      vmWriter.writePush("static", index: symbolTable.indexOf(varName.identifier!))
    default:
      vmWriter.writePush("argument", index: symbolTable.indexOf(varName.identifier!))
    }
  }

  fileprivate func popVariableOffset(_ varName: JackToken) {
    let kind = symbolTable.kindOf(varName.identifier!)
    switch(kind) {
    case "var":
      vmWriter.writePop("local", index: symbolTable.indexOf(varName.identifier!))
    case "field":
      vmWriter.writePop("this", index: symbolTable.indexOf(varName.identifier!))
    case "static":
      vmWriter.writePop("static", index: symbolTable.indexOf(varName.identifier!))
    default:
      vmWriter.writePop("argument", index: symbolTable.indexOf(varName.identifier!))
    }
  }

  fileprivate func writeOpenTag(_ tag: String) {
    //out += "<\(tag)>\n"
  }

  fileprivate func writeCloseTag(_ tag: String) {
    //out += "</\(tag)>\n"
  }

  fileprivate func writeNextToken() -> JackToken {
    let token = tokeniser.next()!
    //out += "\(token)\n"
    return token
  }
}
