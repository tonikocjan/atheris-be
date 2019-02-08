import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return try req.view().render("compiler")
  }
  
  router.post(CompileRequest.self) { req, compile -> Future<View> in
//    LoggerFactory.logger.log(message: "Inside request ...")
    #if os(Linux)
    let code = compile.code.replacingOccurrences(of: "\r", with: "", options: .regularExpression)
    #else
    let code = compile.code.replacingOccurrences(of: "\r", with: "")
    #endif
    let stream = TextStream(string: code)
//    LoggerFactory.logger.log(message: "After stream defined ...")
    do {
      let atheris = try Atheris(inputStream: stream)
      let output = try atheris.compile() as! TextOutputStream
      return try req.view().render("compiler",
                                   ["output": output.buffer,
                                    "code": code])
    } catch {
      let errorMessage = (error as? AtherisError)?.errorMessage ?? error.localizedDescription.replacingOccurrences(of: "\n", with: "\r\n")
      
      return try req.view().render("compiler",
                                   ["error": errorMessage,
                                    "code": code])
    }
  }
}
