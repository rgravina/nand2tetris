import Foundation

public enum AssemblyCommandType {
  case address, computation, label
}

open class AssemblyCommand : CustomStringConvertible {
  open let type:AssemblyCommandType
  open var address:String?
  open var instruction:String?
  open var dest:String?
  open var comp:String?
  open var jump:String?

  /**
  * Takes a assembly command are parses it into components
  */
  public init(command: String) {
    let char = command[0]
    switch char {
    case "@":
      type = .address
      address = command[1..<command.characters.count]
    case "(":
      type = .label
      address = command[1..<command.characters.count-1]
    default:
      type = .computation
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
      let equalsIndex = command.range(of: "=")
      let semiColonIndex = command.range(of: ";")

      // dest
      if (equalsIndex != nil) {
        dest = command[command.startIndex..<equalsIndex!.lowerBound]
      }

      // comp
      if (equalsIndex == nil) {
        comp = command[command.startIndex..<semiColonIndex!.lowerBound]
      } else if (semiColonIndex == nil) {
        comp = command[equalsIndex!.upperBound..<command.endIndex]
      } else {
        comp = command[equalsIndex!.upperBound..<semiColonIndex!.lowerBound]
      }
      assert(comp != nil, "Could not parse the comp part of the assembly instruction '\(command)'.")
      assert(AssemblyCodeMap.comp[comp!] != nil, "The assembly instruction comp section '\(comp!)' in '\(command)' doesn't exist.")

      // jump
      if (semiColonIndex != nil) {
        jump = command[semiColonIndex!.upperBound..<command.endIndex]
      }
    }
  }

  /**
  * Converts an integer to binary number (padded to 16bits)
  */
  open class func decToBin(_ decimal: Int) -> String? {
      let binary = String(decimal, radix: 2)
    var result = ""
    for _ in 0..<(16 - binary.characters.count) {
      result += "0"
    }
    result += binary
    return result
  }

  /**
  * Prints command in assembly form.
  */
  open var description: String {
    get {
      switch(type) {
      case .address:
        return "@\(address!)"
      case .computation:
        var instruction = ""
        if (dest != nil) {
          instruction += "\(dest!)="
        }
        instruction += comp!
        if (jump != nil) {
          instruction += ";\(jump!)"
        }
        return instruction
      case .label:
        return "(\(address!))"
      }
    }
  }

  /**
  * Prints machine code form.
  */
  open var machineCode: String {
    get {
      switch(type) {
      case .address:
        // value is already an address
        if let intValue = Int(address!) {
          return AssemblyCommand.decToBin(intValue)!
        }
        // value is a symbol, so get its address from the symbol table
        return description
      case .computation:
        // If the comp section uses M, then the a-bit shoul be on
        let compPart = AssemblyCodeMap.comp[comp!]!
//      println("\(comp) is \(compPart)")
        let abit = comp!.range(of: "M") != nil ? 1 : 0
//      println("\(abit) is \(abit)")
        let destPart = dest != nil ? AssemblyCodeMap.dest[dest!]! : "000"
        let jumpPart = jump != nil ? AssemblyCodeMap.jump[jump!]! : "000"
        // Leftmost bit is 1 for instruction, net two 11 (unused bits)
        return "111\(abit)\(compPart)\(destPart)\(jumpPart)"
      default:
        return "Can not convert instruction to machine code"
      }
    }
  }
}
