//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/19/22.
//

import Foundation

public struct MillisecondsSince1970Handler: Handler {
    public func transform(value: Any, context: inout Context) -> Any {
        guard let string = value as? String else {
            return value
        }
        guard string.starts(with: "~m") else {
            return value
        }
        guard let double = Double(string.dropFirst(2)) else {
            return value
        }
        return Date(timeIntervalSince1970: double / 1000).timeIntervalSinceReferenceDate
    }
}

public struct ISO8601DateHandler: Handler {

    static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }()

    public func transform(value: Any, context: inout Context) -> Any {
        guard let string = value as? String else {
            return value
        }
        guard string.starts(with: "~t") else {
            return value
        }
        guard let date = Self.iso8601Formatter.date(from: String(string.dropFirst(2))) else {
            return value
        }
        return date.timeIntervalSinceReferenceDate
    }
}
