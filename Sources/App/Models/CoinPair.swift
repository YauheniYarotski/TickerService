import FluentSQLite
import Vapor

struct CoinPair: Content, Hashable {
  let firstAsset: String
  let secondAsset: String
  
  var symbol: String {
    return "\(firstAsset)-\(secondAsset)"
  }
  
}
