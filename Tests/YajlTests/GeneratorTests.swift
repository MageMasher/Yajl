//
//  GeneratorTests.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/12/16.
//
//

import XCTest
@testable import Yajl

class GeneratorTests: YajlTestCase {
  var generator: YajlGenerator!

  override func setUp() {
    super.setUp()
    self.generator = YajlGenerator()
  }

  override func tearDown() {
    self.generator = nil
    super.tearDown()
  }

  func testDictGeneration() {
    let json: JSONRepresentable = ["hello": "world"]
    generator.write(object: json)

    let data = generator.buffer
    let string = String(data: data, encoding: .utf8)

    debugPrint(string!)
    XCTAssert(string! == "{\"hello\":\"world\"}")
  }

  func testArrayGeneration() {
    let json: JSONRepresentable = [1, "hello"]
    generator.write(object: json)

    let data = generator.buffer

    guard let string = String(data: data, encoding: .utf8) else {
      XCTFail("Unable to allocate string from data!")
      return
    }

    debugPrint(string)
    XCTAssert(string == "[1,\"hello\"]")
  }

  static var allTests : [(String, (GeneratorTests) -> () throws -> Void)] {
    return [
      ("testDictGeneration", testDictGeneration),
    ]
  }
}
