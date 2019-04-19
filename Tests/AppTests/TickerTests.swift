@testable import App
import Vapor
import XCTest
import Jobs


final class TickerTests: XCTestCase {
  
    static let __allTests = [
      ("testTickersCanBeRetrievedFromWsAPI", testTickersCanBeRetrievedFromWsAPI)
    ]

  let exchangesURI = "/tickers/"
  var app: Application!
  
  override func setUp() {
    app = try! Application.testable()
  }
  
  override func tearDown() {
    //    conn.close()
    try? app.syncShutdownGracefully()
  }
  
  
  
  func testTickersCanBeRetrievedFromWsAPI() throws {
    
    let jsonString = "{\"interval\":10, \"exchanges\":[{\"exchangeName\":\"Binance\", \"pairs\":[\"LTC-BTC\"] } ] }"
    let expectation = self.expectation(description: "")
    let _ = self.app.createWs().do { (ws) in
      ws.send(jsonString)
      ws.onText { ws, text in
        print(text)
        XCTAssert(text.count > 0)
        expectation.fulfill()
      }
      }.catch { (error) in
        print(error)
    }
    waitForExpectations(timeout: 10, handler: nil)
    
  }
}
