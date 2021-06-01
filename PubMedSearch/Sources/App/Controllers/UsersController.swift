//
//  UsersController.swift
//  
//
//  Created by Can on 30.05.2021.
//

import Vapor

struct UsersController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let usersRoute = routes.grouped("api", "users")
    usersRoute.post(use: createHandler)
    usersRoute.get(use: getAllHandler)
    usersRoute.get(":userID", use: getHandler)
    usersRoute.get(":userID", "articles", use: getArticlesHandler)
  }

  func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
    let user = try req.content.decode(User.self)
    return user.save(on: req.db).map { user }
  }
  
  func getAllHandler(_ req: Request) -> EventLoopFuture<[User]> {
    User.query(on: req.db).all()
  }

  func getHandler(_ req: Request) -> EventLoopFuture<User> {
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound))
  }
  
  func getArticlesHandler(_ req: Request) -> EventLoopFuture<[Article]> {
    User.find(req.parameters.get("userID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { user in
      user.$articles.get(on: req.db)
    }
  }
}

