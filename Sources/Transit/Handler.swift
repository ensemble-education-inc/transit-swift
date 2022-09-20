//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/11/22.
//

import Foundation

func transformDocumentWithRegisteredHandlers(value: Any) -> Any {
    guard let array = value as? [Any] else {
        return value
    }
    var context = Context()
    return registeredHandlers.reduce(array, { array, handler in
        handler.transform(value: array, context: &context)
    })
}

public struct Context {
    var keywordCache: [String] = []
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

let registeredHandlers: [Handler] = [SetHandler(), ScalarHandler(), MapHandler()]
