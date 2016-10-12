//
//  GeneratorOptions.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/12/16.
//
//

import Foundation

extension YajlGenerator {
  /// Options for generating JSON
  public struct Options: OptionSet {
    public var rawValue: UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// No options (default)
    public static let none = Options(rawValue: 0)
    
    /// Generate pretty-printed (beautified) output
    public static let beautify = Options(rawValue: 1 << 0)
    
    /// Validate UTF8 strings
    public static let validateUTF8 = Options(rawValue: 1 << 1)
    
    /// the forward solidus (slash or '/' in human) is not required to be escaped in json text. 
    /// By default, YAJL will not escape it in the iterest of saving bytes. 
    /// Setting this flag will cause YAJL to always escape '/' in generated JSON strings.
    public static let escapeForwardSlash = Options(rawValue: 1 << 2)
  }
}
