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

    /// By default, upon calls to yajl_complete_parse(), yajl will ensure the 
    /// entire input text was consumed and will raise an error otherwise. 
    ///
    /// Enabling this flag will cause yajl to disable this check. This can be 
    /// useful when parsing json out of a that contains more than a single JSON
    /// document.
    public static let allowTrailing   = Options(rawValue: 1 << 2)

    /// Allow multiple values to be parsed by a single handle. The entire text
    /// must be valid JSON, and values can be seperated by any kind of
    /// whitespace.
    ///
    /// This flag will change the behavior of the parser, and cause it continue 
    /// parsing after a value is parsed, rather than transitioning into a
    /// complete state. This option can be useful when parsing multiple values
    /// from an input stream.
    public static let allowMultiple   = Options(rawValue: 1 << 3)

    /// When yajl_complete_parse() is called the parser will check that the top 
    /// level value was completely consumed. I.E., if called whilst in the middle 
    /// of parsing a value yajl will enter an error state (premature EOF). 
    ///
    /// Setting this flag suppresses that check and the corresponding error.
    public static let allowPartial    = Options(rawValue: 1 << 4)
  }
}
