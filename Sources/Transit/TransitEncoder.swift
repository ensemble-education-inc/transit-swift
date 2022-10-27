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
            fatalError()
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            fatalError()
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
                fatalError()
            }

        }
    }
}
