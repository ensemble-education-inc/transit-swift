//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct ListHandler: Handler {
    public func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#list" else {
            return value
        }
        _ = try context.transform(value: array[0])
        return array[1]
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        return value
    }
}
