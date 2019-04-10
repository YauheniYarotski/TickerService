//
//  Stream.swift
//  App
//
//  Created by Yauheni Yarotski on 4/10/19.
//

import Foundation
import Vapor

struct Stream {
  var hostname: String
  var port: Int?
  var path: String
  var streamType: StreamType = .ticker
  
}

enum StreamType {
  case book
  case ticker
}

//protocol Startable {
//  associatedtype ReponseType: Content
//  func start(stream: Stream<ReponseType>)
//}
