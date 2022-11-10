//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 11/9/22.
//

import Foundation

public struct List<Element>: RandomAccessCollection {
    var items: [Element]

    public var startIndex: Int { items.startIndex }
    public var endIndex: Int { items.endIndex }
    public func index(after i: Int) -> Int { items.index(after: i) }
    public subscript(index: Int) -> Element { items[index] }

    public init() {
        self.items = []
    }
}

extension List: Codable where Element: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var items = [Element]()
        while !container.isAtEnd {
            try items.append(container.decode(Element.self))
        }
        self.items = items
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode("~#list")
        try container.encode(items)
    }
}

extension List: Equatable where Element: Equatable { }
