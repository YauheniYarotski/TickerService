//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs

class CoinbaseProManager: BaseTikerManager<CoinbasePair, CoinbaseCoin> {
  
  let ws: CoinbaseProWs = CoinbaseProWs()
  
  override init() {
    super.init()
    ws.tickerResponse = { (response: CoinbaseProTickerResponse) in
      if let pair = CoinbasePair.init(string: response.product_id)  {
        let coinPair = CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
        let ticker = Ticker(tradeTime: response.time, pair: coinPair, price: response.price , quantity: -99)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing Coinbase symbol:",response.product_id)
      }
    }
    
  }
  
  override func getPairsAndCoins() {
    let request = RestRequest.init(hostName: "api.pro.coinbase.com", path: "/products/")
    
    GenericRest.sendRequestToGetArray(request: request, completion: { (response) in
      var pairs = Set<CoinbasePair>()
      var coins = Set<CoinbaseCoin>()
      for draftArrayPair in response {
        if let dictPair = draftArrayPair as? [String: Any],
          let symbol = dictPair["id"] as? String,
          let pair = CoinbasePair(string: symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all conbase asstets updated:",draftArrayPair)
        }
      }
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  override func cooverForWsStartListenTickers(pairs: [CoinbasePair]) {
    ws.startListenTickers(pairs: pairs)
  }
  override func stopListenTickers() {
    ws.stopListenTickers()
  }
}

