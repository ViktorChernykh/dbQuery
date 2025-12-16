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
		_ column: Column,
		_ dataType: DatabaseSchema.DataType,
		_ constraints: DatabaseSchema.FieldConstraint...
	) -> Self {
		return self.field(.definition(
			name: .key(FieldKey(stringLiteral: column.field)),
			dataType: dataType,
			constraints: constraints
		))
	}

	@discardableResult
	public func unique(on columns: Column..., name: String? = nil) -> Self {
		self.constraint(.constraint(
			.unique(fields: columns.map { .key(FieldKey(stringLiteral: $0.field)) }),
			name: name
		))
	}

	@discardableResult
	public func compositeIdentifier(over columns: Column...) -> Self {
		self.constraint(.constraint(.compositeIdentifier(
			columns.map { .key(FieldKey(stringLiteral: $0.field)) }
		), name: ""))
	}

	@discardableResult
	public func deleteUnique(on columns: Column...) -> Self {
		self.schema.deleteConstraints.append(.constraint(
			.unique(fields: columns.map { .key(FieldKey(stringLiteral: $0.field)) })
		))
		return self
	}

	@discardableResult
	public func foreignKey(
		_ column: Column,
		references foreignSchema: String,
		_ foreignField: Column,
		onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
		onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
		name: String? = nil
	) -> Self {
		self.schema.createConstraints.append(.constraint(
			.foreignKey(
				[.key(FieldKey(stringLiteral: column.field))],
				foreignSchema,
				[.key(FieldKey(stringLiteral: foreignField.field))],
				onDelete: onDelete,
				onUpdate: onUpdate
			),
			name: name
		))
		return self
	}

	@discardableResult
	public func foreignKey(
		_ columns: [Column],
		references foreignSchema: String,
		_ foreignFields: [Column],
		onDelete: DatabaseSchema.ForeignKeyAction = .noAction,
		onUpdate: DatabaseSchema.ForeignKeyAction = .noAction,
		name: String? = nil
	) -> Self {
		self.schema.createConstraints.append(.constraint(
			.foreignKey(
				columns.map { .key(FieldKey(stringLiteral: $0.field)) },
				foreignSchema,
				foreignFields.map { .key(FieldKey(stringLiteral: $0.field)) },
				onDelete: onDelete,
				onUpdate: onUpdate
			),
			name: name
		))
		return self
	}

	@discardableResult
	public func updateField(
		_ column: Column,
		_ dataType: DatabaseSchema.DataType
	) -> Self {
		self.updateField(.dataType(
			name: .key(FieldKey(stringLiteral: column.field)),
			dataType: dataType
		))
	}

	@discardableResult
	public func deleteField(_ column: Column) -> Self {
		self.deleteField(.key(FieldKey(stringLiteral: column.field)))
	}
}
