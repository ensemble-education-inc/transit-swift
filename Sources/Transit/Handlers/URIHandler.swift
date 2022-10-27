//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct URIHandler: Handler {
    public func transform(value: Any, context: inout Context) -> Any {
        guard let string = value as? String else {
            return value
        }
        guard string.starts(with: "~r") else {
            return value
        }
        guard let url = URL(string: String(string.dropFirst(2))) else {
            return value
        }
        return url
    }
}
