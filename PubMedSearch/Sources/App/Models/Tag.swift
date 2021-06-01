//
//  File.swift
//  
//
//  Created by Can on 29.05.2021.
//

import Fluent
import Vapor

final class Tag: Model, Content {
    static let schema = "tags"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "link")
    var link: String
    
    @Siblings(through: ArticleTagPivot.self, from: \.$tag, to: \.$article)
    var articles: [Article]
    
    init() {}
    
    init(id: UUID? = nil, name: String, link: String) {
        self.id = id
        self.name = name
        self.link = link
    }
}
