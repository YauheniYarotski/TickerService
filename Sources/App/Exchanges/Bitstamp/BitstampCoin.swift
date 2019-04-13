import FluentSQLite
import Vapor

struct BitstampPair {
  static let separator: String = "/"
  let firstAsset: BitstampCoin
  let secondAsset: BitstampCoin
  
  var symbol: String {
    return "\(firstAsset.rawValue+PoloniexPair.separator)\(secondAsset.rawValue)"
  }
  var urlSymbol: String {
    return "\(firstAsset.rawValue))\(secondAsset.rawValue)".lowercased()
  }
  init(firstAsset: BitstampCoin, secondAsset: BitstampCoin) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
  init?(string: String) {
    let parts = string.uppercased().components(separatedBy: PoloniexPair.separator)
    if parts.count == 2,
      let first = BitstampCoin(rawValue: parts[0]),
      let second = BitstampCoin(rawValue: parts[1]) {
      firstAsset = first
      secondAsset = second
    } else {
      return nil
    }
  }
  
  init?(urlString: String) {
    let urlString = urlString.uppercased()
    for coin1 in BitstampCoin.allCases where urlString.hasPrefix(coin1.rawValue) {
      let suffix = urlString.replacingOccurrences(of: coin1.rawValue, with: "")
      for coin2 in BitstampCoin.allCases where suffix == coin2.rawValue {
          firstAsset = coin1
          secondAsset = coin2
          return
        }
      }
    return nil
  }
  
  
}

extension BitstampPair: Hashable {
  var hashValue: Int {
    return (self.firstAsset.rawValue+self.secondAsset.rawValue).hashValue
  }
}


extension BitstampCoin: CaseIterable {}

enum BitstampCoin: String, Content {
  case ardr = "ARDR"
  case atom = "ATOM"
  case bat = "BAT"
  case bch = "BCH"
  case bchabc = "BCHABC"
  case bchsv = "BCHSV"
  case bcn = "BCN"
  case bnt = "BNT"
  case btc = "BTC"
  case bts = "BTS"
  case burst = "BURST"
  case clam = "CLAM"
  case cvc = "CVC"
  case dash = "DASH"
  case dcr = "DCR"
  case dgb = "DGB"
  case doge = "DOGE"
  case eos = "EOS"
  case etc = "ETC"
  case eth = "ETH"
  case fct = "FCT"
  case foam = "FOAM"
  case game = "GAME"
  case gas = "GAS"
  case gnt = "GNT"
  case grin = "GRIN"
  case huc = "HUC"
  case knc = "KNC"
  case lbc = "LBC"
  case loom = "LOOM"
  case lpt = "LPT"
  case lsk = "LSK"
  case ltc = "LTC"
  case maid = "MAID"
  case mana = "MANA"
  case nav = "NAV"
  case nmc = "NMC"
  case nmr = "NMR"
  case nxt = "NXT"
  case omg = "OMG"
  case omni = "OMNI"
  case pasc = "PASC"
  case poly = "POLY"
  case ppc = "PPC"
  case qtum = "QTUM"
  case rep = "REP"
  case sbd = "SBD"
  case sc = "SC"
  case snt = "SNT"
  case steem = "STEEM"
  case storj = "STORJ"
  case str = "STR"
  case strat = "STRAT"
  case sys = "SYS"
  case usdc = "USDC"
  case usdt = "USDT"
  case usd = "USD"
  case via = "VIA"
  case vtc = "VTC"
  case xcp = "XCP"
  case xem = "XEM"
  case xmr = "XMR"
  case xpm = "XPM"
  case xrp = "XRP"
  case zec = "ZEC"
  case zrx = "ZRX"
}
