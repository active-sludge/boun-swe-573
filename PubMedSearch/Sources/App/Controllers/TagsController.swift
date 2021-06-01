//
//  TagsController.swift
//  
//
//  Created by Can on 30.05.2021.
//

import Vapor

struct TagsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let tagsRoute = routes.grouped("api", "tags")
    tagsRoute.post(use: createHandler)
    tagsRoute.get(use: getAllHandler)
    tagsRoute.get(":tagID", use: getHandler)
    tagsRoute.get(":tagID", "tags", use: getArticlesHandler)
  }
  
  func createHandler(_ req: Request) throws -> EventLoopFuture<Tag> {
    let tag = try req.content.decode(Tag.self)
    return tag.save(on: req.db).map { tag }
  }
  
  func getAllHandler(_ req: Request) -> EventLoopFuture<[Tag]> {
    Tag.query(on: req.db).all()
  }
  
  func getHandler(_ req: Request) -> EventLoopFuture<Tag> {
    Tag.find(req.parameters.get("tagID"), on: req.db).unwrap(or: Abort(.notFound))
  }
  
  func getArticlesHandler(_ req: Request) -> EventLoopFuture<[Article]> {
    Tag.find(req.parameters.get("articleID"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { tag in
        tag.$articles.get(on: req.db)
    }
  }
}
