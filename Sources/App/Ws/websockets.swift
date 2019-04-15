
import Vapor

let wsClientWorker = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public func sockets(_ websockets: NIOWebSocketServer) {
  // Status
  
  let onTextHandler = { (ws: WebSocket, text: String) in
    if let jsonData = text.data(using: .utf8), let exchangesToListen = try? JSONDecoder().decode(ExchangesToListen.self, from: jsonData) {
      operationManager.updateExchangesToListen(exchanges: exchangesToListen)
      ws.send("Did get")
    } else {
      let errorText = "Can't parse JSON to \(ExchangesToListen.self) from: \(text)"
      print(errorText)
      ws.send(errorText)
      return
    }
  }
  
  websockets.get("echo-test") { ws, req in
    print("ws connnected")
    ws.onText { ws, text in
      print("ws received: \(text)")
      ws.send("echo - \(text)")
    }
  }
  
  websockets.get("tickers") { ws, req in
    ws.onText(onTextHandler)
    print("client connected to WS with interval")
    operationManager.sessionManager.add(listener: ws)
  }
  
}

struct ExchangesToListen: Content {
  let interval: Int
  let exchanges:[ExchangesWithPairs]
}

struct ExchangesWithPairs: Content {
  let exchangeName: ExchangeName
  let pairs: [String]
  
  var coinPairs: [CoinPair] {
    return pairs.compactMap({CoinPair.init(string: $0)})
  }
}
