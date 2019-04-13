//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class PoloniexManager: BaseTikerManager {
  let wsApi = PoloniexWs()
  var pairs: [Int:PoloniexPair]? //1,BTC_ATOM
  var coins: [Int:PoloniexCoin]? //1:BTC
  
  weak var job: Job?
  
  func startCollectData() {
    
    job = Jobs.delay(by: .seconds(2), interval: .seconds(10)) {
      if self.pairs == nil {
        self.getPairs()
      } else if self.coins == nil {
        self.getCoins()
      }
    }
    //
    Jobs.add(interval: .seconds(5)) {
      if self.job != nil, let _ = self.pairs, let _ = self.coins {
        self.job?.stop()
        self.startWs()
      }
    }
    
  }
  
  private func getPairs() {
    let request = RestRequest.init(hostName: "poloniex.com", path: "/public", queryParameters: ["command":"returnTicker"])
    
    GenericRest.sendRequest(request: request, completion: { (response) in
      var pairs = [Int:PoloniexPair]()
      for draftDictPair in response {
        if let dictPair = draftDictPair.value as? [String: Any],
          let id = dictPair["id"] as? Int,
          let pair = PoloniexPair(string: draftDictPair.key) {
          pairs[id] = pair
        } else {
          print("Waring!: not all binance asstets updated:",draftDictPair.key)
          return
        }
      }
      self.pairs = pairs.count > 5 ? pairs : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  private func getCoins() {
    let request = RestRequest.init(hostName: "poloniex.com", path: "/public", queryParameters: ["command":"returnCurrencies"])
    
    GenericRest.sendRequest(request: request, completion: { (response) in
      var coins = [Int:PoloniexCoin]()
      for draftDictCoin in response {
        if let dictCoin = draftDictCoin.value as? [String: Any],
          let id = dictCoin["id"] as? Int,
        let coin = PoloniexCoin(rawValue: draftDictCoin.key) {
          coins[id] = coin
        } else {
          print("Waring!: not all poloniex asstets updated:",draftDictCoin.key)
          return
        }
      }
      self.coins = coins.count > 5 ? coins : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  private func startWs() {
    
    wsApi.startListenTickers()
    wsApi.tickerResponse = { response in
      if let pair = self.pairs?[response.pairId]  {
              let coinPair = CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
        let ticker = Ticker(tradeTime: Int(Date().timeIntervalSince1970), pair: coinPair, price: response.price, quantity: -99)
              self.updateTickers(ticker: ticker)
            } else {
              print("no pair with id for response:", response)
            }
    }
    
  }
  
}




