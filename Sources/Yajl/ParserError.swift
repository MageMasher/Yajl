//
//  ParserError.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//


extension YajlParser {
  /// An error that occurs during JSON parsing.
  public enum ParserError: Swift.Error {
    /// An error occured while allocating the parser
    case alloc
    
    /// An error occured in the CYajl library
    case yajlError(UInt32, String)
  }
}

// MARK: - CustomStringConvertible

extension YajlParser.ParserError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .alloc:           return "An error occured while allocating the Yajl Parser"
    case .yajlError(let code, let message):
      return "An error occured in the yajl library: (\(code)) -- \(message)"
    }
  }
}
