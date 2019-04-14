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
  case bitfinex = "Bitfinex"
  case bitstamp = "Bitstamp"
  case coinbasePro = "CoinbasePro"
  case polonex = "Polonex"
}



class ExchangesManager {
  
//  let bitfinexManager = BitfinexManager()
  let binanceManager = BinanceManager()
  let bitstampManager = BitstampManager()
  let coinbaseProManager = CoinbaseProManager()
  let poloniexManager = PoloniexManager()
  
  var exchangesTickers = [ExchangeName:[CoinPair:[Ticker]]]() //[exhange:[pair:ticker]]
  var exchangesPairs = [ExchangeName:[CoinPair]]() //[exhange:[pair:ticker]]
  
  init() {
//    binanceManager.bookDidUpdate = {book in
//      self.updateBook(exchangeName: "Binance", book: book)
//    }
    
    binanceManager.tickerDidUpdate = { tickers in
      self.updateTicker(exchangeName: .binance, tickers: tickers)
    }
    
    binanceManager.didGetPairs = { pairs in
      let pairs = pairs.compactMap({ pair  in
        return CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .binance, pairs: pairs)
    }
    
    coinbaseProManager.tickerDidUpdate = { tickers in
            self.updateTicker(exchangeName: .coinbasePro, tickers: tickers)
          }
    
    coinbaseProManager.didGetPairs = { pairs in
      let pairs = pairs.compactMap({ pair  in
        return CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .coinbasePro, pairs: pairs)
    }
    
//    bitfinexManager.bookDidUpdate = {bitfinexBook in
//      self.updateBook(exchangeName: "Bitfinex", book: bitfinexBook)
//    }
//
    bitstampManager.tickerDidUpdate = {tickers in
      self.updateTicker(exchangeName: .bitstamp, tickers: tickers)
    }
    
    bitstampManager.didGetPairs = { pairs in
      let pairs = pairs.compactMap({ pair  in
        return CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .bitstamp, pairs: pairs)
    }
    
    
    poloniexManager.tickerDidUpdate = {tickers in
      self.updateTicker(exchangeName: .polonex, tickers: tickers)
    }
    poloniexManager.didGetPairs = { poloniexPairs in
      let pairs = poloniexPairs.compactMap({ polonoexPair  in
        return CoinPair.init(firstAsset: polonoexPair.firstAsset.rawValue, secondAsset: polonoexPair.secondAsset.rawValue)
      }).sorted(by: {$0.symbol < $1.symbol})
      self.updatePairs(exchangeName: .polonex, pairs: pairs)
    }

  }
  
  func startCollectData() {
    binanceManager.startCollectData()
    poloniexManager.startCollectData()
    bitstampManager.startCollectData()
    coinbaseProManager.startCollectData()
  }
  
  func updateTicker(exchangeName: ExchangeName, tickers: [CoinPair:[Ticker]]) {
    exchangesTickers[exchangeName] = tickers
  }
  func updatePairs(exchangeName: ExchangeName, pairs: [CoinPair]) {
    exchangesPairs[exchangeName] = pairs
  }
}
