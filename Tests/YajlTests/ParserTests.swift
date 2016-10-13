//
//  ParserTests.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/12/16.
//
//

import XCTest
@testable import Yajl

class ParserTests: YajlTestCase {
  var parser: YajlParser!
  
  override func setUp() {
    super.setUp()
    self.parser = YajlParser()
    self.parser.delegate = self.parserDelegate
  }
  
  override func tearDown() {
    self.parser.delegate = nil
    self.parser = nil
    super.tearDown()
  }
  
  func testExample() {
    if let data = self.loadData("example") {
      let status = parser.parse(data: data)
      XCTAssert(status.state == .complete, "Parser encountered an error")
      XCTAssertNil(status.error, "Got unexpected error")
    } else {
      XCTFail("Unable to load data")
    }
  }
}
