//
//  Atheris.swift
//  Atheris
//
//  Created by Toni Kocjan on 25/09/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

class Atheris {
  let inputStream: InputStream
  var logger: LoggerProtocol = LoggerFactory.logger
  
  init(inputStream: InputStream) {
    self.inputStream = inputStream
  }
  
  func compile() throws -> OutputStream {
    let symbolTable = SymbolTable(symbolDescription: SymbolDescription())
    var syntaxTree: AstBindings?
    
    do {
      logger.log(message: "SML -> Racket 🚀 [0.0.1 (pre-alpha)]:")
      logger.log(message: "Compiling ... ")
      
      let lexan = LexAn(inputStream: inputStream)
      //    let outputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: "lex")!))
      //    for symbol in lexan {
      //      outputStream.printLine(symbol.description)
      //    }
      
      // Parse syntax
      let synan = SynAn(lexan: lexan)
      let ast = try synan.parse()
      syntaxTree = ast
      logger.log(message: "Successfully parsed ast")
      
      // Name resolving
      let nameChecker = NameChecker(symbolTable: symbolTable,
                                    symbolDescription: symbolTable.symbolDescription)
      try nameChecker.visit(node: ast)
      logger.log(message: "Successfully resolved names")
      
      // Type resolving
      let typeChecker = TypeChecker(symbolTable: symbolTable,
                                    symbolDescription: symbolTable.symbolDescription)
      try typeChecker.visit(node: ast)
      logger.log(message: "Successfully parsed types")
      
      // Code generation
      let outputStream = TextOutputStream()
      let codeGenerator = RacketCodeGenerator(outputStream: outputStream,
                                              configuration: .standard, symbolDescription: symbolTable.symbolDescription)
      try codeGenerator.visit(node: ast)
      logger.log(message: "Successfully generated racket code")
      return outputStream
    } catch {
      logger.log(message: "Error: \(error.localizedDescription)")
      if let syntaxTree = syntaxTree {
        try dumpAst(ast: syntaxTree,
                    symbolDescription: symbolTable.symbolDescription)
      }
      throw error
    }
  }
  
  private func dumpAst(ast: AstBindings, outputFile: String = "ast", symbolDescription: SymbolDescriptionProtocol) throws {
    let outputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: outputFile)!))
    let dumpVisitor = DumpVisitor(outputStream: outputStream,
                                  symbolDescription: symbolDescription)
    try dumpVisitor.visit(node: ast)
  }
}

extension Atheris {
  enum Error: Swift.Error {
    case invalidPath(String)
    case fileNotFound(URL)
    case invalidArguments(errorMessage: String)
    
    var localizedDescription: String {
      switch self {
      case .invalidArguments(let errMessage):
        return errMessage
      case .invalidPath(let url):
        return "\(url) is not a valid URL!"
      case .fileNotFound:
        return "File not found or cannot be opened!"
      }
    }
  }
}
