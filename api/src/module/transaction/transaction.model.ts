import {
	Table,
	Column,
	Model,
	HasMany,
	CreatedAt,
	PrimaryKey,
	Default,
	AutoIncrement,
	AllowNull,
	NotNull,
	DataType,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table({
	scopes: Transaction.scopes,
})
export class Transaction extends BaseModel implements Models.Transaction {
	@AutoIncrement
	@PrimaryKey
	@AllowNull(false)
	@Column
	id: number;

	@Column(DataType.STRING(1024))
	txid: string;

	@Column
	type: string;

	@Column
	description: string;

	@Column(DataType.STRING(1024))
	address: string;

	@Column(DataType.STRING(1024))
	originalAddress: string;

	@Default(null)
	@Column
	status: boolean;

	@Column
	transactionId: number;

	@Column
	potId: number;

	@AllowNull(false)
	@Column
	amount: number;

	@AllowNull(false)
	@Column
	outgoing: boolean;

	@AllowNull(false)
	@Default('BTC')
	@Column
	currencyCode: string;

	@CreatedAt
	@Column
	createdAt: Date;
}
