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
    print("Executing \(file) ...")
    
    let pipe = Pipe()
    let task = Process()
    task.arguments = [file]
    task.standardOutput = pipe
    task.currentDirectoryPath = FileManager.default.currentDirectoryPath
    task.launchPath = "racket"

    task.launch()
    task.waitUntilExit()
    task.terminationHandler = {
      print("\nExecution ended with status: \($0.terminationStatus)")

      let result = String(data: pipe.fileHandleForReading.readDataToEndOfFile(),
                          encoding: .utf8)
      completion(result ?? "")
    }
  }
}
