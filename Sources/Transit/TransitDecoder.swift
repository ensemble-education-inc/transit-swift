import Foundation

let defaultHandlers: [Handler] = [
    MapHandler(),
    SetHandler(),
    ScalarHandler(),
    MillisecondsSince1970Handler(),
    ISO8601DateHandler(),
]

public final class TransitDecoder {
    enum TransitDecoderError: Error {
        case notImplemented
    }

    let registeredHandlers: [Handler]

    public init(handlers: [Handler]) {
        registeredHandlers = handlers
    }

    public init() {
        registeredHandlers = defaultHandlers
    }

    public func decode<T: Decodable>(_ t: T.Type, from data: Data) throws -> T {
        try T(from: _TransitDecoder(data: data, codingPath: [], handlers: registeredHandlers))
    }

    final class _TransitDecoder: Decoder {

        var codingPath: [CodingKey]

        var userInfo: [CodingUserInfoKey : Any] = [:]

        let json: Any

        let handlers: [Handler]

        convenience init(data: Data, codingPath: [CodingKey], handlers: [Handler]) throws {
            let json = try JSONSerialization.jsonObject(with: data)
            self.init(json: json, codingPath: [], handlers: handlers)
        }

        init(json: Any, codingPath: [CodingKey], handlers: [Handler]) {
            self.json = transformDocument(value: json, withRegisteredHandlers: handlers)
            self.codingPath = codingPath
            self.handlers = handlers
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            guard json is [String: Any] else {
                throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Expected object but none found."))
            }
            return KeyedDecodingContainer(
                _KeyedContainer<Key>(decoder: self)
            )
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            _UnkeyedContainer(decoder: self)
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            _SingleValueContainer(decoder: self)
        }
    }

