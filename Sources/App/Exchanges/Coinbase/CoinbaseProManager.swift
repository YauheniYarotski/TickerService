//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class CoinbaseProManager {
  
  var wsApi: CoinbaseProWs? = CoinbaseProWs()
  
   init() {
    wsApi = CoinbaseProWs()
//    wsApi.tickerResponse = {  response in
//      print(response.price)
////      self.updateBook(asks: response.asks, bids: response.bids, pair: response.product_id)
//    }
    
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
        wsApi?.start()
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

