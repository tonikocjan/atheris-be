import Vapor

struct Output: Encodable {
  let compilerName = "atheris"
  let compilerVersion = "0.1.2"
  let consoleStack: [String]
  let racketCode: String?
  let smlCode: String?
  let error: String?
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return try req.view().render("compiler", Output(consoleStack: [],
                                                    racketCode: nil,
                                                    smlCode: nil,
                                                    error: nil))
  }
  
  router.post(CompileRequest.self) { req, compile -> Future<View> in
    guard !compile.code.isEmpty else {
      let output = Output(consoleStack: [], racketCode: nil, smlCode: nil, error: nil)
      return try req.view().render("compiler", output)
    }
    
    #if os(Linux)
    let code = compile.code.replacingOccurrences(of: "\r", with: "", options: .regularExpression)
    #else
    let code = compile.code.replacingOccurrences(of: "\r", with: "")
    #endif
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
                                     error: nil))
          .do { promise.succeed(result: $0) }
      }
      return promise.futureResult
    } catch {
      let errorMessage = (error as? AtherisError)?.errorMessage ?? error.localizedDescription.replacingOccurrences(of: "\n", with: "\r\n")
      let output = Output(consoleStack: [],
             racketCode: nil,
             smlCode: code,
             error: errorMessage)
      return try req.view().render("compiler", output)
    }
  }
}
