//
//  ArticlesController.swift
//  
//
//  Created by Can on 29.05.2021.
//

import Vapor
import Fluent

struct ArticlesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let articlesRoutes = routes.grouped("api", "articles")
        articlesRoutes.get(use: getAllHandler)
        articlesRoutes.post(use: createHandler)
        articlesRoutes.get(":articleID", use: getHandler)
        articlesRoutes.put(":articleID", use: updateHandler)
        articlesRoutes.delete(":articleID", use: deleteHandler)
        articlesRoutes.get("search", use: searchHandler)
        articlesRoutes.get("first", use: getFirstHandler)
        articlesRoutes.get("sorted", use: sortedHandler)
        articlesRoutes.get(":articleID", "user", use: getUserHandler)
        articlesRoutes.post(":articleID", "tags", ":TagID", use: addTagsHandler)
        articlesRoutes.get(":articleID", "tags", use: getTagsHandler)
        articlesRoutes.delete(":articleID", "tags", ":TagID", use: removeTagsHandler)
    }
    
    func getAllHandler(_ req: Request) -> EventLoopFuture<[Article]> {
        Article.query(on: req.db).all()
    }
    
    func createHandler(_ req: Request) throws -> EventLoopFuture<Article> {
        let data = try req.content.decode(CreateArticleData.self)
        let article = Article(title: data.title, author: data.author, userID: data.userID)
        return article.save(on: req.db).map { article }
    }
    
    func getHandler(_ req: Request) -> EventLoopFuture<Article> {
        Article.find(req.parameters.get("articleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Article> {
        let updateData = try req.content.decode(CreateArticleData.self)
        return Article.find(req.parameters.get("articleID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { article in
                article.title = updateData.title
                article.author = updateData.author
                article.$user.id = updateData.userID
                return article.save(on: req.db).map {
                    article
                }
            }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Article.find(req.parameters.get("articleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { article in
                article.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Article]> {
        guard let searchTerm = req
                .query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Article.query(on: req.db).group(.or) { or in
            or.filter(\.$title == searchTerm)
            or.filter(\.$author == searchTerm)
        }.all()
    }
    
    func getFirstHandler(_ req: Request) -> EventLoopFuture<Article> {
        Article.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    func sortedHandler(_ req: Request) -> EventLoopFuture<[Article]> {
        Article.query(on: req.db).sort(\.$title, .ascending).all()
    }
    
    func getUserHandler(_ req: Request) -> EventLoopFuture<User> {
        Article.find(req.parameters.get("articleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { article in
                article.$user.get(on: req.db)
            }
    }
    
    func addTagsHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let articleQuery = Article.find(req.parameters.get("articleID"), on: req.db).unwrap(or: Abort(.notFound))
        let tagQuery = Tag.find(req.parameters.get("tagID"), on: req.db).unwrap(or: Abort(.notFound))
        return articleQuery.and(tagQuery).flatMap { article, tag in
            article.$tags.attach(tag, on: req.db).transform(to: .created)
        }
    }
    
    func getTagsHandler(_ req: Request) -> EventLoopFuture<[Tag]> {
        Article.find(req.parameters.get("articleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { article in
                article.$tags.query(on: req.db).all()
            }
    }
    
    func removeTagsHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let articleQuery = Article.find(req.parameters.get("articleID"), on: req.db).unwrap(or: Abort(.notFound))
        let tagQuery = Tag.find(req.parameters.get("tagID"), on: req.db).unwrap(or: Abort(.notFound))
        return articleQuery.and(tagQuery).flatMap { article, tag in
            article.$tags.detach(tag, on: req.db).transform(to: .noContent)
        }
    }
}

struct CreateArticleData: Content {
    let title: String
    let author: String
    let userID: UUID
}
