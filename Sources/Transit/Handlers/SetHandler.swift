//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct SetHandler: Handler {
    public func transform(value: Any, context: inout Context) throws -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#set" else {
            return value
        }
        _ = try context.transform(value: array[0])
        return array[1]
    }
}
