//
//  Page.swift
//  DBQuery
//
//  Created by Victor Chernykh on 26.06.2024.
//

/// A single section of a larger, traversable result set.
public struct Page<T: Codable & Sendable>: Codable, Sendable {
	/// The page's items. Usually response models.
	public var items: [T]

	/// Metadata containing information about current page, items per page, and total items.
	public let metadata: PageMetadata

	/// Creates a new `Page`.
	public init(items: [T], metadata: PageMetadata) {
		self.items = items
		self.metadata = metadata
	}

	/// Maps a page's items to a different type using the supplied closure.
	public func map<U>(_ transform: (T) throws -> (U)) rethrows -> Page<U> {
		try .init(
			items: self.items.map(transform),
			metadata: self.metadata
		)
	}
}
