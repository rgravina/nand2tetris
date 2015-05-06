import Foundation

public enum JackTokenType {
  case Keyword, Symbol, Identifier, IntConstant, StringConstant, Unknown
}

public enum JackTokenKeyword {
  case Class, Method, Function, Contructor,
  Int, Boolean, Char, Void,
  Var, Static, Field, Let,
  Do, If, Else, While,
  Return, True, False,
  Null, This, Unknown
}

public class JackToken : Printable{
  public let type:JackTokenType
  public let keyword:String?
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
      keyword = string
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
      stringVal = string[1..<count(string)-1]
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
    switch (s) {
    case "class", "constructor", "function", "method", "field", "static", "var", "int", "char", "boolean", "void", "true", "false", "null", "this", "that", "let", "do", "if", "else", "while", "return":
      return true
    default:
      return false
    }
  }

  internal static func isIntVal(s: String) -> Bool {
    return s.toInt() != nil
  }

  internal static func isStringVal(s: String) -> Bool {
    return s[0] == "\""
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