//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/20/22.
//

import Foundation

public struct URI: Codable {
    public let url: URL
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let url = URL(string: string) else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "URL could not be decoded from string \"\(string)\""))
        }
        self.url = url
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.url.absoluteString)
    }
}
