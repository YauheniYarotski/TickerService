//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket

class PoloniexWs: BaseWs {
  
  var tickerResponse: ((_ response: PoloniexTickerResponse)->())?
  
  func startListenTickers() {
    //polinex ws api listen all tickers, can't chose:  https://docs.poloniex.com/?shell#ticker-data
    let _ = HTTPClient.webSocket(scheme: .wss, hostname: "api2.poloniex.com", on: wsClientWorker).do({ (ws) in
      
      //{"command": "subscribe", "channel": 1002}
      let request: [String : Any] = ["command":"subscribe", "channel":1002]
      guard let requestJsonData = try?  JSONSerialization.data(
        withJSONObject: request,
        options: []
        ) else {
          print("can't parse poloniex json:", request)
          return
      }
      
      ws.send(requestJsonData)
      self.ws = ws
      
      
      
      
      ws.onText { ws, text in
        //print(text)
        guard  let jsonData = text.data(using: .utf8) else {
          print("Error with parsing poloniex ws response")
          return
        }
        
        if let parsedAny = try? JSONSerialization.jsonObject(with:
          jsonData, options: []),
          let parsedArrayWithAny = parsedAny as? [Any] {
          
          if parsedArrayWithAny.count == 3,
            let _ = parsedArrayWithAny[0] as? Int,
            let tickerData: [Any] = parsedArrayWithAny[2] as? [Any],
            tickerData.count > 1,
            let pairId: Int = tickerData[0] as? Int,
            let price: Double = Double(tickerData[1] as? String ?? "n.a.") {
            
            self.tickerResponse?(PoloniexTickerResponse(pairId: pairId, price: price))
            
          } else if parsedArrayWithAny.count == 1, let _ = parsedArrayWithAny[0] as? Int {
            //"Heartbeat" [1010]
          } else if parsedArrayWithAny.count == 2, let _ = parsedArrayWithAny[0] as? Int, let _ = parsedArrayWithAny[1] as? Int  {
            //"nothin, but mean that we have subscribde"
            //          The first message is acknowledgement of the subscription.
            //          [<id>, 1]
          } else {
            print("annown answer from server", text)
          }
        } else {
          print("annown answer from server 2", text)
        }
      }
    })
    
    
    
  }
  
}



//[1002,null,[24,"0.02349986","0.02352690","0.02345114","-0.02833033","17.26710811","727.44811868",0,"0.02423900","0.02344000"]]

struct PoloniexTickerResponse {
  let pairId: Int
  let price: Double
}
