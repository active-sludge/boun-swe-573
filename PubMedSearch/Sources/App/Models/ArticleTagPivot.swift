//
//  File.swift
//  
//
//  Created by Can on 29.05.2021.
//

import Fluent
import Foundation

final class ArticleTagPivot: Model {
  static let schema = "article-tag-pivot"
  
  @ID
  var id: UUID?
  
  @Parent(key: "articleID")
  var article: Article
  
  @Parent(key: "tagID")
  var tag: Tag
  
  init() {}
  
  init(id: UUID? = nil, article: Article, tag: Tag) throws {
    self.id = id
    self.$tag.id = try article.requireID()
    self.$article.id = try tag.requireID()
  }
}
