//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Vapor


class BaseExchangeManager<T:Content> {
  
  let wsApi: GenericWs?
  let stream: Stream
  
  var book: [String:[Double:Double]] = [:] { //[pair:[Price:Amount]]
    didSet {
      bookDidUpdate?(book)
    }
  }
  var bookDidUpdate: ((_ book: [String:[Double:Double]])->())?
  
  func startCollectData() {
    api?.start(stream: stream)
  }
  
  init(stream: Stream) {
    self.stream = stream
  }
  
}

