import {
	Table,
	Column,
	Model,
	CreatedAt,
	PrimaryKey,
	DataType,
	AutoIncrement,
	Default,
	ForeignKey,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { ADDRESS_TYPES, CurrencyCode, TAddressType } from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Pot } from 'module/pot/pot.model';

@Table({
	scopes: Sender.scopes,
})
export class Sender extends BaseModel implements Models.Sender {

	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Column(DataType.ENUM(...ADDRESS_TYPES))
	type: TAddressType;

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@Column
	data: string;

	@Column(DataType.DOUBLE(18, 8))
	amount: number;

	@Default("BTC")
	@Column
	amountCurrency: CurrencyCode;

	@Column
	limitDay: number;
	@Column
	limitMonth: number;
	@Column
	limitYear: number;
	@Column
	limitMin: number;
	@Column
	limitMax: number;

	@CreatedAt
	@Column
	createdAt: Date;
}
