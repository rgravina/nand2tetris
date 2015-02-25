import Foundation

enum CommandType {
  case Address, Computation, Label
}

class Command {
  init(command: String) {
    println(command)
  }
}