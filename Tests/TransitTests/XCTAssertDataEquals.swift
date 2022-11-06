//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 11/6/22.
//

import Foundation
import XCTest

func XCTAssertDataEquals(_ lhs: Data, _ rhs: Data, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(
        String(decoding: lhs, as: UTF8.self),
        String(decoding: rhs, as: UTF8.self),
        file: file,
        line: line
    )
}
