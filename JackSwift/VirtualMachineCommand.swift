import Foundation

public enum VirtualMachineCommandType {
  case arithmetic, push, pop, label, goto, `if`, function, `return`, call, unknown
}

open class VirtualMachineCommand : CustomStringConvertible {
  open let className:String
  open let type:VirtualMachineCommandType
  open let arg1:String?
  open let arg2:Int?
  open static var rip:Int = 0
  open static var currentFunctionName:String?

  /**
  * Takes a string representing a VM command are parses it into instruction and arguments.
  */
  public init(className: String, command: String) {
    self.className = className
    var tokens = command.characters.split {$0 == " "}.map { String($0) }
    switch(tokens.first!) {
    case "push":
      type = .push
      arg1 = tokens[1]
      arg2 = Int(tokens[2])
    case "pop":
      type = .pop
      arg1 = tokens[1]
      arg2 = Int(tokens[2])
    case "add":
      type = .arithmetic
      arg1 = "add"
      arg2 = nil
    case "sub":
      type = .arithmetic
      arg1 = "sub"
      arg2 = nil
    case "eq":
      type = .arithmetic
      arg1 = "eq"
      arg2 = nil
    case "lt":
      type = .arithmetic
      arg1 = "lt"
      arg2 = nil
    case "gt":
      type = .arithmetic
      arg1 = "gt"
      arg2 = nil
    case "and":
      type = .arithmetic
      arg1 = "and"
      arg2 = nil
    case "or":
      type = .arithmetic
      arg1 = "or"
      arg2 = nil
    case "neg":
      type = .arithmetic
      arg1 = "neg"
      arg2 = nil
    case "not":
      type = .arithmetic
      arg1 = "not"
      arg2 = nil
    case "label":
      type = .label
      arg1 = tokens[1]
      arg2 = nil
    case "if-goto":
      type = .if
      arg1 = tokens[1]
      arg2 = nil
    case "goto":
      type = .goto
      arg1 = tokens[1]
      arg2 = nil
    case "function":
      type = .function
      arg1 = tokens[1]
      arg2 = Int(tokens[2])
    case "return":
      type = .return
      arg1 = nil
      arg2 = nil
    case "call":
      type = .call
      arg1 = tokens[1]
      arg2 = Int(tokens[2])
    default:
      type = .unknown
      arg1 = nil
      arg2 = nil
    }
    print(self)
  }


