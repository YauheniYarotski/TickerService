//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class PoloniexManager: BaseTikerManager<PoloniexPair, PoloniexCoin> {
  let ws = PoloniexWs()
  var pairsIds: [Int:PoloniexPair]?
  var coinsIds: [Int:PoloniexCoin]?  //1,BTC_ATOM
  
  override func getPairsAndCoins() {
    let request = RestRequest.init(hostName: "poloniex.com", path: "/public", queryParameters: ["command":"returnTicker"])
    
    GenericRest.sendRequest(request: request, completion: { (response) in
      var pairsIds = [Int:PoloniexPair]()
      for draftDictPair in response {
        if let dictPair = draftDictPair.value as? [String: Any],
          let id = dictPair["id"] as? Int,
          let pair = PoloniexPair(string: draftDictPair.key) {
          pairsIds[id] = pair
        } else {
          print("Waring!: not all binance asstets updated:",draftDictPair.key)
        }
      }
      self.pairsIds = pairsIds.count > 5 ? pairsIds : nil
      self.pairs = pairsIds.count > 5 ? Set(pairsIds.compactMap({$0.value})) : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  private func getCoins() {
    let request = RestRequest.init(hostName: "poloniex.com", path: "/public", queryParameters: ["command":"returnCurrencies"])
    
    GenericRest.sendRequest(request: request, completion: { (response) in
      var coinsIds = [Int:PoloniexCoin]()
      for draftDictCoin in response {
        if let dictCoin = draftDictCoin.value as? [String: Any],
          let id = dictCoin["id"] as? Int,
        let coin = PoloniexCoin(rawValue: draftDictCoin.key) {
          coinsIds[id] = coin
        } else {
          print("Waring!: not all poloniex asstets updated:",draftDictCoin.key)
        }
      }
      self.coinsIds = coinsIds.count > 5 ? coinsIds : nil
      self.coins = coinsIds.count > 5 ? Set(coinsIds.compactMap({$0.value})) : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  private func startWs() {
    
    ws.startListenTickers()
    ws.tickerResponse = { response in
      if let pair = self.pairsIds?[response.pairId]  {
              let coinPair = CoinPair.init(firstAsset: pair.secondAsset.rawValue, secondAsset: pair.firstAsset.rawValue)
        let ticker = Ticker(tradeTime: Int(Date().timeIntervalSince1970), pair: coinPair, price: response.price, quantity: -99)
              self.updateTickers(ticker: ticker)
            } else {
              print("no pair with id for response:", response)
            }
    }
    
  }
  
  override func stopListenTickers() {
    ws.stopListenTickers()
  }
}




