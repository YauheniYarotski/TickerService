//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket

class GenericWs{
  
  static func start<T:Content> (request: RestRequest, completion: ((_ response: T)->())?) {
    
    
    let wsOnText: ((WebSocket, String) -> ()) = { (ws: WebSocket, text: String) in
      //      print(text)
      if let jsonData = text.data(using: .utf8), let response: T = try? JSONDecoder().decode(T.self, from: jsonData) {
        completion?(response)
      } else {
        print("Error with parsing \(T.self) ws response:", text)
        return
      }
      
    }
    
    let wss = HTTPClient.webSocket(scheme: .wss, hostname: request.hostName, port: request.port, path: request.path, on: wsClientWorker).map(to: WebSocket.self) { (ws) in
      ws.onText(wsOnText)
      ws.onCloseCode({ code in
        print("ws closed with code:",code)
      })
      ws.onError({ (ws, error) in
        print("ws error with error:",error)
      })
      return ws
    }
  }
  
  
  
}





