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
  
  func start<T:Content> (stream: Stream, completion: ((_ response: T)->())?) {
    
    guard let ws = try? HTTPClient.webSocket(scheme: .wss, hostname: stream.hostname,port: stream.port, path: stream.path, on: wsClientWorker).wait() else {
      print("Ws \(stream.hostname) is nil")
      return
    }
    
    ws.onText { ws, text in
      //      print(text)
      if let jsonData = text.data(using: .utf8), let response: T = try? JSONDecoder().decode(T.self, from: jsonData) {
        completion?(response)
      } else {
        print("Error with parsing \(T.self) ws response:", text)
        return
      }
      
    }
    
  }
  
}





