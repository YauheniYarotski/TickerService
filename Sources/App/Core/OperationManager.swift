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
  var agregator: Agregator?
  weak var wsJob: Job?
  
  func start(_ app: Application) {
    
    self.agregator = Agregator(exchangeManager: exchangeManager)
    exchangeManager.startCollectData()
    
    let defaultInetval = 3
    self.wsJob = Jobs.add(interval: .seconds(Double(defaultInetval))) {
      self.sendTickersToWs(defaultInetval)
    }
  }
  
  func updateWsUpdateInterval(newInterval: Int) {
    wsJob?.stop()
    self.wsJob = Jobs.add(interval: .seconds(Double(newInterval))) {
      self.sendTickersToWs(newInterval)
    }
  }
  
  func sendTickersToWs(_ forInterval: Int) {
    if let agregator = agregator {
      let exchnages = ExchangeTickersWithTimeStamp.init(timeStamp: UInt(Date().timeIntervalSince1970), exchanges: agregator.getTickers(for: forInterval))
      self.sessionManager.update(exchnages)
    }
  }
}
