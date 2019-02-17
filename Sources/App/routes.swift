import Vapor

struct Output: Encodable {
  let compilerName = "atheris"
  let compilerVersion = "0.1.2"
  let consoleStack: [String]
  let racketCode: String?
  let smlCode: String?
  let error: String?
  let smlExamples: [String]
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return try req.view().render("compiler", Output(consoleStack: [],
                                                    racketCode: nil,
                                                    smlCode: nil,
                                                    error: nil,
                                                    smlExamples: predefinedSmlExamples))
  }
  
  router.post(CompileRequest.self) { req, compile -> Future<View> in
    guard !compile.code.isEmpty else {
      let output = Output(consoleStack: [],
                          racketCode: nil,
                          smlCode: nil,
                          error: nil,
                          smlExamples: predefinedSmlExamples)
      return try req.view().render("compiler", output)
    }
    
    let code = compile.code.removeLineBreaks()
    let stream = TextStream(string: code)
    
    do {
      let atheris = try Atheris(inputStream: stream)
      let output = try atheris.compile() as! TextOutputStream
      let fileOutputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: "code")!))
      fileOutputStream.print(output.buffer)
      
      let promise = req.eventLoop.newPromise(View.self)
      try Executor().execute(file: "code") { result in
        _ = try? req
          .view()
          .render("compiler", Output(consoleStack: [result],
                                     racketCode: output.buffer,
                                     smlCode: code,
                                     error: nil,
                                     smlExamples: predefinedSmlExamples))
          .do { promise.succeed(result: $0) }
      }
      return promise.futureResult
    } catch {
      let errorMessage = ((error as? AtherisError)?.errorMessage ?? error.localizedDescription)
        .replacingOccurrences(of: "\n", with: "\r\n\t")
      let output = Output(consoleStack: [],
             racketCode: nil,
             smlCode: code,
             error: errorMessage,
             smlExamples: predefinedSmlExamples)
      return try req.view().render("compiler", output)
    }
  }
}
