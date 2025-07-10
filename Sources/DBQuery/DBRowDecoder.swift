import SQLKit

/// See `SQLRowDecoder` https://github.com/vapor/sql-kit/blob/main/Sources/SQLKit/Rows/SQLRowDecoder.swift
public struct DBRowDecoder: Sendable {

	public init() { }

	func decode<T>(_ type: T.Type, from row: any SQLRow) throws -> T
	where T: Decodable {
		return try T.init(from: _Decoder(row: row))
	}

	enum _Error: Error {
		case nesting
		case unkeyedContainer
		case singleValueContainer
	}

	struct _Decoder: Decoder {
		let row: any SQLRow
		var codingPath: [any CodingKey] = []
		var userInfo: [CodingUserInfoKey: Any] {
			[:]
		}

		fileprivate init(row: any SQLRow, codingPath: [any CodingKey] = []) {
			self.row = row
			self.codingPath = codingPath
		}

		func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
		where Key: CodingKey {
			.init(_KeyedDecoder(referencing: self, row: self.row, codingPath: self.codingPath))
		}

		func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
			throw _Error.unkeyedContainer
		}

		func singleValueContainer() throws -> any SingleValueDecodingContainer {
			throw _Error.singleValueContainer
		}
	}

	struct _KeyedDecoder<Key>: KeyedDecodingContainerProtocol
	where Key: CodingKey {
		/// A reference to the decoder we're reading from.
		private let decoder: _Decoder
		let row: any SQLRow
		var codingPath: [any CodingKey] = []
		var allKeys: [Key] {
			self.row.allColumns.compactMap {
				Key.init(stringValue: $0)
			}
		}

		fileprivate init(referencing decoder: _Decoder, row: any SQLRow, codingPath: [any CodingKey] = []) {
			self.decoder = decoder
			self.row = row
		}

		func contains(_ key: Key) -> Bool {
			self.row.contains(column: key.stringValue)
		}

		func decodeNil(forKey key: Key) throws -> Bool {
			try self.row.decodeNil(column: key.stringValue)
		}

		func decode<T>(_ type: T.Type, forKey key: Key) throws -> T
		where T: Decodable {
			try self.row.decode(column: key.stringValue, as: T.self)
		}

		func nestedContainer<NestedKey>(
			keyedBy type: NestedKey.Type,
			forKey key: Key
		) throws -> KeyedDecodingContainer<NestedKey>
		where NestedKey: CodingKey {
			throw _Error.nesting
		}

		func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
			throw _Error.nesting
		}

		func superDecoder() throws -> any Decoder {
			_Decoder(row: self.row, codingPath: self.codingPath)
		}

		func superDecoder(forKey key: Key) throws -> any Decoder {
			throw _Error.nesting
		}
	}
}
