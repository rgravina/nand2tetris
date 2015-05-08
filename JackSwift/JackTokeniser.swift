import Foundation

class JackTokeniser {
  let reader:StreamReader?
  let source:String
  let length:Int
  var pos:Int = 0
  var peekedToken:JackToken? // lookahead token

  /**
   * Open the source file and read contents
   */
  init(path: String, file: String) {
    reader = StreamReader(path: "\(path)/\(file)", delimiter: "")
    source = reader!.nextLine()!
    length = count(source)
  }

  init(file: String) {
    reader = StreamReader(path: file, delimiter: "")
    source = reader!.nextLine()!
    length = count(source)
  }

  /**
   * Returns the next command and advances the current line (skips whitespace and blank lines)
   */
  func next() -> JackToken? {
    // if a lookahead was performed, return that token instead of getting the next from the stream
    if (peekedToken != nil) {
      var tempPeekedToken = peekedToken
      peekedToken = nil
      return tempPeekedToken
    }

    // get next token from the source file
    var token = ""
    while pos < length {
      if ((length - pos) >= 2) {
        if source[pos..<(pos+2)] == "//" {
          // go to start of next line
          while (source[pos] != "\r\n") {
            pos++
          }
        } else if source[pos..<(pos+2)] == "/*" {
          // go to closing comment
          while source[pos..<(pos+2)] != "*/" {
            pos++
          }
          pos+=2
        }
      }

      if source[pos] == " " || source[pos] == "\t" || source[pos] == "\r\n" {
        // keep going
        pos++
      } else {
        // char should go in token
        token.append(source[pos])
        if (JackToken.isSymbol(source[pos])) {
          pos++
          return JackToken(string: token)
        }
        pos++
        while (source[pos] != " " && source[pos] != "\r\n" && !JackToken.isSymbol(source[pos])) {
          token.append(source[pos++])
        }
        return JackToken(string: token)
      }
    }
    return nil
  }

  /**
   * Looks ahead one token without advacing the token stream. Calling repeatedly returns the same token.
   */
  func peek() -> JackToken? {
    if (peekedToken == nil) {
      peekedToken = next()
    }
    return peekedToken
  }
}
