//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class BinanceManager: BaseTikerManager {
  
  let ws = BinanceWs()
  
  var pairs: Set<BinancePair>? {
    didSet {
      if let pairs = pairs {
        didGetPairs?(pairs)
      }
    }
  } //BTC/ATOM
  var coins: Set<BinanceCoin>? //BTC
  var didGetPairs: ((_ pairs: Set<BinancePair>)->())?
  
  override init() {
    super.init()
    ws.tickersResponseHandler = { (response: BinanceStreamTikerResponse) in
      let symbol = response.stream.replacingOccurrences(of: "@trade", with: "").uppercased()
      if let pair = BinancePair(string: symbol) {
        let coinPair = CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
        let ticker = Ticker(tradeTime: response.data.tradeTime, pair: coinPair, price: response.data.price, quantity: response.data.quantity)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing binance symbol:",response.stream)
      }
    }
  }
  
  func startListenTickers(pairs: [BinancePair]) {
    weak var job: Job?
    if self.pairs == nil || self.coins == nil {
      job = Jobs.delay(by: .seconds(2), interval: .seconds(7)) {
        if self.pairs == nil || self.coins == nil {
          self.getPairAndCoins()
        }
      }
    }
    
    if job != nil {
      Jobs.add(interval: .seconds(5)) {
        if job != nil, let _ = self.pairs, let _ = self.coins {
          job?.stop()
          self.ws.startListenTickers(pairs: pairs)
        }
      }
    } else {
      self.ws.startListenTickers(pairs: pairs)
    }
    
  }
  
  private func getPairAndCoins() {
    let infoRequest = RestRequest.init(hostName: "api.binance.com", path: "/api/v1/exchangeInfo")
    var pairs = Set<BinancePair>()
    var coins = Set<BinanceCoin>()
    GenericRest.sendRequest(request: infoRequest, completion: { (response: BinanceInfoResponse) in
      for symbolReponse in response.symbols {
        if let pair = BinancePair(string: symbolReponse.symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all binance asstets updated:",symbolReponse.symbol)
        }
      }
      
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
      
    }, errorHandler:  {  error in
      print("Gor error for request: \(infoRequest)",error)
    })
  }
  
}

struct Ticker: Content {
  let tradeTime: Int
  let pair: CoinPair
  let price: Double
  let quantity: Double
}






class BaseTikerManager {
  
  var tickers: [CoinPair:[Ticker]] = [:] { //[Pair:[Time:Ticker]]
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
  
  
}

