//
//  OperationManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/6/19.
//

import Foundation
import Vapor
import Jobs

class OperationManager {
  let exchangeManager = ExchangesManager()
  let sessionManager = TrackingSessionManager()
  
  func start(_ app: Application) {
    
    let agregator = Agregator(exchangeManager: exchangeManager)
    exchangeManager.startCollectData()
    
    Jobs.add(interval: .seconds(1)) {
//      print("See you every 5 days.")
      let exchnages = ExchangeTickersWithTimeStamp.init(timeStamp: UInt(Date().timeIntervalSince1970), exchanges: agregator.getTickers(for: 10))
      self.sessionManager.update(exchnages)
    }
    
  
  }
}
