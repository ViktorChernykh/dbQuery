//
//  DBSessionPostgres.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import SQLKit
import Vapor

/// Implementation DBSessionProtocol for Postgres database.
public final class DBSessionPostgres: DBSessionProtocol, Sendable {

	/// Singleton instance.
	public static let shared: DBSessionPostgres = .init()
	private let encoder: JSONEncoder = .init()

	// MARK: - Init
	private init() { }

	/// Creates a new session and stores it in the database.
	///
	/// - Parameters:
	///   - csrf: CSRF string.
	///   - data: dictionary with session data.
	///   - expires: sessions expires.
	///   - userId: user id.
	///   - req: `Vapor.Request`.
	/// - Returns: session id.
	public func create(
		csrf: String,
		data: [String: String]?,
		expires: Date,
		userId: UUID?,
		on req: Request
	) async throws -> String {
		let session: DBSessionModel = .init(
			csrf: csrf,
			data: data,
			expires: expires,
			userId: userId
		)
		try await session.create(on: req.application)

		return session.string
	}

	/// Reads session data from the cache by session id.
	///
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: model by session key saved in cache.
	public func read(on req: Request) async throws -> DBSessionModel? {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return nil
		}
		let sql: String = """
		SELECT * FROM \(sess.schema)
		WHERE \(sess.string) = $1
		LIMIT 1;
		"""
		let binds: [any Encodable & Sendable] = [sessionId]

		return try await req.sql.raw(sql, binds)
			.first(decode: DBSessionModel.self)
	}

	/// Reads CSRF from the cache by session id.
	///
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: Cross-Site Request Forgery if specify.
	public func readCSRF(on req: Request) async throws -> String? {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return nil
		}
		let sql: String = """
		SELECT \(sess.csrf) FROM \(sess.schema)
		WHERE \(sess.string) = $1
		LIMIT 1;
		"""
		let binds: [any Encodable & Sendable] = [sessionId]

		return try await req.sql.raw(sql, binds)
			.first(decode: CSRF.self)?.csrf
	}

	/// Updates session CSRF by session ID.
	///
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: CSRF.
	public func setCSRF(on req: Request) async throws -> String? {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return nil
		}
		let csrf: String = Data([UInt8].random(count: 16)).base32EncodedString()
		let sql: String = """
		UPDATE \(sess.schema) SET
		\(sess.csrf) = $1
		WHERE \(sess.string) = $2;
		"""
		let binds: [any Encodable & Sendable] = [csrf, sessionId]
		try await req.sql.raw(sql, binds).run()

		return csrf
	}

	/// Updates the session data in the database.
	///
	/// - Parameters:
	///   - data: session data.
	///   - expires: session expires.
	///   - req: `Vapor.Request`.
	public func update(
		data: [String: String]? = nil,
		expires: Date? = nil,
		on req: Request
	) async throws {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return
		}
		var fields: [String] = []
		var binds: [any Encodable & Sendable] = []
		var sql: String = "UPDATE \(sess.schema) SET "

		if let data {
			let encoded: Data = try encoder.encode(data)
			binds.append(encoded)
			fields.append("\(sess.data) = $\(binds.count)")
		}
		if let expires {
			binds.append(expires)
			fields.append("\(sess.expires) = $\(binds.count)")
		}

		guard !fields.isEmpty else {
			return
		}
		sql += fields.joined(separator: ", ")
		binds.append(sessionId)
		sql += " WHERE \(sess.string) = $\(binds.count);"

		try await req.sql.raw(sql, binds).run()
	}

	public func update(userId: UUID?, on req: Vapor.Request) async throws {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return
		}
		let sql: String = """
		UPDATE \(sess.schema) SET
		\(sess.userId) = $1
		WHERE \(sess.string) = $2;
		"""
		let binds: [any Encodable & Sendable] = [userId, sessionId]

		try await req.sql.raw(sql, binds).run()
	}

	/// Delete session from database.
	///
	/// - Parameter req: `Vapor.Request`.
	public func delete(on req: Request) async throws {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return
		}
		let sql: String = """
		DELETE FROM \(sess.schema)
		WHERE \(sess.string) = $1;
		"""
		let binds: [any Encodable & Sendable] = [sessionId]
		try await req.sql.raw(sql, binds).run()
	}

	/// Delete session from database.
	///
	/// - Parameters:
	///   - sessionId: session key.
	///   - req: `Vapor.Request`.
	public func delete(_ sessionId: String, on req: Request) async throws {
		let sql: String = """
		DELETE FROM \(sess.schema)
		WHERE \(sess.string) = $1;
		"""
		let binds: [any Encodable & Sendable] = [sessionId]
		try await req.sql.raw(sql, binds).run()
	}

	/// Deletes all sessions for the specified user ID.
	///
	/// - Parameters:
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteAll(for userId: UUID, on req: Request) async throws {
		let sql: String = """
		DELETE FROM \(sess.schema)
		WHERE \(sess.userId) = $1;
		"""
		let binds: [any Encodable & Sendable] = [userId]
		try await req.sql.raw(sql, binds).run()
	}

	/// Deletes all sessions for the user except specified sessionId.
	///
	/// - Parameters:
	///	  - sessionId: sessionId for exception.
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteOther(_ sessionId: String, for userId: UUID, on req: Request) async throws {
		let sql: String = """
		DELETE FROM \(sess.schema)
		WHERE \(sess.userId) = $1
		  AND \(sess.string) != $2;
		"""
		let binds: [any Encodable & Sendable] = [userId, sessionId]
		try await req.sql.raw(sql, binds).run()
	}

	/// Deletes all expired sessions.
	///
	/// - Parameter req: `Vapor.Application`.
	public func deleteExpired(on app: Application) async throws {
		let sql: String = """
		DELETE FROM \(sess.schema)
		WHERE \(sess.expires) < $1;
		"""
		let binds: [any Encodable & Sendable] = [Date.now]
		try await app.sql.raw(sql, binds).run()
	}
}
