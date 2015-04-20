import Foundation

public enum AssemblyCommandType {
  case Address, Computation, Label
}

public class AssemblyCommand : Printable {
  public let type:AssemblyCommandType
  public var address:String?
  public var instruction:String?
  public var dest:String?
  public var comp:String?
  public var jump:String?

  /**
  * Takes a assembly command are parses it into components
  */
  public init(command: String) {
    let char = command[0]
    switch char {
    case "@":
      type = .Address
      address = command[1..<count(command)]
    case "(":
      type = .Label
    default:
      type = .Computation
    }
    println(self)
  }

  /**
  * Prints command in original string form.
  */
  public var description: String {
    get {
      switch(type) {
      case .Address:
        return "@\(address!)"
      case .Computation:
        return "todo"
      case .Label:
        return "todo"
      default:
        return "Unknown"
      }
    }
  }

}