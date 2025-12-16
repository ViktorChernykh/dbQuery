//
//  Column.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

/// Simplified version `DBColumn`.
public struct Column: Codable, Sendable {
	public let field: String
	public let table: String

	public init(_ field: String, _ table: String) {
		self.field = field
		self.table = table
	}
}

extension Column: CustomStringConvertible {
	public var description: String {
		"\"\(field)\""
	}
}
