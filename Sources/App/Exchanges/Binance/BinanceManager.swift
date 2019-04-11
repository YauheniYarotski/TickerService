//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class BinanceManager {
  
  let wsApi = GenericWs()
  let restApi = GenericRest()
  var tickers: [CoinPair:[Ticker]] = [:] { //[Pair:[Time:Ticker]]
    didSet {
      tickerDidUpdate?(tickers)
    }
  }
  var tickerDidUpdate: ((_ tickers: [CoinPair:[Ticker]])->())?
  
  var infoReponse: BinanceInfoResponse?
  weak var job: Job?
  
  
  
  init() {
    //
    //    api = ws
    //
    //    restApi.didGetFullBook = { book, pair in
    //      //1) rest gets only 1000 prices, but in book more, so, reload only from min to max
    //      if let minBid = book.minBid, minBid.count == 2, let maxAsk = book.maxAsk, maxAsk.count == 2 {
    //        let minBidPrice = minBid[0]
    //        let maxAskPrice = maxAsk[0]
    //        self.removeOrders(fromMindBid: minBidPrice, toMaxAsk: maxAskPrice, pair: pair)
    //      }
    //      self.updateBook(asks: book.asks, bids: book.bids, pair: pair)
    //    }
  }
  
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
    
    restApi.sendRequest(request: infoRequest, completion: { (response: BinanceInfoResponse) in
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
  
  wsApi.start(request: request) { (response: BinanceStreamTikerResponse) in
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
//    Jobs.delay(by: .seconds(5), interval: .seconds(30)) {
//      self.restApi.getFullBook(for: "BTCUSDT")
//    }


func updateTickers(ticker: Ticker) {
  //TODO: optimeze
  var tickersForPair = tickers[ticker.pair] ?? []
  
  
  //TODO: probably removes rundom
  if tickersForPair.count > 1200 {
    tickersForPair = Array(tickersForPair.prefix(1000))
  }
  
  tickersForPair.append(ticker)
  tickers[ticker.pair] = tickersForPair
}

//  func updateBook(asks: [[Double]], bids: [[Double]], pair: String, deleteOldData: Bool = false) {
//
//    var pairBook = deleteOldData ? [:] : book[pair] ?? [:]
//    for bid in bids {
//      let price = bid[0]
//      let amount = bid[1]
//      if amount > 0 {
//        pairBook[price] = amount
//      } else {
//        pairBook[price] = nil
//      }
//    }
//
//    for ask in asks {
//      let price = -ask[0]
//      let amount = ask[1]
//      if amount > 0 {
//        pairBook[price] = amount
//      } else {
//        pairBook[price] = nil
//      }
//    }
//
//    book[pair] = pairBook
//  }

//  func removeOrders(fromMindBid: Double, toMaxAsk: Double, pair: String) {
//    let pairBook = book[pair] ?? [:]
//    for priceLeve in pairBook {
//      if priceLeve.key > 0 && priceLeve.key > fromMindBid {
//        book[pair]?[priceLeve.key] = nil
//      } else if priceLeve.key < 0 && -priceLeve.key < toMaxAsk {
//        book[pair]?[priceLeve.key] = nil
//      }
//    }
//  }

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
