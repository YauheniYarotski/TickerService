//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class BitstampManager: BaseTikerManager {
  
  let wsApi = BitstampWs()
  var pairs: Set<BitstampPair>? //BTC/ATOM
  var coins: Set<BitstampCoin>? //BTC
  
  func startCollectData() {
    self.startWs()
  }
  
  private func getPairsAndCoins() {
    let request = RestRequest.init(hostName: "www.bitstamp.net", path: "/api/v2/trading-pairs-info")
    
    GenericRest.sendRequestToGetArray(request: request, completion: { (response) in
      var pairs = Set<BitstampPair>()
      var coins = Set<BitstampCoin>()
      for draftArrayPair in response {
        if let dictPair = draftArrayPair as? [String: Any],
          let symbol = dictPair["name"] as? String,
          let pair = BitstampPair(string: symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all binance asstets updated:",draftArrayPair)
          return
        }
      }
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  private func startWs() {
    // btcusd, btceur, eurusd, xrpusd, xrpeur, xrpbtc, ltcusd, ltceur, ltcbtc, ethusd, etheur, ethbtc, bchusd, bcheur, bchbtc
    let pairs = ["btcusd", "xrpusd", "ltcusd", "ethusd"]
    wsApi.startListenTickers(forPairs: pairs)
    wsApi.tickerResponse = { response in
      let urlSymbol = response.symbol
      if let pair = BitstampPair(urlString: urlSymbol)  {
        let coinPair = CoinPair.init(firstAsset: pair.firstAsset.rawValue, secondAsset: pair.secondAsset.rawValue)
        let ticker = Ticker(tradeTime: response.data.timestamp, pair: coinPair, price: response.data.price, quantity: response.data.amount)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing bitstamp symbol:",response.symbol)
      }
    }
    
  }
  
}

