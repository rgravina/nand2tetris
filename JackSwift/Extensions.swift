import Foundation

//
// String subscript extension from http://oleb.net/blog/2014/07/swift-strings/
//
extension String
{
  // e.g. string[0]
  subscript(integerIndex: Int) -> Character {
    let index = characters.index(startIndex, offsetBy: integerIndex)
    return self[index]
  }

  // e.g. string[0..<2]
  subscript(integerRange: Range<Int>) -> String {
    let start = characters.index(startIndex, offsetBy: integerRange.lowerBound)
    let end = characters.index(startIndex, offsetBy: integerRange.upperBound)
    let range = start..<end
    return self[range]
  }

  func substringToIndex(_ index:Int) -> String {
    return self.substring(to: self.characters.index(self.startIndex, offsetBy: index))
  }

  func substringFromIndex(_ index:Int) -> String {
    return self.substring(from: self.characters.index(self.startIndex, offsetBy: index))
  }

  func indexOf(_ target: String) -> Int
  {
    let range = self.range(of: target)
    if let range = range {
      return self.characters.distance(from: self.startIndex, to: range.lowerBound)
    } else {
      return -1
    }
  }
}
