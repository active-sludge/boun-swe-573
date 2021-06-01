//
//  CreateTag.swift
//
//
//  Created by Can on 19.05.2021.
//

import Fluent

struct CreateTag: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tags")
            .id()
            .field("name", .string, .required)
            .field("link", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tags").delete()
    }
}
