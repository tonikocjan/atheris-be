//
//  Logger.swift
//  Atheris
//
//  Created by Toni Kocjan on 29/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

protocol LoggerProtocol {
  func log(message: String)
  func error(message: String)
  func warning(message: String)
}

class Logger: LoggerProtocol {
  func log(message: String) {
    fputs(message, stderr)
  }
  
  func error(message: String) {
    fputs(message, stderr)
  }
  
  func warning(message: String) {
    fputs(message, stderr)
  }
}

class LoggerFactory {
  static let logger: LoggerProtocol = Logger()
}
