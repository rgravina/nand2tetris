import Foundation

public enum JackVarKind: String, Printable {
  case Static = "static"    // static segment (class scope)
  case Field = "field"      // this segment   (class scope)
  case Arg = "arg"          // arg segment    (subroutine scope)
  case Var = "var"          // local segment  (subroutine scope)
  public var description: String {
    return self.rawValue
  }
}

public class JackSymbolTable {
  var classScope = [String:Int]()
  var subroutineScope = [String:Int]()
  var indexes = [String:Int]()

  public init() {
    // assumes one symbol table per class
    indexes = ["static": 0, "field": 0]
  }

  public func startSubroutineScope() {
    // reset arg and local indexes and clear all subroutine variables from the symbol table
    indexes["arg"] = 0
    indexes["var"] = 0
    subroutineScope.removeAll()
  }

  public func define(name: String, type: String, kind: String) {
    // TODO: wrote to the symbol table
    println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(indexes[kind]!++)")
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
