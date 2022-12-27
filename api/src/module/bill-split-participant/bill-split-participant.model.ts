import * as Models from '@sudonym/models';
import { BillSplit } from 'module/bill-split/bill-split.model';
import {
	AllowNull,
	AutoIncrement,
	BelongsTo,
	Column,
	DataType,
	Default,
	ForeignKey,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';

@Table({
	scopes: BillSplitParticipant.scopes,
	paranoid: true,
})
export class BillSplitParticipant
	extends BaseModel
	implements Models.BillSplitParticipant
{
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@BelongsTo(() => BillSplit)
	BillSplit: BillSplit;

	@ForeignKey(() => BillSplit)
	@Column
	billSplitId: number;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	amountPaid: number;

	@AllowNull(false)
	@Default(false)
	@Column
	paid: boolean;

	static scopes = {};
}
