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

  func write() {
    out.writeToFile(outputFile, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
  }
}