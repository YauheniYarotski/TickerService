//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket

class BitstampWs: BaseWs {
  
  var tickerResponse: ((_ response: BitstampTickerResponse)->())?
  
  func startListenTickers(forPairs: [BitstampPair]) {
        
    let _ = HTTPClient.webSocket(scheme: .wss, hostname: "ws.bitstamp.net", on: wsClientWorker).do { (ws) in
      
      for pair in forPairs {
        let bookRequest: [String : Any] = ["event":"bts:subscribe", "data":["channel": "live_trades_\(pair.urlSymbol)"]]
        guard let bookRequestJsonData = try?  JSONSerialization.data(
          withJSONObject: bookRequest,
          options: []
          ) else {
            print("can't parse bitstamp json:", pair)
            return
        }
        self.ws = ws
        ws.send(bookRequestJsonData)
      }
      
      ws.onText { ws, text in
        guard  let jsonData = text.data(using: .utf8) else {
          print("Error with parsing bitstamp ws response")
          return
        }
        if let tickerResponse: BitstampTickerResponse = try? JSONDecoder().decode(BitstampTickerResponse.self, from: jsonData) {
          self.tickerResponse?(tickerResponse)
        } else if let _: BitstampInfoResponse = try? JSONDecoder().decode(BitstampInfoResponse.self, from: jsonData)  {
          //do nothing for now
        }
        else {
          print("Error with parsing bitstamp ws response")
          return
        }
      }
      
    }
    
    
    
  }
  
}



//{"event":"bts:subscription_succeeded","channel":"diff_order_book_btcusd","data":{}}


//{"event":"bts:error","channel":"","data":{"code":null,"message":"Incorrect JSON format."}}
//{"event":"bts:subscription_succeeded","channel":"live_trades_btcusd","data":{}}
//{"data": {"microtimestamp": "1555135143665724", "amount": 0.0015847299999999999, "buy_order_id": 3126671009, "sell_order_id": 3126671156, "amount_str": "0.00158473", "price_str": "5112.85", "timestamp": "1555135143", "price": 5112.8500000000004, "type": 1, "id": 85658352}, "event": "trade", "channel": "live_trades_btcusd"}


struct BitstampInfoResponse: Content {
  let event: String
  let channel: String
}

struct BitstampTickerResponse: Content {
  
  let event: String
  let channel: String
  let data: BitstampTickerData
  
  var symbol: String {
    return channel.replacingOccurrences(of: "live_trades_", with: "")
  }
}

struct BitstampTickerData: Content {
  
  let timestamp: Int
  let microtimestamp: Int?
  let amount: Double
  let price: Double
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    timestamp = Int(try container.decode(String.self, forKey: .timestamp))!
    microtimestamp = Int(try container.decode(String.self, forKey: .microtimestamp))
    amount = try container.decode(Double.self, forKey: .amount)
    price = try container.decode(Double.self, forKey: .price)
  }
  
}
