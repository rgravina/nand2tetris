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

      // dest
      if (equalsIndex != nil) {
        dest = command[command.startIndex..<equalsIndex!.startIndex]
      }

      // comp
      if (equalsIndex == nil) {
        comp = command[command.startIndex..<semiColonIndex!.startIndex]
      } else if (semiColonIndex == nil) {
        comp = command[equalsIndex!.endIndex..<command.endIndex]
      } else {
        comp = command[equalsIndex!.endIndex..<semiColonIndex!.startIndex]
      }

      // jump
      if (semiColonIndex != nil) {
        jump = command[semiColonIndex!.endIndex..<command.endIndex]
      }
    }
    println(self.machineCode)
  }

  /**
  * Prints command in assembly form.
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

  /**
  * Prints machine code form.
  */
  public var machineCode: String {
    get {
      switch(type) {
      case .Address:
        // value is already an address
        if let intValue = address!.toInt() {
          return String(format: "%016d", String(intValue, radix: 2).toInt()!)
        }
        // value is a symbol, so get its address from the symbol table
        return description
      case .Computation:
        // 1 for instruction, 11 for unused bits
        let abit = comp!.rangeOfString("M") != nil ? 1 : 0
        var instruction = "111\(AssemblyCodeMap.comp[comp!]!)\(abit)"
        if let dest = dest {
          instruction += "\(AssemblyCodeMap.dest[dest]!)"
        } else {
          instruction += "000"
        }
        if let jump = jump {
          instruction += "\(AssemblyCodeMap.jump[jump]!)"
        } else {
          instruction += "000"
        }
        return instruction
      case .Label:
        return description
      default:
        return description
      }
    }
  }
}