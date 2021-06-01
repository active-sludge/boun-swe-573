//
//  File.swift
//  
//
//  Created by Can on 1.06.2021.
//

import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get("articles", ":articleID", use: articleHandler)
        routes.get("users", ":userID", use: userHandler)
        routes.get("users", use: allUsersHandler)


    }
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        Article.query(on: req.db).all().flatMap { articles in
            let context = IndexContext(
                title: "Home page",
                articles: articles)
            return req.view.render("index", context)
        }
    }
    
    func articleHandler(_ req: Request) -> EventLoopFuture<View> {
        Article.find(req.parameters.get("articleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { article in
                article.$user.get(on: req.db)
                    .flatMap { user in
                        let context = ArticleContext(
                            title: article.title,
                            article: article,
                            user: user)
                        
                        return req.view.render("article", context)
                    }
            }
    }
    
    // 1
    func userHandler(_ req: Request)
    -> EventLoopFuture<View> {
        // 2
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                // 3
                user.$articles.get(on: req.db).flatMap { articles in
                    // 4
                    let context = UserContext(
                        title: user.name,
                        user: user,
                        articles: articles)
                    return req.view.render("user", context)
                }
            }
    }
    
    // 1
    func allUsersHandler(_ req: Request)
      -> EventLoopFuture<View> {
        // 2
        User.query(on: req.db)
          .all()
          .flatMap { users in
            // 3
            let context = AllUsersContext(
              title: "All Users",
              users: users)
            return req.view.render("allUsers", context)
        }
    }

}

struct IndexContext: Encodable {
    let title: String
    let articles: [Article]
}

struct ArticleContext: Encodable {
    let title: String
    let article: Article
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let articles: [Article]
}

struct AllUsersContext: Encodable {
  let title: String
  let users: [User]
}
