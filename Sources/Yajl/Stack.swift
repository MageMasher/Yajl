//
//  Stack.swift
//  Yajl
//
//  Created by Morgan Lieberthal on 10/13/16.
//
//

struct Stack<ElementType> {
  // MARK: - Properties

  var _items = [ElementType]()

  var count: Int {
    return _items.count
  }

  var last: ElementType? {
    return _items.last
  }

  // MARK: - Methods
  
  mutating func push(_ item: ElementType) {
    _items.append(item)
  }

  @discardableResult
  mutating func pop() -> ElementType {
    return _items.removeLast()
  }

  mutating func reserveCapacity(_ capacity: Int) {
    self._items.reserveCapacity(capacity)
  }
}
