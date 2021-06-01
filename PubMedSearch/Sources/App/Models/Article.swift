//
//  File.swift
//  
//
//  Created by Can on 29.05.2021.
//

import Vapor
import Fluent

final class Article: Model {
    static let schema = "articles"
    
    @ID
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "author")
    var author: String
    
    @Parent(key: "userID")
    var user: User
    
    @Siblings(through: ArticleTagPivot.self, from: \.$article, to: \.$tag)
    var tags: [Tag]
    
    init() {}
    
    init(id: UUID? = nil, title: String, author: String, userID: User.IDValue) {
        self.id = id
        self.title = title
        self.author = author
        self.$user.id = userID
    }
}

extension Article: Content {}
