import Foundation

enum VirtualMachineCommandType {
}

class VirtualMachineCommand {
  init(command: String) {
    println("\(__FILE__):\(__LINE__): \(command)")
  }
}