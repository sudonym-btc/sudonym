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
	BeforeCreate,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { ADDRESS_TYPES, CurrencyCode, TAddressType } from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Pot } from 'module/pot/pot.model';
import { LnUrl } from 'module/lightning/lnurl/lnurl.model';
import { User } from 'module/user/user.model';
import { requestContextCls } from 'helper/context-request';

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

	@ForeignKey(() => User)
	@Column
	userId: string;

	@BeforeCreate
	static populateUserId(params) {
		params.userId = requestContextCls.get('request')?.auth?.uid;
	}

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@ForeignKey(() => LnUrl)
	@Column
	lnurlId: string;

	@Column
	data: string;

	@Column(DataType.DOUBLE(18, 8))
	amount: number;

	@Default('BTC')
	@Column
	amountCurrency: CurrencyCode;

	@Column(DataType.DOUBLE(18, 8))
	limitDay: number;
	@Column(DataType.DOUBLE(18, 8))
	limitMonth: number;
	@Column(DataType.DOUBLE(18, 8))
	limitYear: number;
	@Column(DataType.DOUBLE(18, 8))
	limitMin: number;
	@Column(DataType.DOUBLE(18, 8))
	limitMax: number;

	@CreatedAt
	@Column
	createdAt: Date;
}
