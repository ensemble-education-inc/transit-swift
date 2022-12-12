//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct ArrayHandler: Handler {
    public func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        guard let array = value as? [Any] else {
            return value
        }

        return try array.map({ item in
            return try context.transform(value: item)
        })
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        guard let array = value as? [Any] else {
            return value
        }

        return try array.map({ item in
            return try context.transform(value: item)
        })
    }
}
