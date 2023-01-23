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

        let string = """
            ["^ ","~:a",1,"~:hello",2]
            """
        XCTAssertDataEquals(data, Data(string.utf8))
    }
}
