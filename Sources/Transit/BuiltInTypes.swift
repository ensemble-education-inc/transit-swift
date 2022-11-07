//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 11/7/22.
//

import Foundation

protocol BuiltInType {
    var isScalar: Bool { get }
}

extension Date: BuiltInType {
    var isScalar: Bool { true }
}

extension String: BuiltInType {
    var isScalar: Bool { true }
}

extension UUID: BuiltInType {
    var isScalar: Bool { true }
}

extension Set: BuiltInType {
    var isScalar: Bool { false }
}
