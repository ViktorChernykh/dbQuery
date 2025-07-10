//
//  Column.swift
//  DBQuery
//
//  Created by Victor Chernykh on 03.09.2022.
//

/// Simplified version `DBColumn`.
public struct Column: Codable, Sendable {
	public let key: String
	public let table: String

	public init(_ key: String, _ table: String) {
		self.key = key
		self.table = table
	}
}

extension Column: CustomStringConvertible {
	public var description: String {
		"\"\(key)\""
	}
}
