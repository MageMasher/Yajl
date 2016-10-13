import XCTest
@testable import Yajl

class YajlTests: YajlTestCase {
  var parser: YajlParser!

  override func setUp() {
    super.setUp()
    self.parser = YajlParser()
    self.parser.delegate = self.parserDelegate
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

  func testJSONObject() {
    guard let data = self.loadData("example") else { XCTFail(); return }
    let object = try! Yajl.jsonObject(with: data as Data)
    switch object {
    case .array(_):
      XCTFail("Got an array when we expected a Dictionary")

    case .dict(let value):
      XCTAssertNotNil(value["glossary"])

    default:
      XCTFail("Got unexpected JSON Type")
    }
  }

  func testGeneration() {
    let json: JSONRepresentable = ["hello": "world"]
    let generator = YajlGenerator(options: [])
    generator.write(object: json)

    let data = generator.buffer
    let string = String(data: data, encoding: .utf8)

    debugPrint(string!)
    XCTAssert(string! == "{\"hello\":\"world\"}")
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