    struct _KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey] {
            decoder.codingPath
        }

        var decoder: _TransitDecoder

        var dictOfValues: [String: Any] {
            decoder.json as? [String: Any] ?? [:]
        }

        func value<T>(forKey key: Key) throws -> T {
            guard let untyped = dictOfValues[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(codingPath: codingPath, debugDescription: "\(key) key not found"))
            }
            guard let typed = untyped as? T else {
                throw DecodingError.typeMismatch(T.self, .init(codingPath: codingPath, debugDescription: "Expected type \(T.self) and found \(type(of: untyped))"))
            }
            return typed
        }

        var allKeys: [Key] {
            Array(dictOfValues.keys)
                .compactMap({ return Key(stringValue: $0) })
        }

        func contains(_ key: Key) -> Bool {
            allKeys.contains(where: { $0.stringValue == key.stringValue })
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            let value = try value(forKey: key) as Any

            return type(of: value) == NSNull.self
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try value(forKey: key)
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try value(forKey: key)
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try value(forKey: key)
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try value(forKey: key)
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try value(forKey: key)
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try value(forKey: key)
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try value(forKey: key)
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try value(forKey: key)
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try value(forKey: key)
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try value(forKey: key)
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try value(forKey: key)
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try value(forKey: key)
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try value(forKey: key)
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try value(forKey: key)
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            let dict = try value(forKey: key) as Any
            let decoder = _TransitDecoder(json: dict, codingPath: decoder.codingPath + [key], handlers: decoder.handlers)
            return try T(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {

            let array = try value(forKey: key) as [Any]
            let decoder = _TransitDecoder(json: array, codingPath: decoder.codingPath + [key], handlers: decoder.handlers)
            return KeyedDecodingContainer(_KeyedContainer<NestedKey>(decoder: decoder))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            throw TransitDecoderError.notImplemented
        }

        func superDecoder() throws -> Decoder {
            throw TransitDecoderError.notImplemented
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            throw TransitDecoderError.notImplemented
        }
    }

    struct _UnkeyedContainer: UnkeyedDecodingContainer {

        let decoder: _TransitDecoder

        var arrayOfValues: [Any] {
            decoder.json as? [Any] ?? []
         }

        var codingPath: [CodingKey] {
            decoder.codingPath
        }

        var count: Int? {
            arrayOfValues.count
        }

        var isAtEnd: Bool {
            currentIndex >= count ?? 0
        }

        var currentIndex: Int = 0

        mutating func currentValue<T>() throws -> T {
            let untyped = arrayOfValues[currentIndex]
            guard let typed = untyped as? T else {
                throw DecodingError.typeMismatch(T.self, .init(codingPath: codingPath, debugDescription: "Expected type \(T.self) and found \(type(of: untyped))"))
            }
            currentIndex += 1
            return typed
        }

        mutating func decodeNil() throws -> Bool {
            let value = try currentValue() as Any

            return type(of: value) == NSNull.self
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            throw TransitDecoderError.notImplemented
        }

        func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            throw TransitDecoderError.notImplemented
        }

        func superDecoder() throws -> Decoder {
            throw TransitDecoderError.notImplemented
        }

        mutating func decode(_ type: Bool.Type) throws -> Bool {
            throw TransitDecoderError.notImplemented
        }

        mutating func decode(_ type: String.Type) throws -> String {
            try currentValue()
        }

        mutating func decode(_ type: Double.Type) throws -> Double {
            try currentValue()
        }

        mutating func decode(_ type: Float.Type) throws -> Float {
            try currentValue()
        }

        mutating func decode(_ type: Int.Type) throws -> Int {
            try currentValue()
        }

        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            try currentValue()
        }

        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            try currentValue()
        }

        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            try currentValue()
        }

        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            try currentValue()
        }

        mutating func decode(_ type: UInt.Type) throws -> UInt {
            try currentValue()
        }

        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            try currentValue()
        }

        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            try currentValue()
        }

        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            try currentValue()
        }

        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            try currentValue()
        }

        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let untyped = arrayOfValues[currentIndex]
            let decoder = _TransitDecoder(json: untyped, codingPath: codingPath + [IntCodingKey(intValue: currentIndex)!], handlers: decoder.handlers)

            currentIndex += 1

            return try T(from: decoder)
        }
    }

    struct _SingleValueContainer: SingleValueDecodingContainer {
        let decoder: _TransitDecoder

        var codingPath: [CodingKey] {
            decoder.codingPath
        }

        var value: Any {
            decoder.json
        }

        func currentValue<T>() throws -> T {
            let untyped = value
            guard let typed = untyped as? T else {
                throw DecodingError.typeMismatch(T.self, .init(codingPath: codingPath, debugDescription: "Expected type \(T.self) and found \(type(of: untyped))"))
            }
            return typed
        }

        func decodeNil() -> Bool {
            do {
                let value = try currentValue() as Any

                return type(of: value) == NSNull.self
            } catch {
                return false
            }
        }

        func decode(_ type: Bool.Type) throws -> Bool {
            try currentValue()
        }

        func decode(_ type: String.Type) throws -> String {
            try currentValue()
        }

        func decode(_ type: Double.Type) throws -> Double {
            try currentValue()
        }

        func decode(_ type: Float.Type) throws -> Float {
            try currentValue()
        }

        func decode(_ type: Int.Type) throws -> Int {
            try currentValue()
        }

        func decode(_ type: Int8.Type) throws -> Int8 {
            try currentValue()
        }

        func decode(_ type: Int16.Type) throws -> Int16 {
            try currentValue()
        }

        func decode(_ type: Int32.Type) throws -> Int32 {
            try currentValue()
        }

        func decode(_ type: Int64.Type) throws -> Int64 {
            try currentValue()
        }

        func decode(_ type: UInt.Type) throws -> UInt {
            try currentValue()
        }

        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try currentValue()
        }

        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try currentValue()
        }

        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try currentValue()
        }

        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try currentValue()
        }

        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            try currentValue()
        }
    }
}
