//
//  AcronymsController.swift
//  App
//
//  Created by Yauheni Yarotski on 4/5/19.
//

import Vapor

struct ExchangesController: RouteCollection {
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api","exchanges")
//    usersRoute.get(use: getAllHandler)
    usersRoute.get { req in
      return operationManager.getAllExchangesWithPairs()
    }
  }
  

  
 

}

struct ExchangePairsWithTimeStamp: Content {
  let timeStamp: Int
  let exchanges: [ExchangePairs]
}

struct ExchangePairs: Content {
  let exchangeName: ExchangeName
  let pairs: [String]
}

