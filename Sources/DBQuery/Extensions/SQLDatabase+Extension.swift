//
//  SQLDatabase+Extension.swift
//  dbQuery
//
//  Created by Victor Chernykh on 11.07.2025.
//

import SQLKit

/// See `SQLDatabase` https://github.com/vapor/sql-kit/blob/main/Sources/SQLKit/Database/SQLDatabase.swift
extension SQLDatabase {
	/// Creates a new `RawBuilder`.
	///
	///     db.raw(DBRaw())...
	///
	/// - parameters:
	///    - sql: The DBRaw - alternative SQLQueryString.
	/// - returns: `RawBuilder`.
	public func raw(_ sql: DBRaw) -> DBRawBuilder {
#if DEBUG
		print(sql.sql)
#endif
		return .init(sql, on: self)
	}

	/// Creates a new `RawBuilder`.
	/// - Parameter string: SQL string
	/// - Returns: `RawBuilder`.
	public func raw(_ string: String) -> DBRawBuilder {
#if DEBUG
		print(string)
#endif
		let sql: DBRaw = .init(string)
		return .init(sql, on: self)
	}

	public func raw(_ string: String, _ binds: [any Encodable & Sendable]) -> DBRawBuilder {
#if DEBUG
		print(string)
#endif
		let sql: DBRaw = .init(string, binds)
		return .init(sql, on: self)
	}
}
