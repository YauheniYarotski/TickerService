//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket

class BinanceWs: BaseWs {
  
  var tickersResponseHandler: ((_ response: BinanceStreamTikerResponse)->())?
  
  func startListenTickers(pairs: [BinancePair]) {
    guard pairs.count > 0 else {
      print("binance pairs 0")
      return
    }
    let wsOnText: ((WebSocket, String) -> ()) = { (ws: WebSocket, text: String) in
      //      print(text)
      if let jsonData = text.data(using: .utf8), let response = try? JSONDecoder().decode(BinanceStreamTikerResponse.self, from: jsonData) {
        self.tickersResponseHandler?(response)
      } else {
        print("Error with parsing \(BinanceStreamTikerResponse.self) ws response:", text)
        return
      }
    }
    
    var path =  "/stream?streams="
    for pair in pairs {
      path.append("\(pair.symbol.lowercased())@trade/")
    }
    
    
    
    let request = RestRequest.init(hostName: "stream.binance.com", path: path, port: 9443)
    
    self.ws?.close(code: WebSocketErrorCode.normalClosure)
    
    let _ = HTTPClient.webSocket(scheme: .wss, hostname: request.hostName, port: request.port, path: request.path, on: wsClientWorker).do { (ws) in
      self.ws = ws
      ws.onText(wsOnText)
      
      
      }.catch { (error) in
        print("\(self), error:",error)
    }
    
  }
  
}





