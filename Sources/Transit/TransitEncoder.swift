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
        var context = Context(registeredHandlers: registeredHandlers, transformer: { context, value in try prepareForEncode(value: value, context: &context) })
        let encoder =  _TransitEncoder(value: value, codingPath: [], context: context)
        if value is BuiltInType {
            try encoder.content = .singleValue(context.transform(value: value))
        } else {
            try value.encode(to: encoder)
        }
        return try encoder.makeData()
    }

    final class _TransitEncoder<T: Encodable>: Encoder {

        enum Content {
            case singleValue(Any)
            case array([Any])

            init() {
                self = .array([])
            }

            var value: Any {
                switch self {
                case let .singleValue(value):
                    return value
                case let .array(array):
                    return array
                }
            }

            var isEmpty: Bool {
                count == 0
            }

            var count: Int {
                switch self {
                case .singleValue:
                    return 1
                case let .array(array):
                    return array.count
                }
            }

            mutating func append(_ value: Any) {
                switch self {
                case .singleValue(_):
                    self = .singleValue(value)
                case let .array(array):
                    self = .array(array + [value])
                }
            }
        }
        
        let value: T
        let codingPath: [CodingKey]
        var context: Context
        var userInfo: [CodingUserInfoKey : Any] = [:]
        var content: Content = .init()

        init(value: T, codingPath: [CodingKey], context: Context) {
            self.value = value
            self.codingPath = codingPath
            self.context = context
        }

        func makeData() throws -> Data {
            switch content {
            case let .singleValue(value):
                return try JSONSerialization.data(withJSONObject: ["~#'", value])
            case let .array(array):
                return try JSONSerialization.data(withJSONObject: array)
            }
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
            var codingPath: [CodingKey]

            var encoder: _TransitEncoder

            mutating func superEncoder() -> Encoder {
                fatalError()
            }

            mutating func add(key: String, value: Any) throws {
                if encoder.content.isEmpty {
                    encoder.content.append("^ ")
                }
                encoder.content.append(Keyword(keyword: key).encoded)
                let processedValue = try encoder.context.transform(value: value)
                encoder.content.append(processedValue)
            }

            mutating func encodeNil(forKey key: Key) throws {
                try add(key: key.stringValue, value: NSNull())
            }

            mutating func encode(_ value: Bool, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)

            }

            mutating func encode(_ value: String, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Double, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Float, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int8, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int16, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int32, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: Int64, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt8, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt16, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt32, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode(_ value: UInt64, forKey key: Key) throws {
                try add(key: key.stringValue, value: value)
            }

            mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
//                let encoder = _TransitEncoder<T>(value: value, codingPath: encoder.codingPath + [key], context: encoder.context)
//                try value.encode(to: encoder)
//                try add(key: key.stringValue, value: encoder.array)
                let preparedValue = try encoder.context.transform(value: value)
                try add(key: key.stringValue, value: preparedValue)
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

        struct _UnkeyedContainer: UnkeyedEncodingContainer {
            var codingPath: [CodingKey]

            var encoder: _TransitEncoder

            var count: Int {
                encoder.content.count
            }

            mutating func add(_ value: Any) {
                encoder.content.append(value)
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
                fatalError()
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
//                let encoder = _TransitEncoder<T>(value: value, codingPath: codingPath + [IntCodingKey(intValue: count)].compactMap({ $0 }), context: encoder.context)
//                try value.encode(to: encoder)
//                add(encoder.array)
                let preparedValue = try encoder.context.transform(value: value)
                add(preparedValue)
            }

            mutating func encode(_ value: Bool) throws {
                add(value)
            }
        }

        struct _SingleValueContainer: SingleValueEncodingContainer {
            var codingPath: [CodingKey]

            var encoder: _TransitEncoder

            func setValue(_ value: Any) throws {
                encoder.content = .singleValue(value)
            }

            mutating func encodeNil() throws {
                try setValue(NSNull())
            }

            mutating func encode(_ value: Bool) throws {
                try setValue(value)
            }

            mutating func encode(_ value: String) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Double) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Float) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Int) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Int8) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Int16) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Int32) throws {
                try setValue(value)
            }

            mutating func encode(_ value: Int64) throws {
                try setValue(value)
            }

            mutating func encode(_ value: UInt) throws {
                try setValue(value)
            }

            mutating func encode(_ value: UInt8) throws {
                try setValue(value)
            }

            mutating func encode(_ value: UInt16) throws {
                try setValue(value)
            }

            mutating func encode(_ value: UInt32) throws {
                try setValue(value)
            }

            mutating func encode(_ value: UInt64) throws {
                try setValue(value)
            }

            mutating func encode<T>(_ value: T) throws where T : Encodable {
                let processedValue = try encoder.context.transform(value: value)
                try setValue(processedValue)
            }
        }
    }
}
