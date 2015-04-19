import Foundation

enum VirtualMachineCommandType {
  case Arithmetic, Push, Pop, Label, Goto, If, Function, Return, Call, Unknown
}

class VirtualMachineCommand : Printable {
  let type:VirtualMachineCommandType
  let arg1:String?
  let arg2:String?

  init(command: String) {
    var tokens = split(command) {$0 == " "}
    switch(tokens.first!) {
    case "push":
      type = .Push
      arg1 = tokens[1]
      arg2 = tokens[2]
    case "push":
      type = .Pop
      arg1 = tokens[1]
      arg2 = tokens[2]
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


  var description: String {
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
}