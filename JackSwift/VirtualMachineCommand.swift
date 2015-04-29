import Foundation

public enum VirtualMachineCommandType {
  case Arithmetic, Push, Pop, Label, Goto, If, Function, Return, Call, Unknown
}

public class VirtualMachineCommand : Printable {
  public let type:VirtualMachineCommandType
  public let arg1:String?
  public let arg2:Int?
  public static var rip:Int = 0

  /**
  * Takes a string representing a VM command are parses it into instruction and arguments.
  */
  public init(command: String) {
    var tokens = split(command) {$0 == " "}
    switch(tokens.first!) {
    case "push":
      type = .Push
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "push":
      type = .Pop
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "add":
      type = .Arithmetic
      arg1 = "add"
      arg2 = nil
    case "eq":
      type = .Arithmetic
      arg1 = "eq"
      arg2 = nil
    default:
      type = .Unknown
      arg1 = nil
      arg2 = nil
    }
    println(self)
  }


  /**
  * Prints command in original string form.
  */
  public var description: String {
    get {
      switch(type) {
      case .Arithmetic:
        return "// \(arg1!)"
      case .Push:
        return "// push \(arg1!) \(arg2!)"
      case .Pop:
        return "// pop \(arg1!) \(arg2!)"
      case .Label:
        return "// Label"
      case .Goto:
        return "// Goto"
      case .If:
        return "// If"
      case .Function:
        return "// Function"
      case .Return:
        return "// Return"
      case .Call:
        return "// Call"
      default:
        return "// Unknown"
      }
    }
  }

  /**
  * Prints command in assembler string form.
  *
  * Memory layout
  *
  * 0 - 15          Virtual registers
  *                 0 SP
  *                 1 LCL
  *                 2 ARG
  *                 3 THIS
  *                 4 THAT
  *                 5-12 temp segment
  *                 13-15 general purpose registers
  * 16 - 255        Static variables (all of the VM functions in the program)
  * 256 - 2047      Stack
  * 2048 - 16483    Heap (used to store objects and arrays)
  * 16384 - 24575   Memory mapped I/O
  *
  * Hack Registers
  *
  * - Two 16-bit registers which can be manipulated directly - D and A
  *  by arithmetic and logical expressions like A=D-1, D=!A
  *
  * D - only stores data values
  * A - both data and address (instruction or data) values
  *   - jump instructions look at A
  *   - Load A with e.g. @2
  *
  * M - refers to the memory word whose address is the current value of the A register
  *     e.g. D = Memory[516] - 1 is 1) @516 2) D=M-1
  */
  public var instructions: Array<String> {
    var instructions = Array<String>()
    switch(type) {
    case .Arithmetic:
      switch(arg1!) {
      case "add":
        // pop two values from the stack
        // add them and push back on the stack
        // decrement SP by one.
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1())
        instructions.extend(setAToArg2())
        println("// - Add D and A")
        instructions.append("D=D+A")
        instructions.extend(putDOnStack())
        return instructions
      case "eq":
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1())
        instructions.extend(setAToArg2())
        println("// - TODO Subtract A from D and test for zero (i.e. test for eq), then set top of stack to true (-1) or false (0).")
        let rip = VirtualMachineCommand.rip++
        // set top of stack to be the comparison of D and A
        instructions.append("M=D-A")
        instructions.append("@$RIP:\(rip)")
        instructions.append("D=A")
        instructions.append("@$$TRUE")
        instructions.append("M;JEQ")
        instructions.append("@SP")
        instructions.append("A=A-1")
        instructions.append("M=0")
        instructions.append("($RIP:\(rip))")
        instructions.append("@SP")
        instructions.append("A=M-1")
        return instructions
      default:
        return instructions
      }
    case .Push:
      switch(arg1!) {
      case "constant":
        // push arg2 onto the stack
        //   set memory location in SP to arg2
        //   increment stack pointer (SP)
        instructions.extend(setTopOfStackToValue(arg2!))
        instructions.extend(incrementStackPointer())
        return instructions
      default:
        return instructions
      }
    case .Pop:
//      return "pop \(arg1!) \(arg2!)"
      return instructions
//    case .Label:
//    case .Goto:
//    case .If:
//    case .Function:
//    case .Return:
//    case .Call:
    default:
      return instructions
    }
  }

  private func incrementStackPointer() -> Array<String>  {
    println("// - increment stack pointer")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("M=M+1")
    return instructions
  }

  private func decrementStackPointer() -> Array<String>  {
    println("// - decrement stack pointer")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("M=M-1")
    return instructions
  }

  private func setTopOfStackToValue(value: Int) -> Array<String>  {
    println("// - set top of stack to \(value)")
    var instructions = Array<String>()
    instructions.append("@\(value)")
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("M=D")
    return instructions
  }

  private func setDToArg1() -> Array<String>  {
    println("// - get top of stack and store in D")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("D=M")
    return instructions
  }

  private func setAToArg2() -> Array<String>  {
    println("// - get next value from stack and store in A")
    var instructions = Array<String>()
    instructions.append("A=A-1")
    instructions.append("A=M")
    return instructions
  }

  private func putDOnStack() -> Array<String>  {
    println("// - put value back on stack")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M-1")
    instructions.append("M=D")
    return instructions
  }

  public static var setup: Array<String> {
    println("// initialise stack pointer to 256")
    var instructions = Array<String>()
    instructions.append("@256")
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("M=D")
    instructions.append("@$$START")
    instructions.append("0;JMP")
    instructions.append("($$TRUE)")
    instructions.append("@SP")
    instructions.append("A=M-1")
    instructions.append("M=-1")
    // set A to the RIP
    instructions.append("A=D")
    instructions.append("0;JMP")
    instructions.append("($$START)")
    return instructions
  }
}