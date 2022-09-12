import {
	Table,
	Column,
	Model,
	CreatedAt,
	PrimaryKey,
	DataType,
	AutoIncrement,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { ADDRESS_TYPES, CurrencyCode, TAddressType } from '@sudonym/models';
import { BaseModel } from '../base.model';

@Table({
	scopes: Receiver.scopes,
})
export class Receiver extends BaseModel implements Models.Receiver {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Column(DataType.ENUM(...ADDRESS_TYPES))
	type: TAddressType;

	@Column
	potId: number;

	@Column
	data: string;

	@Column
	amount: number;

	@Column
	amountCurrency: CurrencyCode;

	@CreatedAt
	@Column
	createdAt: Date;
}
