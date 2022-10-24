//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 10/23/22.
//

import Foundation

public final class TransitEncoder {
    enum TransitEncoderError: Error {
        case notImplemented
    }

    let registeredHandlers: [Handler]

    public init(handlers: [Handler]) {
        registeredHandlers = handlers
    }

    public init() {
        registeredHandlers = defaultHandlers
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        try _TransitEncoder(value: value, codingPath: [], handlers: registeredHandlers).makeData()
    }

    final class _TransitEncoder<T: Encodable>: Encoder {

        let value: T
        let codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey : Any] = [:]
        let handlers: [Handler]
        var array: [Any] = []

        init(value: T, codingPath: [CodingKey], handlers: [Handler]) {
            self.value = value
            self.codingPath = codingPath
            self.handlers = handlers
        }

        func makeData() throws -> Data {
            try JSONSerialization.data(withJSONObject: array)
        }

        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            KeyedEncodingContainer(
                _KeyedContainer<Key>(codingPath: codingPath, encoder: self)
            )
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            _UnkeyedContainer(codingPath: codingPath, encoder: self)
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            _SingleValueContainer(codingPath: codingPath, encoder: self)
        }

        struct _KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
            var array: [Any] = []

            var codingPath: [CodingKey]

            var encoder: _TransitEncoder

            mutating func superEncoder() -> Encoder {
                encoder
            }

            mutating func add(key: String, value: Any) {
                array.append(key)
                array.append(value)
            }

            mutating func encodeNil(forKey key: Key) throws {
                add(key: key.stringValue, value: NSNull())
            }

            mutating func encode(_ value: Bool, forKey key: Key) throws {
                add(key: key.stringValue, value: value)

            }

            mutating func encode(_ value: String, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Double, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Float, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int8, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int16, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int32, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int64, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt8, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt16, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt32, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt64, forKey key: Key) throws {
                add(key: key.stringValue, value: value)
            }

            mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
                let encoder = _TransitEncoder<T>(value: value, codingPath: encoder.codingPath + [key], handlers: encoder.handlers)
                try value.encode(to: encoder)
                add(key: key.stringValue, value: encoder.array)
            }

            mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
                fatalError()
            }

            mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
                fatalError()

            }

            mutating func superEncoder(forKey key: Key) -> Encoder {
                encoder
            }
        }

        struct _UnkeyedContainer: UnkeyedEncodingContainer {
            var codingPath: [CodingKey]

            var encoder: _TransitEncoder

            var count: Int {
                array.count
            }

            var array: [Any] = []

            mutating func add(_ value: Any) {
                array.append(value)
            }

            mutating func encodeNil() throws {
                add(NSNull())
            }

            mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
                fatalError()
            }

            mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
                fatalError()
            }

            mutating func superEncoder() -> Encoder {
                encoder
            }

            mutating func encode(_ value: String) throws {
                add(value)
            }

            mutating func encode(_ value: Double) throws {
                add(value)
            }

            mutating func encode(_ value: Float) throws {
                add(value)
            }

            mutating func encode(_ value: Int) throws {
                add(value)
            }

            mutating func encode(_ value: Int8) throws {
                add(value)
            }

            mutating func encode(_ value: Int16) throws {
                add(value)
            }

            mutating func encode(_ value: Int32) throws {
                add(value)
            }

            mutating func encode(_ value: Int64) throws {
                add(value)
            }

            mutating func encode(_ value: UInt) throws {
                add(value)
            }

            mutating func encode(_ value: UInt8) throws {
                add(value)
            }

            mutating func encode(_ value: UInt16) throws {
                add(value)
            }

            mutating func encode(_ value: UInt32) throws {
                add(value)
            }

            mutating func encode(_ value: UInt64) throws {
                add(value)
            }

            mutating func encode<T>(_ value: T) throws where T : Encodable {
                let encoder = _TransitEncoder<T>(value: value, codingPath: codingPath + [IntCodingKey(intValue: count)].compactMap({ $0 }), handlers: encoder.handlers)
                try value.encode(to: encoder)
                add(encoder.array)
            }

            mutating func encode(_ value: Bool) throws {
                add(value)
            }
        }

        struct _SingleValueContainer: SingleValueEncodingContainer {
            var codingPath: [CodingKey]

            var encoder: _TransitEncoder

            var stored: Any?

            mutating func encodeNil() throws {
                stored = NSNull()
            }

            mutating func encode(_ value: Bool) throws {
                stored = value
            }

            mutating func encode(_ value: String) throws {
                stored = value
            }

            mutating func encode(_ value: Double) throws {
                stored = value
            }

            mutating func encode(_ value: Float) throws {
                stored = value
            }

            mutating func encode(_ value: Int) throws {
                stored = value
            }

            mutating func encode(_ value: Int8) throws {
                stored = value
            }

            mutating func encode(_ value: Int16) throws {
                stored = value
            }

            mutating func encode(_ value: Int32) throws {
                stored = value
            }

            mutating func encode(_ value: Int64) throws {
                stored = value
            }

            mutating func encode(_ value: UInt) throws {
                stored = value
            }

            mutating func encode(_ value: UInt8) throws {
                stored = value
            }

            mutating func encode(_ value: UInt16) throws {
                stored = value
            }

            mutating func encode(_ value: UInt32) throws {
                stored = value
            }

            mutating func encode(_ value: UInt64) throws {
                stored = value
            }

            mutating func encode<T>(_ value: T) throws where T : Encodable {
                stored = value
            }
        }
    }
}
