import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';
import { BillSplitParticipant } from 'module/bill-split-participant/bill-split-participant.model';
import { Transaction } from 'module/transaction/transaction.model';
import {
	AllowNull,
	AutoIncrement,
	BelongsTo,
	Column,
	DataType,
	Default,
	ForeignKey,
	HasMany,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';

@Table({
	scopes: BillSplit.scopes,
	paranoid: true,
})
export class BillSplit extends BaseModel implements Models.BillSplit {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Column
	currency: CurrencyCode;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	spendableBalance: number;

	@ForeignKey(() => Transaction)
	transactionId: number;

	@BelongsTo(() => Transaction)
	Transaction: Transaction;

	@HasMany(() => BillSplitParticipant)
	BillSplitParticipants: BillSplitParticipant[];

	static accessors = {};

	static scopes = {
		find: () => ({
			include: [
				{
					model: BillSplitParticipant,
					as: 'BillSplitParticipants',
				},
			],
		}),
	};
}
