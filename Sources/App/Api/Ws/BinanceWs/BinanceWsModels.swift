//
//  BinanceTikerResponse.swift
//  App
//
//  Created by Yauheni Yarotski on 4/10/19.
//

import Foundation
import Vapor

// {"e":"trade","E":1554880529685,"s":"BTCUSDT","t":112760898,"p":"5208.12000000","q":"0.00612000","b":316923179,"a":316923185,"T":1554880529680,"m":true,"M":true}
//  {
//  "e": "trade",     // Event type
//  "E": 123456789,   // Event time
//  "s": "BNBBTC",    // Symbol
//  "t": 12345,       // Trade ID
//  "p": "0.001",     // Price
//  "q": "100",       // Quantity
//  "b": 88,          // Buyer order ID
//  "a": 50,          // Seller order ID
//  "T": 123456785,   // Trade time
//  "m": true,        // Is the buyer the market maker?
//  "M": true         // Ignore
//  }


struct BinanceStreamTikerResponse: Content {
  let stream: String
  let data: BinanceTikerResponse
}

struct BinanceTikerResponse: Content {
  
  let eventType: String
  let eventTime: Int
  let symbol: String
  let tradeId: Int
  let price: Double
  let quantity: Double
  let buyerOrderId: Int
  let sellerOrderId: Int
  let tradeTime: Int
  let iSBuyerMarketMaker: Bool
  let ignore: Bool
  
  enum CodingKeys: String, CodingKey {
    case eventType = "e"
    case eventTime = "E"
    case symbol = "s"
    case tradeId = "t"
    case price = "p"
    case quantity = "q"
    case buyerOrderId = "b"
    case sellerOrderId = "a"
    case tradeTime = "T"
    case iSBuyerMarketMaker = "m"
    case ignore = "M"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    eventType = try container.decode(String.self, forKey: .eventType)
    eventTime = try container.decode(Int.self, forKey: .eventTime)
    symbol = try container.decode(String.self, forKey: .symbol)
    tradeId = try container.decode(Int.self, forKey: .tradeId)
    price = Double(try container.decode(String.self, forKey: .price))!
    quantity = Double(try container.decode(String.self, forKey: .quantity))!
    buyerOrderId = try container.decode(Int.self, forKey: .buyerOrderId)
    sellerOrderId = try container.decode(Int.self, forKey: .sellerOrderId)
    tradeTime = try container.decode(Int.self, forKey: .tradeTime)
    iSBuyerMarketMaker = try container.decode(Bool.self, forKey: .iSBuyerMarketMaker)
    ignore = try container.decode(Bool.self, forKey: .ignore)
  }
}


// {
// "e": "depthUpdate", // Event type
// "E": 123456789,     // Event time
// "s": "BNBBTC",      // Symbol
// "U": 157,           // First update ID in event
// "u": 160,           // Final update ID in event
// "b": [              // Bids to be updated
// [
// "0.0024",       // Price level to be updated
// "10"            // Quantity
// ]
// ],
// "a": [              // Asks to be updated
// [
// "0.0026",       // Price level to be updated
// "100"           // Quantity
// ]
// ]
// }
//
// {"e":"depthUpdate",
// "E":1554705395676,
// "s":"BTCUSDT",
// "U":491907148,
// "u":491907192,
// "b":[["5228.02000000","0.03824500"],["5228.01000000","5.44879100"],["5227.80000000","0.00000000"],["5225.81000000","0.00000000"],["5225.79000000","0.00000000"],["5225.67000000","0.11483400"],["5225.65000000","0.38586400"],["5225.64000000","0.00000000"],["5225.51000000","0.94172600"],["5224.77000000","0.00000000"],["5220.30000000","0.00000000"],["5220.22000000","0.00000000"],["5218.16000000","0.05580000"],["5215.42000000","2.00000000"],["5001.00000000","5.53938200"]],
// "a":[["5229.41000000","0.03824400"],["5229.42000000","0.80000000"],["5229.43000000","0.00000000"],["5229.44000000","0.00000000"],["5233.20000000","0.50000000"],["5239.32000000","0.05671000"],["5239.60000000","0.11470000"],["5239.99000000","0.00000000"]]}
//

struct BinanceBookResponse: Content {
  
  let eventType: String
  let eventTime: Int
  let symbol: String
  let firstUpdateId: Int
  let finalUpdateId: Int
  let bids: [[Double]]
  let asks: [[Double]]
  
  enum CodingKeys: String, CodingKey {
    case eventType = "e"
    case eventTime = "E"
    case symbol = "s"
    case firstUpdateId = "U"
    case finalUpdateId = "u"
    case bids = "b"
    case asks = "a"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    eventType = try container.decode(String.self, forKey: .eventType)
    eventTime = try container.decode(Int.self, forKey: .eventTime)
    symbol = try container.decode(String.self, forKey: .symbol)
    firstUpdateId = try container.decode(Int.self, forKey: .firstUpdateId)
    finalUpdateId = try container.decode(Int.self, forKey: .finalUpdateId)
    bids = try container.decode([[String]].self, forKey: .bids).compactMap({$0.compactMap({Double($0)})})
    asks = try container.decode([[String]].self, forKey: .asks).compactMap({$0.compactMap({Double($0)})})
  }
}

struct BinanceInfoResponse: Content {
  let timezone: String
  let serverTime: UInt
  let symbols: [BinanceSymbolResponse]
}

struct BinanceSymbolResponse: Content  {
  let symbol: String
  let status: String
  let baseAsset: String
  let quoteAsset: String
}


