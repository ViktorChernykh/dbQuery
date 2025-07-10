//
//  SchemaBuilder+Column.swift
//  DBQuery
//
//  Created by Victor Chernykh on 11.09.2022.
//

import FluentKit

/// See `SchemaBuilder`  https://github.com/vapor/fluent-kit/blob/main/Sources/FluentKit/Schema/SchemaBuilder.swift
extension SchemaBuilder {
	public func field(
		_ field: Column,
		_ dataType: DatabaseSchema.DataType,
		_ constraints: DatabaseSchema.FieldConstraint...
	) -> Self {
		return self.field(.definition(
			name: .key(FieldKey(stringLiteral: field.key)),
			dataType: dataType,
			constraints: constraints
		))
	}

	@discardableResult
	public func unique(on fields: Column..., name: String? = nil) -> Self {
		self.constraint(.constraint(
			.unique(fields: fields.map { .key(FieldKey(stringLiteral: $0.key)) }),
			name: name
		))
	}

	@discardableResult
	public func compositeIdentifier(over fields: Column...) -> Self {
		self.constraint(.constraint(.compositeIdentifier(
			fields.map { .key(FieldKey(stringLiteral: $0.key)) }
		), name: ""))
	}

	@discardableResult
	public func deleteUnique(on fields: Column...) -> Self {
		self.schema.deleteConstraints.append(.constraint(
			.unique(fields: fields.map { .key(FieldKey(stringLiteral: $0.key)) })
		))
		return self
	}

	@discardableResult
	public func foreignKey(
		_ field: Column,
		references foreignSchema: String,
		_ foreignField: Column,
		onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
		onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
		name: String? = nil
	) -> Self {
		self.schema.createConstraints.append(.constraint(
			.foreignKey(
				[.key(FieldKey(stringLiteral: field.key))],
				foreignSchema,
				[.key(FieldKey(stringLiteral: foreignField.key))],
				onDelete: onDelete,
				onUpdate: onUpdate
			),
			name: name
		))
		return self
	}

	@discardableResult
	public func foreignKey(
		_ fields: [Column],
		references foreignSchema: String,
		_ foreignFields: [Column],
		onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
		onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
		name: String? = nil
	) -> Self {
		self.schema.createConstraints.append(.constraint(
			.foreignKey(
				fields.map { .key(FieldKey(stringLiteral: $0.key)) },
				foreignSchema,
				foreignFields.map { .key(FieldKey(stringLiteral: $0.key)) },
				onDelete: onDelete,
				onUpdate: onUpdate
			),
			name: name
		))
		return self
	}

	@discardableResult
	public func updateField(
		_ field: Column,
		_ dataType: DatabaseSchema.DataType
	) -> Self {
		self.updateField(.dataType(
			name: .key(FieldKey(stringLiteral: field.key)),
			dataType: dataType
		))
	}

	@discardableResult
	public func deleteField(
		_ field: Column
	) -> Self {
		self.deleteField(.key(FieldKey(stringLiteral: field.key)))
	}
}
