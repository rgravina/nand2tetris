import Foundation

enum VirtualMachineCommandType : Printable {
  case Arithmetic, Push, Pop, Label, Goto, If, Function, Return, Call, Unknown
  var description: String {
    get {
      switch(self) {
      case .Arithmetic:
        return "Arithmetic"
      case .Push:
        return "Push"
      case .Pop:
        return "Pop"
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

class VirtualMachineCommand {
  let type:VirtualMachineCommandType

  init(command: String) {
    var tokens = split(command) {$0 == " "}
    let last = tokens.removeLast()
    // remove newline at end of last token
    tokens.append(last.substringToIndex(last.endIndex.predecessor()))
    switch(tokens.first!) {
    case "push":
      type = .Push
    case "push":
      type = .Pop
    case "add":
      type = .Arithmetic
    default:
      type = .Unknown
    }
    println(type)
  }
}