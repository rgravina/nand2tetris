import Foundation

public enum JackTokenType {
  case keyword, symbol, identifier, intConstant, stringConstant, unknown
}

public enum JackTokenKeyword: String, CustomStringConvertible {
  case Class = "class"
  case Method = "method"
  case Function = "function"
  case Constructor = "constructor"
  case Int = "int"
  case Boolean = "boolean"
  case Char = "char"
  case Void = "void"
  case Var = "var"
  case Static = "static"
  case Field = "field"
  case Let = "let"
  case Do = "do"
  case If = "if"
  case Else = "else"
  case While = "while"
  case Return = "return"
  case True = "true"
  case False = "false"
  case Null = "null"
  case This = "this"

  public var description: String {
    return self.rawValue
  }
}

open class JackToken : CustomStringConvertible{
  open let type:JackTokenType
  open let keyword:JackTokenKeyword?
  open let symbol:Character?
  open let identifier:String?
  open let intVal:Int?
  open let stringVal:String?
  open let arg1:String?
  open let arg2:Int?

  public init(string: String) {
    if JackToken.isSymbol(string[0]) {
      type = .symbol
      symbol = string[0]
      keyword = nil
      intVal = nil
      stringVal = nil
      identifier = nil
    } else if JackToken.isKeyword(string)  {
      type = .keyword
      keyword = JackToken.keywordFromString(string)
      symbol = nil
      intVal = nil
      stringVal = nil
      identifier = nil
    } else if JackToken.isIntVal(string) {
      type = .intConstant
      symbol = nil
      keyword = nil
      intVal = Int(string)
      stringVal = nil
      identifier = nil
    } else if JackToken.isStringVal(string) {
      type = .stringConstant
      symbol = nil
      keyword = nil
      intVal = nil
      // remove double quotes from string
      stringVal = string[1..<string.characters.count-1]
      identifier = nil
    } else {
      type = .identifier
      symbol = nil
      keyword = nil
      intVal = nil
      stringVal = nil
      identifier = string
    }
    arg1 = nil
    arg2 = nil
  }

  internal static func isSymbol(_ c: Character) -> Bool {
    switch (c) {
    case "{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/", "&", "|", "<", ">", "=", "~":
      return true
    default:
      return false
    }
  }

  internal static func isKeyword(_ s: String) -> Bool {
    return JackToken.keywordFromString(s) != nil
  }

  internal static func isIntVal(_ s: String) -> Bool {
    return Int(s) != nil
  }

  internal static func isStringVal(_ s: String) -> Bool {
    return s[0] == "\""
  }

  internal static func keywordFromString(_ s: String) -> JackTokenKeyword? {
    return JackTokenKeyword(rawValue: s)
  }

  open var keywordConstant: Bool {
    if (keyword == nil) {
      return false
    }
    switch (keyword!) {
    case .True, .False, .Null, .This:
      return true
    default:
      return false
    }
  }

  open var binaryOperator: Bool {
    if (symbol == nil) {
      return false
    }
    switch (symbol!) {
    case "+", "-", "*", "/", "&", "|", "<", ">", "=":
      return true
    default:
      return false
    }
  }

  open var unaryOperator: Bool {
    if (symbol == nil) {
      return false
    }
    switch (symbol!) {
    case "-", "~":
      return true
    default:
      return false
    }
  }

  open var description: String {
    get {
      switch(type) {
      case .symbol:
        return "<symbol> \(symbol!) </symbol>"
      case .keyword:
        return "<keyword> \(keyword!) </keyword>"
      case .identifier:
        return "<identifier> \(identifier!) </identifier>"
      case .intConstant:
        return "<integerConstant> \(intVal!) </integerConstant>"
      case .stringConstant:
        return "<stringConstant> \(stringVal!) </stringConstant>"
      default:
        return "(unknown)"
      }
    }
  }
}
