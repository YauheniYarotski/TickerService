//
//  BaseTikerManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/15/19.
//

import Foundation
import Vapor
import Jobs

class BaseTikerManager<Pair:Hashable, Coin: Hashable> {
  
  
  var pairs: Set<Pair>? {
    didSet {
      if let pairs = pairs {
        didGetPairs?(pairs)
      }
    }
  }
  var didGetPairs: ((_ pairs: Set<Pair>)->())?
  
  var coins: Set<Coin>?
  
  var tickers: [CoinPair:[Ticker]] = [:] {
    didSet {
      tickerDidUpdate?(tickers)
    }
  }
  var tickerDidUpdate: ((_ tickers: [CoinPair:[Ticker]])->())?
  
  func updateTickers(ticker: Ticker) {
    //TODO: optimeze
    var tickersForPair = tickers[ticker.pair] ?? []
    
    
    if tickersForPair.count > 1200 {
      tickersForPair = Array(tickersForPair.prefix(1000))
    }
    
    tickersForPair.append(ticker)
    tickers[ticker.pair] = tickersForPair
  }
  
  final func startListenTickers(pairs: [Pair]) {
    weak var job: Job?
    if self.pairs == nil || self.coins == nil {
      job = Jobs.delay(by: .seconds(2), interval: .seconds(7)) {
        if self.pairs == nil || self.coins == nil {
          self.getPairsAndCoins()
        }
      }
    }
    
    if job != nil {
      Jobs.add(interval: .seconds(5)) {
        if job != nil, let _ = self.pairs, let _ = self.coins {
          job?.stop()
          self.cooverForWsStartListenTickers(pairs: pairs)
        }
      }
    } else {
      self.cooverForWsStartListenTickers(pairs: pairs)
    }
    
  }
  
  func getPairsAndCoins() {}
  func cooverForWsStartListenTickers(pairs: [Pair]) {}
  func stopListenTickers() {}
}

struct Ticker: Content {
  let tradeTime: Int
  let pair: CoinPair
  let price: Double
  let quantity: Double
}

