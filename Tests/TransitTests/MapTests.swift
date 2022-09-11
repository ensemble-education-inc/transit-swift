//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/23/22.
//

import Foundation
import Transit
import XCTest

final class MapTests: XCTestCase {

    func testMap10Nested() throws {
        // map_10_nested.json
        let data = """
        ["^ ","~:f",["^ ","~:key0000",0,"~:key0001",1,"~:key0002",2,"~:key0003",3,"~:key0004",4,"~:key0005",5,"~:key0006",6,"~:key0007",7,"~:key0008",8,"~:key0009",9],"~:s",["^ ","^0",0,"^1",1,"^2",2,"^3",3,"^4",4,"^5",5,"^6",6,"^7",7,"^8",8,"^9",9]]
        """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let f: Inner
            let s: Inner
        }
        struct Inner: Codable {
            let key0000: Int
            let key0001: Int
            let key0002: Int
            let key0003: Int
            let key0004: Int
            let key0005: Int
            let key0006: Int
            let key0007: Int
            let key0008: Int
            let key0009: Int
        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.f.key0000, 0)
        XCTAssertEqual(decoded.f.key0001, 1)
        XCTAssertEqual(decoded.f.key0002, 2)
        XCTAssertEqual(decoded.f.key0003, 3)
        XCTAssertEqual(decoded.f.key0004, 4)
        XCTAssertEqual(decoded.f.key0005, 5)
        XCTAssertEqual(decoded.f.key0006, 6)
        XCTAssertEqual(decoded.f.key0007, 7)
        XCTAssertEqual(decoded.f.key0008, 8)
        XCTAssertEqual(decoded.f.key0009, 9)
        XCTAssertEqual(decoded.s.key0000, 0)
        XCTAssertEqual(decoded.s.key0001, 1)
        XCTAssertEqual(decoded.s.key0002, 2)
        XCTAssertEqual(decoded.s.key0003, 3)
        XCTAssertEqual(decoded.s.key0004, 4)
        XCTAssertEqual(decoded.s.key0005, 5)
        XCTAssertEqual(decoded.s.key0006, 6)
        XCTAssertEqual(decoded.s.key0007, 7)
        XCTAssertEqual(decoded.s.key0008, 8)
        XCTAssertEqual(decoded.s.key0009, 9)

    }

    func testMap10Items() throws {
        // map_10_items.json
        let data = """
        ["^ ","~:key0000",0,"~:key0001",1,"~:key0002",2,"~:key0003",3,"~:key0004",4,"~:key0005",5,"~:key0006",6,"~:key0007",7,"~:key0008",8,"~:key0009",9]
        """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let key0000: Int
            let key0001: Int
            let key0002: Int
            let key0003: Int
            let key0004: Int
            let key0005: Int
            let key0006: Int
            let key0007: Int
            let key0008: Int
            let key0009: Int
        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.key0000, 0)
        XCTAssertEqual(decoded.key0001, 1)
        XCTAssertEqual(decoded.key0002, 2)
        XCTAssertEqual(decoded.key0003, 3)
        XCTAssertEqual(decoded.key0004, 4)
        XCTAssertEqual(decoded.key0005, 5)
        XCTAssertEqual(decoded.key0006, 6)
        XCTAssertEqual(decoded.key0007, 7)
        XCTAssertEqual(decoded.key0008, 8)
        XCTAssertEqual(decoded.key0009, 9)
    }

    func testMapMixed() throws {
        // map_mixed.json
        let data = """
        ["^ ","~:c",true,"~:b","a string","~:a",1]
        """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let c: Bool
            let b: String
            let a: Int
        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.c, true)
        XCTAssertEqual(decoded.b, "a string")
        XCTAssertEqual(decoded.a, 1)
    }

    func testMapNested() throws {
        // map_nested.json
        let data = """
        ["^ ","~:simple",["^ ","~:c",3,"~:b",2,"~:a",1],"~:mixed",["^ ","~:c",true,"~:b","a string","~:a",1]]
        """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let simple: Simple
            let mixed: Mixed
        }

        struct Simple: Codable {
            let c: Int
            let b: Int
            let a: Int
        }

        struct Mixed: Codable {
            let c: Bool
            let b: String
            let a: Int
        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.mixed.c, true)
        XCTAssertEqual(decoded.mixed.b, "a string")
        XCTAssertEqual(decoded.mixed.a, 1)
        XCTAssertEqual(decoded.simple.c, 3)
        XCTAssertEqual(decoded.simple.b, 2)
        XCTAssertEqual(decoded.simple.a, 1)
    }

    func testMapSimple() throws {
        // map_simple.json
        let data = """
            ["^ ","~:c",3,"~:b",2,"~:a",1]
        """
            .data(using: .utf8)!

        struct Simple: Codable {
            let c: Int
            let b: Int
            let a: Int
        }

        let decoded = try TransitDecoder().decode(Simple.self, from: data)

        XCTAssertEqual(decoded.c, 3)
        XCTAssertEqual(decoded.b, 2)
        XCTAssertEqual(decoded.a, 1)
    }

    func testMapsFourCharKeywordKeys() throws {
        // maps_four_char_keyword_keys.json
        let data = """
        [["^ ","~:bbbb",2,"~:aaaa",1],["^ ","^0",4,"^1",3],["^ ","^0",6,"^1",5]]
        """
        .data(using: .utf8)!

        struct FourChar: Codable {
            let bbbb: Int
            let aaaa: Int
        }

        let decoded = try TransitDecoder().decode([FourChar].self, from: data)

        XCTAssertEqual(decoded[0].bbbb, 2)
        XCTAssertEqual(decoded[0].aaaa, 1)
        XCTAssertEqual(decoded[1].bbbb, 4)
        XCTAssertEqual(decoded[1].aaaa, 3)
        XCTAssertEqual(decoded[2].bbbb, 6)
        XCTAssertEqual(decoded[2].aaaa, 5)

    }

}
