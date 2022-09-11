//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/23/22.
//

import Foundation
import Transit
import XCTest

final class HandlerTests: XCTestCase {


    func testSetSimple() throws {
        // set_simple.json
        let data = """
        ["~#set",[1,3,2]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([1,2,3]))
    }

    func testSetEmpty() throws {
        // set_empty.json
        let data = """
        ["~#set",[]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([]))
    }

}
