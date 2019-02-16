import Vapor

var buffer = ""

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return try req.view().render("compiler")
  }
  
  router.post(CompileRequest.self) { req, compile -> Future<View> in
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
      try Executor().execute(file: "code") { result -> Void in
        buffer = "atheris [0.0.1 (pre-alpha)]: " + result + "\n" + buffer
        _ = try? req
          .view()
          .render("compiler", ["output": output.buffer,
                               "code": code,
                               "result": buffer])
          .do { promise.succeed(result: $0) }
      }
      return promise.futureResult
    } catch {
      let errorMessage = (error as? AtherisError)?.errorMessage ?? error.localizedDescription.replacingOccurrences(of: "\n", with: "\r\n")
      
      return try req.view().render("compiler",
                                   ["error": errorMessage,
                                    "code": code])
    }
  }
}
