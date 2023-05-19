//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/23/22.
//

import Foundation
import Transit
import XCTest

final class ScalarTests: XCTestCase {

    func testFalseScalarCompact() throws {
        // false.json
        let data = """
        ["~#'",false]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Bool.self, from: data)

        XCTAssertEqual(decoded, false)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testFalseScalarVerbose() throws {
        // false.json
        let data = """
        {"~#'":false}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Bool.self, from: data)

        XCTAssertEqual(decoded, false)

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testOneScalarCompact() throws {
        // one.json
        let data = """
        ["~#'",1]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Int.self, from: data)

        XCTAssertEqual(decoded, 1)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testOneScalarVerbose() throws {
        // one.json
        let data = """
        {"~#'":1}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Int.self, from: data)

        XCTAssertEqual(decoded, 1)

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testNullScalarCompact() throws {
        // nil.json
        let data = """
        ["~#'",null]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Int?.self, from: data)

        XCTAssertEqual(decoded, nil)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testNullScalarVerbose() throws {
        // nil.json
        let data = """
        {"~#'":null}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Int?.self, from: data)

        XCTAssertEqual(decoded, nil)

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }
}
