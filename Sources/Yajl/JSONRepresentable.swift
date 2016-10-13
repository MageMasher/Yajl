//
//  JSONRepresentable.swift
//  Yajl
//
//  Created by J. Morgan Lieberthal on 10/11/15
//

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

// MARK: - ExpressibleBy...

extension JSONRepresentable: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

extension JSONRepresentable: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: Int) {
    self = .int(value)
  }
}

extension JSONRepresentable: ExpressibleByFloatLiteral {
  public init(floatLiteral value: Double) {
    self = .double(value)
  }
}

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

extension JSONRepresentable: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSONSerializable...) {
    self = .array(elements.map({ $0.toJSON() }))
  }
}

extension JSONRepresentable: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, JSONSerializable)...) {
    var theDict: [String: JSONRepresentable] = [:]

    for (key, value) in elements {
      theDict[key] = value.toJSON()
    }

    self = .dict(theDict)
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
  /// Tries to convert `Any` to `JSONRepresentable`, returning `.null` if conversion failed.
  static func convertToJSON(_ object: Any?) -> JSONRepresentable! {
    guard let object = object else { return .null }

    func nsNumberToJSON(_ value: NSNumber) -> JSONRepresentable {
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
    }

    func nsDictionaryToJSON(_ value: NSDictionary) -> JSONRepresentable {
      var result = [String: JSONRepresentable]()
      value.forEach({ result[$0 as! String] = convertToJSON($1) })
      return .dict(result)
    }

    func stringAnyToJSON(_ value: [String: Any]) -> JSONRepresentable {
      var result = [String: JSONRepresentable]()
      value.forEach({ result[$0] = convertToJSON($1) })
      return .dict(result)
    }

    switch object {
    case is NSNull: return .null

    case let value as JSONRepresentable: return value
    case let value as JSONSerializable:  return value.toJSON()
    case let value as String:            return .string(value)
    case let value as NSNumber:          return nsNumberToJSON(value)
    case let value as NSArray:           return .array(value.map(convertToJSON))
    case let value as NSDictionary:      return nsDictionaryToJSON(value)

    case let value as Bool:   return .bool(value)   // `true` on Linux
    case let value as Int:    return .int(value)    // `true` on Linux
    case let value as Double: return .double(value) // `true` on Linux

    case let value as [Any]:         return .array(value.map(convertToJSON))
    case let value as [String: Any]: return stringAnyToJSON(value)

    default: return nil
    }
  }

  /// Initialize `JSONRepresentable` directly from data
  public init?(data: Data) {
    if let json = try? Yajl.jsonObject(with: data) {
      self = json
    } else {
      return nil
    }
  }
}

// MARK: - JSONSerializable

/// Defines an interface for types that can be serialized in JSON format.
public protocol JSONSerializable {
  /// Converts a custom object to `JSONRepresentable`
  ///
  /// - returns: `JSONRepresentable` of the custom object.
  func toJSON() -> JSONRepresentable
}

extension JSONRepresentable: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    return self
  }
}

// MARK: - JSONSerializable for Standard Library Types

extension Bool: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    return .bool(self)
  }
}

extension Int: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    return .int(self)
  }
}

extension Double: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    return .double(self)
  }
}

extension String: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    return .string(self)
  }
}

extension Array: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    if let json = JSONRepresentable.convertToJSON(self) {
      return json
    }

    return .array([])
  }
}

extension Dictionary: JSONSerializable {
  public func toJSON() -> JSONRepresentable {
    if let json = JSONRepresentable.convertToJSON(self) {
      return json
    }

    return .dict([:])
  }
}
