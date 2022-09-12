import {
	Table,
	Column,
	Model,
	HasMany,
	PrimaryKey,
	AutoIncrement,
	BelongsTo,
	ForeignKey,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Transaction } from '../transaction/transaction.model';
import { Settlement } from '../settlement/settlement.model';

@Table
export class SettlementTransaction
	extends BaseModel
	implements Models.SettlementTransaction
{
	@ForeignKey(() => Transaction)
	@Column
	transactionId: number;

	@ForeignKey(() => Settlement)
	@Column
	settlementId: number;
}
