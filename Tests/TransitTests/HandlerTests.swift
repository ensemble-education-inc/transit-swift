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

    func testSetInMap() throws {
        let data = """
        ["^ ","~:a_set",["~#set",[1,3,2]],"~:an_int",14]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_set: Set<Int>
            let an_int: Int
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.a_set, Set([1, 2, 3]))
        XCTAssertEqual(decoded.an_int, 14)
    }

    func testListSimple() throws {
        // set_simple.json
        let data = """
        ["~#list",[1,3,2]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([Int].self, from: data)

        XCTAssertEqual(decoded, [1,3,2])
    }

    func testListEmpty() throws {
        // list_empty.json
        let data = """
        ["~#list",[]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([Int].self, from: data)

        XCTAssertEqual(decoded, [])
    }

    func testListInMap() throws {
        let data = """
        ["^ ","~:a_list",["~#list",[1,3,2]],"~:an_int",14]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_list: [Int]
            let an_int: Int
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.a_list, [1, 3, 2])
        XCTAssertEqual(decoded.an_int, 14)
    }

    func testURIMap() throws {
        // uri_map.json
        let data = """
        ["^ ", "~:uri", "~rhttp://example.com"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.詹姆斯.com/"

        struct Result: Codable {
            let uri: URI
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.uri.url, URL(string: "http://example.com"))
    }

    func testURIs() throws {
        // uris.json
        let data = """
        ["~rhttp://example.com","~rftp://example.com","~rfile:///path/to/file.txt"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.詹姆斯.com/"

        let decoded = try TransitDecoder().decode([URI].self, from: data)

        let expectedURLs = [
            URL(string: "http://example.com"),
            URL(string: "ftp://example.com"),
            URL(string: "file:///path/to/file.txt"),
//            URL(string: "http://www.詹姆斯.com/"),
        ].compactMap({ $0 })

        XCTAssertEqual(decoded[0].url, expectedURLs[0])
        XCTAssertEqual(decoded[1].url, expectedURLs[1])
        XCTAssertEqual(decoded[2].url, expectedURLs[2])
    }


}
