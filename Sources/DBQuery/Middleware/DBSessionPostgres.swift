//
//  DBSessionPostgres.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import SQLKit
import Vapor

/// Implementation DBSessionProtocol for Postgres database.
public struct DBSessionPostgres: DBSessionProtocol, Sendable {

	/// Singleton instance.
	public static let shared: DBSessionPostgres = .init()
	public static let encoder: JSONEncoder = .init()

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
		csrf: String = Data([UInt8].random(count: 32)).base32EncodedString(),
		data: [String: String]? = nil,
		expires: Date = .now.addingTimeInterval(604_800), // 7 days
		userId: UUID? = nil,
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

	/// Updates the session data in the database.
	///
	/// - Parameters:
	///   - data: session data.
	///   - expires: session expires.
	///   - userId: session userId.
	///   - req: `Vapor.Request`.
	public func update(
		data: Data?,
		expires: Date,
		userId: UUID?,
		on req: Request
	) async throws {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return
		}
		let sql: String = """
		UPDATE \(sess.schema) SET
		\(sess.data) = $1,
		\(sess.expires) = $2,
		\(sess.userId) = $3
		WHERE \(sess.string) = $4;
		"""
		let binds: [any Encodable & Sendable] = [data, expires, userId, sessionId]

		try await req.sql.raw(sql, binds).run()
	}

	/// Updates the session data in the cache.
	///
	/// - Parameters:
	///   - data: dictionary with session data.
	///   - req: `Vapor.Request`.
	public func update(data: [String: String]?, on req: Request) async throws {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return
		}
		let sql: String = """
		UPDATE \(sess.schema)
		SET \(sess.data) = $1
		WHERE \(sess.string) = $2;
		"""
		let encoded: Data = try Self.encoder.encode(data)
		let binds: [any Encodable & Sendable] = [encoded, sessionId]

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
	/// - Parameter req: `Vapor.Request`.
	public func deleteExpired(on req: Request) async throws {
		let sql: String = """
		DELETE FROM \(sess.schema)
		WHERE \(sess.expires) < $1;
		"""
		let binds: [any Encodable & Sendable] = [Date.now]
		try await req.sql.raw(sql, binds).run()
	}
}
