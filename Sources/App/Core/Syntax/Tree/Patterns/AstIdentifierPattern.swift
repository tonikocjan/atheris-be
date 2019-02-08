//
//  AstIdentifierPattern.swift
//  Atheris
//
//  Created by Toni Kocjan on 02/12/2018.
//  Copyright © 2018 Toni Kocjan. All rights reserved.
//

import Foundation

public class AstIdentifierPattern: AstPattern, AstBinding, AstExpression {
  public let position: Position
  public let name: String
  public var pattern: AstPattern { return self }
  
  public init(position: Position, name: String) {
    self.position = position
    self.name = name
  }
  
  public func accept(visitor: AstVisitor) throws {
    try visitor.visit(node: self)
  }
}
