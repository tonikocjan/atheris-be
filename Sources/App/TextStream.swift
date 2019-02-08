//
//  TextStream.swift
//  App
//
//  Created by Toni Kocjan on 08/02/2019.
//

import Foundation

public class TextStream: InputStream {
  public let string: String
  private var it = 0
  
  public init(string: String) {
    self.string = string
  }
  
  public func next() throws -> Character {
    guard it < string.count else { throw NSError(domain: "Empty string", code: 0, userInfo: nil) }
    it += 1
    return string[string.index(string.startIndex, offsetBy: it - 1)]
  }
}

public class TextOutputStream: OutputStream {
  var buffer = ""
  
  public func print(_ string: String) {
    buffer += string
  }
  
  public func printLine(_ string: String) {
    buffer += string + "\n"
  }
}
