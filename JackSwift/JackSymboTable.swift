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

struct SymbolTableEntry : Printable {
  var type:String
  var kind:String
  var index:Int

  var description: String {
    return "type:\(type), kind:\(kind) index:\(index)"
  }
}

public class JackSymbolTable {
  var classScope = [String:SymbolTableEntry]()
  var subroutineScope = [String:SymbolTableEntry]()
  var indexes = [String:Int]()

  public init() {
    // assumes one symbol table per class
    indexes = ["static": 0, "field": 0]
  }

  public func startSubroutineScope(method: String, className: String, returnType: String, subroutineName: String) {
    // reset arg and local indexes and clear all subroutine variables from the symbol table
    indexes["arg"] = 0
    indexes["var"] = 0
    subroutineScope.removeAll()
    define(subroutineName, type: returnType, kind: method)
    // methods should have 'this' as the first argument
    if method == "method" {
      define("this", type: className, kind: "arg")
    }
  }

  public func define(name: String, type: String, kind: String) {
    if kind == "static" || kind == "field" {
      let index = indexes[kind]!++
      classScope[name] = SymbolTableEntry(type: type, kind: kind, index: index)
      println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(index)")
    } else if kind == "arg" || kind == "var" {
      let index = indexes[kind]!++
      subroutineScope[name] = SymbolTableEntry(type: type, kind: kind, index: index)
      println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(index)")
    } else {
      classScope[name] = SymbolTableEntry(type: type, kind: kind, index: 0)
      println("Defining new \(kind) name:\(name), type:\(type), kind:\(kind)")
    }
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
