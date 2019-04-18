@testable import App
import Foundation

extension ExchangePairsWithTimeStamp {
  static func createTestSet() -> ExchangePairsWithTimeStamp {
    var exchanges = [ExchangePairs]()
    for exchangeName in ExchangeName.allCases {
      var exchangePairs: ExchangePairs!
      switch exchangeName {
      case .binance: exchangePairs = ExchangePairs(exchangeName: exchangeName,pairs:["BTC-USDT"])
      case .bitstamp: exchangePairs = ExchangePairs(exchangeName: exchangeName,pairs:["BTC-USD"])
      case .coinbasePro: exchangePairs = ExchangePairs(exchangeName: exchangeName,pairs:["BTC-USD"])
      case .poloniex: exchangePairs = ExchangePairs(exchangeName: exchangeName,pairs:["BTC-USDT"])
      }
      exchanges.append(exchangePairs)
    }
    return ExchangePairsWithTimeStamp(timeStamp: UInt(Date().timeIntervalSince1970) ,exchanges: exchanges)
  }
}
