//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct ScalarHandler: Handler {
    public func prepareForDecode(value: Any, context: inout Context) -> Any {
        guard let array = value as? [Any] else {
            return value
        }
        guard array.first as? String == "~#'" else {
            return value
        }
        return array[1]
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        return value
    }
}
