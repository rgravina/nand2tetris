import Foundation

class JackVMWriter {
  let outputFile:String
  var out:String = ""

  init(path: String, file: String) {
    self.outputFile = (path as NSString).appendingPathComponent("\(file[0..<file.characters.count-5]).vm")
  }

  init(file: String) {
    self.outputFile = "\(file[0..<file.characters.count-5]).vm"
  }

  func writeFunction(_ className: String, subroutineName: String, numLocals: Int) {
    out += "function \(className).\(subroutineName) \(numLocals)\n"
  }

  func writePush(_ segment: String, index: Int) {
    out += "push \(segment) \(index)\n"
  }

  func writePop(_ segment: String, index: Int) {
    out += "pop \(segment) \(index)\n"
  }

  func writeCall(_ name: String, numArgs: Int) {
    out += "call \(name) \(numArgs)\n"
  }

  func writeArithmetic(_ command: String) {
    out += "\(command)\n"
  }

  func writeReturn() {
    out += "return\n"
  }

  func writeLabel(_ label: String) {
    out += "label \(label)\n"
  }

  func writeIf(_ label: String) {
    out += "if-goto \(label)\n"
  }

  func writeGoto(_ label: String) {
    out += "goto \(label)\n"
  }

  func write() {
    do {
      try out.write(toFile: outputFile, atomically: false, encoding: String.Encoding.utf8)
    } catch _ {
    };
  }
}
