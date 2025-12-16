//
//  CacheBox.swift
//  dbQuery
//
//  Created by Victor Chernykh on 15.12.2025.
//

import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

/// Thread-safe wrapper around a Bool value.
/// Uses reader–writer lock pattern with a POSIX read-write lock.
public final class CacheBox: @unchecked Sendable {

	/// POSIX read-write lock to support high-performance concurrent reads and exclusive writes.
	/// Chosen over GCD or NIOLock for lower overhead in performance-critical for reading.
	private var lock: pthread_rwlock_t = .init()
	private var value: [String: DBSessionModel]

	public init(_ value: [String: DBSessionModel] = [:]) {
		self.value = value
		let result: Int32 = pthread_rwlock_init(&lock, nil)
		if result != 0 {
			// If we cannot initialize the lock, using this instance is undefined.
			// Failing fast is safer than continuing with a broken lock.
			fatalError("pthread_rwlock_init failed with code \(result)")
		}
	}

	@inline(__always)
	public func load() -> [String: DBSessionModel] {
		pthread_rwlock_rdlock(&lock)
		defer { pthread_rwlock_unlock(&lock) }
		return value
	}

	/// Load the current value in a thread-safe way.
	/// Uses a shared (read) lock, allowing many concurrent readers.
	///
	/// - Returns: DBSessionModel.
	@inline(__always)
	public func load(for key: String) -> DBSessionModel? {
		pthread_rwlock_rdlock(&lock)
		defer { pthread_rwlock_unlock(&lock) }
		return value[key]
	}

	/// Store a new value in a thread-safe way.
	/// Uses an exclusive (write) lock to serialize writers.
	///
	/// - Parameters:
	///   - value: New DBSessionModel to set.
	///   - key: key of model in the dictionary.
	@inline(__always)
	public func store(_ value: DBSessionModel?, for key: String) {
		pthread_rwlock_wrlock(&lock)
		defer { pthread_rwlock_unlock(&lock) }
		self.value[key] = value
	}

	@inline(__always)
	public func remove(by keys: [String]) {
		pthread_rwlock_wrlock(&lock)
		defer { pthread_rwlock_unlock(&lock) }
		for key in keys {
			self.value[key] = nil
		}
	}

	public func update(userId: UUID?, by sessionId: String) {
		pthread_rwlock_wrlock(&lock)
		defer { pthread_rwlock_unlock(&lock) }
		guard var session: DBSessionModel = value[sessionId] else {
			return
		}
		session.userId = userId
		value[sessionId] = session
	}

	deinit {
		// Destroy the lock to release system resources
		let result: Int32 = pthread_rwlock_destroy(&lock)
		if result != 0 {
			// At this point we cannot recover, but logging the error
			print("pthread_rwlock_destroy failed with code \(result)")
		}
	}
}
