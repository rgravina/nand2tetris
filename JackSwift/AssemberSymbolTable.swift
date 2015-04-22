import Foundation

public class AssemblerSymbolTable {
  // predefined symbols and memory locations
  var symbols: [String:UInt] = [
    "SP":0,
    "LCL":1,
    "ARG":2,
    "THIS":3,
    "THAT":4,
    "R0":0,
    "R1":1,
    "R2":2,
    "R3":3,
    "R4":4,
    "R5":5,
    "R6":6,
    "R7":7,
    "R8":8,
    "R9":9,
    "R10":10,
    "R11":11,
    "R12":12,
    "R13":13,
    "R14":14,
    "R15":15,
    "SCREEN":16384,
    "KBD":24576,
  ]

  public init () {
  }

  // variables are stored starting at RAM address 16
  var address:UInt = 16

  public func get(symbol:String) -> UInt? {
    return symbols[symbol]
  }

  public func add(symbol:String) -> UInt? {
    if symbols[symbol] == nil {
      symbols[symbol] = address++
    }
    return symbols[symbol]
  }
}