//
//  Agregator.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//


import Foundation
import Vapor

class Agregator {
  
  let exchangeManager: ExchangesManager
  
  init(exchangeManager: ExchangesManager) {
    self.exchangeManager = exchangeManager
  }
  
  func getTickers(since: Int) -> [ExchangeTickers] {
    var exchanges = [ExchangeTickers]()
    
    for exchange in self.exchangeManager.exchangesTickers {
      var tikers = [WsTicker]()
      
      for pair in exchange.value {
        if let ticker = pair.value.filter({$0.tradeTime >= since}).last {
          let wsTicker = WsTicker.init(pair: pair.key.symbol, price: ticker.price, tradeTime: ticker.tradeTime)
          tikers.append(wsTicker)
        }
      }
      if tikers.count > 0 {
        let exchangesTickers = ExchangeTickers.init(exchangeName: exchange.key, tickers: tikers)
        exchanges.append(exchangesTickers)
      }
      
    }
    return exchanges
  }
  
  //  func getData(granulation: Double) -> [ExchangesBooks] {
  //    var exchanges = [ExchangesBooks]()
  //
  //    for exchange in self.exchangeManager.exchangesBooks  {
  //      var booksForPairs = [BookForPair]()
  //
  //      for pair in exchange.value {
  //        var asks = [Double:Double]()
  //        var bids = [Double:Double]()
  //        for levelPrice in pair.value {
  //          let price = levelPrice.key.granulate(toGranulation: granulation)
  //          let amount = levelPrice.value
  //          if price < 0 {
  //            asks[-price] =  (asks[-price] ?? 0) + amount
  //          } else {
  //            bids[price] =  (bids[price] ?? 0) + amount
  //
  //
  //          }
  //        }
  //
  //        let sorteredAsks = asks.sorted(by: {$0.0 < $1.0}).prefix(30).map({[$0.key.rounded(toPlaces: 2),$0.value.rounded(toPlaces: 2)]})
  //        let sorteredBids = bids.sorted(by: {$0.0 > $1.0}).prefix(30).map({[$0.key.rounded(toPlaces: 2),$0.value.rounded(toPlaces: 2)]})
  //
  //        let totalAsks = sorteredAsks.reduce(0.0) { result, nextAsk in
  //          return result + nextAsk[1]
  //        }
  //        let totalBids: Double = sorteredBids.reduce(0.0) { result, nextBid in
  //          return result + nextBid[1]
  //        }
  //
  //        let bookForPair = BookForPair.init(pair: pair.key, asks: sorteredAsks, bids: sorteredBids, totalAsks: totalAsks.rounded(toPlaces:3), totalBids: totalBids.rounded(toPlaces:3))
  //        booksForPairs.append(bookForPair)
  //      }
  //      let sorteredBooksForPairs = booksForPairs.sorted(by: {$0.pair > $1.pair})
  //      let ex = ExchangesBooks.init(exchangeName: exchange.key, books: sorteredBooksForPairs)
  //      exchanges.append(ex)
  //    }
  //    return exchanges.sorted(by: {$0.exchangeName > $1.exchangeName})
  //  }
  //
}

