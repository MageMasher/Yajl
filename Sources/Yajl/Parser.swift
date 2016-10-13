//
//  Parser.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

import Foundation
import CYajl
import YajlConfig

/// A JSON Parser
///
/// __Example:__
///
/// ````
/// let url = URL(fileURLWithPath: "example.json")
///
/// guard let data = try? Data(contentsOf: url) else { ... }
///
/// let delegate = YajlParser(options: .allowComments)
/// delegate = self
/// do {
///   try parser.parse(data: data)
/// } catch {
///   print("Parser error: \(error)")
/// }
///
/// ````
public class YajlParser {
  // MARK: - Public
  
  /// The parser's delegate
  public var delegate: YajlParserDelegate? {
    didSet {
      if let _ = delegate {
        // clean up the old handle before we do anything
        releaseHandle()

        withUnsafeMutablePointer(to: &delegate, { pointer in
          self.handle = createHandle(for: UnsafeMutableRawPointer(pointer))
        })
      }
    }
  }
  
  /// The state of this parser
  public private(set) var status = ParserStatus()
  
  /// Options (`ParserOptions`) associated with this parser
  public let options: Options
  
  /// The number of bytes the parser has consumed
  public var bytesParsed: Int {
    return yajl_get_bytes_consumed(handle)
  }
  
  // MARK: - Private

  /// The yajl_handle we are working with
  private var handle: yajl_handle! = nil

  // MARK: - Initializers
  
  /// Create a parser with given options.
  ///
  /// - parameter options: `YajlParser.Options` to use.
  public init(options: Options = .none) throws {
    self.options = options
  }

  /// Clean up the handle
  deinit {
    releaseHandle()
  }

  // MARK: - Public Functions

  /// Parse data.
  ///
  /// - parameter data: The NSData object that contains JSON data to parse
  /// - returns: The state of the parser
  public func parse(data: NSData) -> ParserStatus {
    let bytes = data.bytes.assumingMemoryBound(to: UInt8.self)
    let len = data.length
    return parse(bytes, length: len)
  }
  
  /// Parse data.
  ///
  /// - parameter data: The Data structure that contains JSON data to parse
  /// - returns: The state of the parser
  public func parse(data: Data) -> ParserStatus {
    let ns = NSData(data: data)
    return parse(data: ns)
  }
  
  /// Parse data.
  ///
  /// - parameter data: A pointer to raw bytes to be processed.
  /// - parameter length: The number of bytes to be processed.
  /// - returns: The state of the parser
  public func parse(_ data: UnsafePointer<UInt8>, length: Int) -> ParserStatus {
    let parseStatus = yajl_parse(handle, data, length)

    func getErrorMessage() -> String {
      let errorMessage: String

      if let errorCstring = yajl_get_error(handle, 1, data, length) {
        errorMessage = String(cString: errorCstring)
        yajl_free_error(handle, errorCstring)
      } else {
        errorMessage = "Unknown error"
      }

      return errorMessage
    }
      
    if parseStatus == yajl_status_ok {
      status.state = .complete
      return status
    }
    
    if parseStatus == yajl_status_client_canceled {
      status.state = .error
      return status
    }
    
    if parseStatus == yajl_status_error {
      status.error = .yajlError(parseStatus.rawValue, getErrorMessage())
      return status
    }
    
    // if we get all the way down here, something went wrong
    status.state = .error
    status.error = .yajlError(parseStatus.rawValue, "Unexpected status. Should be UNREACHABLE")
    
    return status
  }

  // MARK: - Private Functions
  
  /// Configure the handle
  private func createHandle(for context: UnsafeMutableRawPointer?) -> yajl_handle? {
    guard let handle = yajl_alloc(&ParserCallbacks, nil, context) else {
      status.error = .alloc
      return nil
    }

    configureHandle(handle, options: self.options)
    
    return handle
  }

  /// Clean up the handle
  private func releaseHandle() {
    if self.handle != nil {
      yajl_free(self.handle)
      self.handle = nil
    }
  }
}

// MARK: - Fileprivate Implementation Details

/// Return the delegate from a `context` pointer
fileprivate func getDelegate(context: UnsafeMutableRawPointer?) -> YajlParserDelegate? {
  let p = context?.assumingMemoryBound(to: YajlParserDelegate.self)
  return p?.pointee
}

/// Configure the handle with a set of options
fileprivate func configureHandle(_ handle: yajl_handle, options: YajlParser.Options) {
  let allowComments = options.contains(.allowComments) ? 1 : 0
  configureYajlHandle(handle, option: yajl_allow_comments, intValue: allowComments)

  let skipValidation = options.contains(.validateUTF8) ? 0 : 1 // this is reversed
  configureYajlHandle(handle, option: yajl_dont_validate_strings, intValue: skipValidation)

  let allowTrailing = options.contains(.allowTrailing) ? 1 : 0 // back to normal boolean
  configureYajlHandle(handle, option: yajl_allow_trailing_garbage, intValue: allowTrailing)

  let allowMultiple = options.contains(.allowMultiple) ? 1 : 0
  configureYajlHandle(handle, option: yajl_allow_multiple_values, intValue: allowMultiple)

  let allowPartial = options.contains(.allowPartial) ? 1 : 0
  configureYajlHandle(handle, option: yajl_allow_partial_values, intValue: allowPartial)
}

// MARK: - Parser Callbacks 

/// The set of callbacks to be used.
// This is defined as a `fileprivate` 'global' variable for performance reasons.
fileprivate var ParserCallbacks: yajl_callbacks = {
  var callbacks = yajl_callbacks()
  
  callbacks.yajl_null = { (context) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.parser(addedValue: .null)
    
    return 1
  }
  
  callbacks.yajl_boolean = { (context, value) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.parser(addedValue: .bool(value != 0))
    
    return 1
  }
  
  callbacks.yajl_integer = { (context, value) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.parser(addedValue: .int(Int(value)))
    
    return 1
  }
  
  callbacks.yajl_double = { (context, value) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.parser(addedValue: .double(value))
    
    return 1
  }
  
  callbacks.yajl_string = { (context, stringValue, len) -> Int32 in
    let delegate = getDelegate(context: context)
    
    let stringData = Data(bytes: stringValue!, count: len)
    let theString = String(data: stringData, encoding: .utf8) ?? ""
    
    delegate?.parser(addedValue: .string(theString))
    
    return 1
  }
  
  callbacks.yajl_start_map = { (context) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.dictionaryStart()
    
    return 1
  }
  
  callbacks.yajl_map_key = { (context, stringBytes, len) -> Int32 in
    let delegate = getDelegate(context: context)
    
    let stringData = Data(bytes: stringBytes!, count: len)
    let theString = String(data: stringData, encoding: .utf8) ?? ""
    
    delegate?.parser(mappedKey: theString)
    
    return 1
  }
  
  callbacks.yajl_end_map = { (context) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.dictionaryEnd()
    
    return 1
  }
  
  callbacks.yajl_start_array = { (context) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.arrayStart()
    
    return 1
  }
  
  callbacks.yajl_end_array = { (context) -> Int32 in
    let delegate = getDelegate(context: context)
    delegate?.arrayEnd()
    
    return 1
  }
  
  return callbacks
}()
