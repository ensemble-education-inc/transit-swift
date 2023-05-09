//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct SetHandler: Handler {
    public func prepareForDecode(value: Any, context: inout Context) throws -> Any {
        if let array = value as? [Any] {
            guard array.first as? String == "~#set" else {
                return value
            }
            _ = try context.transform(value: array[0])
            return array[1]
        } else if let dict = value as? OrderedDictionary<String, Any> {
            if let list = dict["~#set"] {
                return list
            }
        }
        return value
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        guard let set = value as? Set<AnyHashable> else {
            return value
        }

        var converted: [Any] = []
        for item in set {
            if let encodable = item as? Encodable {
                let encoder = TransitEncoder._TransitEncoder(
                    value: AnyEncodable(base: encodable),
                    codingPath: [],
                    context: context
                )
                try encodable.encode(to: encoder)
                converted.append(encoder.content.value)
            } else {
                converted.append(item)
            }
        }

        return ["~#set", converted]
    }
}

struct AnyEncodable: Encodable {
    let base: Encodable

    func encode(to encoder: Encoder) throws {
        try base.encode(to: encoder)
    }
}
