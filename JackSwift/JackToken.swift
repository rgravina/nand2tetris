import Foundation

public enum JackTokenType {
  case Keyword, Symbol, Identifier, IntConstant, StringConstant, Unknown
}

public enum JackTokenKeyword: String, Printable {
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

public class JackToken : Printable{
  public let type:JackTokenType
  public let keyword:JackTokenKeyword?
  public let symbol:Character?
  public let identifier:String?
  public let intVal:Int?
  public let stringVal:String?
  public let arg1:String?
  public let arg2:Int?

  public init(string: String) {
    if JackToken.isSymbol(string[0]) {
      type = .Symbol
      symbol = string[0]
      keyword = nil
      intVal = nil
      stringVal = nil
      identifier = nil
    } else if JackToken.isKeyword(string)  {
      type = .Keyword
      keyword = JackToken.keywordFromString(string)
      symbol = nil
      intVal = nil
      stringVal = nil
      identifier = nil
    } else if JackToken.isIntVal(string) {
      type = .IntConstant
      symbol = nil
      keyword = nil
      intVal = string.toInt()
      stringVal = nil
      identifier = nil
    } else if JackToken.isStringVal(string) {
      type = .StringConstant
      symbol = nil
      keyword = nil
      intVal = nil
      // remove double quotes from string
      stringVal = string[1..<count(string)-2]
      identifier = nil
    } else {
      type = .Identifier
      symbol = nil
      keyword = nil
      intVal = nil
      stringVal = nil
      identifier = string
    }
    arg1 = nil
    arg2 = nil
  }

  internal static func isSymbol(c: Character) -> Bool {
    switch (c) {
    case "{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/", "&", "|", "<", ">", "=", "~":
      return true
    default:
      return false
    }
  }

  internal static func isKeyword(s: String) -> Bool {
    return JackToken.keywordFromString(s) != nil
  }

  internal static func isIntVal(s: String) -> Bool {
    return s.toInt() != nil
  }

  internal static func isStringVal(s: String) -> Bool {
    return s[0] == "\""
  }

  internal static func keywordFromString(s: String) -> JackTokenKeyword? {
    return JackTokenKeyword(rawValue: s)
  }

  public var keywordConstant: Bool {
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

  public var binaryOperator: Bool {
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

  public var unaryOperator: Bool {
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

  public var description: String {
    get {
      switch(type) {
      case .Symbol:
        return "<symbol> \(symbol!) </symbol>"
      case .Keyword:
        return "<keyword> \(keyword!) </keyword>"
      case .Identifier:
        return "<identifier> \(identifier!) </identifier>"
      case .IntConstant:
        return "<integerConstant> \(intVal!) </integerConstant>"
      case .StringConstant:
        return "<stringConstant> \(stringVal!) </stringConstant>"
      default:
        return "(unknown)"
      }
    }
  }
}