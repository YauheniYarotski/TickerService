import FluentSQLite
import Vapor

struct CoinPair: Content, Hashable {
  let firstAsset: BinanceCoin
  let secondAsset: BinanceCoin
  
  var symbol: String {
    return "\(firstAsset.rawValue)-\(secondAsset.rawValue)"
  }
  
}
