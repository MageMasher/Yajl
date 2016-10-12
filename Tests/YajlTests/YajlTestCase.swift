//
//  YajlTestCase.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/12/16.
//
//

import XCTest
@testable import Yajl

class YajlTestCase: XCTestCase {
  func loadData(_ fixtureName: String) -> NSData? {
    guard let path = Bundle(for: type(of: self)).path(forResource: fixtureName, ofType: "json") else {
      XCTFail("Invalid fixture name \(fixtureName) for data.")
      return nil
    }
    
    do {
      let data = try NSData(contentsOfFile: path, options: .uncachedRead)
      return data
    } catch {
      XCTFail("\(error)")
      return nil
    }
  }

  func loadString(_ fixture: String) -> String {
    guard let ns = loadData(fixture) else { return "" }
    return String(data: (ns as Data), encoding: .utf8)!
  }

  func directoryWith(path: String) -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let fullPath = (paths.last! as NSString).appendingPathComponent(path)
    print("Using path: \(fullPath)")
    return fullPath
  }

  var parserDelegate = TestParserDelegate()
}

class TestParserDelegate: YajlParserDelegate {
  var currentIndentLevel: Int = 0

  var indent: String {
    if currentIndentLevel == 0 {
      return ""
    }

    return String(repeating: " ", count: currentIndentLevel * 2)
  }

  func dictionaryStart() {
    print("\(indent){")
    currentIndentLevel += 1
  }

  func dictionaryEnd() {
    currentIndentLevel -= 1
    print("\(indent)}")
  }

  func arrayStart() {
    print("\(indent)[")
    currentIndentLevel += 1
  }

  func arrayEnd() {
    print("\(indent)]")
    currentIndentLevel -= 1
  }

  func parser(mappedKey key: String) {
    print("\(indent)'\(key)':", terminator: " ")
    let oldIndent = currentIndentLevel
    currentIndentLevel = 0
    defer { currentIndentLevel = oldIndent }
  }

  func parser(addedValue value: JSONRepresentable) {
    print(value.description)
  }
}
