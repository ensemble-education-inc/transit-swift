//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

import Foundation

func prepareForDecode(value: Any, context: inout Context) throws -> Any {
    return try context.registeredHandlers.reduce(value, { array, handler in
        try handler.prepareForDecode(value: array, context: &context)
    })
}

func prepareForEncode(value: Any, context: inout Context) throws -> Any {
    return try context.registeredHandlers.reduce(value, { array, handler in
        try handler.prepareForEncode(value: array, context: &context)
    })
}

final class RefArray<Element>: RandomAccessCollection, CustomStringConvertible {
    var array: [Element] = []

    var startIndex: Int { array.startIndex }
    var endIndex: Int { array.endIndex }
    subscript(index: Int) -> Element { array[index] }
    func index(after i: Int) -> Int { array.index(after: i) }

    var description: String {
        array.description
    }
}

public struct Context {
    let registeredHandlers: [Handler]
    var keywordCache: RefArray<String> = .init()
    let transformer: (inout Context, Any) throws -> Any

    mutating func transform(value: Any) throws -> Any {
        return try self.transformer(&self, value)
    }

    mutating func prepareKeyForEncoding(_ key: String) throws -> String {
        if let index = keywordCache.firstIndex(of: key) {
            let lookUpKeyHighBit = index / 44
            let lookUpKeyLowBit = index % 44

            let lookUpKey: String
            if lookUpKeyHighBit == 0 {
                lookUpKey = "\(UnicodeScalar(lookUpKeyLowBit + 48)!)"
            } else {
                lookUpKey = "\(UnicodeScalar(lookUpKeyHighBit + 48)!)\(UnicodeScalar(lookUpKeyLowBit + 48)!)"
            }
            return "^\(lookUpKey)"
        } else if key.starts(with: "^") && Int(key.dropFirst()) != nil {
            // if they key is already cached don't recache it
            return key
        } else {
            return self.insertInCache(key)
        }
    }

    @discardableResult
    mutating func insertInCache(_ string: String) -> String {
        if string.count > 3 {
            keywordCache.array.append(string)
        }
        return string
    }

    func lookupKeyIndex(_ key: String) -> Int? {
        guard key.starts(with: "^") else { return nil }

        var lookupKey = key.dropFirst()
        guard lookupKey.count <= 2 else { return nil }
        if lookupKey.count == 1 {
            lookupKey.insert("0", at: lookupKey.startIndex)
        }
        let index = lookupKey
            .reversed()
            .enumerated()
            .reduce(0, { acc, el in
                acc + (Int(el.element.asciiValue ?? 0) - 48) * Int(pow(Double(44), Double(el.offset)))
            })
        return index
    }

    mutating func normalize(rawKey: String) throws -> String {
        if let index = lookupKeyIndex(rawKey) {
            if index < keywordCache.count {
                return keywordCache[index]
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The cache key '\(rawKey)', index \(index), could not be found."))
            }
        } else {
            return insertInCache(rawKey)
        }
    }

}

public protocol Handler {
    func prepareForDecode(value: Any, context: inout Context) throws -> Any
    func prepareForEncode(value: Any, context: inout Context) throws -> Any
}

