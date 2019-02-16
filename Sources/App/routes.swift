import Vapor

struct Output: Encodable {
  var compilerName = "atheris"
  var compilerVersion = "0.1.2"
  var consoleStack = [String]()
  var racketCode: String? = ""
  var smlCode: String? = ""
  var error: String? = ""
}

var requestOutput = Output()

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return try req.view().render("compiler", requestOutput)
  }
  
  router.post(CompileRequest.self) { req, compile -> Future<View> in
    #if os(Linux)
    let code = compile.code.replacingOccurrences(of: "\r", with: "", options: .regularExpression)
    #else
    let code = compile.code.replacingOccurrences(of: "\r", with: "")
    #endif
    let stream = TextStream(string: code)
    requestOutput.smlCode = code
    
    do {
      let atheris = try Atheris(inputStream: stream)
      let output = try atheris.compile() as! TextOutputStream
      let fileOutputStream = FileOutputStream(fileWriter: try FileWriter(fileUrl: URL(string: "code")!))
      fileOutputStream.print(output.buffer)
      requestOutput.racketCode = output.buffer
      
      let promise = req.eventLoop.newPromise(View.self)
      try Executor().execute(file: "code") { result in
        requestOutput.consoleStack.insert(result, at: 0)
        requestOutput.error = nil
        _ = try? req
          .view()
          .render("compiler", requestOutput)
          .do { promise.succeed(result: $0) }
      }
      return promise.futureResult
    } catch {
      let errorMessage = (error as? AtherisError)?.errorMessage ?? error.localizedDescription.replacingOccurrences(of: "\n", with: "\r\n")
      requestOutput.error = errorMessage
      requestOutput.racketCode = nil
      return try req.view().render("compiler", requestOutput)
    }
  }
}