  /**
  * Prints command in original string form.
  */
  open var description: String {
    get {
      switch(type) {
      case .arithmetic:
        return "// \(arg1!)"
      case .push:
        return "// push \(arg1!) \(arg2!)"
      case .pop:
        return "// pop \(arg1!) \(arg2!)"
      case .label:
        return "// label \(arg1!)"
      case .goto:
        return "// goto \(arg1!)"
      case .if:
        return "// if \(arg1!)"
      case .function:
        return "// function \(arg1!) \(arg2!)"
      case .return:
        return "// return"
      case .call:
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
  open var instructions: Array<String> {
    var instructions = Array<String>()
    switch(type) {
    case .arithmetic:
      switch(arg1!) {
      case "add":
        instructions.append(contentsOf: decrementStackPointer())
        instructions.append(contentsOf: setDToArg1AndAToArg2())
        instructions.append("D=A+D")
        instructions.append(contentsOf: putDOnStack())
        return instructions
      case "sub":
        instructions.append(contentsOf: decrementStackPointer())
        instructions.append(contentsOf: setDToArg1AndAToArg2())
        instructions.append("D=A-D")
        instructions.append(contentsOf: putDOnStack())
        return instructions
      case "eq", "lt", "gt":
        instructions.append(contentsOf: decrementStackPointer())
        instructions.append(contentsOf: setDToArg1AndAToArg2())
        let rip = VirtualMachineCommand.rip += 1
        instructions.append("D=A-D")         // A-D == 0 if equal, <0 if arg1 < arg2, >0 if arg1 > arg2
        instructions.append("@R13")
        instructions.append("M=D")           // R13 contains comparison
        instructions.append("@$RIP:\(rip)")  // unique return instruction pointer
        instructions.append("D=A")           // need this as the next instruction overwrites A
        instructions.append("@R14")
        instructions.append("M=D")           // R14 contains RIP
        instructions.append("@$$\(arg1!.uppercased())")         // Jump to EQ function
        instructions.append("0;JMP")
        instructions.append("($RIP:\(rip))") // The end of this equals instruction
        return instructions
      case "and":
        instructions.append(contentsOf: decrementStackPointer())
        instructions.append(contentsOf: setDToArg1AndAToArg2())
        instructions.append("D=A&D")
        instructions.append(contentsOf: putDOnStack())
        return instructions
      case "or":
        instructions.append(contentsOf: decrementStackPointer())
        instructions.append(contentsOf: setDToArg1AndAToArg2())
        instructions.append("D=A|D")
        instructions.append(contentsOf: putDOnStack())
        return instructions
      case "neg":
        instructions.append("@SP")
        instructions.append("A=M-1")
        instructions.append("D=-M")
        instructions.append(contentsOf: putDOnStack())
        return instructions
      case "not":
        instructions.append("@SP")
        instructions.append("A=M-1")
        instructions.append("D=!M")
        instructions.append(contentsOf: putDOnStack())
        return instructions
      default:
        return instructions
      }
    case .push:
      switch(arg1!) {
      case "constant":
        // push arg2 onto the stack
        //   set memory location in SP to arg2
        //   increment stack pointer (SP)
        instructions.append(contentsOf: setTopOfStackToValue(arg2!))
        instructions.append(contentsOf: incrementStackPointer())
        return instructions
      case "local", "argument", "this", "that", "temp", "pointer":
        // set top of stack to the value in local + offset
        // e.g. push local 0
        instructions.append(contentsOf: putAddressFromSementWithOffsetInD())
        instructions.append("A=D")
        instructions.append("D=M")  // store value at address in D
        instructions.append(contentsOf: incrementStackPointer())
        instructions.append(contentsOf: putDOnStack())
        return instructions
      case "static":
        instructions.append("@\(className).\(arg2!)")
        instructions.append("D=M")  // store value at address in D
        instructions.append(contentsOf: incrementStackPointer())
        instructions.append(contentsOf: putDOnStack())
        return instructions
      default:
        return instructions
      }
    case .pop:
      instructions.append(contentsOf: decrementStackPointer())
      switch(arg1!) {
        case "static":
          instructions.append("@\(className).\(arg2!)")
          instructions.append("D=A")
        default:
          instructions.append(contentsOf: putAddressFromSementWithOffsetInD())
      }
      instructions.append("@R13")   // store D in R13
      instructions.append("M=D")
      instructions.append(contentsOf: putTopOfStackInD())
      instructions.append("@R13")
      instructions.append("A=M")    // load R13 into A

      // R13/A - address to save into
      // D - value to save
      instructions.append("M=D")
      return instructions
    case .label:
      instructions.append("(\(getFullLabelName()))")
      return instructions
    case .if:
      instructions.append(contentsOf: decrementStackPointer())
      instructions.append(contentsOf: putTopOfStackInD())
      instructions.append("@\(getFullLabelName())")
      instructions.append("D;JNE")
      return instructions
    case .goto:
      instructions.append("@\(getFullLabelName())")
      instructions.append("0;JMP")
      return instructions
    case .function:
      // set function name it it can be used in lables
      VirtualMachineCommand.currentFunctionName = arg1!

      // declare a label for the function entry (arg1)
      // number of local variables (arg2)
      // initialise all local variables to zero
      instructions.append("(\(arg1!))")
      instructions.append("@LCL")
      instructions.append("D=M")
      for _ in 0..<arg2! {
        instructions.append("AD=D+1")
        instructions.append("M=0")
        instructions.append(contentsOf: incrementStackPointer())
      }
      return instructions
    case .return:
      instructions.append("@LCL")   // use R13 to save frame address
      instructions.append("D=M")
      instructions.append("@R13")
      instructions.append("M=D")

      instructions.append("@5")     // use R14 to save return address (frame-5)
      instructions.append("A=D-A")
      instructions.append("D=M")
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
    case .call:
      return VirtualMachineCommand.call(arg1!, arguments: arg2!)
    default:
      return instructions
    }
  }

  fileprivate func incrementStackPointer() -> Array<String>  {
    print("// - increment stack pointer")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("M=M+1")
    return instructions
  }

  fileprivate func decrementStackPointer() -> Array<String>  {
    print("// - decrement stack pointer")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("M=M-1")
    return instructions
  }

  fileprivate func setTopOfStackToValue(_ value: Int) -> Array<String>  {
    print("// - set top of stack to \(value)")
    var instructions = Array<String>()
    instructions.append("@\(value)")
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("M=D")
    return instructions
  }

  fileprivate func setDToArg1AndAToArg2() -> Array<String>  {
    print("// - get top of stack and store in D")
    print("// - get next value from stack and store in A")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("D=M")
    instructions.append("A=A-1")
    instructions.append("A=M")
    return instructions
  }

  fileprivate func putDOnStack() -> Array<String>  {
    print("// - put value back on stack")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M-1")
    instructions.append("M=D")
    return instructions
  }

  fileprivate func putTopOfStackInD() -> Array<String>  {
    print("// - put top of stack in D")
    var instructions = Array<String>()
    instructions.append("@SP")
    instructions.append("A=M")
    instructions.append("D=M")
    return instructions
  }

  fileprivate func getFullLabelName() -> String {
    if let functionName = VirtualMachineCommand.currentFunctionName {
      return "\(functionName)$\(arg1!)"
    } else {
      return arg1!
    }
  }


  fileprivate static func call(_ function: String, arguments: Int) -> Array<String>  {
    print("// - call function")
    var instructions = Array<String>()
    let rip = VirtualMachineCommand.rip += 1
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
    instructions.append("@\((arguments + 5))")
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

  fileprivate func putAddressFromSementWithOffsetInD() -> Array<String>  {
    print("// - put address off segment+offset in D")
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
      print("// unknown segment")
    }
    return instructions
  }

  open static var setup: Array<String> {
    print("// initialise stack pointer to 256")
    var instructions = Array<String>()
    instructions.append("@256")
    instructions.append("D=A")
    instructions.append("@SP")
    instructions.append("M=D")
    instructions.append(contentsOf: VirtualMachineCommand.call("Sys.init", arguments: 0))

    let comparisonFunctions:Array<(comp: String, jump: String)> = [
      (comp: "EQ", jump: "JNE"),
      (comp: "LT", jump: "JGE"),
      (comp: "GT", jump: "JLE")
    ]

    for comparisonFuction in comparisonFunctions {
      // @R13 - should contain result of arg2 - arg1.
      // @R14 - should contain the return address
      // @SP  - should point to the address after the top value on the stack
      print("// \(comparisonFuction.comp) function")
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

    return instructions
  }
}
