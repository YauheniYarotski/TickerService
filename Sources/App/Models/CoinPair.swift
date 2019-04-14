import FluentSQLite
import Vapor

struct CoinPair: Content, Hashable {
  let firstAsset: String
  let secondAsset: String
  
  var symbol: String {
    return "\(firstAsset)-\(secondAsset)"
  }
  
  enum CodingKeys: String, CodingKey {
    case firstAsset
    case secondAsset
    case symbol
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(symbol, forKey: .symbol)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    firstAsset = try container.decode(String.self, forKey: .firstAsset)
    secondAsset = try container.decode(String.self, forKey: .secondAsset)
  }
  
  init(firstAsset: String, secondAsset: String) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
}
