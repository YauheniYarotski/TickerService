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
  
  func startCollectData() {
    self.startWs()
  }
  
  
  private func startWs() {
    // btcusd, btceur, eurusd, xrpusd, xrpeur, xrpbtc, ltcusd, ltceur, ltcbtc, ethusd, etheur, ethbtc, bchusd, bcheur, bchbtc
    let pairs = ["btcusd", "xrpusd", "ltcusd", "ethusd"]
    wsApi.startListenTickers(forPairs: pairs)
    wsApi.tickerResponse = { response in
      let symbol = response.symbol.uppercased()
      if let bianceCoinPiar = BinanceCoinPair(rawValue: symbol), let firstAsset = bianceCoinPiar.firstAsset, let secondAsset = bianceCoinPiar.secondAsset  {
        let coinPair = CoinPair.init(firstAsset: firstAsset, secondAsset: secondAsset)
        let ticker = Ticker(tradeTime: response.data.timestamp, pair: coinPair, price: response.data.price, quantity: response.data.amount)
        self.updateTickers(ticker: ticker)
      } else {
        print("error pasing binance symbol:",response.symbol)
      }
    }
    
  }
  
}


