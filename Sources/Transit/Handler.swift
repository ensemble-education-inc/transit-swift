//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

import Foundation

func prepareForDecode(value: Any, withRegisteredHandlers registeredHandlers: [Handler]) throws -> Any {

    var context = Context(registeredHandlers: registeredHandlers, transformer: { context, value in try prepareForDecode(value: value, context: &context) })

    return try context.transform(value: value)
}

func prepareForDecode(value: Any, context: inout Context) throws -> Any {
    let value = try context.registeredHandlers.reduce(value, { array, handler in
        try handler.prepareForDecode(value: array, context: &context)
    })

    if let array2 = value as? [Any] {
        return try array2.map({ item in
            return try prepareForDecode(value: item, context: &context)
        })
    } else {
        return value
    }
}

//func prepareForEncode(value: Any, withRegisteredHandlers registeredHandlers: [Handler]) throws -> Any {
//
//    var context = Context(registeredHandlers: registeredHandlers, transformer: { context, value in try prepareForEncode(value: value, context: &context) })
//
//    return try context.transform(value: value)
//}

func prepareForEncode(value: Any, context: inout Context) throws -> Any {
    return try context.registeredHandlers.reduce(value, { array, handler in
        try handler.prepareForEncode(value: array, context: &context)
    })
}

final class RefArray<Element>: RandomAccessCollection {
    var array: [Element] = []

    var startIndex: Int { array.startIndex }
    var endIndex: Int { array.endIndex }
    subscript(index: Int) -> Element { array[index] }
    func index(after i: Int) -> Int { array.index(after: i) }
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
        } else {
            let inserted = self.insertInCache(key)
            let normalized = Keyword(keyword: inserted).encoded
            return normalized
        }
    }

    @discardableResult
    mutating func insertInCache(_ string: String) -> String {
        var keyToUse = string[...]
        if keyToUse.starts(with: "~:") {
            keyToUse.removeFirst(2)
        }
        if keyToUse.starts(with: "~$") {
            keyToUse.removeFirst(2)
        }

        let sanitized = String(keyToUse)
        if keyToUse.count > 1 {
            keywordCache.array.append(sanitized)
        }
        return sanitized
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

