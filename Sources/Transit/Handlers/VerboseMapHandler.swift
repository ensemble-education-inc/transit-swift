//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 5/9/23.
//

import Foundation
import OrderedCollections

struct VerboseMapHandler: Handler {
    func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        guard let dict = value as? [String: Any] else {
            return value
        }

        var dictToReturn: OrderedDictionary<String, Any> = [:]
        for (key, value) in dict {
            let keyToUse = try context.normalize(rawKey: key)
            let valueToInsert = try context.transform(value: value)
            dictToReturn[keyToUse] = valueToInsert
        }
        return dictToReturn
    }

    func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        return value
    }
}
