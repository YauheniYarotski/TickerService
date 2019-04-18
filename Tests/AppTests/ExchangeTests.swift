@testable import App
import Vapor
import XCTest



final class ExchangeTests: XCTestCase {
  
  static let __allTests = [
    ("testPairsCanBeRetrievedFromAPI", testPairsCanBeRetrievedFromAPI)
  ]
  
  //  let usersName = "Alice"
  //  let usersUsername = "alicea"
  let exchangesURI = "/api/exchanges/"
  var app: Application!
  //  var conn: PostgreSQLConnection!
  
  override func setUp() {
    //    try! Application.reset()
    app = try! Application.testable()
    //    conn = try! app.newConnection(to: .psql).wait()
  }
  
  override func tearDown() {
    //    conn.close()
    try? app.syncShutdownGracefully()
  }
  
  
  
  func testPairsCanBeRetrievedFromAPI() throws {
    var nilableExchanges: ExchangePairsWithTimeStamp?
    var count = 0
    sleep(5)
    while (nilableExchanges?.exchanges.count ?? 0) < ExchangeName.allCases.count && count < 5 {
      count = count + 1
      sleep(5)
      nilableExchanges = try app.getResponse(to: exchangesURI, decodeTo: ExchangePairsWithTimeStamp.self)
    }
    guard let exchanges = nilableExchanges else {
      XCTFail()
      return
    }
    
    XCTAssertEqual(exchanges.exchanges.count, ExchangeName.allCases.count)
    
    let exchangesMisedFromApi = ExchangeName.allCases.filter({ exchnageName in !exchanges.exchanges.contains(where: {$0.exchangeName == exchnageName})})
    XCTAssert(exchangesMisedFromApi.count == 0)
    
    let exchangesThatDontHavePairs = exchanges.exchanges.filter({$0.pairs.count == 0})
    XCTAssert(exchangesThatDontHavePairs.isEmpty)
    for ex in exchanges.exchanges {
      XCTAssert(ex.pairs.contains(where: {$0.contains("BTC")}))
      XCTAssert(ex.pairs.contains(where: {$0.contains("ETH")}))
    }
  }
}
