//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

import Foundation

func transformDocument(value: Any, withRegisteredHandlers registeredHandlers: [Handler]) -> Any {

    var context = Context(registeredHandlers: registeredHandlers)

    return transform(value: value, context: &context)
}

func transform(value: Any, context: inout Context) -> Any {
    guard let array = value as? [Any] else {
        return value
    }

    let value = context.registeredHandlers.reduce(array, { array, handler in
        handler.transform(value: array, context: &context)
    })


    if let array2 = value as? [Any] {
        return array2.map({ item in
            return transform(value: item, context: &context)
        })
    } else {
        return value
    }
}

public struct Context {
    let registeredHandlers: [Handler]
    var keywordCache: [String] = []

    mutating func insertInCache(_ string: String) -> String {
        var keyToUse = string[...]
        if keyToUse.starts(with: "~:") {
            keyToUse.removeFirst(2)
        }
        if keyToUse.hasSuffix("?") {
            keyToUse.removeLast()
        }

        let sanitized = String(keyToUse)
        if keyToUse.count > 1 {
            keywordCache.append(sanitized)
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

    mutating func normalize(rawKey: String) -> String {
        if let index = lookupKeyIndex(rawKey) {
            return keywordCache[Int(index)]
        } else {
            return insertInCache(rawKey)
        }
    }

}

public protocol Handler {
    func transform(value: Any, context: inout Context) -> Any
}

