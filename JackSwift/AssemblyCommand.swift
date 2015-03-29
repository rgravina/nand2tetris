import Foundation

enum AssemblyCommandType {
  case Address, Computation, Label
}

class AssemblyCommand {
  init(command: String) {
    println(command)
  }
}