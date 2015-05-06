import Foundation

//
// String subscript extension from http://oleb.net/blog/2014/07/swift-strings/
//
extension String
{
  // e.g. string[0]
  subscript(integerIndex: Int) -> Character {
    let index = advance(startIndex, integerIndex)
    return self[index]
  }

  // e.g. string[0..<2]
  subscript(integerRange: Range<Int>) -> String {
    let start = advance(startIndex, integerRange.startIndex)
    let end = advance(startIndex, integerRange.endIndex)
    let range = start..<end
    return self[range]
  }

  func substringToIndex(index:Int) -> String {
    return self.substringToIndex(advance(self.startIndex, index))
  }

  func substringFromIndex(index:Int) -> String {
    return self.substringFromIndex(advance(self.startIndex, index))
  }

  func indexOf(target: String) -> Int
  {
    var range = self.rangeOfString(target)
    if let range = range {
      return distance(self.startIndex, range.startIndex)
    } else {
      return -1
    }
  }
}