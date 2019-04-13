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
  
  init() {
//    binanceManager.bookDidUpdate = {book in
//      self.updateBook(exchangeName: "Binance", book: book)
//    }
    
    binanceManager.tickerDidUpdate = { tickers in
      self.updateTicker(exchangeName: .binance, tickers: tickers)
    }
    
    coinbaseProManager.tickerDidUpdate = { tickers in
            self.updateTicker(exchangeName: .coinbasePro, tickers: tickers)
          }
    
    
//    bitfinexManager.bookDidUpdate = {bitfinexBook in
//      self.updateBook(exchangeName: "Bitfinex", book: bitfinexBook)
//    }
//
    bitstampManager.tickerDidUpdate = {tickers in
      self.updateTicker(exchangeName: .bitstamp, tickers: tickers)
    }
    poloniexManager.tickerDidUpdate = {tickers in
      self.updateTicker(exchangeName: .polonex, tickers: tickers)
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
}
