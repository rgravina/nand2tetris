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
  var className:String?
  var classScope = [String:SymbolTableEntry]()
  var subroutineScope = [String:SymbolTableEntry]()
  var indexes = [String:Int]()

  public init() {
    // assumes one symbol table per class
    indexes = ["static": 0, "field": 0]
  }

  public func startSubroutineScope(method: String, className: String) {
    // reset arg and local indexes and clear all subroutine variables from the symbol table
    indexes["arg"] = 0
    indexes["var"] = 0
    subroutineScope.removeAll()
    // methods should have 'this' as the first argument
    if method == "method" {
      define("this", type: className, kind: "arg")
    }
  }

  public func define(name: String, type: String, kind: String) {
    if kind == "static" || kind == "field" {
      let index = indexes[kind]!++
      classScope[name] = SymbolTableEntry(type: type, kind: kind, index: index)
      //println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(index)")
    } else if kind == "arg" || kind == "var" {
      let index = indexes[kind]!++
      subroutineScope[name] = SymbolTableEntry(type: type, kind: kind, index: index)
      //println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(index)")
    } else {
      //println("Found method or class indentifier... ignoring. name:\(name), type:\(type), kind:\(kind)")
    }
  }

  public func varCount(kind: String) -> Int {
    return indexes[kind]!
  }

  public func kindOf(name: String) -> String {
    if let subScope = subroutineScope[name] {
      return subScope.kind
    }
    return classScope[name]!.kind
  }

  public func typeOf(name: String) -> String {
    if let subScope = subroutineScope[name] {
      return subScope.type
    } else if let clsScope = classScope[name] {
      return clsScope.type
    } else {
      // for class idetifiers, their type is the same as the name of the class
      return name
    }
  }

  public func indexOf(name: String) -> Int {
    if let subScope = subroutineScope[name] {
      return subScope.index
    }
    return classScope[name]!.index
  }
}
