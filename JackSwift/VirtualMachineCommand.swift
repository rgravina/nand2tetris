import Foundation

public enum VirtualMachineCommandType {
  case Arithmetic, Push, Pop, Label, Goto, If, Function, Return, Call, Unknown
}

public class VirtualMachineCommand : Printable {
  public let fileName:String
  public let type:VirtualMachineCommandType
  public let arg1:String?
  public let arg2:Int?
  public static var rip:Int = 0
  public static var currentFunctionName:String?

  /**
  * Takes a string representing a VM command are parses it into instruction and arguments.
  */
  public init(fileName: String, command: String) {
    self.fileName = fileName
    var tokens = split(command) {$0 == " "}
    switch(tokens.first!) {
    case "push":
      type = .Push
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "pop":
      type = .Pop
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "add":
      type = .Arithmetic
      arg1 = "add"
      arg2 = nil
    case "sub":
      type = .Arithmetic
      arg1 = "sub"
      arg2 = nil
    case "eq":
      type = .Arithmetic
      arg1 = "eq"
      arg2 = nil
    case "lt":
      type = .Arithmetic
      arg1 = "lt"
      arg2 = nil
    case "gt":
      type = .Arithmetic
      arg1 = "gt"
      arg2 = nil
    case "and":
      type = .Arithmetic
      arg1 = "and"
      arg2 = nil
    case "or":
      type = .Arithmetic
      arg1 = "or"
      arg2 = nil
    case "neg":
      type = .Arithmetic
      arg1 = "neg"
      arg2 = nil
    case "not":
      type = .Arithmetic
      arg1 = "not"
      arg2 = nil
    case "label":
      type = .Label
      arg1 = tokens[1]
      arg2 = nil
    case "if-goto":
      type = .If
      arg1 = tokens[1]
      arg2 = nil
    case "goto":
      type = .Goto
      arg1 = tokens[1]
      arg2 = nil
    case "function":
      type = .Function
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
    case "return":
      type = .Return
      arg1 = nil
      arg2 = nil
    case "call":
      type = .Call
      arg1 = tokens[1]
      arg2 = tokens[2].toInt()
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
        return "// label \(arg1!)"
      case .Goto:
        return "// goto \(arg1!)"
      case .If:
        return "// if \(arg1!)"
      case .Function:
        return "// function \(arg1!) \(arg2!)"
      case .Return:
        return "// return"
      case .Call:
        return "// call \(arg1!) \(arg2!)"
      default:
        return "// unknown"
      }
    }
  }

  /**
  * Prints command in assembler string form.
  *
  * Memory layout
  *
  * 0 - 15          Virtual registers
  *                 0 SP      (the stack pointer. Starts at 256)
  *                 1 LCL     (the address of the start of the local segment for the current function)
  *                 2 ARG     (the address of the start of the argument segment for the current function)
  *                 3 THIS    (the address of the start of the this segment for the current function)
  *                 4 THAT    (the address of the start of the that segment for the current function)
  *                 5-12      (temp segment)
  *                 13-15     (general purpose registers)
  * 16 - 255        Static variables (all of the VM functions in the program)
  *                           (static segment)
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
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1AndAToArg2())
        instructions.append("D=A+D")
        instructions.extend(putDOnStack())
        return instructions
      case "sub":
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1AndAToArg2())
        instructions.append("D=A-D")
        instructions.extend(putDOnStack())
        return instructions
      case "eq", "lt", "gt":
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1AndAToArg2())
        let rip = VirtualMachineCommand.rip++
        instructions.append("D=A-D")         // A-D == 0 if equal, <0 if arg1 < arg2, >0 if arg1 > arg2
        instructions.append("@R13")
        instructions.append("M=D")           // R13 contains comparison
        instructions.append("@$RIP:\(rip)")  // unique return instruction pointer
        instructions.append("D=A")           // need this as the next instruction overwrites A
        instructions.append("@R14")
        instructions.append("M=D")           // R14 contains RIP
        instructions.append("@$$\(arg1!.uppercaseString)")         // Jump to EQ function
        instructions.append("0;JMP")
        instructions.append("($RIP:\(rip))") // The end of this equals instruction
        return instructions
      case "and":
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1AndAToArg2())
        instructions.append("D=A&D")
        instructions.extend(putDOnStack())
        return instructions
      case "or":
        instructions.extend(decrementStackPointer())
        instructions.extend(setDToArg1AndAToArg2())
        instructions.append("D=A|D")
        instructions.extend(putDOnStack())
        return instructions
      case "neg":
        instructions.append("@SP")
        instructions.append("A=M-1")
        instructions.append("D=-M")
        instructions.extend(putDOnStack())
        return instructions
      case "not":
        instructions.append("@SP")
        instructions.append("A=M-1")
        instructions.append("D=!M")
        instructions.extend(putDOnStack())
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
      case "local", "argument", "this", "that", "temp", "pointer":
        // set top of stack to the value in local + offset
        // e.g. push local 0
        instructions.extend(putAddressFromSementWithOffsetInD())
        instructions.append("A=D")
        instructions.append("D=M")  // store value at address in D
        instructions.extend(incrementStackPointer())
        instructions.extend(putDOnStack())
        return instructions
      case "static":
        instructions.append("@\(fileName).\(arg2!)")
        instructions.append("D=M")  // store value at address in D
        instructions.extend(incrementStackPointer())
        instructions.extend(putDOnStack())
        return instructions
      default:
        return instructions
      }
    case .Pop:
      instructions.extend(decrementStackPointer())
      switch(arg1!) {
        case "static":
          instructions.append("@\(fileName).\(arg2!)")
          instructions.append("D=A")
        default:
          instructions.extend(putAddressFromSementWithOffsetInD())
      }
      instructions.append("@R13")   // store D in R13
      instructions.append("M=D")
      instructions.extend(putTopOfStackInD())
      instructions.append("@R13")
      instructions.append("A=M")    // load R13 into A

      // R13/A - address to save into
      // D - value to save
      instructions.append("M=D")
      return instructions
    case .Label:
      instructions.append(getFullLabelName())
      return instructions
    case .If:
      instructions.extend(decrementStackPointer())
      instructions.extend(putTopOfStackInD())
      instructions.append(getFullLabelName())
      instructions.append("D;JNE")
      return instructions
    case .Goto:
      instructions.append(getFullLabelName())
      instructions.append("0;JMP")
      return instructions
    case .Function:
      // set function name it it can be used in lables
      VirtualMachineCommand.currentFunctionName = arg1!

      // declare a label for the function entry (arg1)
      // number of local variables (arg2)
      // initialise all local variables to zero
      instructions.append("(\(arg1!))")
      instructions.append("@LCL")
      instructions.append("D=M")
      for i in 0..<arg2! {
        instructions.append("AD=D+1")
        instructions.append("M=0")
        instructions.extend(incrementStackPointer())
      }
      return instructions
    case .Return:
      // clear current function name
      VirtualMachineCommand.currentFunctionName = nil

      instructions.append("@LCL")   // use R13 to save frame address
      instructions.append("D=M")
      instructions.append("@R13")
      instructions.append("M=D")

      instructions.append("@5")     // use R14 to save return address (frame-5)
      instructions.append("D=D-A")
      instructions.append("@R14")
      instructions.append("M=D")

      instructions.append("@SP")    // eet *ARG = top of stack (i.e. return value)
      instructions.append("A=M-1")
      instructions.append("D=M")
      instructions.append("@ARG")
      instructions.append("A=M")
      instructions.append("M=D")

      instructions.append("@ARG")   // set SP = ARG + 1
      instructions.append("D=M")
      instructions.append("@SP")
      instructions.append("M=D+1")

      let callersRegisters = ["THAT", "THIS", "ARG", "LCL"]
      for register in callersRegisters {
        instructions.append("@R13")   // load frame address again
        instructions.append("A=M-1")  // get value of *(frame-i) and update R13
        instructions.append("D=A")
        instructions.append("@R13")
        instructions.append("M=D")
        instructions.append("A=D")
        instructions.append("D=M")
        instructions.append("@\(register)")
        instructions.append("M=D")    // that at FRAME-i
      }

      instructions.append("@R14")   // load return address again
      instructions.append("A=M")
      instructions.append("0;JMP")  // jump to return address
      return instructions
    case .Call:
      return VirtualMachineCommand.call(arg1!, arguments: arg2!)
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

  private func setDToArg1AndAToArg2() -> Array<String>  {
    println("// - get top of stack and store in D")
    println("// - get next value from stack and store in A")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("D=M")
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

  private func putTopOfStackInD() -> Array<String>  {
    println("// - put top of stack in D")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("D=M")
    return instructions
  }

  private func getFullLabelName() -> String {
    if let functionName = VirtualMachineCommand.currentFunctionName {
      return "(\(functionName)$\(arg1!))"
    } else {
      return "(\(arg1!))"
    }
  }


  private static func call(function: String, arguments: Int) -> Array<String>  {
    println("// - call function")
    var instructions = Array<String>()
    let rip = VirtualMachineCommand.rip++
    instructions.append("@$RIP:\(rip)")  // push RIP
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("M=D")
    instructions.append("@SP")    // inc stack pointer
    instructions.append("M=M+1")

    // push pointers on stack
    let callersRegisters = ["LCL", "ARG", "THIS", "THAT"]
    for register in callersRegisters {
      instructions.append("@\(register)")
      instructions.append("D=M")
      instructions.append("@SP")
      instructions.append("A=M")
      instructions.append("M=D")
      instructions.append("@SP")  // inc stack pointer
      instructions.append("M=M+1")
    }

    // reposition ARG = SP - nArgs - 5
    instructions.append("@\((0 - arguments - 5) * -1)")
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("D=M-D")
    instructions.append("@ARG")
    instructions.append("M=D")

    // set LCL to SP
    instructions.append("@SP")
    instructions.append("D=M")
    instructions.append("@LCL")
    instructions.append("M=D")

    // make function call
    instructions.append("@\(function)")
    instructions.append("0;JMP")

    instructions.append("($RIP:\(rip))") // the instruction after this function call
    return instructions
  }

  private func putAddressFromSementWithOffsetInD() -> Array<String>  {
    println("// - put address off segment+offset in D")
    var instructions = Array<String>()
    instructions.append("@\(arg2!)")  // load offset
    instructions.append("D=A")        // save offset in D
    // get segment base pointer
    switch(arg1!) {
    case "local":
      instructions.append("@LCL")
      instructions.append("D=D+M")  // set R13 location to save into
    case "argument":
      instructions.append("@ARG")
      instructions.append("D=D+M")  // set R13 location to save into
    case "this":
      instructions.append("@THIS")
      instructions.append("D=D+M")  // set R13 location to save into
    case "that":
      instructions.append("@THAT")
      instructions.append("D=D+M")  // set R13 location to save into
    case "temp":
      instructions.append("@5")
      instructions.append("D=D+A")  // set R13 location to save into
    case "pointer":
      instructions.append("@3")
      instructions.append("D=D+A")  // set R13 location to save into
    default:
      println("// unknown segment")
    }
    return instructions
  }

  public static var setup: Array<String> {
    println("// initialise stack pointer to 256")
    var instructions = Array<String>()
    instructions.append("@256")
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("M=D")
    instructions.extend(VirtualMachineCommand.call("Sys.init", arguments: 0))

    let comparisonFunctions:Array<(comp: String, jump: String)> = [
      (comp: "EQ", jump: "JNE"),
      (comp: "LT", jump: "JGE"),
      (comp: "GT", jump: "JLE")
    ]

    for comparisonFuction in comparisonFunctions {
      // @R13 - should contain result of arg2 - arg1.
      // @R14 - should contain the return address
      // @SP  - should point to the address after the top value on the stack
      println("// \(comparisonFuction.comp) function")
      instructions.append("($$\(comparisonFuction.comp))")
      instructions.append("@R13")
      instructions.append("D=M")
      instructions.append("@$$\(comparisonFuction.comp):FALSE")
      instructions.append("D;\(comparisonFuction.jump)")
      instructions.append("@SP")
      instructions.append("A=M-1")
      instructions.append("M=-1")   // true
      instructions.append("@$$\(comparisonFuction.comp):END")
      instructions.append("0;JMP")
      instructions.append("($$\(comparisonFuction.comp):FALSE)")
      instructions.append("@SP")
      instructions.append("A=M-1")
      instructions.append("M=0")    // false
      instructions.append("($$\(comparisonFuction.comp):END)")
      instructions.append("@R14")
      instructions.append("A=M")
      instructions.append("0;JMP")
    }

    //instructions.append("(Sys.init)")
    return instructions
  }
}