//
//  DocumentDelegate.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

import Foundation

/// The `YajlDocumentDelegate` protocol defines an interface for
/// event-driven parsing of a JSON document.
public protocol YajlDocumentDelegate: class {
  /// The document added a dictionary
  ///
  /// - parameter document: The document that added the `dict`
  /// - parameter dict: The dictionary that was added
  func document(_ document: YajlDocument, didAdd dict: [String: JSONRepresentable])

  /// The document added an array
  ///
  /// - parameter document: The document that added the `array`
  /// - parameter array: The array that was added
  func document(_ document: YajlDocument, didAdd array: [JSONRepresentable])

  /// The document added an object to an array
  ///
  /// - parameter document: The document that added the `object`
  /// - parameter object: The object that was added to the `array`
  /// - parameter array: The array to which the object was added
  func document(_ document: YajlDocument,
                didAdd object: JSONRepresentable,
                toArray: [JSONRepresentable])

  /// The document added an object to a dictionary
  ///
  /// - parameter document: The document that added the `object`
  /// - parameter object: The object that was added to the `dict`
  /// - parameter key: The key for which the object was set 
  /// - parameter dict: The array to which the object was added
  func document(_ document: YajlDocument,
                didSet object: JSONRepresentable,
                forKey key: String,
                inDictionary dict: [String: JSONRepresentable])
}

/// All of these methods are technically optional, but we don't want
/// to restrict conformers to only `@objc` classes, so we provide empty
/// default implementations.
extension YajlDocumentDelegate {
  func document(_ document: YajlDocument, didAdd dict: [String: JSONRepresentable]) {
    #if DEBUG
      debugPrint(document, dict)
    #endif
  }
  func document(_ document: YajlDocument, didAdd array: [JSONRepresentable]) {
    #if DEBUG
      debugPrint(document, array)
    #endif
  }
  
  func document(_ document: YajlDocument,
                didAdd object: JSONRepresentable,
                toArray: [JSONRepresentable]) {
    #if DEBUG
      debugPrint(document, object, toArray)
    #endif
  }
  
  func document(_ document: YajlDocument,
                didSet object: JSONRepresentable,
                forKey key: String,
                inDictionary dict: [String: JSONRepresentable]) {
    #if DEBUG
      debugPrint(document, object, key, dict)
    #endif
  }
}
