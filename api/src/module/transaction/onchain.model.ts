import * as Models from '@sudonym/models';
import { BaseModel } from 'module/base.model';
import { Column, DataType, Table } from 'sequelize-typescript';

@Table
export class Onchain extends BaseModel implements Models.OnchainTransaction {
	@Column
	id: string;

	@Column(DataType.DOUBLE(21, 11))
	amount: number | null;

	@Column
	fromAddress: string;

	@Column
	toAddress: string;

	@Column
	blockHeight: number;
}
