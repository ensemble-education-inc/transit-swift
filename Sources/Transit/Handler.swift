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
    return registeredHandlers.reduce(array, { array, handler in
        handler.transform(value: array)
    })
}

public protocol Handler {
    func transform(value: Any) -> Any
}

public struct SetHandler: Handler {
    public func transform(value: Any) -> Any {
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
    public func transform(value: Any) -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#'" else {
            return value
        }
        return array[1]
    }
}

let registeredHandlers: [Handler] = [SetHandler(), ScalarHandler()]
