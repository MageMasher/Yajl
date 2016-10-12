import XCTest
@testable import Yajl

class YajlTests: YajlTestCase {
  var parser: YajlParser!

  override func setUp() {
    super.setUp()
    if let prsr = try? YajlParser(options: []) {
      self.parser = prsr
      self.parser.delegate = self.parserDelegate
    } else {
      XCTFail("Unable to allocate parser")
    }
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

  func testPerformance() {
    guard let data = self.loadData("example") else {
      XCTFail("Couldn't get data.")
      return
    }
    
    measure {
      for _ in 0..<1000 {
        let _ = self.parser.parse(data: data)
      }
    }
  }

  func testNSJSONPerformance() {
    guard let data = self.loadData("example") else {
      XCTFail("Couldn't get data.")
      return
    }

    measure {
      for _ in 0..<1000 {
        let _ = try! JSONSerialization.jsonObject(with: Data(referencing: data), options: .allowFragments)
      }
    }
  }
  
  static var allTests : [(String, (YajlTests) -> () throws -> Void)] {
    return [
      ("testExample", testExample),
    ]
  }
}
