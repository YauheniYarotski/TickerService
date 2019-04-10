import Vapor

struct ExchangesBooks: Content {
  let exchangeName: String
  let books: [BookForPair]
}

struct BookForPair: Content {
  let pair: String
  let asks: [[Double]]
  let bids: [[Double]]
  
  let totalAsks: Double
  let totalBids: Double
}


struct ExchangeTickers: Content {
  let exchangeName: ExchangeName
  let tickers: [WsTicker]
}

struct WsTicker: Content {
  let pair: String
  let price: Double
  let tradeTime: Int
}
