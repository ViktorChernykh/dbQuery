//
//  SQLQueryFetcher+Extension.swift
//  DBQuery
//
//  Created by Victor Chernykh on 11.09.2022.
//

import SQLKit

/// See `SQLQueryFetcher`  https://github.com/vapor/sql-kit/blob/main/Sources/SQLKit/Builders/Prototypes/SQLQueryFetcher.swift
extension SQLQueryFetcher {

	/// Using a default-configured ``DBRowDecoder``, returns the first output row, if any, decoded as a given type.
	///
	/// - Parameter type: The type of the desired value.
	/// - Returns: Decoded type.
	@inlinable
	public func first<D: Decodable>(decode type: D.Type) async throws-> D? {
		(self as? any SQLPartialResultBuilder)?.limit(1)
		nonisolated(unsafe) var rows: [any SQLRow] = .init()

		try await self.run {
			if rows.isEmpty { rows.append($0) }
		}
		return try rows.first?.decode(type: D.self)
	}

	/// Returns the named column from the first output row, if any, decoded as a given type.
	///
	/// - Parameters:
	///   - column: The name of the column to decode.
	///   - type: The type of the desired value.
	/// - Returns: The decoded value, if any.
	@inlinable
	public func first<D: Decodable>(column: String, as type: D.Type) async throws -> D? {
		try await self.first()?.decode(column: column, as: D.self)
	}

	/// Using the given ``DBRowDecoder``, returns the output rows, if any, decoded as a given type.
	///
	/// - Parameter type: The type of the desired values.
	/// - Returns: Array of decoded type.
	@inlinable
	public func all<D: Decodable>(decode type: D.Type) async throws -> [D] {
		nonisolated(unsafe) var rows: [any SQLRow] = .init()

		try await self.run { row in rows.append(row) }
		return try rows.map {
			try $0.decode(type: D.self)
		}
	}

	/// Returns the named column from the first output row, if any, decoded as a given type.
	///
	/// - Parameters:
	///   - column: The name of the column to decode.
	///   - type: The type of the desired value.
	/// - Returns: The decoded value, if any.
	@inlinable
	public func all<D: Decodable>(column: String, as type: D.Type) async throws -> [D] {
		try await self.all().map { try $0.decode(column: column, as: D.self) }
	}
}
