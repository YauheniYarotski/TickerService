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
  let agregator = Agregator()
  weak var wsJob: Job?
  
  init() {
    agregator.tickersSourceHandler = {self.exchangeManager.exchangesTickers}
  }
  
  func start(_ app: Application) {
    
    let binancePair = CoinPair(firstAsset: "BTC", secondAsset: "USDT")
    let coinbasePair = CoinPair(firstAsset: "BTC", secondAsset: "USD")
    let poloniesPair = CoinPair(firstAsset: "BTC", secondAsset: "USDT")
    let bitstampPair = CoinPair(firstAsset: "BTC", secondAsset: "USD")
    exchangeManager.startCollectData(exchangesWithPairs: [.binance:[binancePair],.coinbasePro:[coinbasePair],.poloniex:[poloniesPair], .bitstamp:[bitstampPair]])
    
    let defaultInetval = 10
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
  
  private func sendTickersToWs(_ forInterval: Int) {
    let exchnages = ExchangeTickersWithTimeStamp.init(
      timeStamp: UInt(Date().timeIntervalSince1970),
      exchanges: agregator.getTickers(since: Int(Date().timeIntervalSince1970) - forInterval))
    self.sessionManager.update(exchnages)
    
  }
  
  func getAllExchangesWithPairs() -> ExchangePairsWithTimeStamp {
    var exchanges = [ExchangePairs]()
    let collection = exchangeManager.exchangesPairs
    for exchange in collection {
      let exchange = ExchangePairs.init(exchangeName: exchange.key, pairs: exchange.value.compactMap({$0.symbol}))
      exchanges.append(exchange)
    }
    return ExchangePairsWithTimeStamp.init(timeStamp: UInt(Date().timeIntervalSince1970), exchanges: exchanges)
  }
  
  func updateExchangesToListen(exchanges: ExchangesToListen) {
    let dict = exchanges.exchanges.reduce(into: [ExchangeName:[CoinPair]]()) { (res, ex) in
      res[ex.exchangeName] = ex.coinPairs
    }
    exchangeManager.startCollectData(exchangesWithPairs: dict)
    updateWsUpdateInterval(newInterval: exchanges.interval)
  }
}
