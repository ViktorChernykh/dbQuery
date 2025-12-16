//
//  Application+sql.swift
//  DBQuery
//
//  Created by Victor Chernykh on 26.06.2024.
//

import SQLKit
import Vapor

extension Application {
	/// Returns Fluent.Database as SQLKit.SQLDatabase.
	public var sql: any SQLDatabase {
		guard let sql = self.db as? any SQLDatabase else {
			fatalError("The database is not sql.")
		}
		return sql
	}
}
