//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 9/29/22.
//

import Foundation
import Transit
import XCTest

final class KeywordCachingTests: XCTestCase {

    func testDecodingWithTag() throws {

        let data = """
        ["^ ","~:result",["^ ","~:chet-curriculums",["~#list",[["^ ","~:id",43,"~:readable-id","learning-path","~:name","Learning Path","~:display-name",null,"~:order",2,"~:experimental",false],["^ ","^3",76,"^4","featured","^5","Featured","^6",null,"^7",3,"^8",false],["^ ","^3",5,"^4","games-by-topic","^5","Games By Topic","^6",null,"^7",1,"^8",false]]]]]
        """
            .data(using: .utf8)!

        struct Decoded: Codable {
            let result: Result
        }

        struct Result: Codable {
            let curriculums: [Curriculum]

            enum CodingKeys: String, CodingKey {
                case curriculums = "chet-curriculums"
            }
        }

        struct Curriculum: Codable {
            let id: Int
            let readableID: String

            enum CodingKeys: String, CodingKey {
                case id, readableID = "readable-id"
            }

        }

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.curriculums.first?.id, 43)
        XCTAssertEqual(decoded.result.curriculums.first?.readableID, "learning-path")
    }
}
