//
//  String+Atheris.swift
//  App
//
//  Created by Toni Kocjan on 17/02/2019.
//

import Foundation

extension String {
  func removeLineBreaks() -> String {
    #if os(Linux)
    return replacingOccurrences(of: "\r", with: "", options: .regularExpression)
    #else
    return replacingOccurrences(of: "\r", with: "")
    #endif
  }
}
