//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class CoinbaseProManager: BaseTikerManager {
  
  let wsApi: CoinbaseProWs = CoinbaseProWs()
  
  override init() {
    super.init()
    wsApi.tickerResponse = { (response: CoinbaseProTickerResponse) in
      let symbol = response.product_id.replacingOccurrences(of: "-", with: "")
      if let bianceCoinPiar = BinanceCoinPair(rawValue: symbol), let firstAsset = bianceCoinPiar.firstAsset, let secondAsset = bianceCoinPiar.secondAsset  {
        let coinPair = CoinPair.init(firstAsset: firstAsset, secondAsset: secondAsset)
        let ticker = Ticker(tradeTime: response.time, pair: coinPair, price: response.price , quantity: -99)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing binance symbol:",response.product_id)
      }
    }
    
  }
  
  func startCollectData() {
    
//    job = Jobs.delay(by: .seconds(2), interval: .seconds(5)) {
//      if self.infoReponse == nil {
//        self.getInfo()
//      }
//    }
//
//    Jobs.add(interval: .seconds(5)) {
//      if self.job != nil, let _ = self.infoReponse {
//        self.job?.stop()
        wsApi.start()
//      }
//    }
    
  }
  
  
  
  
//  func updateBook(asks: [[Double]], bids: [[Double]], pair: String) {
//    var pairBook = book[pair] ?? [:]
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
//
////    print("bids",pairBook.filter({$0.key > 0}).count)
////    print("asks",pairBook.filter({$0.key < 0}).count)
//  }
  
}

