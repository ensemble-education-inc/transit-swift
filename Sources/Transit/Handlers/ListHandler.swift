//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation
import OrderedCollections

public struct ListHandler: Handler {
    public func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        if let array = value as? [Any] {
            guard array.first as? String == "~#list" else {
                return value
            }
            _ = try context.transform(value: array[0])
            return array[1]
        } else if let dict = value as? OrderedDictionary<String, Any> {
            if let list = dict["~#list"] {
                return list
            }
        }
        return value
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        // Lists are not covariant so you can't cast to a List<Any> here
        return value
    }
}
