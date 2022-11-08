//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 11/7/22.
//

import Foundation

protocol BuiltInType {
    static var isScalar: Bool { get }
}

extension BuiltInType {
    var isScalar: Bool {
        Self.isScalar
    }
}

extension Date: BuiltInType {
    static var isScalar: Bool { true }
}

extension String: BuiltInType {
    static var isScalar: Bool { true }
}

extension Int: BuiltInType {
    static var isScalar: Bool { true }
}

extension Bool: BuiltInType {
    static var isScalar: Bool { true }
}

extension UUID: BuiltInType {
    static var isScalar: Bool { true }
}

extension URL: BuiltInType {
    static var isScalar: Bool { true }
}

extension Set: BuiltInType {
    static var isScalar: Bool { false }
}

extension Optional: BuiltInType where Wrapped: BuiltInType {
    static var isScalar: Bool {
        Wrapped.isScalar
    }
}
