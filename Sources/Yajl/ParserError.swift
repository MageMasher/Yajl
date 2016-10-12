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
    
    /// Double overflow has been detected
    case doubleOverflow
    
    /// Integer overflow has been detected
    case integerOverflow

    /// An error occured in the CYajl library
    case yajlError(UInt32, String)
  }
}

// MARK: - CustomStringConvertible

extension YajlParser.ParserError: CustomStringConvertible {
  public var description: String {
    switch self {
    case .alloc:           return "An error occured while allocating the Yajl Parser"
    case .doubleOverflow:  return "Double overflow was detected."
    case .integerOverflow: return "Integer overflow was detected."
    case .yajlError(let code, let message):
      return "An error occured in the yajl library: (\(code)) -- \(message)"
    }
  }
}
