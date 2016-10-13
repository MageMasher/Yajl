//
//  Ref.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/13/16.
//
//


/// A simple wrapper to turn a Value type into a Reference type
class Ref<T> {
  /// The value we are wrapping
  var val: T
  
  /// Basic intializer with value
  init(_ v: T) { self.val = v }
  
  /// Copy initializer
  init(_ other: Ref<T>) { self.val = other.val }

  /// Initialize referencing a value
  init(referencing: T) { self.val = referencing }
}
