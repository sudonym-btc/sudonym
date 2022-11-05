import * as Models from '@sudonym/models';
import { ADDRESS_TYPES, CurrencyCode, TAddressType } from '@sudonym/models';
import { context } from 'helper/context-request';
import { BoltCard } from 'module/bolt-card/bolt-card.model';
import { Pot } from 'module/pot/pot.model';
import {
	AutoIncrement,
	BeforeCreate,
	BelongsTo,
	Column,
	CreatedAt,
	DataType,
	Default,
	ForeignKey,
	HasOne,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { LnUrl } from '../lightning/lnurl/lnurl.model';
import { User } from '../user/user.model';

@Table({
	scopes: Sender.scopes,
	defaultScope: Sender.scopes.default(),
})
export class Sender extends BaseModel implements Models.Sender {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Column(DataType.ENUM(...ADDRESS_TYPES))
	type: TAddressType;

	@BelongsTo(() => User)
	User: User;

	@ForeignKey(() => User)
	@Column
	userId: string;

	@BeforeCreate
	static populateUserId(params) {
		params.userId = context.get('request')?.auth?.uid;
	}

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@BelongsTo(() => LnUrl)
	lnurl: LnUrl;

	@ForeignKey(() => LnUrl)
	@Column
	lnurlId: string;

	@Column
	data: string;

	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@Default('BTC')
	@Column
	amountCurrency: CurrencyCode;

	@Column(DataType.DOUBLE(21, 11))
	limitDay: number;
	@Column(DataType.DOUBLE(21, 11))
	limitMonth: number;
	@Column(DataType.DOUBLE(21, 11))
	limitYear: number;
	@Column(DataType.DOUBLE(21, 11))
	limitMin: number;
	@Column(DataType.DOUBLE(21, 11))
	limitMax: number;

	@HasOne(() => BoltCard)
	BoltCard: BoltCard;

	@CreatedAt
	@Column
	createdAt: Date;

	static scopes = {
		default: () => ({
			include: [
				{
					model: LnUrl,
					as: 'lnurl',
				},
			],
		}),
	};
}
