import Transit
import XCTest

final class NullTests: XCTestCase {

    struct Decoded: Codable {
        let result: Result
    }

    struct Result: Codable {
        let id: Int
        let username: String?
    }


    func testDecodingWithNull() throws {
        let data = """
          [
            "^ ",
            "~:result",
            [
              "^ ",
              "~:id",
              9,
              "~:username",
              null,
            ]
          ]
        """
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, nil)
        XCTAssertEqual(decoded.result.id, 9)
    }

    func testDecodingWithValue() throws {
        let data = """
          [
            "^ ",
            "~:result",
            [
              "^ ",
              "~:id",
              9,
              "~:username",
              "soroushk",
            ]
          ]
        """
            .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Decoded.self, from: data)

        XCTAssertEqual(decoded.result.username, "soroushk")
        XCTAssertEqual(decoded.result.id, 9)
    }
}
