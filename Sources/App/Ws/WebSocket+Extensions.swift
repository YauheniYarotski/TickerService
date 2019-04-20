import Vapor
import WebSocket
import Foundation

extension WebSocket {
  
  func sendConten<T: Content>(_ data: T) {
    let encoder = JSONEncoder()
    guard let jsonData = try? encoder.encode(data) else { return }
    guard let jsonText = String(data: jsonData, encoding: .utf8) else { return }
    send(text: jsonText)
  }
}
