//
//  StringInterpolation+Extension.swift
//  DBQuery
//
//  Created by Victor Chernykh on 17.12.2022.
//

extension String.StringInterpolation {
	/// `col` mean only field without table. Quote -> always.
	public mutating func appendInterpolation(full column: Column) {
		let string: String = "\"\(column.table)\".\"\(column.key)\""
		appendLiteral(string)
	}

	public mutating func appendInterpolation(quot text: String) {
		let string = "\"\(text)\""
		appendLiteral(string)
	}
}
