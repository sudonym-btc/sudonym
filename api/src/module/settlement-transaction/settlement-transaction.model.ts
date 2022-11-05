import * as Models from '@sudonym/models';
import { Column, ForeignKey, Table } from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { Settlement } from '../settlement/settlement.model';
import { Transaction } from '../transaction/transaction.model';

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
