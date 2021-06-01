//
//  CreateArticleTagPivot.swift
//  
//
//  Created by Can on 19.05.2021.
//

import Foundation

import Fluent

struct CreateArticleTagPivot: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("article-tag-pivot")
      .id()
      .field("articleID", .uuid, .required, .references("articles", "id", onDelete: .cascade))
      .field("tagID", .uuid, .required, .references("tags", "id", onDelete: .cascade))
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("article-tag-pivot").delete()
  }
}
