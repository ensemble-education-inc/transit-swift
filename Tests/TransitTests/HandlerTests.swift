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

    func testSetSimpleCompact() throws {
        // set_simple.json
        let data = """
        ["~#set",[1,3,2]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([1,2,3]))

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssert(String(decoding: encoded, as: UTF8.self).contains("~#set"))

        // redecode because the set items' order may be different than what we expect
        let redecoded = try TransitDecoder().decode(Set<Int>.self, from: encoded)

        XCTAssertEqual(redecoded, Set([1,2,3]))
    }

    func testSetSimpleVerbose() throws {
        // set_simple.json
        let data = """
        {"~#set":[1,3,2]}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([1,2,3]))

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssert(String(decoding: encoded, as: UTF8.self).contains("~#set"))

        // redecode because the set items' order may be different than what we expect
        let redecoded = try TransitDecoder(mode: .verbose).decode(Set<Int>.self, from: encoded)

        XCTAssertEqual(redecoded, Set([1,2,3]))
    }

    func testSetWithNestedCodableTypeCompact() throws {
        // set_simple.json
        let data = """
        ["~#set",[1,3,2]]
        """
        .data(using: .utf8)!

        struct IntWrapper: Codable, Hashable {
            let int: Int

            init(int: Int) {
                self.int = int
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(self.int)
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.int = try container.decode(Int.self)
            }
        }

        let decoded = try TransitDecoder().decode(Set<IntWrapper>.self, from: data)

        XCTAssertEqual(decoded, Set([.init(int: 1), .init(int: 2), .init(int: 3)]))

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssert(String(decoding: encoded, as: UTF8.self).contains("~#set"))

        // redecode because the set items' order may be different than what we expect
        let redecoded = try TransitDecoder().decode(Set<IntWrapper>.self, from: encoded)

        XCTAssertEqual(redecoded, Set([.init(int: 1), .init(int: 2), .init(int: 3)]))
    }

    func testSetWithNestedCodableTypeVerbose() throws {
        // set_simple.json
        let data = """
        {"~#set":[1,3,2]}
        """
        .data(using: .utf8)!

        struct IntWrapper: Codable, Hashable {
            let int: Int

            init(int: Int) {
                self.int = int
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(self.int)
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.int = try container.decode(Int.self)
            }
        }

        let decoded = try TransitDecoder(mode: .verbose).decode(Set<IntWrapper>.self, from: data)

        XCTAssertEqual(decoded, Set([.init(int: 1), .init(int: 2), .init(int: 3)]))

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssert(String(decoding: encoded, as: UTF8.self).contains("~#set"))

        // redecode because the set items' order may be different than what we expect
        let redecoded = try TransitDecoder(mode: .verbose).decode(Set<IntWrapper>.self, from: encoded)

        XCTAssertEqual(redecoded, Set([.init(int: 1), .init(int: 2), .init(int: 3)]))
    }

    func testSetEmptyCompact() throws {
        // set_empty.json
        let data = """
        ["~#set",[]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([]))

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testSetEmptyVerbose() throws {
        // set_empty.json
        let data = """
        {"~#set":[]}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([]))

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testSetInMapCompact() throws {
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

    func testSetInMapVerbose() throws {
        let data = """
        {"~:a_set":{"~#set":[1,3,2]},"~:an_int":14}
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_set: Set<Int>
            let an_int: Int
        }
        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(decoded.a_set, Set([1, 2, 3]))
        XCTAssertEqual(decoded.an_int, 14)
    }

    func testSetWithDatesCompact() throws {
        let data = """
        ["~#set",["~m946728000000", "~t1776-07-04T12:00:00.000Z"]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Date>.self, from: data)

        XCTAssertEqual(decoded, Set([Date(timeIntervalSince1970: -6106017600), Date(timeIntervalSince1970: 946728000)]))
    }

    func testSetWithDatesVerbose() throws {
        let data = """
        {"~#set":["~m946728000000", "~t1776-07-04T12:00:00.000Z"]}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Set<Date>.self, from: data)

        XCTAssertEqual(decoded, Set([Date(timeIntervalSince1970: -6106017600), Date(timeIntervalSince1970: 946728000)]))
    }

    func testListSimpleCompact() throws {
        // set_simple.json
        let data = """
        ["~#list",[1,3,2]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(List<Int>.self, from: data)

        XCTAssertEqual(Array(decoded), [1,3,2])

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListSimpleVerbose() throws {
        // set_simple.json
        let data = """
        {"~#list":[1,3,2]}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(List<Int>.self, from: data)

        XCTAssertEqual(Array(decoded), [1,3,2])

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListEmptyCompact() throws {
        // list_empty.json
        let data = """
        ["~#list",[]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(List<Int>.self, from: data)

        XCTAssertEqual(decoded, .init())

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListEmptyVerbose() throws {
        // list_empty.json
        let data = """
        {"~#list":[]}
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(List<Int>.self, from: data)

        XCTAssertEqual(decoded, .init())

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListKeywordInsertedTwiceCompact() throws {
        // list_empty.json
        let data = """
        ["~#list",[["^ ","~:aaaa",["^0",[["^ ","~:cccc",2]]],"~:bbbb",["^0",[["^ ","^3",5]]]]]]
        """
        .data(using: .utf8)!

        struct Item: Codable {
            let cccc: Int?
            let bbbb: Int?
        }

        struct Content: Codable {
            let aaaa: List<Item>
            let bbbb: List<Item>
        }

        let decoded = try TransitDecoder().decode(List<Content>.self, from: data)

        XCTAssertEqual(decoded.first?.aaaa.first?.cccc, 2)
        XCTAssertEqual(decoded.first?.bbbb.first?.bbbb, 5)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListKeywordInsertedTwiceVerbose() throws {
        // list_empty.json
        let data = """
        {"~#list":[{"~:aaaa":{"~#list":[{"~:cccc":2}]},"~:bbbb":{"~#list":[{"~:bbbb":5}]}}]}
        """
        .data(using: .utf8)!

        struct Item: Codable {
            let cccc: Int?
            let bbbb: Int?
        }

        struct Content: Codable {
            let aaaa: List<Item>
            let bbbb: List<Item>
        }

        let decoded = try TransitDecoder(mode: .verbose).decode(List<Content>.self, from: data)

        XCTAssertEqual(decoded.first?.aaaa.first?.cccc, 2)
        XCTAssertEqual(decoded.first?.bbbb.first?.bbbb, 5)

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testTwoListsCompact() throws {
        let data = """
        ["^ ","~:aaaa",["~#list",[1,2]],"~:bbbb",["^1",[3]]]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let aaaa: List<Int>
            let bbbb: List<Int>
        }

        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.aaaa), [1, 2])
        XCTAssertEqual(Array(decoded.bbbb), [3])

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testTwoListsVerbose() throws {
        let data = """
        {"~:aaaa":{"~#list":[1,2]},"~:bbbb":{"~#list":[3]}}
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let aaaa: List<Int>
            let bbbb: List<Int>
        }

        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.aaaa), [1, 2])
        XCTAssertEqual(Array(decoded.bbbb), [3])

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListsWithKeywordsCompact() throws {
        // list_empty.json
        let data = """
        ["^ ","~:aaaa",["~#list",["~:alpha","~:beta"]],"~:bbbb",["^1",["^2","^2","~:delta","^3"]]]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let aaaa: List<String>
            let bbbb: List<String>
        }

        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.aaaa), ["~:alpha", "~:beta"])
        XCTAssertEqual(Array(decoded.bbbb), ["~:alpha", "~:alpha", "~:delta", "~:beta"])

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListsWithKeywordsVerbose() throws {
        // list_empty.json
        let data = """
        {"~:aaaa":{"~#list":["~:alpha","~:beta"]},"~:bbbb":{"~#list":["~:alpha","~:alpha","~:delta","~:beta"]}}
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let aaaa: List<String>
            let bbbb: List<String>
        }

        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.aaaa), ["~:alpha", "~:beta"])
        XCTAssertEqual(Array(decoded.bbbb), ["~:alpha", "~:alpha", "~:delta", "~:beta"])

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListInMapCompact() throws {
        let data = """
        ["^ ","~:a_list",["~#list",[1,3,2]],"~:an_int",14]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_list: List<Int>
            let an_int: Int
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.a_list), [1, 3, 2])
        XCTAssertEqual(decoded.an_int, 14)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testListInMapVerbose() throws {
        let data = """
        {"~:a_list":{"~#list":[1,3,2]},"~:an_int":14}
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_list: List<Int>
            let an_int: Int
        }
        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(Array(decoded.a_list), [1, 3, 2])
        XCTAssertEqual(decoded.an_int, 14)

        let encoded = try TransitEncoder(mode: .verbose, outputFormatting: .sortedKeys).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testURIMapCompact() throws {
        // uri_map.json
        let data = """
        ["^ ","~:uri","~rhttp://example.com"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.詹姆斯.com/"

        struct Result: Codable {
            let uri: URL
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.uri, URL(string: "http://example.com"))

        let encoded = try TransitEncoder(outputFormatting: .withoutEscapingSlashes).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testURIMapVerbose() throws {
        // uri_map.json
        let data = """
        {"~:uri":"~rhttp://example.com"}
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.詹姆斯.com/"

        struct Result: Codable {
            let uri: URL
        }
        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(decoded.uri, URL(string: "http://example.com"))

        let encoded = try TransitEncoder(mode: .verbose, outputFormatting: .withoutEscapingSlashes).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testURIsCompact() throws {
        // uris.json
        let data = """
        ["~rhttp://example.com","~rftp://example.com","~rfile:///path/to/file.txt"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.詹姆斯.com/"

        let decoded = try TransitDecoder().decode([URL].self, from: data)

        let expectedURLs = [
            URL(string: "http://example.com"),
            URL(string: "ftp://example.com"),
            URL(string: "file:///path/to/file.txt"),
//            URL(string: "http://www.詹姆斯.com/"),
        ].compactMap({ $0 })

        XCTAssertEqual(decoded[0], expectedURLs[0])
        XCTAssertEqual(decoded[1], expectedURLs[1])
        XCTAssertEqual(decoded[2], expectedURLs[2])

        let encoded = try TransitEncoder(outputFormatting: .withoutEscapingSlashes).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testURIsVerbose() throws {
        // uris.json
        let data = """
        ["~rhttp://example.com","~rftp://example.com","~rfile:///path/to/file.txt"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.詹姆斯.com/"

        let decoded = try TransitDecoder(mode: .verbose).decode([URL].self, from: data)

        let expectedURLs = [
            URL(string: "http://example.com"),
            URL(string: "ftp://example.com"),
            URL(string: "file:///path/to/file.txt"),
//            URL(string: "http://www.詹姆斯.com/"),
        ].compactMap({ $0 })

        XCTAssertEqual(decoded[0], expectedURLs[0])
        XCTAssertEqual(decoded[1], expectedURLs[1])
        XCTAssertEqual(decoded[2], expectedURLs[2])

        let encoded = try TransitEncoder(mode: .verbose, outputFormatting: .withoutEscapingSlashes).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testUUIDMapCompact() throws {
        // uri_map.json
        let uuid = UUID().uuidString
        let data = """
        ["^ ","~:uuid","~u\(uuid)"]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let uuid: UUID
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.uuid.uuidString, uuid)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testUUIDMapVerbose() throws {
        // uri_map.json
        let uuid = UUID().uuidString
        let data = """
        {"~:uuid":"~u\(uuid)"}
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let uuid: UUID
        }
        let decoded = try TransitDecoder(mode: .verbose).decode(Result.self, from: data)

        XCTAssertEqual(decoded.uuid.uuidString, uuid)

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testUUIDsCompact() throws {
        // uuids.json
        let data = """
        ["~u5A2CBEA3-E8C6-428B-B525-21239370DD55","~uD1DC64FA-DA79-444B-9FA4-D4412F427289","~u501A978E-3A3E-4060-B3BE-1CF2BD4B1A38","~uB3BA141A-A776-48E4-9FAE-A28EA8571F58"]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([UUID].self, from: data)

        let expectedUUIDs = [
            "5a2cbea3-e8c6-428b-b525-21239370dd55",
            "d1dc64fa-da79-444b-9fa4-d4412f427289",
            "501a978e-3a3e-4060-b3be-1cf2bd4b1a38",
            "b3ba141a-a776-48e4-9fae-a28ea8571f58"
        ].compactMap({ UUID(uuidString: $0) })

        XCTAssertEqual(decoded[0], expectedUUIDs[0])
        XCTAssertEqual(decoded[1], expectedUUIDs[1])
        XCTAssertEqual(decoded[2], expectedUUIDs[2])
        XCTAssertEqual(decoded[3], expectedUUIDs[3])

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testUUIDsVerbose() throws {
        // uuids.json
        let data = """
        ["~u5A2CBEA3-E8C6-428B-B525-21239370DD55","~uD1DC64FA-DA79-444B-9FA4-D4412F427289","~u501A978E-3A3E-4060-B3BE-1CF2BD4B1A38","~uB3BA141A-A776-48E4-9FAE-A28EA8571F58"]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode([UUID].self, from: data)

        let expectedUUIDs = [
            "5a2cbea3-e8c6-428b-b525-21239370dd55",
            "d1dc64fa-da79-444b-9fa4-d4412f427289",
            "501a978e-3a3e-4060-b3be-1cf2bd4b1a38",
            "b3ba141a-a776-48e4-9fae-a28ea8571f58"
        ].compactMap({ UUID(uuidString: $0) })

        XCTAssertEqual(decoded[0], expectedUUIDs[0])
        XCTAssertEqual(decoded[1], expectedUUIDs[1])
        XCTAssertEqual(decoded[2], expectedUUIDs[2])
        XCTAssertEqual(decoded[3], expectedUUIDs[3])

        let encoded = try TransitEncoder(mode: .verbose).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }
}
