//
//  DictifyArrays.swift
//  EnsembleUI
//
//  Created by Soroush Khanlou on 8/20/22.
//

import Foundation

struct MapHandler: Handler {
    let objectMarker = "^ "

    func lookupKeyIndex(_ key: String) -> Int? {
        guard key.starts(with: "^") else { return nil }

        var lookupKey = key.dropFirst()
        guard lookupKey.count <= 2 else { return nil }
        if lookupKey.count == 1 {
            lookupKey.insert("0", at: lookupKey.startIndex)
        }
        let index = lookupKey
            .reversed()
            .enumerated()
            .reduce(0, { acc, el in
                acc + (Int(el.element.asciiValue ?? 0) - 48) * Int(pow(Double(44), Double(el.offset)))
            })
        return index
    }

    func transform(value possibleArray: Any, context: inout Context) -> Any {
        guard let array = possibleArray as? [Any] else {
            return possibleArray
        }

        var slice = array[...]

        guard slice.first as? String == objectMarker else {
            return array
        }

        slice.removeFirst()
        var dict: [String: Any] = [:]
        while let key = slice.popFirst().flatMap({ $0 as? String }), let value = slice.popFirst() {
            var keyToUse = key
            if let index = lookupKeyIndex(key) {
                keyToUse = context.keywordCache[Int(index)]
            } else {
                if let keyword = Keyword(encoded: key)?.rawValue {
                    keyToUse = keyword
                }
                if keyToUse.hasSuffix("?") { keyToUse.removeLast() }
                context.insertInCache(keyToUse)
            }
            var valueToInsert = value
            if let nestedArray = value as? [Any] {
                valueToInsert = self.transform(value: nestedArray, context: &context)
            }
            dict[keyToUse] = valueToInsert
        }
        return dict
    }

}
