//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/22/22.
//

import Foundation

public struct Keyword: Equatable, Hashable {
    public let rawValue: String

    public init?(encoded: String) {
        if encoded.starts(with: "~:") {
            self.rawValue = String(encoded.dropFirst(2))
        } else {
            return nil
        }
    }

    public init(keyword: String) {
        self.rawValue = keyword
    }

    public var encoded: String {
        "~:\(rawValue)"
    }
}

extension Keyword: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = Self(encoded: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Keyword did not start with `~:`.")
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(encoded)
    }
}
