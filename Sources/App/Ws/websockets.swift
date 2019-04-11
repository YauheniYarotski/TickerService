
import Vapor

let wsClientWorker = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public func sockets(_ websockets: NIOWebSocketServer) {
  // Status
  
  websockets.get("echo-test") { ws, req in
    print("ws connnected")
    ws.onText { ws, text in
      print("ws received: \(text)")
      ws.send("echo - \(text)")
    }
  }
  
  websockets.get("tickers", Int.parameter) { ws, req in
    if let interval = try? req.parameters.next(Int.self) {
      print("client connected to WS with interval:", interval)
      operationManager.updateWsUpdateInterval(newInterval: interval)
      operationManager.sessionManager.add(listener: ws)
    } else {
      print("Can't connect ws")
    }
  }
  
}
