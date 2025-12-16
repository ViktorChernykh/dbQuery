import Fluent
import SQLKit

extension Database {
	/// Returns Fluent.Database as SQLKit.SQLDatabase
	public var sql: any SQLDatabase {
		guard let sql = self as? any SQLDatabase else {
			fatalError("The database is not sql.")
		}
		return sql
	}
}
