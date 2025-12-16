//
//  DBSessionsMiddleware.swift
//  DBQuery
//
//  Created by Victor Chernykh on 30.01.2023.
//

/// `Example. Copy to your project.`

/*
import Vapor

/// Middleware for processing sessions.
final class DBSessionsMiddleware: AsyncMiddleware {
	// MARK: Properties
	/// The sessions configuration.
	let configuration: DBSessionsConfiguration
	/// Session store.
	let delegate: any DBSessionProtocol

	/// Creates a new `DBSessionsMiddleware`.
	///
	/// - parameters:
	///     - configuration: `SessionsConfiguration` to use for naming and creating cookie values.
	///     - storage: `StorageDelegate` implementation to use for fetching and storing sessions.
	init(
		configuration: DBSessionsConfiguration,
		storageType: DBStorageType
	) {
		self.configuration = configuration

		switch storageType {
		case .memory:
			self.delegate = DBSessionMemory.shared
		case .postgres:
			self.delegate = DBSessionPostgres.shared
		case .custom(let driver):
			self.delegate = driver
		}
	}

	func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
		let cookieValue: String
		let expires: Date = .now.addingTimeInterval(configuration.timeInterval)

		// Check for an existing session
		if let session: DBSessionModel = try await delegate.read(on: req), // read session
		   session.expires > Date.now {
			cookieValue = session.string
			var userId: UUID? = session.userId

			// Authenticate
			if let id: UUID = userId {
				let sql: String = "SELECT * FROM u WHERE id = $1 LIMIT 1;"
				if let user: UserModel = try await req.sql.raw(sql, [id])
					.first(decode: UserModel.self) {
					req.auth.login(user)
				} else {
					userId = nil
				}
			}

			// Update session
			try await delegate.update(
				data: session.data,
				expires: expires,
				userId: userId,
				on: req
			)

		} else {
			// Create a new session
			cookieValue = try await delegate.create(
				csrf: Data([UInt8].random(count: 32)).base32EncodedString(),
				data: [:],
				expires: expires,
				userId: nil,
				on: req
			)

			// So that the handlers inside can see the new session.
			req.cookies["session"] = configuration.cookieFactory(
				cookieValue,
				expires: expires
			)
		}

		let response: Response = try await next.respond(to: req)

		// In response.cookies, it is always necessary for the client to save/update expires.
		response.cookies["session"] = configuration.cookieFactory(
			cookieValue,
			expires: expires
		)

		return response
	}
}
*/
