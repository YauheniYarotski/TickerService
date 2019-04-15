//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class BinanceManager: BaseTikerManager<BinancePair, BinanceCoin> {
  
  let ws = BinanceWs()
  
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
  
  
  
  override func getPairsAndCoins() {
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
  
  override func cooverForWsStartListenTickers(pairs: [BinancePair]) {
    ws.startListenTickers(pairs: pairs)
  }
  
  override func stopListenTickers() {
    ws.stopListenTickers()
  }
  
}

