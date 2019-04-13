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
  
  var infoReponse: BinanceInfoResponse?
  
  weak var job: Job?
  
  func startCollectData() {
    
    job = Jobs.delay(by: .seconds(2), interval: .seconds(5)) {
      if self.infoReponse == nil {
        self.getInfo()
      }
    }
    
    Jobs.add(interval: .seconds(5)) {
      if self.job != nil, let _ = self.infoReponse {
        self.job?.stop()
        self.startWs()
      }
    }
    
  }
  
  private func getInfo() {
    let infoRequest = RestRequest.init(hostName: "api.binance.com", path: "/api/v1/exchangeInfo")
    
    GenericRest.sendRequest(request: infoRequest, completion: { (response: BinanceInfoResponse) in
      self.infoReponse = response
      
      
      //TODO: for tests
      for symbol in response.symbols {
        guard let pair = BinanceCoinPair(rawValue: symbol.symbol),
          let _ = pair.firstAsset,
          let _ = pair.secondAsset else {
            print("Waring!: not all binance asstets updated:",symbol)
            return
        }
      }
      
    }, errorHandler:  {  error in
      print("Gor error for request: \(infoRequest)",error)
    })
  }
  
  private func startWs() {
    // /stream?streams=<streamName1>/<streamName2>/<streamName3>
    let path =  "/stream?streams=btcusdt@trade/ethusdt@trade/xrpusdt@trade"
    let request = RestRequest.init(hostName: "stream.binance.com", path: path, port: 9443)
    
    GenericWs.start(request: request) { (response: BinanceStreamTikerResponse) in
      let symbol = response.stream.replacingOccurrences(of: "@trade", with: "").uppercased()
      if let bianceCoinPiar = BinanceCoinPair(rawValue: symbol), let firstAsset = bianceCoinPiar.firstAsset, let secondAsset = bianceCoinPiar.secondAsset  {
        let coinPair = CoinPair.init(firstAsset: firstAsset, secondAsset: secondAsset)
        let ticker = Ticker(tradeTime: response.data.tradeTime, pair: coinPair, price: response.data.price, quantity: response.data.quantity)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing binance symbol:",response.stream)
      }
    }
  }
  
}

struct Ticker: Content {
  let tradeTime: Int
  let pair: CoinPair
  let price: Double
  let quantity: Double
}


struct BinanceInfoResponse: Content {
  let timezone: String
  let serverTime: UInt
  let symbols: [BinanceSymbolResponse]
}

struct BinanceSymbolResponse: Content  {
  let symbol: String
  let status: String
  let baseAsset: String
  let quoteAsset: String
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

