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
      address = command[1..<count(command)-1]
    default:
      type = .Computation
      /**
       * Now we can work out the C instruction fields
       *
       * C instruction
       * dest=comp;jump
       * either dest or jump may be empty
       * if dest is empty. the '=' is omitted
       * if jump is empty, the ';' is omitted
       *
       * i.e dest=comp;jump, comp;jump, dest=comp.
       */
      let equalsIndex = command.rangeOfString("=")
      let semiColonIndex = command.rangeOfString(";")
      if (equalsIndex != nil) {
        dest = command[command.startIndex..<equalsIndex!.startIndex]
      } else {
        comp = command[command.startIndex..<semiColonIndex!.startIndex]
      }
      if (semiColonIndex != nil) {
        jump = command[semiColonIndex!.endIndex..<command.endIndex]
      } else {
        comp = command[equalsIndex!.endIndex..<command.endIndex]
      }
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
        var instruction = ""
        if (dest != nil) {
          instruction += "\(dest!)="
        }
        instruction += comp!
        if (jump != nil) {
          instruction += ";\(jump!)"
        }
        return instruction
      case .Label:
        return "(\(address!))"
      default:
        return "Unknown"
      }
    }
  }

}