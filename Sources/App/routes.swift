import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get { req in
    return try req.view().render("compiler")
  }
  
  router.post(CompileRequest.self) { req, compile -> Future<View> in
    switch 10 {
    case 0...:
      break
    default:
      break
    }
    
    let code = compile.code.replacingOccurrences(of: "\r", with: "")
    let stream = TextStream(string: code)
    let atheris = Atheris(inputStream: stream)
    do {
      let output = try atheris.compile() as! TextOutputStream
      let executor = Executor()
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
