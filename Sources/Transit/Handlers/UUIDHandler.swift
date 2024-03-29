//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct UUIDHandler: Handler {
    public func prepareForDecode(value: Any, context: inout Context) -> Any {
        guard let string = value as? String else {
            return value
        }
        guard string.starts(with: "~u") else {
            return value
        }
        guard let uuid = UUID(uuidString: String(string.dropFirst(2))) else {
            return value
        }
        return uuid
    }

    public func prepareForEncode(value: Any, context: inout Context) throws -> Any {
        guard let uuid = value as? UUID else {
            return value
        }
        return "~u\(uuid)"
    }
}
