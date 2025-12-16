//
//  DBSessionMemory.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

import SQLKit
import Vapor

/// Singleton for storage in memory.
public final class DBSessionMemory: DBSessionProtocol {
	/// Singleton instance
	public static let shared: DBSessionMemory = .init()

	/// Storage for sessions
	private let cacheBox: CacheBox = .init()
	private let encoder: JSONEncoder = .init()

	// MARK: - Init
	private init() { }

	// MARK: - Methods

	/// Creates a new session and stores it in the cache.
	///
	/// - Parameters:
	///   - csrf: CSRF string.
	///   - data: dictionary with session data.
	///   - expires: sessions expires.
	///   - userId: user id.
	///   - _: Not used, only for protocol conforms.
	/// - Returns: session id.
	public func create(
		csrf: String = Data([UInt8].random(count: 32)).base32EncodedString(),
		data: [String: String]? = nil,
		expires: Date = Date.now.addingTimeInterval(604_800), // 7 days
		userId: UUID? = nil,
		on _: Request
	) async throws -> String {
		let session: DBSessionModel = .init(
			csrf: csrf,
			data: data,
			expires: expires,
			userId: userId
		)
		cacheBox.store(session, for: session.string)

		return session.string
	}

	/// Reads session data from cache by session id.
	///
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: model  by session key saved in cache.
	public func read(on req: Request) async throws -> DBSessionModel? {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return nil
		}
		return cacheBox.load(for: sessionId)
	}

	/// Reads session CSRF from the cache by session ID.
	///
	/// - Parameter req: `Vapor.Request`.
	/// - Returns: Cross-Site Request Forgery if specify.
	public func readCSRF(on req: Request) async throws -> String? {
		guard let sessionId: String = req.cookies["session"]?.string else {
			return nil
		}
		return cacheBox.load(for: sessionId)?.csrf
	}

	/// Updates the session data in the cache.
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
		guard let sessionId: String = req.cookies["session"]?.string,
			  var session: DBSessionModel = cacheBox.load(for: sessionId) else {
			return
		}
		session.data = data
		session.expires = expires
		session.userId = userId

		cacheBox.store(session, for: sessionId)
	}

	/// Updates the session data in the cache.
	///
	/// - Parameters:
	///   - data: dictionary with session data.
	///   - req: `Vapor.Request`.
	public func update(data: [String: String]?, on req: Request) async throws {
		guard let sessionId: String = req.cookies["session"]?.string,
			  var session: DBSessionModel = cacheBox.load(for: sessionId) else {
			return
		}
		if let data {
			session.data = try JSONEncoder().encode(data)
		} else {
			session.data = nil
		}

		cacheBox.store(session, for: sessionId)
	}

	/// Delete session from the cache.
	///
	/// - Parameter req: `Vapor.Request`.
	public func delete(on req: Request) async throws {
		if let sessionId: String = req.cookies["session"]?.string {
			cacheBox.remove(by: [sessionId])
		}
	}

	/// Delete session from the cache.
	///
	/// - Parameters:
	///   - sessionId: session key.
	///   - req: `Vapor.Request`.
	public func delete(_ sessionId: String, on req: Request) async throws {
		cacheBox.remove(by: [sessionId])
	}
	
	/// Deletes all sessions for the specified user ID.
	///
	/// - Parameters:
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteAll(for userId: UUID, on req: Request) async throws {
		var sessionIds: [String] = .init()
		let cache: [String: DBSessionModel] = cacheBox.load()

		for (key, value) in cache {
			if value.userId == userId {
				sessionIds.append(key)
			}
		}
		cacheBox.remove(by: sessionIds)
	}
	/// Deletes all sessions for the  user ID except specified sessionId.
	///
	/// - Parameters:
	///	  - sessionId: sessionId for exception.
	///   - userId: ID of the user whose sessions will be deleted.
	///   - req: `Vapor.Request`.
	public func deleteOther(_ sessionId: String, for userId: UUID, on req: Request) async throws {
		var sessionIds: [String] = .init()
		let cache: [String: DBSessionModel] = cacheBox.load()

		for (key, value) in cache {
			if value.userId == userId, key != sessionId {
				sessionIds.append(key)
			}
		}
		cacheBox.remove(by: sessionIds)
	}

	/// Deletes all expired sessions.
	/// - Parameter _: Not used, only for protocol conforms.
	public func deleteExpired(on _: Request) async throws {
		var sessionIds: [String] = .init()
		let cache: [String: DBSessionModel] = cacheBox.load()

		for (key, value) in cache {
			if value.expires < Date.now {
				sessionIds.append(key)
			}
		}
		cacheBox.remove(by: sessionIds)
	}
}
