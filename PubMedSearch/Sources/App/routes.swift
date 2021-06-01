import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("hello") { req -> String in
        return "Hello, world!"
    }
        
    let articlesController = ArticlesController()
    try app.register(collection: articlesController)
    
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let tagsController = TagsController()
    try app.register(collection: tagsController)
    
    
}
