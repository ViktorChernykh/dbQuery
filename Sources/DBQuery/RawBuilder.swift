import SQLKit

/// Builds raw SQL queries.
///
///     db.raw(DBRaw())
///         .all(decoding: Planet.self)
///
public final class DBRawBuilder: SQLQueryFetcher {

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
