//
//  DBSessionModel.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import Fluent
import SQLKit
import Vapor

public typealias sess = DBSessionModel.v1

public struct DBSessionModel: Codable, Sendable {
	public static let schema = v1.schema
	public static let alias = v1.alias
	private static let encoder: JSONEncoder = .init()

	// Generate session id.
	static func generateID() -> String {
		var bytes: Data = .init()
		for _ in 0..<32 {
			bytes.append(UInt8.random(in: .min ..< .max))
		}
		return bytes.base64EncodedString()
	}

	struct Migrate: AsyncMigration {
		typealias v1 = DBSessionModel.v1

		func prepare(on db: any Database) async throws {
			try await db.schema(v1.schema)
				.id()
				.field(v1.string, .custom("VARCHAR(64)"), .required)
				.field(v1.csrf, .custom("VARCHAR(64)"), .required)
				.field(v1.data, .data)
				.field(v1.expires, .datetime, .required)
				.field(v1.userId, .uuid)
				.create()

			let sql: String = """
			CREATE UNIQUE INDEX \(v1.alias)_string_uidx ON \(v1.schema) (
			\(v1.string));
			"""
			try await db.sql.raw(DBRaw(sql)).run()
		}

		func revert(on db: any Database) async throws {
			try await db.schema(v1.schema).delete()
		}
	}

	public static var migrate: any AsyncMigration {
		Migrate()
	}

	public let id: UUID
	public let string: String	// session id
	public let csrf: String
	public var data: Data?
	public var expires: Date
	public var userId: UUID?

	public init(
		id: UUID = UUID(),
		string: String? = nil,
		csrf: String = Data([UInt8].random(count: 16)).base32EncodedString(),
		data: [String: String]? = nil,
		expires: Date,
		userId: UUID? = nil
	) {
		self.id = id
		self.string = string ?? Self.generateID()
		self.csrf = csrf

		if let data, let encoded: Data = try? Self.encoder.encode(data) {
			self.data = encoded
		} else {
			self.data = nil
		}
		self.expires = expires
		self.userId = userId
	}
}

extension DBSessionModel {
	public enum v1 {
		public static let schema: String = "_db_sessions"
		public static let alias: String = "sess"

		public static let id: Column = .init("id", Self.alias)
		public static let string: Column = .init("string", Self.alias)
		public static let csrf: Column = .init("csrf", Self.alias)
		public static let data: Column = .init("data", Self.alias)
		public static let expires: Column = .init("expires", Self.alias)
		public static let userId: Column = .init("userId", Self.alias)
	}
}

// MARK: - create

extension DBSessionModel {

	@discardableResult
	public func create(on app: Application) async throws -> UUID {
		let sql: String = "INSERT INTO \(v1.schema) VALUES($1, $2, $3, $4, $5, $6);"
		let binds: [any Encodable & Sendable] = [
			id,
			string,
			csrf,
			data,
			expires,
			userId
		]
		let query: DBRaw = DBRaw(sql, binds)
		try await app.sql.raw(query).run()

		return id
	}
}
