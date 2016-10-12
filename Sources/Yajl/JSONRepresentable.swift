//
//  JSONRepresentable.swift
//  Yajl
//
//  Created by J. Morgan Lieberthal on 10/11/15
//

import CYajl

/// Wraps a JSON-representable type
public enum JSONRepresentable {
  /// The `null` value
  case null

  /// A `boolean` value
  case bool(Bool)

  /// An `int`
  ///
  /// While not strictly present in JSON (all javascript numbers are doubles),
  /// this is convenient
  case int(Int)
  
  /// A `float`
  case double(Double)

  /// A `string`
  case string(String)

  /// An `array`
  case array([JSONRepresentable])

  /// A `dictionary`
  case dict([String: JSONRepresentable])
}

// MARK: - CustomStringConvertible

extension JSONRepresentable: CustomStringConvertible {
  public var description: String {
    switch self {
    case .null: return "null"
    case .bool(let value): return value.description
    case .int(let value): return value.description
    case .double(let value): return value.description
    case .string(let value): return value.debugDescription
    case .array(let values): return values.description
    case .dict(let values): return values.description
    }
  }
}

// MARK: - ExpressibleByNilLiteral

extension JSONRepresentable: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .null
  }
}

// MARK: - ExpressibleByArrayLiteral

extension JSONRepresentable: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSONRepresentable...) {
    self = .array(elements)
  }
}

// MARK: - ExpressibleByIntegerLiteral 

extension JSONRepresentable: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .int(value)
  }
}

// MARK: - ExpressibleByFloatLiteral

extension JSONRepresentable: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .double(value)
  }
}

// MARK: - ExpressibleByStringLiteral

extension JSONRepresentable: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .string(value)
  }

  public init(unicodeScalarLiteral value: String) {
    self = .string(value)
  }

  public init(extendedGraphemeClusterLiteral value: String) {
    self = .string(value)
  }
}

// MARK: - ExpressibleByDictionaryLiteral

extension JSONRepresentable: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSONRepresentable)...) {
    var theDict: [String: JSONRepresentable] = [:]

    for (key, value) in elements {
      theDict[key] = value
    }
    
    self = .dict(theDict)
  }
}

// MARK: - ExpressibleByBooleanLiteral

extension JSONRepresentable: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

// MARK: - Equatable

extension JSONRepresentable: Equatable {}

/// `==(_:_:)` implementation for JSONRepresentable
public func ==(lhs: JSONRepresentable, rhs: JSONRepresentable) -> Bool {
  switch (lhs, rhs) {
  case (.null, .null): return true
  case (.null, _): return false

  case (.bool(let a), .bool(let b)): return a == b
  case (.bool, _): return false

  case (.int(let a), .int(let b)): return a == b
  case (.int, _): return false

  case (.double(let a), .double(let b)): return a == b
  case (.double, _): return false

  case (.string(let a), .string(let b)): return a == b
  case (.string, _): return false

  case (.array(let a), .array(let b)): return a == b
  case (.array, _): return false

  case (.dict(let a), .dict(let b)): return a == b
  case (.dict, _): return false
  }
}

// MARK: - Extra Initializers and Static Functions

import Foundation

/// The `Type` of an NSBoolean
private let nsBooleanType = type(of: NSNumber(value: false))

extension JSONRepresentable {
  static func convertToJSON(_ object: Any) -> JSONRepresentable {
    switch object {
    case is NSNull:
      return .null

    case let value as String:
      return .string(value)

    case let value as NSNumber:
      // Check if this is a boolean NSNumber
      // FIXME: This is all rather expensive...
      if type(of: value) === nsBooleanType {
        return .bool(value != 0)
      }

      let asInt = value.intValue
      if NSNumber(value: asInt) == value {
        return .int(asInt)
      }

      return .double(value.doubleValue)

    case let value as NSArray:
      return .array(value.map(convertToJSON))

    case let value as NSDictionary:
      var result = [String: JSONRepresentable]()
      value.forEach({ result[$0 as! String] = convertToJSON($1) })
      return .dict(result)

    case let asBool as Bool:
      return .bool(asBool)

    case let asInt as Int:
      return .int(asInt)

    case let asDouble as Double:
      return .double(asDouble)

    case let value as [Any]:
      return .array(value.map(convertToJSON))

    case let value as [String: Any]:
      var result = [String: JSONRepresentable]()
      value.forEach({ result[$0] = convertToJSON($1) })
      return .dict(result)

    default:
      fatalError("Unexpected object: \(object) \(type(of: object))")
    }
  }
}

// MARK: - JSONSerializable

/// Defines an interface for types that can be serialized in JSON format.
public protocol JSONSerializable {
  func toJSON() -> JSONRepresentable
}
