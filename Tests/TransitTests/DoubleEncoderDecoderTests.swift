import Transit
import XCTest

struct Pair<A: Codable, B: Codable>: Codable {

    let a: A
    let b: B

}

extension Pair {
    init(from decoder: Decoder) throws {
        self.a = try A(from: decoder)
        self.b = try B(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        try a.encode(to: encoder)
        try b.encode(to: encoder)
    }

}

final class DoubleEncoderDecoderTests: XCTestCase {


    struct DInt: Codable {
        let c: Int
    }

    struct EInt: Codable {
        let d: Int
    }

    func testDecoding() throws {
        let data = Data("""
        { "~:c": 5, "~:d": 7 }
        """.utf8)
        let value = try TransitDecoder(mode: .verbose).decode(Pair<DInt, EInt>.self, from: data)
        XCTAssertEqual(value.a.c, 5)
        XCTAssertEqual(value.b.d, 7)
    }

    func testEncoding() throws {
        let data = Data("""
        {"~:c":5,"~:d":7}
        """.utf8)
        let pair = Pair<DInt, EInt>(a: .init(c: 5), b: .init(d: 7))
        let encoded = try TransitEncoder(mode: .verbose, outputFormatting: .sortedKeys).encode(pair)
        XCTAssertDataEquals(data, encoded)
    }
}
