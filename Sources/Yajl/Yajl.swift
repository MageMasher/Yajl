//
//  Yajl.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/12/16.
//
//

import struct Foundation.Data
import class Foundation.NSNumber
import Foundation.NSNull

/// Alias JSON => JSONRepresentable, unless this 'macro' is defined.
#if !AVOID_JSON_COLLISION
  public typealias JSON = JSONRepresentable
#endif

/// Represents an invalid json object
public enum JSONError: Swift.Error {
  /// The JSON object is invalid
  case invalidJSONObject
}

/// A class that provides convenience methods for parsing and generating JSON.
/// Meant to be used as a drop-in replacement for JSONSerialization.
public final class Yajl {
  /// Create a Swift Object or Structure from given JSON data.
  ///
  /// The data must be in one of the 5 supported encodings listed in the JSON specification:
  ///   - UTF-8,
  ///   - UTF-16LE,
  ///   - UTF-16BE, 
  ///   - UTF-32LE, 
  ///   - UTF-32BE. 
  ///
  /// The data may or may not have a BOM. The most efficient encoding to use for 
  /// parsing is UTF-8, so if you have a choice in encoding the data passed to this 
  /// method, use UTF-8.
  ///
  /// - parameter data: A data object containing JSON data.
  /// - parameter options: Options for parsing the JSON data and creating objects.
  ///   For possible values, see `YajlParser.Options`
  public static func jsonObject(with data: Data, options: YajlParser.Options = []) throws -> JSONRepresentable {
    let document = YajlDocument(parserOptions: options)
    try document.parse(data: data)
    return document.root!
  }

  /// Returns JSON data from a Foundation object.
  ///
  /// If `obj` will not produce valid JSON, an exception is thrown. 
  /// This exception is thrown prior to parsing and represents a programming error, 
  /// not an internal error. You should check whether the input will produce valid JSON before 
  /// calling this method by using `isValidJSONObject(_:)`.
  ///
  /// Setting the `beautify` option will generate JSON with whitespace designed to make the 
  /// output more readable. 
  /// If that option is not set, the most compact possible JSON will be generated.
  ///
  /// - parameter object: The object from which to generate JSON data.
  /// - parameter options: Options for creating the JSON data. See `YajlGenerator.Options`.
  /// - throws: If the JSON object is invalid, or if an error occured while generating.
  public static func data(withJSONObject object: JSONRepresentable,
                          options: YajlGenerator.Options = []) throws -> Data {
    guard isValidJSONObject(object) else {
      throw JSONError.invalidJSONObject
    }

    let generator = YajlGenerator(options: options)
    generator.write(object: object)

    return generator.buffer
  }

  /// Returns a boolean value that indicates whether a given object can
  /// be converted to JSON data.
  ///
  /// - parameter obj: The object to test.
  /// - returns: `true` if the object can be converted to JSON, `false` otherwise.
  public static func isValidJSONObject(_ obj: Any) -> Bool {
    func checkValid(_ obj: Any) -> Bool {
      /// Object is a Swift.String or NSNull
      if obj is String || obj is NSNull {
        return true
      }

      // object is an NSNumber, and is not Infinity or NaN
      if let number = obj as? NSNumber {
        let invalid = number.doubleValue.isInfinite || number.doubleValue.isNaN
        return !invalid
      }
      
      // object is a Swift.Array
      if let array = obj as? [Any] {
        for element in array {
          guard checkValid(element) else { return false }
        }

        return true
      }

      // object is a Swift.Dictionary
      if let dictionary = obj as? [String: Any] {
        for (_, value) in dictionary {
          guard checkValid(value) else { return false }
        }

        return true
      }

      // invalid object
      return false
    }

    guard !(obj is JSONRepresentable || obj is JSONSerializable) else { return true }
    
    guard obj is [Any] || obj is [String: Any] else { return false }
    
    return checkValid(obj)
  }

  /// This is really just a namespace, so no initializer is available
  private init() {}
}
