//
//  DBStorageType.swift
//  DBQuery
//
//  Created by Victor Chernykh on 28.03.2023.
//

/// Delegate options for DBSessionsMiddleware.
public enum DBStorageType {
	case memory
	case postgres
	case custom(any DBSessionProtocol)
}
