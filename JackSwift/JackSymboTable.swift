import Foundation

public enum JackVarKind: String, Printable {
  case Static = "static"
  case Field = "field"
  case Arg = "arg"
  case Var = "var"
  public var description: String {
    return self.rawValue
  }
}

public class JackSymbolTable {
  var classScope = [String:Int]()
  var subroutineScope = [String:Int]()

  public init() {
  }

  public func startSubroutineScope() {
    subroutineScope.removeAll()
  }

  public func define(name: String, type: String, kind: JackTokenKeyword) {
    println("Defining new variable name:\(name), type:\(type), kind:\(kind).")
  }

  public func varCount(kind: JackTokenKeyword) -> Int {
    return 0
  }

  public func varCount(name: String) -> JackVarKind {
    return .Static
  }

  public func typeOf(name: String) -> JackTokenKeyword {
    return .This
  }

  public func indexOf(name: String) -> Int {
    return 0
  }
}
