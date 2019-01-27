import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  // "It works" page
  router.get { req in
    return try req.view().render("welcome")
  }
  
  router.get("racket") { req in
    return try req.view().render("editor")
  }
  
  router.post(CompileRequest.self, at: "compile") { req, compile -> String in
    do {
      let code = compile.code.replacingOccurrences(of: "\r", with: "")
      let stream = TextStream(string: code)
      let atheris = Atheris(inputStream: stream)
      let output = try atheris.compile() as! TextOutputStream
      return output.buffer
    } catch {
      return error.localizedDescription
    }
  }
  
  // Says hello
  router.get("hello", String.parameter) { req -> Future<View> in
    return try req.view().render("hello", [
      "name": req.parameters.next(String.self)
      ])
  }
}
