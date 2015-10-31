import Foundation

//
// String subscript extension from http://oleb.net/blog/2014/07/swift-strings/
//
extension String
{
  // e.g. string[0]
  subscript(integerIndex: Int) -> Character {
    let index = startIndex.advancedBy(integerIndex)
    return self[index]
  }

  // e.g. string[0..<2]
  subscript(integerRange: Range<Int>) -> String {
    let start = startIndex.advancedBy(integerRange.startIndex)
    let end = startIndex.advancedBy(integerRange.endIndex)
    let range = start..<end
    return self[range]
  }

  func substringToIndex(index:Int) -> String {
    return self.substringToIndex(self.startIndex.advancedBy(index))
  }

  func substringFromIndex(index:Int) -> String {
    return self.substringFromIndex(self.startIndex.advancedBy(index))
  }

  func indexOf(target: String) -> Int
  {
    let range = self.rangeOfString(target)
    if let range = range {
      return self.startIndex.distanceTo(range.startIndex)
    } else {
      return -1
    }
  }
}