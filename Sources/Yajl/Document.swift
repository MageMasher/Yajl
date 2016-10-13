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

  /// The root object of the document
  public var root: JSONRepresentable? {
    switch self._root {
    case let ar as ArrayRef: return .array(ar.val)
    case let dr as DictRef: return .dict(dr.val)
    default: return nil
    }
  }

  /// The delegate for this document
  public weak var delegate: YajlDocumentDelegate?

  /// The status of the Document's parser
  public fileprivate(set) var parserStatus = YajlParser.ParserStatus()

  // MARK: - Private

  /// The root object of our document.
  /// - note: This must be `.array` or `.dict`
  fileprivate var _root: JSONRootType? = nil

  /// The current type of the root object
  var currentType: CurrentType = .none

  /// If we should keep a reference to the `root` once we are done parsing
  var saveRoot: Bool

  /// The parser for our document 
  fileprivate var parser: YajlParser

  /// Reference to a dictionary. If a `map` is in progress, this points
  /// to the current `map`.
  fileprivate weak var dict: DictRef?

  /// Reference to an array. If an `array` is in progress, this points
  /// to the current `array`.
  fileprivate weak var array: ArrayRef?

  /// Reference to the current key, if a `map` is in progress.
  fileprivate var key: NSString?

  /// The 'Stack' of parsed objects
  /// FIXME: This is smelly
  fileprivate var stack: Stack<JSONSerializable> = Stack()

  /// The 'Stack' of parsed keys
  fileprivate var keyStack: Stack<NSString> = Stack()

  // MARK: - Initializers 

  /// Create a Document with `YajlParser.Options` and a given `capacity`.
  ///
  /// - parameter parserOptions: Options for the document's parser
  /// - throws: An error if one occured
  public init(parserOptions: YajlParser.Options = [],
              capacity: Int = YajlDocument.defaultStackCapacity,
              saveRoot: Bool = false) {
    self.parser = YajlParser(options: parserOptions)
    self.saveRoot = saveRoot
    self.parser.delegate = self
    self.stack.reserveCapacity(capacity)
    self.keyStack.reserveCapacity(capacity)
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
    self.stack.pop()

    self.array = nil
    self.dict = nil
    self.currentType = .none

    guard let value = self.stack.last else { return }

    switch value {
    case let asArray as ArrayRef:
      self.array = asArray
      self.currentType = .array

    case let asDict as DictRef:
      self.dict = asDict
      self.currentType = .dict

    default: break
    }
  }

  fileprivate func popKey() {
    self.key = nil
    self.keyStack.pop()
    if let last = self.keyStack.last {
      self.key = last
    }
  }
}

// MARK: - ParserDelegate

extension YajlDocument: YajlParserDelegate {
  public func parser(addedValue value: JSONRepresentable) {
    switch currentType {
    case .array:
      self.array!.val.append(value)
      self.delegate?.document(self, didAdd: value, toArray: array!.val)

    case .dict:
      self.dict!.val[key as! String] = value
      self.delegate?.document(self, didSet: value, forKey: key as! String, inDictionary: dict!.val)
      self.popKey()

    default: break
    }
  }

  public func parser(mappedKey key: String) {
    self.key = NSString(string: key)
    self.keyStack.push(self.key!) // push
  }

  public func dictionaryStart() {
    let newDict = DictRef()

    if self._root == nil {
      self._root = newDict
    }

    self.stack.push(newDict)
    self.dict = newDict
    self.currentType = .dict
  }

  public func dictionaryEnd() {
    guard let value = self.stack.last?.toJSON() else {
      print("\(#function) -- value was nil")
      return
    }

    let dict = self.dict!

    self.pop()
    self.parser(addedValue: value)

    self.delegate?.document(self, didAdd: dict.val)
  }

  public func arrayStart() {
    let newArray = ArrayRef()

    if self._root == nil {
      self._root = newArray
    }

    self.stack.push(newArray)

    self.array = newArray
    self.currentType = .array
  }

  public func arrayEnd() {
    let value = self.stack.last!.toJSON()

    let array = self.array!

    self.pop()
    self.parser(addedValue: value)
    self.delegate?.document(self, didAdd: array.val)
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

// MARK: - Reference wrapper

class Ref<T> {
  var val: T
  init(_ v: T) { self.val = v }
  init(other: Ref<T>) { self.val = other.val }
}

protocol RefType {
  associatedtype ValueType
  var val: ValueType { get set }
}

protocol JSONRootType {}

final class DictRef: Ref<[String: JSONRepresentable]>, RefType {
  override init(_ v: [String: JSONRepresentable]) { super.init(v) }
  init() { super.init([:]) }
}

extension DictRef: JSONSerializable {
  func toJSON() -> JSONRepresentable {
    return .dict(self.val)
  }
}

extension DictRef: JSONRootType {}

final class ArrayRef: Ref<[JSONRepresentable]>, RefType {
  override init(_ v: [JSONRepresentable]) { super.init(v) }
  init() { super.init([]) }
  convenience init(capacity: Int) {
    self.init()
    self.val.reserveCapacity(capacity)
  }
}

extension ArrayRef: JSONRootType {}

extension ArrayRef: JSONSerializable {
  func toJSON() -> JSONRepresentable {
    return .array(self.val)
  }
}

// MARK: - Root Object Type 

final class RootObjectType {

}
