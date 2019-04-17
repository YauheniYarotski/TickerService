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
    self.startSendTickers(with: 5, requestedExchanges: [:])
  }
  
  private func startSendTickers(with interval: Int, requestedExchanges: [ExchangeName:[CoinPair]]) {
    var requestedExchanges = requestedExchanges
    if requestedExchanges.isEmpty {
      let binancePair = CoinPair(firstAsset: "BTC", secondAsset: "USDT")
      let coinbasePair = CoinPair(firstAsset: "BTC", secondAsset: "USD")
      let poloniesPair = CoinPair(firstAsset: "BTC", secondAsset: "USDT")
      let bitstampPair = CoinPair(firstAsset: "BTC", secondAsset: "USD")
      requestedExchanges = [.binance:[binancePair],.coinbasePro:[coinbasePair],.poloniex:[poloniesPair], .bitstamp:[bitstampPair]]
    }
    exchangeManager.startCollectData(exchangesWithPairs: requestedExchanges)
    
    wsJob?.stop()
    self.wsJob = Jobs.add(interval: .seconds(Double(interval))) {
      
      if let exchanesToSend = self.agregator.getTickers(since: Int(Date().timeIntervalSince1970) - interval, for: requestedExchanges) {
        let exchanesToSendWithTimeStamp = ExchangeTickersWithTimeStamp(
          timeStamp: UInt(Date().timeIntervalSince1970),
          exchanges:exchanesToSend)
        self.sessionManager.update(exchanesToSendWithTimeStamp)
      }
      
    }
    
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
  
  func updateExchangesToListen(exchangesToListen: ExchangesToListen) {
    let dict = exchangesToListen.exchanges.reduce(into: [ExchangeName:[CoinPair]]()) { (res, ex) in
      res[ex.exchangeName] = ex.coinPairs
    }
    startSendTickers(with: exchangesToListen.interval, requestedExchanges: dict)
  }
}
