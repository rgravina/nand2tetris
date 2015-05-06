import Foundation

class JackParse {
  let tokeniser:JackTokeniser

  init(path: String, file: String) {
    tokeniser = JackTokeniser(path: path, file: file)
  }

  init(file: String) {
    tokeniser = JackTokeniser(file: file)
  }

  func parse() {
    println("<tokens>")
    while let token = tokeniser.next() {
      println(token)
    }
    println("<tokens>")

  }
}
