//
//  Generator.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

import CYajl
import Foundation

/// JSON Generator
///
/// The generator supports the following types:
///   - `Array`
///   - `Dictionary`
///   - `String`
///   - `Int`
///   - `Double`
///   - `nil`
///
/// Additionally, the generator supports any type that conforms to 
/// the `JSONSerializable` protocol.
public class YajlGenerator {
  // MARK: - Public
  
  /// Options for JSON generation 
  public let options: Options

  /// An indent string to be used when generating JSON. This string is only
  /// used if `options` contains .beautify
  public let indentString: String

  /// The buffer that we are writing to.
  public var buffer: Data {
    var len: Int = 0
    var buf: UnsafePointer<UInt8>?
    let status = yajl_gen_get_buf(self.handle, &buf, &len)

    guard status == yajl_gen_status_ok, buf != nil else { return Data() }

    return Data(bytes: UnsafeMutableRawPointer(mutating: buf!), count: len)
  }

  // MARK: - Private

  /// The handle of the `yajl_gen` we are using
  private var handle: yajl_gen!

  // MARK: - Initializers

  /// Create a YajlGenerator, given `options` and an `indentString`
  ///
  /// - parameter options: `Options` for json generation
  /// - parameter indentString: The string to be used as an 'indent' when
  ///   `options` contains `.beautify`
  public init(options: Options = .none, indentString: String = "") {
    self.options = options
    self.indentString = indentString
    self.handle = yajl_gen_alloc(nil)
    configureHandle(self.handle, generator: self)
  }

  /// Clean up the handle on deinitialization
  deinit {
    if self.handle != nil {
      yajl_gen_free(self.handle)
      self.handle = nil
    }
  }

  /// Write an object's JSON representation to the buffer.
  /// 
  /// - parameter object: The object to serialize as JSON.
  /// - precondition: `object` is of type JSONRepresentable
  public func write(object: JSONRepresentable) {
    func genArray(_ contents: [JSONRepresentable]) {
      yajl_gen_array_open(handle)
      for element in contents {
        write(object: element)
      }
      yajl_gen_array_close(handle)
    }

    func genDict(_ contents: [String: JSONRepresentable]) {
      yajl_gen_map_open(handle)
      for key in contents.keys.sorted() {
        write(object: .string(key))
        write(object: contents[key]!)
      }
      yajl_gen_map_close(handle)
    }

    switch object {
    case .null:            yajl_gen_null(handle)
    case .bool(let val):   yajl_gen_bool(handle, val ? 1 : 0)
    case .int(let val):    yajl_gen_integer(handle, Int64(val))
    case .double(let val): yajl_gen_double(handle, val)
    case .string(let val): yajl_gen_string(handle, val, val.lengthOfBytes(using: .utf8))
    case .array(let vals): genArray(vals)
    case .dict(let kvps):  genDict(kvps)
    }
  }

  /// Write an object's JSON representation to the buffer.
  ///
  /// - parameter object: The object to serialize as JSON.
  /// - precondition: `object` conforms to `JSONSerializable`
  public func write(object: JSONSerializable) {
    write(object: object.toJSON())
  }

  /// Reset the buffer to its initial state
  public func resetBuffer() {
    yajl_gen_clear(self.handle)
  }
}

import YajlConfig

/// Configure the generator handle
fileprivate func configureHandle(_ handle: yajl_gen, generator: YajlGenerator) {
  let options = generator.options

  let pp = options.contains(.beautify) ? 1 : 0
  configureYajlGenerator(handle, option: yajl_gen_beautify, intValue: pp)

  let validate = options.contains(.validateUTF8) ? 1 : 0
  configureYajlGenerator(handle, option: yajl_gen_validate_utf8, intValue: validate)

  let escape = options.contains(.escapeForwardSlash) ? 1 : 0
  configureYajlGenerator(handle, option: yajl_gen_escape_solidus, intValue: escape)

  configureYajlGenerator(handle, option: yajl_gen_indent_string, stringValue: generator.indentString)
}
