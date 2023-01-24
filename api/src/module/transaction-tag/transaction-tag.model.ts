import * as Models from '@sudonym/models';
import { Transaction } from 'module/transaction/transaction.model';
import {
	AllowNull,
	AutoIncrement,
	BelongsTo,
	Column,
	CreatedAt,
	ForeignKey,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';

@Table({
	scopes: TransactionTag.scopes,
	paranoid: true,
})
export class TransactionTag extends BaseModel implements Models.TransactionTag {
	@AutoIncrement
	@PrimaryKey
	@AllowNull(false)
	@Column
	id: number;

	@ForeignKey(() => Transaction)
	@AllowNull(false)
	@Column
	transactionId: number;

	@AllowNull(false)
	@Column
	tagId: number;

	@BelongsTo(() => Transaction)
	Transaction: Transaction;

	@CreatedAt
	@Column
	createdAt: Date;

	static scopes = {};
}
