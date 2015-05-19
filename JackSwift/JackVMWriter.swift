import Foundation

class JackVMWriter {
  let outputFile:String
  var out:String = ""

  init(path: String, file: String) {
    self.outputFile = path.stringByAppendingPathComponent("\(file[0..<count(file)-5]).vm")
  }

  init(file: String) {
    self.outputFile = "\(file[0..<count(file)-5]).vm"
  }

  func writeFunction(className: String, subroutineName: String, numLocals: Int) {
    out += "function \(className).\(subroutineName) \(numLocals)\n"
  }

  func writePush(segment: String, index: Int) {
    out += "push \(segment) \(index)\n"
  }

  func writePop(segment: String, index: Int) {
    out += "pop \(segment) \(index)\n"
  }

  func writeCall(name: String, numArgs: Int) {
    out += "call \(name) \(numArgs)\n"
  }

  func writeArithmetic(command: String) {
    out += "\(command)\n"
  }

  func writeReturn() {
    out += "return\n"
  }

  func writeLabel(label: String) {
    out += "label \(label)\n"
  }

  func writeIf(label: String) {
    out += "if-goto \(label)\n"
  }

  func writeGoto(label: String) {
    out += "goto \(label)\n"
  }

  func write() {
    out.writeToFile(outputFile, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
  }
}