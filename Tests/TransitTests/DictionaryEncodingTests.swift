//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 1/22/23.
//

import XCTest
import Transit

final class DictionaryEncodingTests: XCTestCase {

    func testBasic() throws {
        let dict = ["a": 1, "hello": 2]

        let data = try TransitEncoder().encode(dict)
        let decoded = try TransitDecoder().decode([String: Int].self, from: data)

        XCTAssertEqual(decoded, dict)
    }

    func testIntKeys() throws {
        //["^ ","~i1","hey","~i2","hello"]

        let dict = [1: "hey", 2: "hello"]

        let data = try TransitEncoder().encode(dict)

        let option1 = #"["^ ","~i1","hey","~i2","hello"]"#.data(using: .utf8)!
        let option2 = #"["^ ","~i2","hello""~i1","hey",]"#.data(using: .utf8)!
        XCTAssert([option1, option2].contains(data))

        let string = String(decoding: data, as: UTF8.self)
        XCTAssert(string.contains("~i1"))
        XCTAssert(string.contains("~i2"))
        let decoded = try TransitDecoder().decode([Int: String].self, from: data)

        XCTAssertEqual(decoded, dict)
    }
}
