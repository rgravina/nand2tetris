import Foundation

public enum JackVarKind: String, CustomStringConvertible {
  case Static = "static"    // static segment (class scope)
  case Field = "field"      // this segment   (class scope)
  case Arg = "arg"          // arg segment    (subroutine scope)
  case Var = "var"          // local segment  (subroutine scope)
  public var description: String {
    return self.rawValue
  }
}

struct SymbolTableEntry : CustomStringConvertible {
  var type:String
  var kind:String
  var index:Int

  var description: String {
    return "type:\(type), kind:\(kind) index:\(index)"
  }
}

open class JackSymbolTable {
  var className:String?
  var classScope = [String:SymbolTableEntry]()
  var subroutineScope = [String:SymbolTableEntry]()
  var indexes = [String:Int]()

  public init() {
    // assumes one symbol table per class
    indexes = ["static": 0, "field": 0]
  }

  open func startSubroutineScope(_ method: String, className: String) {
    // reset arg and local indexes and clear all subroutine variables from the symbol table
    indexes["arg"] = 0
    indexes["var"] = 0
    subroutineScope.removeAll()
    // methods should have 'this' as the first argument
    if method == "method" {
      define("this", type: className, kind: "arg")
    }
  }

  open func define(_ name: String, type: String, kind: String) {
    if kind == "static" || kind == "field" {
      indexes[kind]! += 1
      let index = indexes[kind]!
      classScope[name] = SymbolTableEntry(type: type, kind: kind, index: index)
      //println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(index)")
    } else if kind == "arg" || kind == "var" {
      indexes[kind]! += 1
      let index = indexes[kind]!
      subroutineScope[name] = SymbolTableEntry(type: type, kind: kind, index: index)
      //println("Defining new variable name:\(name), type:\(type), kind:\(kind) index:\(index)")
    } else {
      //println("Found method or class indentifier... ignoring. name:\(name), type:\(type), kind:\(kind)")
    }
  }

  open func varCount(_ kind: String) -> Int {
    return indexes[kind]!
  }

  open func kindOf(_ name: String) -> String {
    if let subScope = subroutineScope[name] {
      return subScope.kind
    }
    return classScope[name]!.kind
  }

  open func typeOf(_ name: String) -> String? {
    if let subScope = subroutineScope[name] {
      return subScope.type
    } else if let clsScope = classScope[name] {
      return clsScope.type
    } else {
      return nil
    }
  }

  open func indexOf(_ name: String) -> Int {
    if let subScope = subroutineScope[name] {
      return subScope.index
    }
    return classScope[name]!.index
  }
}
