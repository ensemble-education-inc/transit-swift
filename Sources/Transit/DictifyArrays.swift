//
//  DictifyArrays.swift
//  EnsembleUI
//
//  Created by Soroush Khanlou on 8/20/22.
//

import Foundation

private let objectMarker = "^ "

func dictifyArrays(_ possibleArray: Any) -> Any {
    var keywords: [String] = []
    return dictifyArrays(possibleArray, keywordCache: &keywords)
}

func dictifyArrays(_ possibleArray: Any, keywordCache: inout [String]) -> Any {
    guard let array = possibleArray as? [Any] else {
        return possibleArray
    }
    var slice = array[...]
    guard slice.first as? String == objectMarker else {
        for item in slice {
            if let stringValue = (item as? String), stringValue.starts(with: "~:") {
                keywordCache.append(String(stringValue.dropFirst(2)))
            }
        }
        return possibleArray
    }

    slice.removeFirst()

    var dict: [String: Any] = [:]
    while let key = slice.popFirst().flatMap({ $0 as? String }), let value = slice.popFirst() {
        var keyToUse = key
        if key.starts(with: "^") {
            var lookupKey = key.dropFirst()
            if lookupKey.count <= 2 {
                if lookupKey.count == 1 {
                    lookupKey.insert("0", at: lookupKey.startIndex)
                }
                let index = lookupKey
                    .reversed()
                    .enumerated()
                    .reduce(0, { acc, el in
                        acc + (Int(el.element.asciiValue ?? 0) - 48) * Int(pow(Double(44), Double(el.offset)))
                    })
                keyToUse = keywordCache[Int(index)]
            }
        } else {
            if let keyword = Keyword(encoded: key)?.rawValue {
                keyToUse = keyword
            }
            if keyToUse.hasSuffix("?") { keyToUse.removeLast() }
            keywordCache.append(keyToUse)
        }
        var valueToInsert = value
        if let nestedArray = value as? [Any] {
            valueToInsert = dictifyArrays(nestedArray, keywordCache: &keywordCache)
        }
        dict[keyToUse] = valueToInsert
    }

    return dict
}
