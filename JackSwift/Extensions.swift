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
}