//
//  SQLRow+Extension.swift
//  DBQuery
//
//  Created by Victor Chernykh on 11.09.2022.
//

import SQLKit

extension SQLRow {
	/// Decode an entire `Decodable` type at once, optionally applying a prefix and/or a decoding strategy
	/// to each key of the type before looking it up in the row.
	public func decode<D: Decodable>(type: D.Type) throws -> D {
		let rowDecoder: DBRowDecoder = .init()
		return try rowDecoder.decode(D.self, from: self)
	}
}
