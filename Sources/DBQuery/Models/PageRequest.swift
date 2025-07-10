//
//  PageRequest.swift
//  DBQuery
//
//  Created by Victor Chernykh on 26.06.2024.
//

/// Represents information needed to generate a `Page` from the full result set.
public struct PageRequest: Decodable, Sendable {
	/// Page number to request. Starts at `1`.
	public let page: Int

	/// Max items per page.
	public let per: Int

	public var offset: Int {
		(page - 1) * per
	}

	enum CodingKeys: String, CodingKey {
		case page
		case per
	}

	/// `Decodable` conformance.
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
		self.per = try container.decodeIfPresent(Int.self, forKey: .per) ?? 100
	}

	/// Crates a new `PageRequest`.
	///
	/// - Parameters:
	///   - page: Page number to request. Starts at `1`.
	///   - per: Max items per page.
	public init(page: Int, per: Int) {
		self.page = page
		self.per = per
	}
}
