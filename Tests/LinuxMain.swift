import XCTest
// 1
@testable import AppTests

// 2
XCTMain([
  testCase(ExchangeTests.__allTests)
  ])

