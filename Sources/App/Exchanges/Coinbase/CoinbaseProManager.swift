//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs

class CoinbaseProManager: BaseTikerManager {
  
  let wsApi: CoinbaseProWs = CoinbaseProWs()
  
  var pairs: Set<CoinbasePair>? {
    didSet {
      if let pairs = pairs {
        didGetPairs?(pairs)
      }
    }
  } //BTC/ATOM
  var coins: Set<CoinbaseCoin>? //BTC
  var didGetPairs: ((_ pairs: Set<CoinbasePair>)->())?
  
  override init() {
    super.init()
    wsApi.tickerResponse = { (response: CoinbaseProTickerResponse) in
      if let pair = CoinbasePair.init(string: response.product_id)  {
        let coinPair = CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
        let ticker = Ticker(tradeTime: response.time, pair: coinPair, price: response.price , quantity: -99)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing Coinbase symbol:",response.product_id)
      }
    }
    
  }
  
  
  func startCollectData() {
    
    weak var job: Job? = Jobs.delay(by: .seconds(2), interval: .seconds(10)) {
      if self.pairs == nil || self.coins == nil {
        self.getPairsAndCoins()
      }
    }
    //
    Jobs.add(interval: .seconds(10)) {
      if job != nil, let _ = self.pairs, let _ = self.coins {
        job?.stop()
        self.wsApi.start()
      }
    }
    
  }
  
  
  
  
  private func getPairsAndCoins() {
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
}

