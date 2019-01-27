//
//  CompileRequest.swift
//  App
//
//  Created by Toni Kocjan on 27/01/2019.
//

import Vapor

struct CompileRequest: Content {
  let code: String
}
