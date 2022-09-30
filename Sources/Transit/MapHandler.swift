//
//  DictifyArrays.swift
//  EnsembleUI
//
//  Created by Soroush Khanlou on 8/20/22.
//

import Foundation

struct MapHandler: Handler {
    let objectMarker = "^ "

    func transform(value possibleArray: Any, context: inout Context) throws -> Any {
        guard let array = possibleArray as? [Any] else {
            return possibleArray
        }

        var slice = array[...]

        guard slice.first as? String == objectMarker else {
            for item in array {
                if let stringValue = (item as? String), ["~:", "~#", "~$"].contains(where: stringValue.starts(with:)) {
                    _ = context.insertInCache(stringValue)
                }
            }
            return array
        }

        slice.removeFirst()
        var dict: [String: Any] = [:]
        while let key = slice.popFirst().flatMap({ $0 as? String }), let value = slice.popFirst() {
            let keyToUse = try context.normalize(rawKey: key)
            let valueToInsert = try context.transform(value: value)
            dict[keyToUse] = valueToInsert
        }
        return dict
    }

}
