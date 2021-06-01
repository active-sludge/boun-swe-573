//
//  CreateArticle.swift
//  
//
//  Created by Can on 19.05.2021.
//

import Fluent

struct CreateArticle: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("articles")
      .id()
      .field("title", .string, .required)
      .field("author", .string, .required)
      .field("userID", .uuid, .required, .references("users", "id"))
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("articles").delete()
  }
}
