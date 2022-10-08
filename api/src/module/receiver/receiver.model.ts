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
import { LnUrl } from 'module/lightning/lnurl/lnurl.model';

@Table({
	scopes: Receiver.scopes,
})
export class Receiver extends BaseModel implements Models.Receiver {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@ForeignKey(() => Receiver)
	@Column
	parentId: number;

	@Column(DataType.ENUM(...ADDRESS_TYPES))
	type: TAddressType;

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@ForeignKey(() => LnUrl)
	@Column
	lnurlId: string;

	@Column(DataType.STRING(1024))
	data: string;

	@Column(DataType.DOUBLE(18, 8))
	amount: number;

	@Default('BTC')
	@Column
	amountCurrency: CurrencyCode;

	@Default(0)
	@Column
	received: number;

	@CreatedAt
	@Column
	createdAt: Date;
}
