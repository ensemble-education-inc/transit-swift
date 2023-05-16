import Transit
import XCTest

final class NullTests: XCTestCase {

    struct Decoded: Codable {
        let result: Result
    }

    struct Result: Codable {
        let id: Int
        let username: String?

        enum CodingKeys: CodingKey {
            case id
            case username
        }

        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.username, forKey: .username) // don't use encodeIfPresent so that you get the null in the final result
        }
    }

    func testDecodingWithNullCompact() throws {
        let data = """
        ["^ ","~:result",["^ ","~:id",9,"~:username",null]]
        """
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, nil)
        XCTAssertEqual(decoded.result.id, 9)

        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testDecodingWithNullVerbose() throws {
        let data = #"{"~:result":{"~:id":9,"~:username":null}}"#
            .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, nil)
        XCTAssertEqual(decoded.result.id, 9)

        let encoded = try TransitEncoder(mode: .verbose, outputFormatting: .sortedKeys).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testDecodingWithValueCompact() throws {
        let data = """
        ["^ ","~:result",["^ ","~:id",9,"~:username","soroushk"]]
        """
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, "soroushk")
        XCTAssertEqual(decoded.result.id, 9)


        let encoded = try TransitEncoder().encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }

    func testDecodingWithValueVerbose() throws {
        let data = #"{"~:result":{"~:id":9,"~:username":"soroushk"}}"#
            .data(using: .utf8)!

        let decoded = try TransitDecoder(mode: .verbose).decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, "soroushk")
        XCTAssertEqual(decoded.result.id, 9)


        let encoded = try TransitEncoder(mode: .verbose, outputFormatting: .sortedKeys).encode(decoded)

        XCTAssertDataEquals(encoded, data)
    }
}
