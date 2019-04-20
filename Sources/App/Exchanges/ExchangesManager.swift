//
//  ExchangesManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/7/19.
//

import Foundation
import Vapor

enum ExchangeName: String, Content {
  case binance = "Binance"
  //  case bitfinex = "Bitfinex"
  case bitstamp = "Bitstamp"
  case coinbasePro = "CoinbasePro"
  case poloniex = "Poloniex"
  
  //  init(from decoder: Decoder) throws {
  //    let label = try decoder.singleValueContainer().decode(String.self)
  //    switch label {
  //    case "Binance": self = .binance
  //    case "Bitstamp": self = .bitstamp
  //    default: self = .poloniex
  //      // default: self = .other(label)
  //    }
  //  }
}

extension ExchangeName: CaseIterable {}

class ExchangesManager {
  
  static var typeName: String {
    return String(describing: self)
  }
  
  let serialQueue = DispatchQueue.init( label: "queue \(typeName)")
  
  let binanceManager = BinanceManager()
  let bitstampManager = BitstampManager()
  let coinbaseProManager = CoinbaseProManager()
  let poloniexManager = PoloniexManager()
  
  private var exchangesTickers = [ExchangeName:[CoinPair:[Ticker]]]()
  var exchangesPairs = [ExchangeName:[CoinPair]]()
  //  var exchangesPairsToListen = [ExchangeName:[CoinPair]]() {
  //    didSet {
  //      self.startCollectData(exchangesWithPairs: exchangesPairsToListen)
  //    }
  //  }
  
  init() {
    
    
    binanceManager.tickerDidUpdate = { tickers in
      self.updateTickers(exchangeName: .binance, tickers: tickers)
    }
    
    binanceManager.didGetPairs = { pairs in
      let pairs = pairs.compactMap({ pair  in
        return CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .binance, pairs: pairs)
    }
    
    coinbaseProManager.tickerDidUpdate = { tickers in
      self.updateTickers(exchangeName: .coinbasePro, tickers: tickers)
    }
    
    coinbaseProManager.didGetPairs = { pairs in
      let pairs = pairs.compactMap({ pair  in
        return CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .coinbasePro, pairs: pairs)
    }
    
    bitstampManager.tickerDidUpdate = {tickers in
      self.updateTickers(exchangeName: .bitstamp, tickers: tickers)
    }
    
    bitstampManager.didGetPairs = { pairs in
      let pairs = pairs.compactMap({ pair  in
        return CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .bitstamp, pairs: pairs)
    }
    
    
    poloniexManager.tickerDidUpdate = {tickers in
      self.updateTickers(exchangeName: .poloniex, tickers: tickers)
    }
    poloniexManager.didGetPairs = { poloniexPairs in
      let pairs = poloniexPairs.compactMap({ polonoexPair  in
        return CoinPair.init(firstAsset: polonoexPair.firstAsset.rawValue, secondAsset: polonoexPair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .poloniex, pairs: pairs)
    }
    
  }
  
  func startCollectData(exchangesWithPairs: [ExchangeName:[CoinPair]]) {
    stopAllExchanges()
    
    for exchangePair in exchangesWithPairs {
      switch exchangePair.key {
      case .binance:
        let binancePairs = exchangePair.value.compactMap({BinancePair.init(string: ($0.firstAsset+$0.secondAsset))})
        binanceManager.startListenTickers(pairs: binancePairs)
      case .coinbasePro:
        let pairs = exchangePair.value.compactMap({CoinbasePair.init(string: ($0.firstAsset+CoinbasePair.separator+$0.secondAsset))})
        coinbaseProManager.startListenTickers(pairs: pairs)
      case .bitstamp:
        let pairs = exchangePair.value.compactMap({BitstampPair.init(string: ($0.firstAsset+BitstampPair.separator+$0.secondAsset))})
        bitstampManager.startListenTickers(pairs: pairs)
      case .poloniex:
        let pairs = exchangePair.value.compactMap({PoloniexPair.init(string: ($0.firstAsset+PoloniexPair.separator+$0.secondAsset))})
        poloniexManager.startListenTickers(pairs: pairs)
      }
    }
  }
  
  func updateTickers(exchangeName: ExchangeName, tickers: [CoinPair:[Ticker]]) {
    serialQueue.async {
      self.exchangesTickers[exchangeName] = tickers
    }
  }
  
  func getTickers() -> [ExchangeName:[CoinPair:[Ticker]]] {
    var copy: [ExchangeName:[CoinPair:[Ticker]]]!
    serialQueue.sync {
      copy = self.exchangesTickers
    }
    return copy
  }
  
  func updatePairs(exchangeName: ExchangeName, pairs: [CoinPair]) {
    exchangesPairs[exchangeName] = pairs
  }
  
  private func stopAllExchanges() {
    for ex in ExchangeName.allCases {
      switch ex {
      case .binance: binanceManager.stopListenTickers()
      case .bitstamp: bitstampManager.stopListenTickers()
      case .coinbasePro: coinbaseProManager.stopListenTickers()
      case .poloniex: poloniexManager.stopListenTickers()
      }
    }
  }
}
