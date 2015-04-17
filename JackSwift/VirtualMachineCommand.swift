import Foundation

enum VirtualMachineCommandType {
  case Arithmetic, Push, Pop, Label, Goto, If, Function, Return, Call, Unknown
}

class VirtualMachineCommand {
  let type:VirtualMachineCommandType

  init(command: String) {
    let tokens = split(command) {$0 == " "}
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
    println(tokens)
  }
}