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
    #if os(Linux)
    let launchPath = "racket"
    #else
    let launchPath = "/Applications/Racket v7.1/bin/racket"
    #endif
    
    let pipe = Pipe()
    let task = Process()
    task.arguments = [file]
    task.standardOutput = pipe
    task.currentDirectoryPath = FileManager.default.currentDirectoryPath
    task.launchPath = launchPath
    task.launch()
    task.waitUntilExit()
    task.terminationHandler = { _ in
      let result = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                          encoding: .utf8)
      completion(result ?? "")
    }
  }
}
