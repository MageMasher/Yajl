//
//  DocumentTests.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/12/16.
//
//

import XCTest
@testable import Yajl

class DocumentTests: YajlTestCase, YajlDocumentDelegate {
  var document: YajlDocument!
  
  override func setUp() {
    super.setUp()
    document = YajlDocument()
    document.delegate = self
  }
  
  override func tearDown() {
    document = nil
    super.tearDown()
  }
  
  func testDocument() {
    guard let data = self.loadData("example") else {
      XCTFail("Unable to get data.")
      return
    }

    if let status = try? document.parse(data: data) {
      XCTAssert(status.error == nil, "Encountered an error: \(status.error!)")
      XCTAssert(document.root != nil, "Document has a NULL root!!")

      switch document.root! {
      case .dict(let dict):
        XCTAssert(dict["glossary"] != nil, "Got a nil value for glossary")
      default:
        XCTFail("Unexpected root type")
      }
    } else {
      XCTFail("Unable to parse data.")
    }
  }
}
