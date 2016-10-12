//
//  ParserDelegate.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

/// The `YajlParserDelegate` protocol defines an interface for callbacks that
/// occur during the parsing of JSON.
public protocol YajlParserDelegate: class {
  /// The parser encountered the beginning of a Dictionary
  ///
  /// - parameter parser: The parser that sends this message 
  func dictionaryStart()

  /// The parser encountered the end of a Dictionary
  ///
  /// - parameter parser: The parser that sends this message 
  func dictionaryEnd()

  /// The parser encountered the beginning of an Array
  ///
  /// - parameter parser: The parser that sends this message 
  func arrayStart()

  /// The parser encountered the end of an Array
  ///
  /// - parameter parser: The parser that sends this message 
  func arrayEnd()

  /// The parser mapped a key
  ///
  /// - parameter parser: The parser that sends this message 
  /// - parameter key: The string value of the key that was mapped.
  func parser(mappedKey key: String)

  /// The parser added a value
  ///
  /// - parameter parser: The parser that sends this message 
  /// - parameter value: The JSON-representable value that was added.
  func parser(addedValue value: JSONRepresentable)
}
