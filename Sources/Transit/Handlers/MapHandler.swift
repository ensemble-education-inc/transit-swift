//
//  DictifyArrays.swift
//  EnsembleUI
//
//  Created by Soroush Khanlou on 8/20/22.
//

import Foundation
import OrderedCollections

struct CachingHandler: Handler {
    func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        guard let stringValue = (value as? String) else {
            return value
        }
        if ["~:", "~#", "~$", "~i"].contains(where: stringValue.starts(with:)) {
            _ = context.insertInCache(stringValue)
        }
        if stringValue.starts(with: "^") {
            return try context.normalize(rawKey: stringValue)
        }
        return stringValue
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        guard let stringValue = (value as? String) else {
            return value
        }
        if ["~:", "~#", "~$", "~i"].contains(where: stringValue.starts(with:)) {
            return try context.prepareKeyForEncoding(stringValue)
        }
        return value
    }
}

struct MapHandler: Handler {
    let objectMarker = "^ "

    func prepareForDecode(value possibleArray: Any, context: inout Context) throws -> Any {
        guard let array = possibleArray as? [Any] else {
            return possibleArray
        }

        var slice = array[...]

        guard slice.first as? String == objectMarker else {
            return array
        }

        slice.removeFirst()
        var dict: OrderedDictionary<String, Any> = [:]
        while let key = slice.popFirst().flatMap({ $0 as? String }), let value = slice.popFirst() {
            let keyToUse = try context.normalize(rawKey: key)
            let valueToInsert = try context.transform(value: value)
            dict[keyToUse] = valueToInsert
        }
        return dict
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        guard let dict = value as? OrderedDictionary<String, Any> else {
            return value
        }

        return ["^ "] + dict.flatMap({ [$0, $1] })
    }
}
