import SQLKit

/// Builds raw SQL queries.
///
///     db.raw(DBRaw())
///         .all(decoding: Planet.self)
///
public final class RawBuilder: SQLQueryFetcher {

	/// See `SQLQueryBuilder`.
	public var database: any SQLDatabase

	/// See `SQLQueryBuilder`.
	public var query: any SQLExpression

	/// Creates a new `RawBuilder`.
	public init(_ query: any SQLExpression, on db: any SQLDatabase) {
		self.database = db
		self.query = query
	}
}

// MARK: - Connection

extension SQLDatabase {
	/// Creates a new `RawBuilder`.
	///
	///     db.raw(DBRaw())...
	///
	/// - parameters:
	///    - sql: The DBRaw - alternative SQLQueryString.
	/// - returns: `RawBuilder`.
	public func raw(_ sql: DBRaw) -> RawBuilder {
#if DEBUG
		print(sql.sql)
#endif
		return .init(sql, on: self)
	}

	/// Creates a new `RawBuilder`.
	/// - Parameter string: SQL string
	/// - Returns: `RawBuilder`.
	public func raw(_ string: String) -> RawBuilder {
#if DEBUG
		print(string)
#endif
		let sql: DBRaw = .init(string)
		return .init(sql, on: self)
	}

	public func raw(_ string: String, _ binds: [any Encodable & Sendable]) -> RawBuilder {
#if DEBUG
		print(string)
#endif
		let sql: DBRaw = .init(string, binds)
		return .init(sql, on: self)
	}
}
