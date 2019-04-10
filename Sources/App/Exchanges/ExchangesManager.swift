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
//  let bitstampManager = BitstampManager()
//  let coinbaseProManager = CoinbaseProManager()
  
  var exchangesTickers = [ExchangeName:[String:[Ticker]]]() //[exhange:[pair:ticker]]
  
  init() {
//    binanceManager.bookDidUpdate = {book in
//      self.updateBook(exchangeName: "Binance", book: book)
//    }
    
    binanceManager.tickerDidUpdate = { tickers in
      self.updateTicker(exchangeName: .binance, tickers: tickers)
    }
    
    
//    bitfinexManager.bookDidUpdate = {bitfinexBook in
//      self.updateBook(exchangeName: "Bitfinex", book: bitfinexBook)
//    }
//
//    bitstampManager.bookDidUpdate = {book in
//      self.updateBook(exchangeName: "Bitstamp", book: book)
//    }
//
//    coinbaseProManager.bookDidUpdate = {book in
//      self.updateBook(exchangeName: "CoinbasePro", book: book)
//    }
  }
  
  func startCollectData() {
    binanceManager.startCollectData()

//    bitfinexManager.startCollectData()
//    bitstampManager.startCollectData()
//    coinbaseProManager.startCollectData()
  }
  
  func updateTicker(exchangeName: ExchangeName, tickers: [String:[Ticker]]) {
    exchangesTickers[exchangeName] = tickers
  }
}
