//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 5/9/23.
//

import Foundation
import OrderedCollections

struct VerboseDictHandler: Handler {
    func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        guard let dict = value as? [String: Any] else {
            return value
        }

        return OrderedDictionary(uniqueKeysWithValues: dict)
    }

    func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        return value
    }
}
