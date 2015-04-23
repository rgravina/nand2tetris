import Foundation

public enum VirtualMachineCommandType {
  case Arithmetic, Push, Pop, Label, Goto, If, Function, Return, Call, Unknown
}

public class VirtualMachineCommand : Printable {
  public let type:VirtualMachineCommandType
  public let arg1:String?
  public let arg2:Int?

  /**
  * Takes a string representing a VM command are parses it into instruction and arguments.
  */
  public init(command: String) {
    var tokens = split(command) {$0 == " "}
    switch(tokens.first!) {
    case "push":
      type = .Push
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "push":
      type = .Pop
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "add":
      type = .Arithmetic
      arg1 = "add"
      arg2 = nil
    default:
      type = .Unknown
      arg1 = nil
      arg2 = nil
    }
    println(self)
  }


  /**
  * Prints command in original string form.
  */
  public var description: String {
    get {
      switch(type) {
      case .Arithmetic:
        return "\(arg1!)"
      case .Push:
        return "push \(arg1!) \(arg2!)"
      case .Pop:
        return "pop \(arg1!) \(arg2!)"
      case .Label:
        return "Label"
      case .Goto:
        return "Goto"
      case .If:
        return "If"
      case .Function:
        return "Function"
      case .Return:
        return "Return"
      case .Call:
        return "Call"
      default:
        return "Unknown"
      }
    }
  }

  /**
  * Prints command in assembler string form.
  */
  public var assembly: String {
    /* TODO implment add similar to this
     * Computes R0 = 2 + 3
      @2
      D=A
      @3
      D=D+A
      @0
      M=D
     */
    get {
      return "todo assembly instruction"
    }
  }
}