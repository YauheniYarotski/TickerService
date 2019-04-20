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
  
  let serialQueue = DispatchQueue.init( label: "queue")
  
  
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
    serialQueue.async {
      //done here for optimize
      let count = self.tickers[ticker.pair]?.count ?? 0
      if count > 0 {
        self.tickers[ticker.pair]!.append(ticker)
      } else {
        self.tickers[ticker.pair] = [ticker]
      }
      //TODO: for optimization can be moved to seperate thread and for some time remove it
      if count > 1200 {
        self.tickers[ticker.pair]!.removeFirst(200)
      }
    }
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

