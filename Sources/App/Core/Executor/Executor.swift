//
//  Executor.swift
//  Atheris
//
//  Created by Toni Kocjan on 04/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public protocol ExecutorProtocol {
  func execute(file: String, completion: @escaping (String) -> Void) throws
}

public class Executor: ExecutorProtocol {
  public func execute(file: String, completion: @escaping (String) -> Void) throws {
    let pipe = Pipe()
    let task = Process()
    task.arguments = [file]
    task.standardOutput = pipe
    task.currentDirectoryPath = FileManager.default.currentDirectoryPath
    task.launchPath = "racket"
    task.launch()
    task.waitUntilExit()
    task.terminationHandler = { _ in
      let result = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                          encoding: .utf8)
      completion(result ?? "")
    }
  }
}
