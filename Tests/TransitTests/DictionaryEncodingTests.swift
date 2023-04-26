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
        let option2 = #"["^ ","~i2","hello","~i1","hey"]"#.data(using: .utf8)!
        XCTAssert([option1, option2].contains(data))

        let string = String(decoding: data, as: UTF8.self)
        XCTAssert(string.contains("~i1"))
        XCTAssert(string.contains("~i2"))
        let decoded = try TransitDecoder().decode([Int: String].self, from: data)

        XCTAssertEqual(decoded, dict)
    }

    func testThatIntKeysAreCachedWhenLongEnough() throws {
        struct Wrapper: Codable, Equatable {
            let chetQuestions: Empty
            let chetQuestionTagTies: Dictionary<Int, TagTie>

            enum CodingKeys: String, CodingKey {
                case chetQuestions = "chet-questions"
                case chetQuestionTagTies = "chet-question-tag-ties"
            }

            struct TagTie: Codable, Equatable {
                let id: Int
                let tagID: Int
                let questionID: Int

                enum CodingKeys: String, CodingKey {
                    case id = "id"
                    case tagID = "tag-id"
                    case questionID = "question-id"
                }
            }

            struct Empty: Codable, Equatable {

            }
        }

        let expected = """
            ["^ ","~:chet-questions",["^ "],"~:chet-question-tag-ties",["^ ","~i-1",["^ ","~:question-id",26867,"~:tag-id",49,"~:id",-1],"~i-2",["^ ","^3",26867,"^4",66,"^5",-2]]]
         """
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Wrapper.self, from: expected)

        XCTAssertEqual(decoded.chetQuestions, Wrapper.Empty())
        XCTAssertEqual(decoded.chetQuestionTagTies.count, 2)
        XCTAssertEqual(decoded.chetQuestionTagTies[-1]?.id, -1)
        XCTAssertEqual(decoded.chetQuestionTagTies[-1]?.questionID, 26867)
        XCTAssertEqual(decoded.chetQuestionTagTies[-1]?.tagID, 49)
        XCTAssertEqual(decoded.chetQuestionTagTies[-2]?.id, -2)
        XCTAssertEqual(decoded.chetQuestionTagTies[-2]?.questionID, 26867)
        XCTAssertEqual(decoded.chetQuestionTagTies[-2]?.tagID, 66)
        let encoded = try TransitEncoder().encode(decoded)

        print(String(decoding: encoded, as: UTF8.self))
        let decodedAgain = try TransitDecoder().decode(Wrapper.self, from: encoded)
        XCTAssertEqual(decodedAgain.chetQuestions, Wrapper.Empty())
        XCTAssertEqual(decodedAgain.chetQuestionTagTies.count, 2)
        XCTAssertEqual(decodedAgain.chetQuestionTagTies[-1]?.id, -1)
        XCTAssertEqual(decodedAgain.chetQuestionTagTies[-1]?.questionID, 26867)
        XCTAssertEqual(decodedAgain.chetQuestionTagTies[-1]?.tagID, 49)
        XCTAssertEqual(decodedAgain.chetQuestionTagTies[-2]?.id, -2)
        XCTAssertEqual(decodedAgain.chetQuestionTagTies[-2]?.questionID, 26867)
        XCTAssertEqual(decodedAgain.chetQuestionTagTies[-2]?.tagID, 66)

    }
}
