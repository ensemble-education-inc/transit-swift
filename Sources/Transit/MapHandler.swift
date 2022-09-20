//
//  DictifyArrays.swift
//  EnsembleUI
//
//  Created by Soroush Khanlou on 8/20/22.
//

import Foundation

struct MapHandler: Handler {
    let objectMarker = "^ "

    func transform(value possibleArray: Any, context: inout Context) -> Any {
        guard let array = possibleArray as? [Any] else {
            return possibleArray
        }

        var slice = array[...]

        guard slice.first as? String == objectMarker else {
            for item in array {
                if let stringValue = (item as? String), stringValue.starts(with: "~:") {
                    _ = context.insertInCache(stringValue)
                }
            }
            return array
        }

        slice.removeFirst()
        var dict: [String: Any] = [:]
        while let key = slice.popFirst().flatMap({ $0 as? String }), let value = slice.popFirst() {
            let keyToUse = context.normalize(rawKey: key)
            var valueToInsert = value
            if let nestedArray = value as? [Any] {
                valueToInsert = Transit.transform(value: nestedArray, context: &context)
            }
            dict[keyToUse] = valueToInsert
        }
        return dict
    }

}
