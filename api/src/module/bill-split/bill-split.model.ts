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

	@AllowNull(false)
	@Column
	currency: CurrencyCode;

	@AllowNull(false)
	@Column(DataType.DOUBLE(21, 11))
	amount: number;

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
