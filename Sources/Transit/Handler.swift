//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

import Foundation

func transformDocumentWithRegisteredHandlers(value: Any) -> Any {

    var context = Context()

    return transform(value: value, context: &context)
}

func transform(value: Any, context: inout Context) -> Any {
    guard let array = value as? [Any] else {
        return value
    }

    for item in array {
        if let stringValue = (item as? String), stringValue.starts(with: "~:") {
            let keyToUse = String(stringValue.dropFirst(2))
            context.insertInCache(keyToUse)
        }
    }

    let value = registeredHandlers.reduce(array, { array, handler in
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
            print("caching \(keyToUse) at \(keywordCache.count)")
            keywordCache.append(sanitized)
        }
        return sanitized
    }

}

public protocol Handler {
    func transform(value: Any, context: inout Context) -> Any
}

public struct SetHandler: Handler {
    public func transform(value: Any, context: inout Context) -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#set" else {
            return value
        }
        return array[1]
    }
}

public struct ScalarHandler: Handler {
    public func transform(value: Any, context: inout Context) -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#'" else {
            return value
        }
        return array[1]
    }
}

let registeredHandlers: [Handler] = [MapHandler(), SetHandler(), ScalarHandler()]
