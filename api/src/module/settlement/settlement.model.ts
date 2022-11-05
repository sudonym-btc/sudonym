import * as Models from '@sudonym/models';
import { Column, DataType, PrimaryKey, Table } from 'sequelize-typescript';
import { BaseModel } from '../base.model';

@Table
export class Settlement extends BaseModel implements Models.Settlement {
	@PrimaryKey
	@Column
	id: number;

	@Column
	fromCurrency: string;

	@Column
	toCurrency: string;

	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@Column
	exchangeId: string;

	@Column
	status: boolean;

	@Column
	orderId: string;
}
