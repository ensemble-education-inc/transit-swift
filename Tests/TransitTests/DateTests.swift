//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/23/22.
//

import Foundation
import Transit
import XCTest

final class DateTests: XCTestCase {

    struct Result: Codable {
        let date: Date
    }

    func testSimpleMillisecondsSince1970DateCompact() throws {

        // date_in_map.json
        let data = #"["^ ","~:date","~m946728000000"]"#
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.date, Date(timeIntervalSince1970: 946728000))

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)

    }

    func testSimpleMillisecondsSince1970DateVerbose() throws {

        // date_in_map.json
        let data = #"{"~:date":"~m946728000000"}"#
            .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(decoded.date, Date(timeIntervalSince1970: 946728000))

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testSimpleISO8601DateCompact() throws {
        // dates_interesting.verbose.json
        let data = """
            ["~t1776-07-04T12:00:00.000Z","~t1970-01-01T00:00:00.000Z","~t2000-01-01T12:00:00.000Z","~t2014-04-07T22:17:17.000Z"]
        """
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([Date].self, from: data)

        XCTAssertEqual(decoded[0], Date(timeIntervalSince1970: -6106017600))
        XCTAssertEqual(decoded[1], Date(timeIntervalSince1970: 0))
        XCTAssertEqual(decoded[2], Date(timeIntervalSince1970: 946728000))
    }
    
    func testSimpleISO8601DateVerbose() throws {

        // dates_interesting.verbose.json
        let data = """
            ["~t1776-07-04T12:00:00.000Z","~t1970-01-01T00:00:00.000Z","~t2000-01-01T12:00:00.000Z","~t2014-04-07T22:17:17.000Z"]
        """
            .data(using: .utf8)!


        let decoded = try TransitDecoder(mode: .verbose).decode([Date].self, from: data)

        XCTAssertEqual(decoded[0], Date(timeIntervalSince1970: -6106017600))
        XCTAssertEqual(decoded[1], Date(timeIntervalSince1970: 0))
        XCTAssertEqual(decoded[2], Date(timeIntervalSince1970: 946728000))
    }

    func testSingleDateCompact() throws {
        // one_date.json
        let data = #"["~#'","~m946728000000"]"#
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Date.self, from: data)

        XCTAssertEqual(decoded, Date(timeIntervalSince1970: 946728000))

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testSingleDateVerbose() throws {
        // one_date.json
        let data = #"{"~#'":"~m946728000000"}"#
            .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Date.self, from: data)

        XCTAssertEqual(decoded, Date(timeIntervalSince1970: 946728000))

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)

    }
}
