//
//  ParserOptions.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

import Foundation

extension YajlParser {
  /// Options for Parser
  public struct Options: OptionSet {
    public var rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }

    /// No options (you can also pass `[]`).
    public static let none            = Options(rawValue: 0)
    
    /// Javascript-style comments will be allowed in the input 
    /// (both `/*...*/` and `//...` styles are allowed).
    public static let allowComments   = Options(rawValue: 1 << 0)
    
    /// Invalid UTF8 strings will cause the parser to throw an error.
    public static let validateUTF8    = Options(rawValue: 1 << 1)
    
    /// Will force strict precision on numbers and the parser will throw a 
    /// `ParserError.integerOverflow` if integer overflow is detected. 
    public static let strictPrecision = Options(rawValue: 1 << 2)
  }
}
