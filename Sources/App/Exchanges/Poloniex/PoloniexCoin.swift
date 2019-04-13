import FluentSQLite
import Vapor

struct PoloniexPair {
  static let separator: String = "_"
  let firstAsset: PoloniexCoin
  let secondAsset: PoloniexCoin
  
  var symbol: String {
    return "\(firstAsset.rawValue+PoloniexPair.separator)\(secondAsset.rawValue)"
  }
  init(firstAsset: PoloniexCoin, secondAsset: PoloniexCoin) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
  init?(string: String) {
    let parts = string.components(separatedBy: PoloniexPair.separator)
    if parts.count == 2,
      let first = PoloniexCoin(rawValue: parts[0]),
      let second = PoloniexCoin(rawValue: parts[1]) {
      firstAsset = first
      secondAsset = second
    } else {
      return nil
    }
  }
  
  
}



extension PoloniexCoin: CaseIterable {}

enum PoloniexCoin: String, Content {
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
  case myr = "MYR"
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
