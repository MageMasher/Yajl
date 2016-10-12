//
//  ParserStatus.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/11/16.
//
//

extension YajlParser {
  /// The status of the parser
  public struct ParserStatus {
    /// Represents the state of the Yajl parser.
    public enum State {
      /// The parser's initial status.
      case initial
      /// The parser has completed, and everything went well.
      case complete
      /// The parser encountered an error.
      case error
    }
    
    /// The state of the parser
    public internal(set) var state: State = .initial
    
    /// An optional error, if one occured
    public internal(set) var error: ParserError? = nil {
      didSet {
        if let _ = error {
          self.state = .error
        } 
      }
    }

    /// Default initializer
    init() {}
  }
}
