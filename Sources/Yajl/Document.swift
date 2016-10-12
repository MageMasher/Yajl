//
//  Document.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

import Foundation

/// JSON Document interface
public class YajlDocument {
  // MARK: - Public

  /// The default capacity for new collections
  public static let defaultStackCapacity = 20

  /// The root object of our document.
  /// - note: This must be `.array` or `.dict`
  public fileprivate(set) var root: JSONRepresentable! = nil

  /// The delegate for this document
  public weak var delegate: YajlDocumentDelegate?

  /// The status of the Document's parser
  public fileprivate(set) var parserStatus = YajlParser.ParserStatus()

  // MARK: - Private

  /// The current type of the root object
  var currentType: CurrentType = .none

  /// The parser for our document 
  fileprivate var parser: YajlParser

  /// Reference to a dictionary. If a `map` is in progress, this points
  /// to the current `map`.
  fileprivate var dict: [String: JSONRepresentable]? = nil

  /// Reference to an array. If an `array` is in progress, this points
  /// to the current `array`.
  fileprivate var array: [JSONRepresentable]? = nil

  /// Reference to the current key, if a `map` is in progress.
  fileprivate var key: String? = nil

  /// The 'Stack' of parsed objects
  fileprivate var stack: [JSONRepresentable] = []

  /// The 'Stack' of parsed keys
  fileprivate var keyStack: [String] = []

  // MARK: - Initializers 

  /// Create a Document with `YajlParser.Options` and a given `capacity`.
  ///
  /// - parameter parserOptions: Options for the document's parser
  /// - throws: An error if one occured
  public init(parserOptions: YajlParser.Options = [], capacity: Int = YajlDocument.defaultStackCapacity) {
    self.parser = try! YajlParser(options: parserOptions)
    self.parser.delegate = self
  }

  /// Create a Document with a `Data` struct, `YajlParser.Options` and a given `capacity`.
  ///
  /// - parameter data: The data containing the bytes to parse
  /// - parameter parserOptions: Options for the document's parser
  public convenience init(data: Data, parserOptions: YajlParser.Options = [], capacity: Int = YajlDocument.defaultStackCapacity) throws {
    self.init(parserOptions: parserOptions, capacity: capacity)
    try self.parse(data: data)
  }

  // MARK: - Methods 

  /// Parse some JSON data.
  ///
  /// - parameter data: The data to parse
  @discardableResult
  public func parse(data: Data) throws -> YajlParser.ParserStatus {
    self.parserStatus = self.parser.parse(data: data)

    if self.parserStatus.state == .error {
      throw self.parserStatus.error!
    }

    return parserStatus
  }

  /// Parse some JSON data.
  ///
  /// - parameter data: The data to parse
  @discardableResult
  public func parse(data: NSData) throws -> YajlParser.ParserStatus {
    return try parse(data: Data(referencing: data))
  }

  // MARK: - Private Methods

  fileprivate func pop() {
    self.stack.removeLast()
    self.array = nil
    self.dict = nil
    self.currentType = .none

    var value: JSONRepresentable? = nil

    if stack.count > 0 {
      value = stack.last!
    }

    guard let val = value else { return }

    switch val {
    case .array(let contents):
      self.array = contents
      self.currentType = .array

    case .dict(let contents):
      self.dict = contents
      self.currentType = .dict

    default: break
    }
  }

  fileprivate func popKey() {
    key = nil
    keyStack.removeLast()

    if keyStack.count > 0 {
      key = keyStack[keyStack.count - 1]
    }
  }
}

// MARK: - ParserDelegate

extension YajlDocument: YajlParserDelegate {
  public func parser(addedValue value: JSONRepresentable) {
    switch currentType {
    case .array:
      self.array!.append(value)
      self.delegate?.document(self, added: value, to: array!)

    case .dict:
      self.dict![key!] = value
      self.delegate?.document(self, set: value, for: key!, inDictionary: dict!)
      self.popKey()

    default: break
    }
  }

  public func parser(mappedKey key: String) {
    self.key = key
    self.keyStack.append(self.key!) // push
  }

  public func dictionaryStart() {
    let dict = [String: JSONRepresentable](minimumCapacity: YajlDocument.defaultStackCapacity)

    if self.root == nil {
      self.root = .dict(dict)
    }

    self.stack.append(.dict(dict))
    self.dict = dict
    self.currentType = .dict
  }

  public func dictionaryEnd() {
    let value = self.stack.last!
    let dict = self.dict!
    self.pop()
    self.parser(addedValue: value)
    self.delegate?.document(self, didAdd: dict)
  }

  public func arrayStart() {
    let array = [JSONRepresentable]()

    if self.root == nil {
      self.root = .array(array)
    }

    self.stack.append(.array(array))
    self.array = array
    self.currentType = .array
  }

  public func arrayEnd() {
    let value = self.stack.last!
    let array = self.array!

    self.pop()
    self.parser(addedValue: value)
    self.delegate?.document(self, didAdd: array)
  }
}

// MARK: - CurrentRootType

extension YajlDocument {
  /// Describes the current type of the root object
  enum CurrentType {
    /// No root object is set
    case none
    /// The root object is an array
    case array
    /// The root object is a dictionary
    case dict
  }
}
