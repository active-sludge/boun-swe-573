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
  }

  func indexHandler(_ req: Request) -> EventLoopFuture<View> {
      return req.view.render("index")
  }
}
